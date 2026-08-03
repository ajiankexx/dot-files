# Dotfiles

这个仓库保存需要安装到用户目录的配置，并在覆盖现有配置前创建备份。

## 目录结构

```text
.
├── .config/       # 顶层条目安装到 ~/.config/
├── home/          # 顶层条目安装到 ~/
├── Brewfile
├── install.sh
└── restore.sh
```

例如，[WezTerm 配置](/.config/wezterm/wezterm.lua)会安装为
`~/.config/wezterm/wezterm.lua`，[Zsh 入口文件](/home/.zshrc)会安装为
`~/.zshrc`。

## 安装

运行[安装脚本](/install.sh)：

```sh
bash install.sh
```

安装脚本逐个处理 `.config/` 和 `home/` 中的顶层条目：

1. 检查 Cargo；未安装时通过 rustup 安装 Rust 工具链。
2. 通过 Cargo 安装 `tree-sitter-cli`。
3. 检查 uv；未安装时通过 uv 官方安装脚本安装。
4. 目标已存在时，先备份再替换。
5. 目标不存在时，直接复制，并记录该目标原先不存在。
6. 文件、目录和符号链接都会保留。

Cargo 缺失时执行：

```sh
curl https://sh.rustup.rs -sSf | sh
```

安装 `tree-sitter-cli` 时执行：

```sh
cargo install tree-sitter-cli
```

安装 uv 时执行：

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

默认备份位置是 `~/.dotfiles-backups/install-<时间戳>/`。可通过环境变量
修改备份根目录：

```sh
DOTFILES_BACKUP_DIR=/path/to/backups bash install.sh
```

如需同时安装 [Brewfile](/Brewfile) 中的软件包：

```sh
bash install.sh --brew
```

## 恢复

使用[恢复脚本](/restore.sh)查看备份：

```sh
bash restore.sh --list
```

恢复最新一次安装：

```sh
bash restore.sh
```

也可以恢复指定备份：

```sh
bash restore.sh ~/.dotfiles-backups/install-20260729-120000
```

恢复时，安装前存在的目标会还原，安装前不存在的目标会被移除。
