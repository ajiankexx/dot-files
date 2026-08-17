# Automatically manage a repository-local Python virtual environment.
# Only deactivate environments that were activated by this hook.
typeset -g DOTFILES_AUTO_VENV=''
typeset -g DOTFILES_AUTO_VENV_PENDING=1
typeset -gx VIRTUAL_ENV_DISABLE_PROMPT=1

dotfiles_auto_venv() {
  local repo_root activate_script

  repo_root="$(command git rev-parse --show-toplevel 2>/dev/null)" || repo_root=''
  activate_script="$repo_root/.venv/bin/activate"

  if [[ -n "$repo_root" && -r "$activate_script" ]]; then
    if [[ "$VIRTUAL_ENV" != "$repo_root/.venv" ]]; then
      if [[ -n "$DOTFILES_AUTO_VENV" && "$VIRTUAL_ENV" == "$DOTFILES_AUTO_VENV" ]]; then
        deactivate
      fi
      source "$activate_script"
    fi
    DOTFILES_AUTO_VENV="$VIRTUAL_ENV"
  elif [[ -n "$DOTFILES_AUTO_VENV" && "$VIRTUAL_ENV" == "$DOTFILES_AUTO_VENV" ]]; then
    deactivate
    DOTFILES_AUTO_VENV=''
  fi
}

dotfiles_schedule_auto_venv() {
  DOTFILES_AUTO_VENV_PENDING=1
}

dotfiles_apply_auto_venv() {
  (( DOTFILES_AUTO_VENV_PENDING )) || return
  DOTFILES_AUTO_VENV_PENDING=0
  dotfiles_auto_venv
}

autoload -Uz add-zsh-hook
# Directory changes can happen inside widgets such as fzf's Alt+C. Loading an
# activation script there can interfere with the widget's terminal cleanup, so
# defer the actual environment change until zsh is ready to draw a new prompt.
add-zsh-hook chpwd dotfiles_schedule_auto_venv
add-zsh-hook precmd dotfiles_apply_auto_venv
