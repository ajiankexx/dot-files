# Mac 配置记录

本文记录 macOS 上由 [`mac-config.sh`](/mac-config.sh) 执行的配置命令及其作用。

执行全部当前记录的 Mac 配置：

```sh
bash install.sh --mac
```

## 当前安装命令

| 命令 | 作用 |
| --- | --- |
| `defaults write com.apple.finder AppleShowAllFiles -bool true` | 设置 Finder 显示以 `.` 开头的隐藏文件和文件夹，例如 `.codex`。 |
| `killall Finder` | 重新启动 Finder，使上一条配置立即生效。 |

后续新增 Mac 配置时，将命令添加到 [`mac-config.sh`](/mac-config.sh)，并在本表补充命令作用。

## 手动切换与恢复

在 Finder 中打开目标文件夹后，按 `⌘ Command + ⇧ Shift + .`，即可显示或隐藏以 `.` 开头的隐藏文件和文件夹，例如 `.codex`。

恢复为默认的隐藏状态：

```sh
defaults write com.apple.finder AppleShowAllFiles -bool false
killall Finder
```

检查 Finder 当前记录的值：

```sh
defaults read com.apple.finder AppleShowAllFiles
```

返回 `1` 表示显示隐藏文件，返回 `0` 表示隐藏隐藏文件。
