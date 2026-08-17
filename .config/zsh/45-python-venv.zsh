# Automatically manage a repository-local Python virtual environment.
# Only deactivate environments that were activated by this hook.
typeset -g DOTFILES_AUTO_VENV=''
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

autoload -Uz add-zsh-hook
add-zsh-hook chpwd dotfiles_auto_venv
dotfiles_auto_venv
