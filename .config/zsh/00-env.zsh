# Environment shared by interactive zsh sessions.

export CLICOLOR=1
export LSCOLORS='gxfxcxdxbxegedabagacad'

# Load plain KEY=value pairs from a private local file.  This deliberately does
# not source the file, so its contents are treated as data rather than shell code.
local env_file="$HOME/.config/.env"
if [[ -r "$env_file" ]]; then
  local line name value
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}" # Permit files edited with CRLF line endings.
    [[ -z "${line//[[:space:]]/}" || "$line" == \#* ]] && continue

    name="${line%%=*}"
    value="${line#*=}"
    if [[ "$line" == *=* && "$name" =~ '^[A-Za-z_][A-Za-z0-9_]*$' ]]; then
      export "$name=$value"
    fi
  done < "$env_file"
fi
