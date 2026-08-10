-- 右 Command 驱动原生应用切换器：
-- 右 Command：打开／确认；H：向左；L：向右；Esc：取消。
-- 右 Command 会被本配置独占，不再能作为普通的 Command 修饰键使用。

local eventtap = hs.eventtap
local types = eventtap.event.types
local right_command_keycode = 54
local left_command_keycode = 55
local switching = false

local function post_key(key, is_down, modifiers)
  eventtap.event.newKeyEvent(modifiers or {}, key, is_down):post()
end

local function release_command()
  if switching then
    eventtap.event.newKeyEvent(left_command_keycode, false):post()
    switching = false
  end
end

local function select_next_application()
  -- 让 macOS 先处理虚拟 Command 的按下，再收到 Command-Tab。
  -- 同一轮事件循环立即发送时，部分应用会把 Tab 当作控件焦点切换。
  hs.timer.doAfter(0.01, function()
    if switching then
      post_key("tab", true, { "cmd" })
      post_key("tab", false, { "cmd" })
    end
  end)
end

local function move_selection(key, modifiers)
  post_key(key, true, modifiers)
  post_key(key, false, modifiers)
end

-- 必须保存引用；否则 Hammerspoon 会在配置加载后回收 event tap。
right_command_switcher = eventtap.new({ types.flagsChanged, types.keyDown }, function(event)
  local event_type = event:getType()
  local keycode = event:getKeyCode()

  -- 修饰键以 flagsChanged 事件报告。只处理右 Command 的按下，忽略其松开。
  if event_type == types.flagsChanged and keycode == right_command_keycode then
    local right_command_down =
      (event:rawFlags() & eventtap.event.rawFlagMasks.deviceRightCommand) ~= 0

    if right_command_down then
      if not switching then
        -- 保持一个虚拟左 Command 为按下状态，使原生切换器持续显示。
        eventtap.event.newKeyEvent(left_command_keycode, true):post()
        switching = true
        select_next_application()
      else
        -- 松开虚拟 Command，确认当前选中的应用并关闭切换器。
        release_command()
      end
    end
    return true
  end

  if switching and event_type == types.keyDown then
    if keycode == hs.keycodes.map.h then
      move_selection("tab", { "cmd", "shift" })
      return true
    end
    if keycode == hs.keycodes.map.l then
      move_selection("tab", { "cmd" })
      return true
    end
    if keycode == hs.keycodes.map.escape then
      -- 先让原生切换器收到 Esc，再松开虚拟 Command，避免选中当前项目。
      post_key("escape", true, { "cmd" })
      post_key("escape", false, { "cmd" })
      release_command()
      return true
    end
  end

  return false
end):start()
