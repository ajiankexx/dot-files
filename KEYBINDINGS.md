# 键位配置说明

本文记录仓库中显式配置的键位。未列出应用自身的默认快捷键；需要查看 Neovim 当前实际生效的完整映射时，可在 Neovim 中运行 `:map`、`:imap`，或按 `<Space>spk` 打开键位选择器。

记号：`C` 为 Ctrl，`M` / `A` 为 Alt（Option），`S` 为 Shift，`Super` 为 Command；`<Space>` 是空格。Neovim 的 `n`、`i`、`x`、`o` 分别代表普通、插入、可视和 operator-pending 模式。

## 生效层级

键盘事件依次可能经过系统级重映射、终端、Shell 与应用本身。macOS 使用 Karabiner 与 Hammerspoon；Linux 使用 keyd。两套系统级配置不会同时生效。WezTerm 的配置会优先处理其已定义的快捷键，其余按键再传给 zsh 或 Neovim。

## macOS：Karabiner 与 Hammerspoon

来源：[Karabiner 配置](/.config/karabiner/karabiner.json) 与 [Hammerspoon 配置](/home/.hammerspoon/init.lua)。

| 按键 | 作用 |
| --- | --- |
| 单独按左 Option | 发送 `⌘Space`，通常用于切换输入法；与其他键组合时仍是 Option。 |
| 单独按左 Shift（150 ms 内松开） | 发送 `⌃Space`。 |
| `Ctrl+C` / `Ctrl+V` | 重映射为 `⌘C` / `⌘V`，用于复制、粘贴。 |
| Fn | 重映射为左 Ctrl。 |
| Caps Lock | 重映射为 Escape。 |
| Escape | 重映射为 Caps Lock。 |
| 右 Command | 打开 macOS 原生应用切换器，并前进到下一项；再次按下时确认选择。右 Command 不再作为普通 Command 修饰键。 |
| 右 Command 后按 `H` / `L` | 在应用切换器中向前 / 向后选择应用。 |
| 右 Command 后按 Escape | 取消应用切换。 |

## Linux：keyd

来源：[keyd 全局配置](/.config/keyd/config) 与 [WezTerm 专用覆盖](/.config/keyd/app.conf)。

| 按键 | 作用 |
| --- | --- |
| Caps Lock 按住 | 作为 Ctrl。 |
| 单独按 Caps Lock | 发送 `Alt+Space`。 |
| Caps Lock 按住后 `N` | 发送 Escape。 |
| Alt 按住 | 保持 Alt。 |
| 单独按 Alt | 发送 `Ctrl+B`。 |
| Alt 层的 `Z/X/C/V/A/R/F//` | 分别发送 `Ctrl+Z`、`Ctrl+X`、`Ctrl+Insert`、`Shift+Insert`、`Ctrl+A`、`Ctrl+R`、`Ctrl+F`、`Ctrl+/`。 |
| WezTerm 中 `Alt+Z/X/C/A/R/F//` | 透传为 `Alt+Z/X/C/A/R/F//`，避免被上述 Alt 层改写。 |

## WezTerm

来源：[WezTerm 配置](/.config/wezterm/wezterm.lua)。

| 按键 | 作用 |
| --- | --- |
| `Super+H` / `Super+L` | 激活前一个 / 后一个标签页。 |
| `Super+←` / `Super+→` | 将当前标签页向左 / 向右移动。 |
| `Ctrl+Super+=` / `Ctrl+Super+-` / `Ctrl+Super+0` | 放大 / 缩小 / 重置字体大小。 |
| `Super+V`、`Shift+Insert` | 从系统剪贴板粘贴。 |
| `Ctrl+Alt+Z` | 禁用，不向终端程序发送。 |
| `Ctrl+滚轮上/下` | 放大 / 缩小字体。 |
| 鼠标左键选中后松开 | 复制所选内容到 Clipboard 和 Primary Selection。 |
| `Ctrl+左键` | 打开鼠标下的链接。 |
| 鼠标右键 | 从 Clipboard 粘贴。 |

## Zsh、fzf 与命令行

来源：[Zsh 键位](/.config/zsh/60-keybindings.zsh)、[自动建议与 fzf](/.config/zsh/90-plugins.zsh)。Zsh 使用 vi 编辑模式；以下为显式覆盖或由 fzf 键位脚本提供的快捷键。

### 常用命令

| 命令 | 作用 |
| --- | --- |
| `croot` | 跳转到当前 Git 仓库的根目录。在仓库外执行时会提示未处于 Git 仓库中。 |

`croot` 定义在 [Zsh 工具配置](/.config/zsh/40-tools.zsh)。

| 按键 | 适用位置 | 作用 |
| --- | --- | --- |
| `↑` | 命令行 | 以当前输入为前缀向后搜索历史命令，并将匹配项回填到命令行末尾。 |
| `↓` | 命令行 | 在前缀匹配的历史命令中向前移动。 |
| `Ctrl+R` | vi 插入 / 普通模式 | 打开 fzf 历史搜索；已输入的文字会成为初始查询。回车只回填选中的命令，随后再按回车才执行。在选择器内再按 `Ctrl+R` 切换排序，按 `Alt+R` 切换原始显示。 |
| `Ctrl+T` | 命令行 | 打开 fzf 文件选择器，将选中的文件或目录路径插入命令行。可用 `Tab` 多选，因此可一次将多个路径传给 `vim`、`cat` 等命令。 |
| `Alt+C` | 命令行 | 打开 fzf 目录选择器，选择目录后切换过去。 |
| `Ctrl+F` | 命令行 | 接受灰色的 zsh-autosuggestions 自动建议。 |
| `Ctrl+←` / `Ctrl+→` | 命令行 | 按词向后 / 向前移动光标。 |
| Backspace、`Ctrl+H` | 命令行 | 删除前一个字符。 |
| `Ctrl+K` | vi 插入 / 普通模式 | 从光标删除到行尾。 |
| `Ctrl+U` | vi 插入 / 普通模式 | 从光标删除到行首。 |

## Neovim

来源：[核心映射](/.config/nvim/lua/key_mapping.lua)。`<leader>` 配置为 `<Space>`，因此下文的 `<leader>f` 实际按法是 `Space` 后按 `f`。

### 通用编辑、窗口与剪贴板

| 按键 | 模式 | 作用 |
| --- | --- | --- |
| `<leader>y` / `<leader>Y` / `<leader>ay` | n、x / n / n、x | 复制选区、复制至行尾、复制整个缓冲区到系统剪贴板。 |
| `Y`、`yaf` | n | 复制至行尾；复制整个缓冲区到系统剪贴板。 |
| `Ctrl+Insert`、`Alt+C`、`Alt+X` | x | 复制、复制、剪切到系统剪贴板。 |
| `Alt+V`、`Shift+Insert`、`Ctrl+右键` | n、x / i / n、i | 从系统剪贴板粘贴；图片文件类型支持时会尝试插入图片。 |
| `<leader>p` / `<leader>P` | n、x | 在光标后 / 前粘贴；图片文件类型支持时会插入图片。 |
| `Alt+A` | n、x、i | 全选当前缓冲区。 |
| `<leader>sc` | n | 开关拼写检查。 |
| `<leader>I` | n | 开关 LSP inlay hints。 |
| `<leader>h/l/j/k` | n | 在左 / 右 / 下 / 上新建分割窗口。 |
| `Ctrl+H/J/K/L` | n | 在左 / 下 / 上 / 右窗口间移动。 |
| `=` | n | 使所有窗口等宽高。 |
| `<leader>T` | n | 将当前窗口移到新的标签页。 |
| `<leader>t2/t4/t8` | n | 将当前缓冲区缩进宽度设为 2 / 4 / 8。 |
| `<leader>tt` | n | 开关 `expandtab`。 |
| `Ctrl+U`、`Ctrl+K` | i | 从光标删至首个非空白处 / 删至行尾。 |
| `Ctrl+W`、`Alt+D` | i、命令行 | 向后删除一个词 / 向前删除一个词。 |
| `Ctrl+A`、`Ctrl+E` | i、命令行 | 移到首个非空白处 / 行尾。 |
| `Ctrl+L` | i | 向右移动一个字符。 |

### 查找、文件、缓冲区与终端

来源：[Snacks 配置](/.config/nvim/lua/plugins/snacks_config.lua)、[Bufferline 配置](/.config/nvim/lua/plugins/buffer_line.lua)、[终端配置](/.config/nvim/lua/plugins/terminal.lua)。

| 按键 | 模式 | 作用 |
| --- | --- | --- |
| `Ctrl+P` / `Ctrl+F` | n | 文件选择 / 当前工作目录实时文本搜索。 |
| `Ctrl+Y` | n | 恢复最近的 Snacks 选择器。 |
| `<leader><leader>` | n | 在当前缓冲区内模糊查找行。 |
| `<leader>sp` | n | 选择图片文件并插入。 |
| `<leader>spd/spm/spk/spb/sph` | n | 打开诊断、man、键位、缓冲区、帮助选择器。 |
| `<leader>s/ / sc / sj / sd / sD / sw / sm / sM / su / sl / sq` | n（`sw` 也支持 x） | 打开搜索历史、命令历史、跳转列表、当前缓冲区诊断、全局诊断、光标词/选区搜索、标记、man、撤销历史、location list、quickfix list。 |
| `<leader>gb` | n、x | 在浏览器打开当前 Git 目标。 |
| `<leader>uc/ud/ut` | n | 开关 conceal、诊断、Treesitter。 |
| `<leader>1` 至 `<leader>0` | n | 跳转到第 1 至第 10 个缓冲区。 |
| `H` / `L` / `gb` / `Q` | n | 前一缓冲区 / 后一缓冲区 / 从列表选缓冲区 / 不保存关闭当前缓冲区。 |
| `Ctrl+T` | n、i、终端 | 显示或隐藏浮动终端。 |
| `Ctrl+G` | n、i、终端 | 显示或隐藏 lazygit。 |
| `<leader>r` | n | 编译并运行当前支持的文件；Markdown 缓冲区会打开预览。 |

Snacks 选择器打开后：`Ctrl+J/K` 移动结果，`Ctrl+U/D` 滚动预览，`Tab/Shift+Tab` 多选并前后移动，`Ctrl+S/V` 水平/垂直分屏打开，`Alt+P` 开关预览，`Alt+F/I/D` 开关跟随链接、忽略文件、隐藏文件，`Ctrl+Q` 送入 quickfix，`?` 或 `F1` 查看完整帮助。

### LSP、Git、调试与格式化

来源：[LSP Saga](/.config/nvim/lua/plugins/lsp_saga.lua)、[LSP 配置](/.config/nvim/lua/plugins/lsp_config.lua)、[GitSigns 配置](/.config/nvim/lua/plugins/git_signs.lua)、[冲突处理配置](/.config/nvim/lua/plugins/git_conflict.lua)、[调试器配置](/.config/nvim/lua/plugins/debugger.lua)、[格式化配置](/.config/nvim/lua/plugins/formatter.lua)。

| 按键 | 模式 | 作用 |
| --- | --- | --- |
| `gd` / `gD` / `gt` / `gi` / `gr` | n | 定义 / 声明 / 类型定义 / 实现 / 引用。 |
| `ga` | n、x | 代码操作。 |
| `<leader>d/i/o` | n | 预览定义 / 调入层级 / 调出层级。 |
| `[d` / `]d` | n | 上一处 / 下一处诊断。 |
| `[g` / `]g` | n、x、o | 上一处 / 下一处 Git hunk。 |
| `gcu/gcd/gcs` | n | 还原当前 hunk / 预览 hunk 差异 / 显示当前行完整 blame。 |
| `[x` / `]x` | n | 上一处 / 下一处合并冲突。 |
| `gcc/gci/gcb/gcn` | n | 冲突时保留当前 / 对方 / 双方 / 都不保留。 |
| `<leader>f` | n、x | 格式化缓冲区或选区。 |
| `<leader>D/b/B` | n | 开关调试界面 / 开关断点 / 设置条件断点。 |
| `<leader>dt/dr/df/de` | n | 调试光标下测试 / 打开 REPL / 浮动调试元素 / 求值表达式。 |
| `F4/F5/F6/F9/F10/F11/F12` | n | 终止 / 继续 / 重启 / 单步后退 / 越过 / 进入 / 跳出调试。 |

### 结构导航与文本对象

来源：[Treesitter 文本对象](/.config/nvim/lua/plugins/tree_sitter.lua)、[非 ASCII 词移动](/.config/nvim/lua/plugins/non_ascii.lua)、[搜索跳转](/.config/nvim/lua/plugins/search.lua)。

| 按键模式 | 作用 |
| --- | --- |
| `af/if`、`ac/ic`、`al/il`、`ab/ib`、`ar/ir`、`ap/ip`、`ai/ii`（x、o） | 选择函数、类、循环、代码块、return、参数、条件分支的外侧 / 内侧。 |
| `]f/[f`、`]c/[c`、`]l/[l`、`]b/[b`、`]r/[r`、`]p/[p`、`]i/[i`（n） | 前往下一个 / 上一个函数、类、循环、块、return、参数、条件分支的起始处；对应大写末位键前往结束处。 |
| `sn{f,c,l,b,r,p,i}` / `sp{f,c,l,b,r,p,i}`（n） | 与下一个 / 上一个对应结构交换位置。 |
| `w/b/e/ge`、`iw/aw` | 对中文等非 ASCII 文本按词移动，或选择词内 / 词及周围。 |
| `n/N`、`;` / `,` | 下一个 / 上一个搜索匹配；重复上一次支持重复的结构跳转及其反向。 |
| `]s/[s`、`]t/[t`、`]w/[w` | 下一处 / 上一处拼写错误、TODO 注释、当前词引用。 |
| `f/t/F/T` 后输入字符 | Flash 在当前行跳转；`;` / `,` 继续 / 反向继续。 |
| `*/#`、`gn` | 用 Flash 向前 / 向后搜索光标词；按语法结构跳转。 |

### 文件类型专用

| 场景 | 按键 | 作用 |
| --- | --- | --- |
| Go 文件 | `<leader>Gr/Gb/Gt/Gf/GT/Gc/Gx/Ga/Gi/Gs/Ge/Gj/Gd/Gm/Gv` | 运行、构建、测试、覆盖率、调试、切换文件、实现接口、填充结构体、添加 JSON tag、文档、`go mod tidy`、漏洞检查。 |
| Markdown 插入模式 | `,1` 至 `,4` | 插入 1 至 4 级标题。 |
| Markdown 插入模式 | `,a/b/c/t/m` | 插入链接、粗体、代码块、行内代码、数学公式占位模板。 |
| Markdown | `,f` | 跳到下一个 `<++>` 占位符。 |
| Markdown | `gx` | 切换当前行或选中行的任务复选框。 |
| Markdown | `o` | 在行尾新建一行。 |
| Markdown 插入模式 | Enter、Backspace、Tab | 续写 / 退出列表项、处理列表缩进。 |
| Rime LSP 已附加 | `Ctrl+Space` | 开关 Rime 输入法与中文标点映射。 |

## 未设置自定义键位的应用

[Fish 配置](/.config/fish/config.fish) 只有交互式会话占位注释；[tmux 配置目录](/.config/tmux) 只有环境继承脚本，未定义 tmux 前缀或按键绑定。因此这两者继续使用各自默认键位。

## 已知冲突与优先级

- `<leader>R` 同时用于 Snacks 的“编译运行 / Markdown 渲染”与 LSP Saga 的“重命名”。LSP 附加后通常会由后加载的 LSP 映射覆盖；当前文件类型和插件加载顺序会影响最终结果。
- `<leader>r` 同时存在终端运行命令与 Markdown 预览的缓冲区局部映射；在 Markdown 中以预览映射为准。
- `Ctrl+G` 在 Snacks 与 toggleterm 中都定义为 lazygit；两者意图相同。
- `Ctrl+P`、`Ctrl+F` 在 Neovim 普通模式由 Snacks 使用，在 zsh 命令行则分别是 fzf 文件选择与接受自动建议，二者不会互相冲突。
