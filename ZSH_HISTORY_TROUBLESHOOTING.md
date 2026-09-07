# Zsh 历史记录无法检索的问题说明

## 现象

在新开的 Zsh 终端中，曾在此前会话执行且已经写入
`~/.zsh_history` 的命令，无法通过以下方式找到：

```sh
history | grep <关键字>
```

例如，`spcli` 本身仍可被命令补全识别，但 `history | grep spcli`
没有返回此前执行过的 `spcli` 命令。

## 根因

`history` 搜索的是当前 Zsh 进程的内存历史，并不直接扫描
`~/.zsh_history`。Zsh 的隐式历史加载发生在启动阶段；而本仓库是在
Zsh 启动后，由 Zsh 入口配置加载历史设置，届时才设置 `HISTFILE`。
因此新 shell 已知道历史文件的位置，却没有自动把既有记录载入内存。

历史文件和选项配置位于
[`.config/zsh/20-history.zsh`](/.config/zsh/20-history.zsh#L1-L16)。此前的
`append_history`、`inc_append_history` 与 `share_history` 确保记录持续写入和
跨会话追加，但不会补载新 shell 启动前已有的全部记录。

`spcli` 的命令补全是独立机制：只要其可执行文件位于 `$PATH`，Zsh 就可以发现
该命令；补全可用并不代表旧历史已被载入。

## 修复

在设置历史文件路径和历史选项后，显式读取历史文件：

```zsh
[[ -r "$HISTFILE" ]] && fc -R "$HISTFILE"
```

该逻辑已加入
[`.config/zsh/20-history.zsh`](/.config/zsh/20-history.zsh#L14-L16)。此后每个
新 Zsh 会话都会先载入既有历史，再继续使用实时追加和共享历史。

## 验证方法

重开终端，或重新启动 Zsh，然后执行：

```sh
history | grep -F spcli
```

若要在当前已经打开的终端中立即加载历史文件，可执行：

```sh
fc -R "$HISTFILE"
```

也可以绕过内存历史，直接检查持久化文件：

```sh
grep -n -F spcli "$HISTFILE"
```

## 补充：末尾反斜杠

如果历史中的命令末尾带有反斜杠（`\\`），Zsh 会将其记录为续行命令，显示时可能
出现 `\\n` 或看起来像多行。此情形不会阻止以 `spcli` 等前缀关键词搜索，但应使用
实际保存的内容进行精确匹配。
