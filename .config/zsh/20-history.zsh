# History.
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=20000
SAVEHIST=20000
setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history
setopt share_history

# HISTFILE is configured from .zshrc, after zsh's implicit history-file load.
# Load it explicitly so a newly opened terminal can search prior sessions.
[[ -r "$HISTFILE" ]] && fc -R "$HISTFILE"
