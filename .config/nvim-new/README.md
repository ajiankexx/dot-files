# nvim-new v1.0.0

`nvim-new` 是当前推荐使用的 Neovim 配置版本。它以旧标签
`nvim-working-2026-07-30` 为迁移基线，在保留原有编辑习惯、快捷键和界面布局的
前提下，按照各插件最新 README 和升级说明完成了兼容性迁移。

## 版本信息

| 项目 | 当前版本 |
| --- | --- |
| 配置版本 | `nvim-new v1.0.0` |
| Git 标签 | `nvim-new-v1.0.0` |
| 发布日期 | `2026-07-31` |
| Neovim | `NVIM v0.12.4`，Release 构建 |
| Lua 运行时 | `LuaJIT 2.1.1783415239` |
| 插件管理器 | Lazy.nvim stable |
| 插件锁文件 | 61 个仓库条目 |
| 旧版本基线 | `nvim-working-2026-07-30` |

所有插件的准确分支和提交都记录在
[lazy-lock.json](/.config/nvim-new/lazy-lock.json)，因此同一个 Git 标签可以恢复出相同的
插件组合。几个重要插件的锁定状态如下：

| 插件 | 分支或版本策略 | 锁定提交 |
| --- | --- | --- |
| Lazy.nvim | stable bootstrap | `306a055` |
| blink.cmp | `1.*` 稳定版本，当前为 `v1.10.2` | `78336bc` |
| Catppuccin | `main` | `79e2049` |
| nvim-treesitter | 新版 `main` | `0f32dff` |
| nvim-treesitter-textobjects | 新版 `main` | `898ee30` |
| mason.nvim | `mason-org/main` | `2a6940a` |
| mason-lspconfig.nvim | `mason-org/main` | `67029cc` |
| nvim-lspconfig | `master` | `9ae2b3b` |
| neo-tree.nvim | `v3.x` | `ebd6676` |
| snacks.nvim | Kaiser-Yang fork 的 `develop` | `7578cf3` |

## 启动和确认版本

运行安装脚本后，配置会被复制到 `~/.config/nvim-new`。使用下面的命令启动，而不会
影响原来的 `~/.config/nvim`：

```sh
NVIM_APPNAME=nvim-new nvim
```

确认 Neovim 程序版本：

```sh
NVIM_APPNAME=nvim-new nvim --version
```

进入 Neovim 后确认当前配置目录：

```vim
:lua print(vim.fn.stdpath("config"))
```

预期输出以 `.config/nvim-new` 结尾。也可以执行：

```vim
:lua print(vim.env.NVIM_APPNAME)
```

预期输出为 `nvim-new`。

## 整体设计

### 1. 新旧配置并行

新版放在独立的 [nvim-new 目录](/.config/nvim-new)，没有覆盖旧的
[nvim 目录](/.config/nvim)。`NVIM_APPNAME` 会让 Neovim 同时隔离配置目录、数据目录、
状态目录和缓存目录，因此可以在同一台机器上并行测试两个版本。

这种设计提供了两个回退层级：

1. 启动时去掉 `NVIM_APPNAME=nvim-new`，立即回到旧配置。
2. 使用 Git 标签 `nvim-new-v1.0.0` 恢复本次已验证的文件和插件锁。

### 2. 启动职责分层

[init.lua](/.config/nvim-new/init.lua) 只负责组织启动顺序：加载核心选项、全局快捷键、
Markdown 行为、行级编辑行为、Lazy.nvim bootstrap，最后加载调试辅助逻辑。

具体职责被拆分为：

- [core.lua](/.config/nvim-new/lua/core.lua)：编辑器选项、根目录判断和基础自动命令。
- [key_mapping.lua](/.config/nvim-new/lua/key_mapping.lua)：与插件无关的全局快捷键。
- [markdown_support.lua](/.config/nvim-new/lua/markdown_support.lua)：Markdown 编辑体验。
- [line_wise.lua](/.config/nvim-new/lua/line_wise.lua)：行级移动和操作语义。
- [utils.lua](/.config/nvim-new/lua/utils.lua)：映射、LSP capability、重复移动等共享能力。
- [package_manager.lua](/.config/nvim-new/lua/package_manager.lua)：只负责安装和加载稳定版
  Lazy.nvim。
- [plugins/init.lua](/.config/nvim-new/lua/plugins/init.lua)：插件规格的唯一聚合入口。

入口文件禁用了 Lazy.nvim 的自动更新检查和配置变动监听，并从 runtimepath 排除了若干
不使用的内置插件。这让启动行为更确定，也避免后台检查干扰正常编辑。

### 3. 可复现而不是盲目追逐主分支

迁移时读取的是各仓库最新 README，但“最新”不等于所有插件都直接使用 `main`：

- README 明确稳定的插件使用最新版稳定标签。
- README 明确要求主分支的新架构时使用主分支。
- 可能发生破坏性变化的插件保留官方推荐的版本约束。
- 最终解析结果写入 [lazy-lock.json](/.config/nvim-new/lazy-lock.json)。

最典型的例子是 blink.cmp：其 `main` 正在开发带有破坏性变化的 v2，官方 README 建议
生产配置继续使用 v1。因此新版在
[blink_cmp.lua](/.config/nvim-new/lua/plugins/blink_cmp.lua) 中明确使用 `version = "1.*"`，
而不是把一次更新直接变成 v2 迁移。

### 4. 原生 Neovim API 优先

LSP 使用 Neovim 0.12 的原生 `vim.lsp.config()` 和 `vim.lsp.enable()`，配置入口位于
[lsp_config.lua](/.config/nvim-new/lua/plugins/lsp_config.lua)。通用 capability 和根目录
规则集中定义，语言特定覆盖放在 [lsp 目录](/.config/nvim-new/lsp)。

Treesitter 的高亮和折叠同样使用 Neovim 原生接口，而不是旧版插件的集中式
`configs.setup()`。相关实现位于
[tree_sitter.lua](/.config/nvim-new/lua/plugins/tree_sitter.lua)。

### 5. 显式管理工具安装和 LSP 启用

Mason 负责安装外部工具，但不决定哪些 LSP 客户端被启用：

- [mason.lua](/.config/nvim-new/lua/plugins/mason.lua) 管理语言服务器、格式化器和调试工具。
- [mason_lsp_config.lua](/.config/nvim-new/lua/plugins/mason_lsp_config.lua) 声明需要确保安装的
  LSP，并设置 `automatic_enable = false`。
- [lsp_config.lua](/.config/nvim-new/lua/plugins/lsp_config.lua) 明确启用实际需要的客户端。

这样可以同时支持 Mason 安装的服务器和系统中已有的服务器，也不会因为
mason-lspconfig 的默认行为变化而意外启用额外客户端。

Mason v2 的 registry 是异步加载的。新版先 refresh registry，再检查包是否存在；无 UI 的
headless 启动不会触发工具下载。这保证 CI、诊断命令和启动测试不会被后台安装任务阻塞。

### 6. 编辑体验保持兼容

新版继续保留原有的主要工作流：

- blink.cmp 提供 LSP、代码片段、路径、缓冲区、项目 ripgrep、字典和 Git 补全。
- Neo-tree、Bufferline、Lualine 和 Snacks 组成导航与界面层。
- Conform 负责格式化，缺少专用格式化器时回退到 LSP。
- Gitsigns、git-conflict.nvim 和 Octo 提供 Git/GitHub 工作流。
- nvim-dap、nvim-dap-ui、nvim-jdtls 提供调试和 Java 支持。
- render-markdown.nvim 与 markdown-preview.nvim 分别提供编辑器内渲染和浏览器预览。
- Comment.nvim、Surround、Yanky、Ultimate Autopair 和 Flash 保留高频编辑动作。

复杂的自定义快捷键和业务逻辑仍保留在各自插件模块中，而不是为了追求“最小配置”而
删除用户已经形成肌肉记忆的行为。

### 7. 可移植路径和凭据安全

旧配置把字典路径写死为 `~/.config/nvim/...`，这在 `NVIM_APPNAME=nvim-new` 下会错误读取
旧目录。新版在 [blink_cmp.lua](/.config/nvim-new/lua/plugins/blink_cmp.lua) 中通过
`stdpath("config")` 构造路径；可选的非 ASCII 字典配置也采用同样方式。

[translate.lua](/.config/nvim-new/lua/plugins/translate.lua) 不再保存明文 API 密钥，而是读取
`SILICONFLOW_API_KEY` 环境变量。该本地插件目前没有加入默认插件集合，因为对应仓库不在
当前可用的 61 个远端仓库中。

Pastify 会在 setup 阶段执行 Python。新版在
[pastify.lua](/.config/nvim-new/lua/plugins/pastify.lua) 中检查 Neovim Python provider；provider
不可用时只禁用 Pastify，不影响其他插件启动。

## 与旧标签版本的关键差异

以下比较以 `nvim-working-2026-07-30` 为旧版本基线。

| 领域 | 旧版本 | nvim-new v1.0.0 |
| --- | --- | --- |
| 配置位置 | 只使用默认 `nvim` app | 独立 `nvim-new` app，可与旧版并行 |
| 目录结构 | 包含误嵌套的第二份 `nvim/nvim` 和日志文件 | 只有一份有效配置，不携带运行日志 |
| 插件聚合 | Ufo、Render Markdown、Img Clip 被重复加入；保留多项注释规格 | 每个默认插件只聚合一次，条件插件集中在列表末尾 |
| Treesitter | 调用旧的 `install.update(... )()` 构建函数 | 新主分支要求 `lazy = false` 和 `build = ":TSUpdate"` |
| Treesitter 功能 | 依赖旧版插件配置习惯 | 使用原生高亮、折叠和新版 textobjects 模块 API |
| Mason 来源 | `williamboman/*`、`v1.x` | `mason-org/*`、v2 主分支 |
| Mason registry | 同步读取 registry，手动拼接固定数据路径 | 异步 refresh，`PATH = "append"`，不硬编码 app 数据目录 |
| mason-lspconfig | 使用已移除的 `automatic_installation` | 使用 `automatic_enable = false` 与 `ensure_installed` |
| LSP 启用 | 已使用原生 API，但工具安装层仍是 Mason v1 | 保留原生 API，并与 Mason v2 显式分工 |
| blink.cmp | `version = "*"`，稳定/开发边界不明确 | 遵循 README 固定 `1.*` 稳定系列 |
| 字典路径 | 固定读取旧的 `~/.config/nvim` | 从当前 app 的 `stdpath("config")` 解析 |
| Catppuccin | 固定 `v1.11.0` | 使用当前最新版并由 lockfile 固定提交 |
| Bufferline 主题 | 使用已移除的 `groups.integrations.bufferline` | 使用 `catppuccin.special.bufferline.get_theme()` |
| Pastify | Python provider 缺失会在加载时中断配置 | provider 缺失时安全跳过 |
| Translate 密钥 | 配置文件中保存明文密钥 | 只读取环境变量，且默认不加载本地插件 |
| 可复现性 | 旧 lockfile 固定 Mason v1 等旧提交 | 新 lockfile 固定迁移验证后的 61 个提交 |

## 条件插件

默认插件列表会根据环境启用少量可选功能：

- 系统存在 `gh` 时加入 Octo。
- 非 macOS、存在 Node.js 且网络可用时加入 Copilot 和 Avante。
- Neovim Python provider 可用时启用 Pastify。

因此，不同机器第一次启动后 Lazy.nvim 的实际插件图可能略有区别。当前 macOS 环境中，
lockfile 有 61 个仓库条目；Python provider 不可用时运行期插件图为 60 个。

## 验证记录

本版本完成了以下验证：

1. 使用隔离的 config、data、state 和 cache 目录执行最新版插件同步。
2. 普通 headless 启动无错误。
3. 强制加载 Lazy.nvim 当前解析到的全部插件无错误。
4. Lazy spec 解析结果为 `spec_errors = nil`。
5. 在沙箱外使用 `nvim-new` 打开 Lua 文件并正常退出，确认文件监视器不受测试沙箱限制。
6. 扫描新版目录，确认没有明文 API 密钥或写死的用户绝对路径。

验证启动命令的基本形式为：

```sh
NVIM_APPNAME=nvim-new nvim --headless -i NONE '+qa'
```

## 已知前置条件和限制

- Neovim 必须为 0.12 或更新版本；新版 nvim-treesitter 主分支明确依赖 Neovim 0.12。
- Treesitter parser 安装需要 `tree-sitter-cli`、C 编译器、`tar` 和 `curl`。
- Pastify 需要 Python provider 与 Pillow；未满足时会被安全禁用。
- 首次以图形或终端 UI 启动时，Mason 才会异步安装缺失工具。
- markdown-preview.nvim 的上游 npm 依赖在安装时会报告 audit 漏洞；这是插件自身依赖树，
  不是本配置引入的自定义 JavaScript。
- 当条件插件集合发生变化时，应重新执行 Lazy.nvim 同步并提交更新后的 lockfile。

## 维护流程

插件仓库 README 的本地副本由仓库根目录的
[sync-nvim-plugins.sh](/sync-nvim-plugins.sh) 维护：

```sh
./sync-nvim-plugins.sh
```

升级配置时建议遵循下面的顺序：

1. 更新本地插件仓库并阅读 README、UPGRADE 和 CHANGELOG。
2. 只在 [nvim-new 目录](/.config/nvim-new) 中修改配置。
3. 使用隔离目录执行 Lazy.nvim sync。
4. 运行普通启动和强制加载全部插件测试。
5. 检查 lockfile 差异，确认没有意外切换到开发分支。
6. 提交配置和文档，再创建 annotated Git 标签。

查看本版本而不切换当前分支：

```sh
git show nvim-new-v1.0.0
```

在临时 detached HEAD 中完整检查本版本：

```sh
git switch --detach nvim-new-v1.0.0
```
