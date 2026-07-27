# Completion.
autoload -Uz compinit
compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' list-colors 'di=1;34' 'ln=1;36' 'so=1;35' 'pi=33' 'ex=1;32' 'bd=1;33' 'cd=1;33' 'su=37;41' 'sg=30;43' 'tw=30;42' 'ow=30;43' '*.md=1;36' '*.txt=0;37' '*.log=0;90' '*.json=1;33' '*.ya?ml=1;33' '*.toml=1;33' '*.ini=1;33' '*.conf=1;33' '*.sh=1;32' '*.zsh=1;32' '*.bash=1;32' '*.py=1;32' '*.go=1;32' '*.js=1;32' '*.ts=1;32' '*.tsx=1;32' '*.jsx=1;32' '*.rs=1;32' '*.zip=1;31' '*.tar=1;31' '*.gz=1;31' '*.tgz=1;31' '*.xz=1;31' '*.7z=1;31' '*.rar=1;31' '*.jpg=1;35' '*.jpeg=1;35' '*.png=1;35' '*.gif=1;35' '*.webp=1;35' '*.svg=1;35' '*.mp3=0;35' '*.wav=0;35' '*.mp4=0;35' '*.mov=0;35' '*.mkv=0;35'
zstyle ':completion:*:descriptions' format '[%F{yellow}%d%f]'
zstyle ':completion:*:messages' format '%F{magenta}%d%f'
zstyle ':completion:*:warnings' format '%F{red}no matches for:%f %d'
zstyle ':completion:*:corrections' format '%F{green}%d (errors: %e)%f'
zstyle ':completion:*' group-name ''
zstyle ':fzf-tab:*' fzf-pad 4
zstyle ':fzf-tab:complete:*' fzf-flags --height=55% --layout=reverse --border=rounded --info=inline --prompt='> ' --marker='* ' --pointer='> ' --color=fg:#d0d0d0,fg+:#ffffff,bg+:#243042,hl:#7dcfff,hl+:#ffd580,info:#8bd5ca,prompt:#a6da95,pointer:#ffcc66,marker:#f5a97f,border:#7aa2f7,label:#c6a0f6,header:#91d7e3
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'if command -v eza >/dev/null 2>&1; then eza --all --color=always --icons=always --group-directories-first $realpath; else ls -lah $realpath; fi'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'if command -v eza >/dev/null 2>&1; then eza --all --color=always --icons=always --group-directories-first $realpath; else ls -lah $realpath; fi'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then if command -v eza >/dev/null 2>&1; then eza --all --color=always --icons=always --group-directories-first $realpath; else ls -lah $realpath; fi; else if command -v bat >/dev/null 2>&1; then bat --style=numbers --color=always --line-range=:200 $realpath 2>/dev/null; else sed -n "1,200p" $realpath 2>/dev/null; fi; fi'
