# Homebrew tools for non-login shells.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

# Path.
export PATH="$HOME/.bun/bin:$PATH"

# WezTerm is installed in Downloads, so expose the CLI bundled with the app.
# Update this path if the app is moved or replaced with a newer release.
WEZTERM_APP="$HOME/Downloads/WezTerm-macos-20240203-110809-5046fc22/WezTerm.app"
if [[ -x "$WEZTERM_APP/Contents/MacOS/wezterm" ]]; then
  export PATH="$WEZTERM_APP/Contents/MacOS:$PATH"
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
