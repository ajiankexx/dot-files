# Neovim 最重要的 8 个插件

本文从当前配置实际启用的插件中，按“是否构成编辑器核心能力、日常使用频率、
被其他插件依赖的程度”选出 8 个。这里的“用法”优先记录本仓库的真实配置，
而不是插件的通用默认键位。

> 本配置的 `<leader>` 是空格键。因此 `<leader>f` 表示先按空格，再按 `f`。

## 1. lazy.nvim：插件管理器

### 作用

lazy.nvim 是整套插件配置的入口，负责安装、加载、更新和锁定其他插件版本。
Neovim 启动时会先检查本地是否存在 lazy.nvim；如果没有，就从 GitHub 克隆稳定版，
随后读取 `plugins` 模块中的插件清单。配置入口见
[package_manager.lua](/.config/nvim/lua/package_manager.lua#L1-L13)和
[init.lua](/.config/nvim/init.lua#L5-L21)。

### 用法

- `:Lazy`：打开插件管理界面。
- 在界面中按 `I` 安装缺失插件，按 `U` 更新插件，按 `S` 同步当前配置，按 `X` 清理不再使用的插件。
- `:Lazy sync`：直接同步插件状态，适合修改插件配置后使用。
- `:Lazy profile`：查看插件加载耗时，排查启动变慢的问题。
- `:Lazy log`：查看插件版本变更记录。

插件版本被记录在 [lazy-lock.json](/.config/nvim/lazy-lock.json)，因此在另一台机器上
安装时可以复现相同版本。日常不要手工修改这个文件，应让 lazy.nvim 自动维护。

## 2. mason.nvim：开发工具安装器

### 作用

Mason 在 Neovim 内统一安装和管理 LSP 服务端、格式化器、Linter 和调试适配器。
它解决的是“工具如何下载安装到本机”，不是“如何启用 LSP”。本配置会在有图形界面的
Neovim 启动后刷新 Mason 注册表，并自动补装清单中缺失的工具；无界面的检查不会触发安装。
具体清单见 [mason.lua](/.config/nvim/lua/plugins/mason.lua#L1-L48)。

当前自动管理的工具包括 `clangd`、`pyright`、`lua-language-server`、
`typescript-language-server`、`vue-language-server`、`gopls`、`prettier`、
`stylua`、`clang-format`、`google-java-format` 等。

### 用法

- `:Mason`：打开工具管理界面。
- 在 Mason 界面中按 `/` 搜索工具，按 `i` 安装，按 `u` 更新，按 `X` 卸载。
- `:MasonInstall <工具名>`：安装指定工具，例如 `:MasonInstall pyright`。
- `:MasonUpdate`：刷新可安装工具的注册表。
- `:MasonLog`：工具安装失败时查看日志。

如果某种语言没有智能提示，先用 `:Mason` 确认对应服务端是否已安装，再用
`:LspInfo` 检查它是否已连接当前缓冲区。

## 3. nvim-treesitter：语法树解析

### 作用

Tree-sitter 把代码解析成语法树，让 Neovim 理解“函数、类、参数、条件块”等结构，
从而提供更准确的高亮、折叠、结构化选择和跳转。本配置对所有文件类型尝试启动
Tree-sitter，并使用语法树计算折叠；同时启用了 textobjects、context 和 matchup。
配置见 [tree_sitter.lua](/.config/nvim/lua/plugins/tree_sitter.lua#L81-L183)。

### 用法

结构化选择可在可视模式或操作符等待模式下使用：

- `af` / `if`：选择整个函数 / 函数内部。
- `ac` / `ic`：选择整个类 / 类内部。
- `ap` / `ip`：选择整个参数 / 参数内部。
- `ai` / `ii`：选择整个条件语句 / 条件语句内部。
- `al` / `il`：选择整个循环 / 循环内部。

这些文本对象也能和操作符组合。例如 `daf` 删除整个函数，`yif` 复制函数体，
`ciac` 修改整个类。完整选择映射见
[tree_sitter.lua](/.config/nvim/lua/plugins/tree_sitter.lua#L3-L18)。

结构化移动和交换：

- `]f` / `[f`：下一个 / 上一个函数开头。
- `]F` / `[F`：下一个 / 上一个函数结尾。
- `]c` / `[c`：下一个 / 上一个类开头。
- `snp` / `spp`：把当前参数和下一个 / 上一个参数交换。
- `;` / `,`：重复上一次结构化移动 / 反向重复。

对应配置见 [tree_sitter.lua](/.config/nvim/lua/plugins/tree_sitter.lua#L20-L78)和
[tree_sitter.lua](/.config/nvim/lua/plugins/tree_sitter.lua#L99-L160)。

常用命令还有 `:TSInstall <语言>`、`:TSUpdate` 和 `:InspectTree`，分别用于安装解析器、
更新解析器和查看当前文件的语法树。

## 4. nvim-lspconfig：语言智能核心

### 作用

nvim-lspconfig 把 Neovim 内置 LSP 客户端连接到各语言服务端，提供定义跳转、引用查找、
重命名、代码操作、诊断和补全数据。本配置显式启用了 Bash、C/C++、JavaScript、
TypeScript、Vue、Lua、Python、Go、Rust、JSON、YAML、Markdown 等服务端，详见
[lsp_config.lua](/.config/nvim/lua/plugins/lsp_config.lua#L13-L41)。Mason 负责安装其中多数服务端，
nvim-lspconfig 则负责启动并连接它们；两者分工不同。

### 用法

当前配置使用 Lspsaga 展示大部分 LSP 结果，但底层能力来自 nvim-lspconfig：

- `gd`：跳到定义。
- `gt`：跳到类型定义。
- `gi`：查找实现。
- `gr`：查找引用。
- `<leader>d`：浮窗预览定义。
- `<leader>i` / `<leader>o`：查看传入 / 传出调用。
- `<leader>R`：重命名符号并自动保存相关修改。
- `ga`：显示可用的代码操作；可视模式下会作用于选中范围。
- `]d` / `[d`：跳到下一条 / 上一条诊断。
- `<leader>I`：开关 LSP 内联提示。

Lspsaga 的键位见 [lsp_saga.lua](/.config/nvim/lua/plugins/lsp_saga.lua#L56-L86)，代码操作见
[lsp_config.lua](/.config/nvim/lua/plugins/lsp_config.lua#L35-L41)，内联提示见
[key_mapping.lua](/.config/nvim/lua/key_mapping.lua#L110-L117)。排错时可使用 `:LspInfo`，
确认当前缓冲区连接了哪些服务端。

## 5. blink.cmp：自动补全引擎

### 作用

blink.cmp 汇总 LSP、代码片段和文件路径等来源，生成插入模式与命令行补全菜单。
在 Markdown、文本、注释和字符串中，本配置还会增加当前缓冲区、ripgrep 和英文词典来源；
在 Git 提交或 Octo 缓冲区中可增加 GitHub/GitLab 项目来源。来源选择见
[blink_cmp.lua](/.config/nvim/lua/plugins/blink_cmp.lua#L238-L264)。

### 用法

- `<C-j>` / `<C-k>`：选择下一项 / 上一项。
- `<CR>`：接受当前补全项。
- `<C-c>`：关闭补全菜单。
- `<C-u>` / `<C-d>`：向上 / 向下滚动补全文档。
- `<C-s>`：显示或隐藏函数签名。
- `<C-x>`：只显示代码片段候选。
- `<Tab>` / `<S-Tab>`：在代码片段占位符之间向前 / 向后跳转。

键位定义见 [blink_cmp.lua](/.config/nvim/lua/plugins/blink_cmp.lua#L15-L47)。菜单不会预选第一项，
但候选被选中后会临时写入缓冲区；按回车才正式接受。补全文档会自动显示，配置见
[blink_cmp.lua](/.config/nvim/lua/plugins/blink_cmp.lua#L157-L229)。

## 6. snacks.nvim：搜索、选择器与实用工具集合

### 作用

Snacks 在这套配置中承担了原本常由 Telescope 等多个插件完成的工作：文件查找、全文搜索、
缓冲区内容搜索、诊断列表、历史记录、Lazygit、终端运行和 Git 网页跳转。它是日常定位文件
和代码最频繁使用的入口。

### 用法

最重要的两个键位：

- `<C-p>`：查找当前工作目录中的文件。
- `<C-f>`：使用 ripgrep 全文搜索。
- `<C-y>`：恢复上一次选择器。
- `<leader><leader>`：模糊搜索当前缓冲区的行。
- `<leader>sw`：搜索光标下的单词；可视模式下搜索选中文本。
- `<leader>sd` / `<leader>sD`：查看当前缓冲区 / 整个工作区的诊断。
- `<leader>su`：搜索撤销历史。
- `<C-g>`：打开 Lazygit，需要系统已安装 `lazygit`。
- `<leader>gb`：在浏览器对应的 Git 托管页面中打开当前文件或选中范围。

文件和全文搜索依赖系统中的 `rg`。主要键位见
[snacks_config.lua](/.config/nvim/lua/plugins/snacks_config.lua#L424-L575)和
[snacks_config.lua](/.config/nvim/lua/plugins/snacks_config.lua#L599-L675)。

在选择器中可用 `<C-j>` / `<C-k>` 上下移动，`<C-s>` 水平分屏打开，`<C-v>` 垂直分屏打开，
`<C-q>` 把结果送入 quickfix，`<C-c>` 关闭选择器。选择器键位见
[snacks_config.lua](/.config/nvim/lua/plugins/snacks_config.lua#L217-L300)。

## 7. neo-tree.nvim：文件与项目浏览器

### 作用

Neo-tree 提供三种树形视图：文件系统、Git 状态和当前文档符号。它会跟随当前文件，显示
Git 状态与诊断，并在重命名或移动文件后通知 Snacks 更新相关引用。启用的视图与事件处理见
[explorer.lua](/.config/nvim/lua/plugins/explorer.lua#L45-L97)。

### 用法

- `<C-e>`：打开文件系统树，并定位当前文件。
- `<C-q>`：打开 Git 状态树，并定位当前文件。
- `<C-w>`：打开当前文件的文档符号树。
- `<CR>`：进入目录或打开文件。
- `h` / `l`：折叠或进入节点。
- `H` / `L`：递归折叠 / 展开节点。
- `a`、`r`、`m`、`c`、`d`：新建、重命名、移动、复制、删除文件。
- `y`、`x`、`p`：复制、剪切、粘贴文件。
- `<C-s>` / `<C-v>`：在水平 / 垂直分屏中打开文件。
- `R`：刷新，`?`：显示帮助。

三个入口键位见 [explorer.lua](/.config/nvim/lua/plugins/explorer.lua#L416-L448)，树内通用键位见
[explorer.lua](/.config/nvim/lua/plugins/explorer.lua#L131-L238)，文件操作见
[explorer.lua](/.config/nvim/lua/plugins/explorer.lua#L240-L291)。

## 8. conform.nvim：统一代码格式化

### 作用

Conform 为不同文件类型选择正确的外部格式化器，并提供统一的调用方式。如果某种语言没有
配置外部格式化器，它会回退到 LSP 格式化。本配置把 C/C++ 交给 `clang-format`，Python
交给 `autopep8`，Java 交给 `google-java-format`，Lua 交给 `stylua`，前端与 Markdown
交给 `prettier`，Bazel 文件交给 `buildifier`。映射表见
[formatter.lua](/.config/nvim/lua/plugins/formatter.lua#L25-L47)。

### 用法

- 普通模式按 `<leader>f`：异步格式化整个文件。
- 可视模式选中代码后按 `<leader>f`：只格式化选中范围。
- `:ConformInfo`：查看当前文件会使用哪个格式化器，以及格式化器是否可执行。

快捷键和 LSP 回退策略见 [formatter.lua](/.config/nvim/lua/plugins/formatter.lua#L6-L24)。
如果格式化没有发生，先执行 `:ConformInfo`，再到 `:Mason` 中检查对应格式化器是否安装。

## 一套高频工作流

1. 用 `<C-p>` 找文件，或用 `<C-f>` 搜索代码内容。
2. 用 `gd`、`gr`、`gi` 在符号关系间导航。
3. 输入代码时用 blink.cmp 的 `<C-j>`、`<C-k>` 和 `<CR>` 完成补全。
4. 用 `af`、`if`、`]f` 等 Tree-sitter 文本对象选择或移动代码结构。
5. 用 `ga` 执行修复，用 `]d` / `[d` 浏览剩余诊断。
6. 完成修改后用 `<leader>f` 格式化，再用 `<C-g>` 进入 Lazygit 检查变更。

这 8 个插件构成了一条完整链路：lazy.nvim 管插件，Mason 管外部工具，Tree-sitter 理解语法，
nvim-lspconfig 提供语言语义，blink.cmp 负责输入，Snacks 与 Neo-tree 负责导航，Conform
负责统一输出格式。
