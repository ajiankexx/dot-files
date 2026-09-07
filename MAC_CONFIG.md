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

## 使用 `osascript` 发送通知

`osascript` 是 macOS 自带的命令行工具，可在终端中执行 AppleScript。
例如，下面的命令会尝试发送一条系统通知并播放提示音：

```sh
/usr/bin/osascript -e 'display notification "任务已完成" with title "Claude Code" sound name "Glass"'
```

使用绝对路径 `/usr/bin/osascript` 可以避免脚本、IDE 或 Hook 的 `PATH`
环境不完整而找不到命令。

检查脚本是否成功执行：

```sh
/usr/bin/osascript -e 'display notification "test" with title "test"'; echo $?
```

退出码 `0` 仅表示 AppleScript 成功执行，不保证 macOS 一定展示通知横幅。
如果没有看到通知：

1. 检查“系统设置 → 通知 → 脚本编辑器”是否允许通知。
2. 检查专注模式或勿扰模式是否开启。
3. 打开通知中心，确认通知是否被静默收纳。
4. 在“脚本编辑器”中新建文稿并运行以下代码，使应用尝试向通知中心注册：

```applescript
display notification "测试通知" with title "Claude Code" sound name "Glass"
```

部分 macOS 版本不会将命令行启动的 `osascript` 正确注册为通知来源：命令可能返回
`0`，但通知设置中没有“脚本编辑器”，也不显示通知。此时可使用专门的通知工具
`terminal-notifier`。它已加入 [Brewfile](/Brewfile)，运行 `bash install.sh --brew`
时会自动安装；也可以单独安装：

```sh
brew install terminal-notifier
terminal-notifier -title "Claude Code" -message "任务已完成" -sound Glass
```

将通知用于 Claude Code Hook 时，可在 `~/.claude/settings.json` 中配置：

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/usr/bin/osascript -e 'display notification \"Claude 已完成回复\" with title \"Claude Code\" sound name \"Glass\"'"
          }
        ]
      }
    ]
  }
}
```

`Stop` Hook 会在 Claude Code 完成一次回复时执行该命令。如果配置文件已有
`hooks`，应合并 `Stop` 字段，不要覆盖其他 Hook。
