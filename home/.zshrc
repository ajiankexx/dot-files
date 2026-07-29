# Interactive shell configuration.

[[ -o interactive ]] || return

export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"

for file in "$ZSH_CONFIG_DIR"/*.zsh(N); do
  source "$file"
done
