# fzf theme and default preview.
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS='
    --height=40%
    --layout=reverse
    --border
    --preview-window=right:50%
    --preview "tree -C {} | head -20"
    --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
    --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
    --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
    --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
  '
fi
