# Helpful aliases.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=always --group-directories-first'
  alias ll='eza --long --all --git --icons=always --group-directories-first'
  alias la='eza --all --icons=always --group-directories-first'
  alias l='eza --long --git --icons=always --group-directories-first'
  alias tree='eza --tree --icons=always --group-directories-first'
else
  alias ll='ls -lah'
  alias la='ls -A'
  alias l='ls -CF'
  alias ls='ls -G'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
  alias less='bat --paging=always'
  alias preview='bat --style=numbers,changes,header --color=always --line-range=:240'
fi

alias grep='grep --color=auto'
alias gs='git status'

# Temporary commands: keep short-lived or experimental wrappers here. Add future
# temporary commands below; promote stable commands into a dedicated config file.
codex-huoshan() {
  CODEX_HOME="$HOME/.codex-huoshan" command codex "$@"
}

# Quickly name the current WezTerm tab: tabname "project-name".
tabname() {
  if [[ -z "$WEZTERM_PANE" ]]; then
    print -u2 'tabname: this command must run inside WezTerm'
    return 1
  fi
  command wezterm cli set-tab-title "$*"
}
