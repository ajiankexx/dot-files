#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf '错误: mac-config.sh 只能在 macOS 上执行。\n' >&2
  exit 1
fi

if ! command -v defaults >/dev/null 2>&1; then
  printf '错误: 未找到 macOS defaults 命令。\n' >&2
  exit 1
fi

if ! command -v killall >/dev/null 2>&1; then
  printf '错误: 未找到 killall 命令。\n' >&2
  exit 1
fi

# Finder：显示以 . 开头的隐藏文件和文件夹。
defaults write com.apple.finder AppleShowAllFiles -bool true

# 重新启动 Finder，使配置立即生效。
killall Finder
