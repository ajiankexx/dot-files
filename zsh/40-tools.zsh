# Modern CLI tools.
export BAT_THEME='TwoDark'
export BAT_STYLE='numbers,changes,header'
export EZA_COLORS='uu=36:gu=37:da=90:ur=34:uw=35:ux=32:ue=32:gr=34:gw=35:gx=32:tr=34:tw=35:tx=32:di=1;34:ln=1;36:ex=1;32:*.md=1;36:*.json=1;33:*.yaml=1;33:*.yml=1;33:*.toml=1;33:*.go=1;32:*.py=1;32:*.js=1;32:*.ts=1;32:*.tsx=1;32:*.zip=1;31:*.tar=1;31:*.gz=1;31:*.png=1;35:*.jpg=1;35:*.jpeg=1;35:*.webp=1;35'

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# zoxide + fzf directory picking.
if command -v fzf >/dev/null 2>&1; then
  # Use fzf to choose a zoxide directory, with a simple directory listing preview.
  function zi {
    local dir
    dir="$(zoxide query -l | fzf --preview 'ls -la {}')"
    [[ -n "$dir" ]] && cd "$dir"
  }

  # Select multiple zoxide directories and print the selected paths.
  function zim {
    local dirs
    dirs="$(zoxide query -l | fzf -m)"

    if [[ -n "$dirs" ]]; then
      print -r -- "$dirs" | while read -r dir; do
        print -r -- "Selected: $dir"
      done
    fi
  }

  # Choose a zoxide directory, jump into it, then list its contents.
  function zfp {
    local dir
    dir="$(zoxide query -l | fzf --preview 'tree -L 2 {}')"
    [[ -n "$dir" ]] && cd "$dir" && ls -la
  }

  # Choose a zoxide directory, jump into it, then run a command there.
  function zexec {
    local dir cmd
    dir="$(zoxide query -l | fzf)"

    if [[ -n "$dir" ]]; then
      cd "$dir" || return
      read "cmd?Enter command: "
      eval "$cmd"
    fi
  }

  # Quickly switch between directories whose path contains "project".
  function zp {
    local dir
    dir="$(zoxide query -l | grep -i project | fzf)"
    [[ -n "$dir" ]] && cd "$dir"
  }

  # Search zoxide entries after sorting them numerically in reverse order.
  function zr {
    local dir
    dir="$(zoxide query -l | sort -k2 -rn | fzf)"
    [[ -n "$dir" ]] && cd "$dir"
  }

  # Only search zoxide directories that are Git repositories.
  function zgit {
    local dir
    dir="$(zoxide query -l | xargs -I {} sh -c 'test -d "{}/.git" && echo "{}"' | fzf)"
    [[ -n "$dir" ]] && cd "$dir"
  }

  # Limit zoxide results before opening fzf, useful if the database gets large.
  function zil {
    local dir
    dir="$(zoxide query -l | head -50 | fzf)"
    [[ -n "$dir" ]] && cd "$dir"
  }

  # Reload zoxide results as the fzf query changes.
  function zia {
    local dir
    dir="$(zoxide query -l | fzf --bind 'change:reload:zoxide query -l {q}')"
    [[ -n "$dir" ]] && cd "$dir"
  }
fi
