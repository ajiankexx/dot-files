# Key bindings.
bindkey -v
export KEYTIMEOUT=1
history-beginning-search-backward-end() {
  zle history-beginning-search-backward
  zle end-of-line
}
zle -N history-beginning-search-backward-end
# Terminals may send either CSI (Esc [) or SS3/application (Esc O) sequences
# for arrow keys. Support both in vi insert mode.
bindkey -M viins '^[[A' history-beginning-search-backward-end
bindkey -M viins '^[[B' history-beginning-search-forward
bindkey -M viins '^[OA' history-beginning-search-backward-end
bindkey -M viins '^[OB' history-beginning-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
# Ctrl+K removes everything from the cursor through the end of the command line.
bindkey -M viins '^K' kill-line
bindkey -M vicmd '^K' kill-line
# Ctrl+U removes everything from the cursor back to the start of the command line.
bindkey -M viins '^U' backward-kill-line
bindkey -M vicmd '^U' backward-kill-line
