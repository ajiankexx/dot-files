# Key bindings.
bindkey -v
export KEYTIMEOUT=1
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
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
