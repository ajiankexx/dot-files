local wezterm = require('wezterm')
local act = wezterm.action
-- check if a command exists
local function command_exists(cmd)
    local handle = io.popen('command -v ' .. cmd .. " >/dev/null 2>&1 && echo 'yes' || echo 'no'")
    local result = handle:read('*a')
    handle:close()
    return result:find('yes') ~= nil
end

-- Check if WSL is available
local function is_wsl_available()
    local handle = io.popen('wsl.exe -l')
    local result = handle:read('*a')
    handle:close()
    return result ~= nil and result ~= ''
end

-- Get the default program based on the operating system
local function default_program()
    local default_prog = nil
    local target = wezterm.target_triple
    if target:find('windows') then
        if is_wsl_available() then
            default_prog = { 'wsl.exe' }
        else
            default_prog = { 'powershell.exe' }
        end
    else
        if command_exists('fish') then
            default_prog = { 'fish' }
        elseif command_exists('zsh') then
            default_prog = { 'zsh' }
        else
            default_prog = { 'bash' }
        end
    end
    return default_prog
end

local function tab_title(tab)
    local title = tab.tab_title
    if title and #title > 0 then
        return title
    end
    return tab.active_pane.title
end

local process_icons = {
    ['bash'] = '',
    ['docker'] = '',
    ['fish'] = '󰈺',
    ['git'] = '',
    ['lazygit'] = '',
    ['lua'] = '',
    ['node'] = '󰎙',
    ['nvim'] = '',
    ['python'] = '',
    ['ssh'] = '󰣀',
    ['vim'] = '',
    ['zsh'] = '',
}

local function basename(path)
    return path and path:gsub('^.*[/\\]', '') or ''
end

local function process_icon(pane)
    return process_icons[basename(pane.foreground_process_name)] or ''
end

local function working_directory(pane)
    local cwd = pane:get_current_working_dir()
    return cwd and cwd.file_path or nil
end

local function git_branch(cwd)
    if not cwd then
        return nil
    end
    local ok, stdout = wezterm.run_child_process({ 'git', '-C', cwd, 'branch', '--show-current' })
    local branch = stdout:gsub('%s+$', '')
    return ok and #branch > 0 and branch or nil
end

local function status_pill(elements, icon, text, bg, fg)
    table.insert(elements, { Background = { Color = '#1e1e2e' } })
    table.insert(elements, { Foreground = { Color = bg } })
    table.insert(elements, { Text = '' })
    table.insert(elements, { Background = { Color = bg } })
    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Text = string.format(' %s %s ', icon, text) })
    table.insert(elements, { Background = { Color = '#1e1e2e' } })
    table.insert(elements, { Foreground = { Color = bg } })
    table.insert(elements, { Text = ' ' })
end

-- Render each tab as a rounded "pill".  The Nerd Font already configured below
-- supplies the Powerline edge glyphs used here.
wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
    local title = wezterm.truncate_right(tab_title(tab), max_width - 5)
    local pill_bg = tab.is_active and '#89b4fa' or (hover and '#585b70' or '#313244')
    local pill_fg = tab.is_active and '#1e1e2e' or '#cdd6f4'
    local bar_bg = '#1e1e2e'

    return {
        { Background = { Color = bar_bg } },
        { Foreground = { Color = pill_bg } },
        { Text = '' },
        { Background = { Color = pill_bg } },
        { Foreground = { Color = pill_fg } },
        { Text = string.format(' %d  %s  %s ', tab.tab_index + 1, process_icon(tab.active_pane), title) },
        { Background = { Color = bar_bg } },
        { Foreground = { Color = pill_bg } },
        { Text = '' },
        { Text = ' ' },
    }
end)

wezterm.on('update-status', function(window, pane)
    local elements = {}
    local cwd = working_directory(pane)
    if cwd then
        local home = os.getenv('HOME')
        if home and cwd:sub(1, #home) == home then
            cwd = '~' .. cwd:sub(#home + 1)
        end
        status_pill(elements, '', wezterm.truncate_left(cwd, 36), '#45475a', '#cdd6f4')
    end

    local branch = git_branch(working_directory(pane))
    if branch then
        status_pill(elements, '', wezterm.truncate_right(branch, 24), '#a6e3a1', '#1e1e2e')
    end

    window:set_right_status(wezterm.format(elements))
end)

return {
    initial_rows = 50,
    initial_cols = 120,
    automatically_reload_config = true,
    notification_handling = 'AlwaysShow',
    color_scheme = 'Catppuccin Mocha',
    use_fancy_tab_bar = false,
    tab_bar_at_bottom = false,
    tab_max_width = 32,
    status_update_interval = 5000,
    show_new_tab_button_in_tab_bar = true,
    colors = {
        tab_bar = {
            background = '#1e1e2e',
            new_tab = { bg_color = '#45475a', fg_color = '#cdd6f4' },
            new_tab_hover = { bg_color = '#89b4fa', fg_color = '#1e1e2e' },
        },
    },
    -- default_prog = default_program(),
    default_prog = {'zsh'},
    -- disable_default_key_bindings = true,
    -- enable_tab_bar = false,
    font = wezterm.font_with_fallback({
        'FiraCode Nerd Font',
        'JetBrainsMono Nerd Font',
        'CaskaydiaMono Nerd Font',
        'JetBrains Mono',
        -- macOS Chinese fallback fonts.  Keep these after the monospace fonts so
        -- ASCII, Nerd Font glyphs, and box-drawing characters retain their width.
        'Hiragino Sans GB',
        'Heiti SC',
    }),
    font_size = 14,
    keys = {
        { key = 'z', mods = 'CTRL|ALT', action = 'Nop' },
        { key = '=', mods = 'CTRL|SUPER', action = act.IncreaseFontSize },
        { key = '-', mods = 'CTRL|SUPER', action = act.DecreaseFontSize },
        { key = '0', mods = 'CTRL|SUPER', action = act.ResetFontSize },
        { key = 'v', mods = 'SUPER', action = act.PasteFrom('Clipboard') },
        { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom("Clipboard") },
    },
    mouse_bindings = {
        {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = 'CTRL',
            action = act.IncreaseFontSize,
        },
        {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = 'CTRL',
            action = act.DecreaseFontSize,
        },
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'NONE',
            action = act.CompleteSelection('ClipboardAndPrimarySelection'),
        },
        {
            event = { Down = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = act.OpenLinkAtMouseCursor,
        },
        {
            event = { Down = { streak = 1, button = 'Right' } },
            mods = 'NONE',
            action = act.PasteFrom('Clipboard'),
        },
    },
    window_close_confirmation = 'NeverPrompt',
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
}
