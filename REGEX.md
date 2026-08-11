# fzf、find 与 grep 匹配速查

`grep` 用正则表达式匹配文本内容；`find` 默认用 glob 匹配文件名，也可用正则匹配完整路径；`fzf` 默认使用模糊匹配，查询语法不是正则表达式。三者的匹配对象和语法不同，不能直接互换。

## 先选对工具

| 目标 | 推荐工具 | 示例 |
| --- | --- | --- |
| 在文件内容中找文本或模式 | `grep` | `grep -nE 'error|warning' app.log` |
| 递归查找文件内容 | `grep -r` | `grep -rnE 'TODO|FIXME' .` |
| 按文件名查找 | `find -name` | `find . -name '*.md'` |
| 按完整路径查找 | `find -regex` | `find -E . -regex '.*\.md'` |
| 从候选项中交互选择 | `fzf` | `history | fzf` |

## grep：在文本内容中使用正则

### 常用选项

| 选项 | 作用 |
| --- | --- |
| `-E` | 使用扩展正则（ERE），支持 `+`、`?`、`|`、`()`；日常优先使用。 |
| `-i` | 忽略大小写。 |
| `-v` | 输出不匹配的行。 |
| `-n` | 显示行号。 |
| `-r` | 递归搜索目录。 |
| `-l` | 只显示包含匹配内容的文件名。 |
| `-o` | 只输出匹配到的部分。 |
| `-w` | 按完整单词匹配。 |

### 常见模式

以下示例使用 `grep -E`。正则应放在单引号内，避免 shell 先解释 `$`、`*` 等字符。

| 目的 | 模式 | 示例 |
| --- | --- | --- |
| 行以 `mini` 开头 | `^mini` | `grep -nE '^mini' commands.txt` |
| 行以 `.md` 结尾 | `\.md$` | `grep -nE '\.md$' files.txt` |
| 精确匹配整行 `mini` | `^mini$` | `grep -nE '^mini$' commands.txt` |
| 匹配多个候选 | `error|warning` | `grep -nE 'error|warning' app.log` |
| 可选后缀 | `mini(-extra)?` | `grep -nE 'mini(-extra)?' commands.txt` |
| 重复一次或多次 | `[0-9]+` | `grep -nE '[0-9]+' app.log` |
| 匹配一个字符 | `colou?r` | `grep -nE 'colou?r' words.txt` |
| 匹配字符集合 | `v[0-9]+` | `grep -nE 'v[0-9]+' versions.txt` |
| 排除匹配行 | `-vE '^[[:space:]]*(#|$)'` | `grep -vE '^[[:space:]]*(#|$)' config.ini` |

### 字符类

POSIX 字符类跨平台表现更稳定：

| 表达式 | 含义 |
| --- | --- |
| `[[:digit:]]` | 数字 |
| `[[:alpha:]]` | 字母 |
| `[[:alnum:]]` | 字母或数字 |
| `[[:space:]]` | 空白字符 |
| `[[:lower:]]` / `[[:upper:]]` | 小写 / 大写字母 |

例如，匹配历史文件中真正以 `mini` 作为命令开头的记录：

```sh
grep -E ';mini([^[:alnum:]_]|$)' ~/.zsh_history
```

`grep mini ~/.zsh_history` 只表示该行任意位置包含 `mini`，因此也会命中参数、路径或 Git URL。

## find：文件名 glob 与路径正则

### `-name`：默认首选

`find -name` 使用 shell 风格的 glob，不使用正则。模式应加引号，避免被 shell 提前展开。

```sh
# 所有 Markdown 文件
find . -name '*.md'

# 忽略大小写
find . -iname '*readme*'

# 查找名为 config 或 config.local 的文件
find . -name 'config*'

# 排除 .git 目录
find . -path './.git' -prune -o -name '*.md' -print
```

glob 的常用记号：`*` 表示任意长度字符串，`?` 表示一个字符，`[abc]` 表示集合中的一个字符。`*.md` 是 glob；在正则中应写为 `.*\.md`。

### `-regex`：匹配完整路径

`find -regex` 对整个搜索路径做匹配，而非只匹配文件名。以当前目录为起点时，路径通常以 `./` 开头，因此模式往往以 `.*` 开始。

macOS（BSD find）默认使用基本正则；加入 `-E` 后使用扩展正则：

```sh
# macOS：路径以 .md 结尾
find -E . -regex '.*\.md'

# macOS：匹配 .config 或 home 下的 Markdown 文件
find -E . -regex './(\.config|home)/.*\.md'
```

GNU find 的写法不同，需要明确正则类型：

```sh
find . -regextype posix-extended -regex '.*\.md'
```

文件名匹配优先使用 `-name`；只有需要按目录层级、完整路径或复杂结构筛选时再使用 `-regex`。

## fzf：模糊查询，不是正则

fzf 的默认查询把空格分隔为多个词，并按模糊匹配排序：

```sh
# 在历史中查找同时包含 mini 和 config 的条目
history | fzf --query 'mini config'

# 从文件列表中选择
find . -type f | fzf
```

启用默认的 extended-search 后，fzf 常用查询语法如下：

| 查询 | 含义 |
| --- | --- |
| `mini` | 模糊匹配；字符按顺序出现即可。 |
| `'mini` | 精确子串匹配。 |
| `^mini` | 以 `mini` 开头。 |
| `yaml$` | 以 `yaml` 结尾。 |
| `^mini$` | 完全等于 `mini`。 |
| `!test` | 排除包含 `test` 的项。 |
| `mini | config` | 匹配 `mini` 或 `config`。 |

`fzf` 中的 `^`、`$`、`!`、`|` 和前导单引号是 fzf 查询语法的一部分；它们的语义与 grep 正则相近，但 fzf 不支持把任意正则直接作为查询。需要正则过滤时，先用 `grep -E` 或 `find -regex` 产生候选，再交给 fzf：

```sh
# 先用正则过滤历史，再选择一条
grep -E ';mini([^[:alnum:]_]|$)' ~/.zsh_history | fzf

# 查找 Go 或 Rust 源文件，再选择
find -E . -regex '.*\.(go|rs)' | fzf
```

## 容易混淆的写法

| 需求 | 正确写法 | 原因 |
| --- | --- | --- |
| find 查 `.lua` 文件 | `find . -name '*.lua'` | `-name` 使用 glob。 |
| grep 查 `.lua` 后缀 | `grep -E '\.lua$' list.txt` | `.` 在正则中表示任意字符，需转义。 |
| grep 查行首 `mini` | `grep -E '^mini' file` | `^` 表示行首。 |
| fzf 只查以 `mini` 开头的候选 | `fzf --query '^mini'` | 这是 fzf 的前缀查询语法。 |
| 排除 `.git` 再找 Markdown | `find . -path './.git' -prune -o -name '*.md' -print` | `-prune` 阻止进入该目录。 |
