# Prompt.
autoload -Uz colors
colors
autoload -Uz vcs_info

zstyle ':vcs_info:git:*' formats '%b'
zstyle ':vcs_info:git:*' actionformats '%b|%a'

function prompt_segment {
  local bg="$1"
  local fg="$2"
  local text="$3"
  [[ -n "$text" ]] && print -r -- "%K{$bg}%F{$fg} ${text} %f%k"
}

function prompt_git_segment {
  [[ -n "$vcs_info_msg_0_" ]] && prompt_segment magenta black "git:${vcs_info_msg_0_}"
}

function prompt_python_segment {
  local py_version=""

  if [[ -n "$VIRTUAL_ENV" ]]; then
    py_version="${VIRTUAL_ENV:t}"
  elif [[ -f pyproject.toml || -f requirements.txt || -f setup.py ]]; then
    py_version="$(python3 --version 2>/dev/null | awk '{print $2}')"
  fi

  [[ -n "$py_version" ]] && prompt_segment blue white "py:${py_version}"
}

function prompt_node_segment {
  local node_version=""

  if [[ -f package.json || -f bun.lockb || -f bun.lock || -f pnpm-lock.yaml || -f yarn.lock || -f package-lock.json ]]; then
    if command -v node >/dev/null 2>&1; then
      node_version="$(node --version 2>/dev/null)"
    elif command -v bun >/dev/null 2>&1; then
      node_version="bun:$(bun --version 2>/dev/null)"
    fi
  fi

  [[ -n "$node_version" ]] && prompt_segment cyan black "node:${node_version#v}"
}

function precmd {
  vcs_info
  PROMPT_CONTEXT="$(prompt_git_segment)$(prompt_python_segment)$(prompt_node_segment)"
}

function zle-set-cursor-shape {
  # DECSCUSR: a steady block in vi normal mode, a steady bar while inserting.
  if [[ $1 == vicmd ]]; then
    printf '\e[2 q'
  else
    printf '\e[6 q'
  fi
}

function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    VIM_PROMPT_MODE='%K{yellow}%F{black} N %f%k'
  else
    VIM_PROMPT_MODE='%K{green}%F{black} I %f%k'
  fi
  zle-set-cursor-shape "$KEYMAP"
  zle reset-prompt
}

function zle-line-init {
  VIM_PROMPT_MODE='%K{green}%F{black} I %f%k'
  zle-set-cursor-shape viins
  zle reset-prompt
}

function zle-line-finish {
  zle-set-cursor-shape vicmd
}

zle -N zle-keymap-select
zle -N zle-line-init
zle -N zle-line-finish

PROMPT='${VIM_PROMPT_MODE}%K{240}%F{255} %~ %f%k${PROMPT_CONTEXT}
%F{81}❯%f '
RPROMPT='%F{244}%*%f %(?..%F{160}· exit:%?%f)'
