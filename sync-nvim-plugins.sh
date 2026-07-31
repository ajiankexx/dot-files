#!/usr/bin/env bash

set -u -o pipefail

readonly PLUGIN_DIR="${NVIM_PLUGIN_DIR:-${HOME}/nvim-plugin}"

dry_run=false

usage() {
  cat <<EOF
用法: $0 [--dry-run]

将当前 Neovim 配置使用的插件仓库同步到：
  ${PLUGIN_DIR}

选项:
  --dry-run  只显示将执行的操作
  -h, --help 显示帮助

可通过 NVIM_PLUGIN_DIR 修改保存目录。
EOF
}

while (($#)); do
  case "$1" in
    --dry-run) dry_run=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知选项: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

# 此清单来自 require('lazy.core.config').plugins，目录名与 Lazy 插件名一致。
readonly repositories=(
  'Comment.nvim|https://github.com/numToStr/Comment.nvim.git'
  'actions-preview.nvim|https://github.com/aznhe21/actions-preview.nvim.git'
  'auto-save.nvim|https://github.com/Pocco81/auto-save.nvim.git'
  'auto-session|https://github.com/rmagatti/auto-session.git'
  'blink-cmp-avante|https://github.com/Kaiser-Yang/blink-cmp-avante.git'
  'blink-cmp-dictionary|https://github.com/Kaiser-Yang/blink-cmp-dictionary.git'
  'blink-cmp-git|https://github.com/Kaiser-Yang/blink-cmp-git.git'
  'blink-ripgrep.nvim|https://github.com/mikavilpas/blink-ripgrep.nvim.git'
  'blink.cmp|https://github.com/saghen/blink.cmp.git'
  'bufferline.nvim|https://github.com/akinsho/bufferline.nvim.git'
  'catppuccin|https://github.com/catppuccin/nvim.git'
  'colorful-winsep.nvim|https://github.com/nvim-zh/colorful-winsep.nvim.git'
  'conform.nvim|https://github.com/stevearc/conform.nvim.git'
  'copilot-lualine|https://github.com/AndreM222/copilot-lualine.git'
  'flash.nvim|https://github.com/folke/flash.nvim.git'
  'friendly-snippets|https://github.com/rafamadriz/friendly-snippets.git'
  'git-conflict.nvim|https://github.com/akinsho/git-conflict.nvim.git'
  'gitsigns.nvim|https://github.com/lewis6991/gitsigns.nvim.git'
  'guess-indent.nvim|https://github.com/NMAC427/guess-indent.nvim.git'
  'img-clip.nvim|https://github.com/Kaiser-Yang/img-clip.nvim.git'
  'kulala.nvim|https://github.com/mistweaverco/kulala.nvim.git'
  'lazy.nvim|https://github.com/folke/lazy.nvim.git'
  'lspsaga.nvim|https://github.com/nvimdev/lspsaga.nvim.git'
  'lualine.nvim|https://github.com/nvim-lualine/lualine.nvim.git'
  'markdown-preview.nvim|https://github.com/iamcco/markdown-preview.nvim.git'
  'mason-lspconfig.nvim|https://github.com/mason-org/mason-lspconfig.nvim.git'
  'mason.nvim|https://github.com/mason-org/mason.nvim.git'
  'neo-tree.nvim|https://github.com/nvim-neo-tree/neo-tree.nvim.git'
  'noice.nvim|https://github.com/folke/noice.nvim.git'
  'nui.nvim|https://github.com/MunifTanjim/nui.nvim.git'
  'nvim-dap|https://github.com/mfussenegger/nvim-dap.git'
  'nvim-dap-ui|https://github.com/rcarriga/nvim-dap-ui.git'
  'nvim-dap-virtual-text|https://github.com/theHamsta/nvim-dap-virtual-text.git'
  'nvim-highlight-colors|https://github.com/brenoprata10/nvim-highlight-colors.git'
  'nvim-jdtls|https://github.com/mfussenegger/nvim-jdtls.git'
  'nvim-lspconfig|https://github.com/neovim/nvim-lspconfig.git'
  'nvim-nio|https://github.com/nvim-neotest/nvim-nio.git'
  'nvim-notify|https://github.com/rcarriga/nvim-notify.git'
  'nvim-surround|https://github.com/kylechui/nvim-surround.git'
  'nvim-treesitter|https://github.com/nvim-treesitter/nvim-treesitter.git'
  'nvim-treesitter-context|https://github.com/nvim-treesitter/nvim-treesitter-context.git'
  'nvim-treesitter-textobjects|https://github.com/nvim-treesitter/nvim-treesitter-textobjects.git'
  'nvim-ts-autotag|https://github.com/windwp/nvim-ts-autotag.git'
  'nvim-ts-context-commentstring|https://github.com/JoosepAlviste/nvim-ts-context-commentstring.git'
  'nvim-ufo|https://github.com/kevinhwang91/nvim-ufo.git'
  'nvim-web-devicons|https://github.com/nvim-tree/nvim-web-devicons.git'
  'nvim-window-picker|https://github.com/s1n7ax/nvim-window-picker.git'
  'pastify.nvim|https://github.com/ajiankexx/pastify.nvim.git'
  'plenary.nvim|https://github.com/nvim-lua/plenary.nvim.git'
  'promise-async|https://github.com/kevinhwang91/promise-async.git'
  'rainbow-delimiters.nvim|https://github.com/HiPhish/rainbow-delimiters.nvim.git'
  'render-markdown.nvim|https://github.com/MeanderingProgrammer/render-markdown.nvim.git'
  'snacks.nvim|https://github.com/Kaiser-Yang/snacks.nvim.git'
  'todo-comments.nvim|https://github.com/folke/todo-comments.nvim.git'
  'toggleterm.nvim|https://github.com/akinsho/toggleterm.nvim.git'
  'ultimate-autopair.nvim|https://github.com/altermo/ultimate-autopair.nvim.git'
  'vim-markdown-toc|https://github.com/mzlogin/vim-markdown-toc.git'
  'vim-matchup|https://github.com/andymass/vim-matchup.git'
  'which-key.nvim|https://github.com/folke/which-key.nvim.git'
  'win-resizer.nvim|https://github.com/Kaiser-Yang/win-resizer.nvim.git'
  'yanky.nvim|https://github.com/gbprod/yanky.nvim.git'
)

normalize_url() {
  local url="$1"

  case "${url}" in
    git@github.com:*) url="https://github.com/${url#git@github.com:}" ;;
    ssh://git@github.com/*) url="https://github.com/${url#ssh://git@github.com/}" ;;
  esac

  url="${url%.git}"
  printf '%s\n' "${url%/}"
}

sync_repository() {
  local name="$1"
  local url="$2"
  local destination="${PLUGIN_DIR}/${name}"
  local origin_url

  if [[ ! -e "${destination}" ]]; then
    if [[ "${dry_run}" == true ]]; then
      printf '[clone]  %s <- %s\n' "${destination}" "${url}"
      return 0
    fi
    printf '[clone]  %s\n' "${name}"
    git clone --single-branch -- "${url}" "${destination}"
    return $?
  fi

  if [[ ! -d "${destination}/.git" ]]; then
    printf '[error]  %s 已存在，但不是 Git 仓库\n' "${destination}" >&2
    return 1
  fi

  if ! origin_url="$(git -C "${destination}" remote get-url origin 2>/dev/null)"; then
    printf '[error]  %s 没有 origin remote\n' "${destination}" >&2
    return 1
  fi

  if [[ "$(normalize_url "${origin_url}")" != "$(normalize_url "${url}")" ]]; then
    printf '[error]  %s 的 origin 不匹配：%s\n' "${destination}" "${origin_url}" >&2
    return 1
  fi

  if [[ -n "$(git -C "${destination}" status --porcelain)" ]]; then
    printf '[error]  %s 有未提交修改，已跳过\n' "${destination}" >&2
    return 1
  fi

  if [[ "${dry_run}" == true ]]; then
    printf '[update] %s\n' "${destination}"
    return 0
  fi

  printf '[update] %s\n' "${name}"
  git -C "${destination}" pull --ff-only --prune
}

if [[ "${dry_run}" == false ]]; then
  mkdir -p -- "${PLUGIN_DIR}"
fi

succeeded=0
failed=0

for repository in "${repositories[@]}"; do
  name="${repository%%|*}"
  url="${repository#*|}"

  if sync_repository "${name}" "${url}"; then
    ((succeeded += 1))
  else
    ((failed += 1))
  fi
done

printf '\n完成：成功 %d，失败 %d，总计 %d。\n' \
  "${succeeded}" "${failed}" "${#repositories[@]}"

((failed == 0))
