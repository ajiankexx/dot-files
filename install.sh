#!/usr/bin/env bash
# Bootstrap this dotfiles repository after cloning it to ~/.config.
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
skip_brew=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [--skip-brew]

Install the Homebrew packages from Brewfile and link ~/.zshrc to this repo's
modular zsh configuration. The repository must be cloned to ~/.config (or
$XDG_CONFIG_HOME).
EOF
}

while (($#)); do
  case "$1" in
    --skip-brew) skip_brew=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ "$repo_root" != "$config_root" ]]; then
  printf 'This repository must be located at %s; found it at %s.\n' \
    "$config_root" "$repo_root" >&2
  exit 1
fi

if [[ "$skip_brew" == false ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    printf 'Homebrew is required. Install it from https://brew.sh, then rerun this script.\n' >&2
    exit 1
  fi
  brew bundle --file="$repo_root/Brewfile"
fi

zshrc_source="$repo_root/.zshrc"
zshrc_target="$HOME/.zshrc"
if [[ -L "$zshrc_target" && "$(readlink "$zshrc_target")" == "$zshrc_source" ]]; then
  printf '~/.zshrc is already linked.\n'
elif [[ -e "$zshrc_target" || -L "$zshrc_target" ]]; then
  backup="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
  mv "$zshrc_target" "$backup"
  ln -s "$zshrc_source" "$zshrc_target"
  printf 'Backed up the existing ~/.zshrc to %s and created the repository link.\n' "$backup"
else
  ln -s "$zshrc_source" "$zshrc_target"
  printf 'Linked ~/.zshrc to the repository configuration.\n'
fi

printf 'Installation complete. Open a new terminal to load the zsh configuration.\n'
printf 'Karabiner-Elements still requires macOS Accessibility and Input Monitoring permissions.\n'
