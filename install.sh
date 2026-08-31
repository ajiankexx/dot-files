#!/usr/bin/env bash

set -euo pipefail

readonly REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_SOURCE="${REPO_DIR}/.config"
readonly HOME_SOURCE="${REPO_DIR}/home"
readonly VSCODE_SOURCE="${REPO_DIR}/vscode"
readonly MAC_CONFIG_SOURCE="${REPO_DIR}/mac-config.sh"
readonly CONFIG_TARGET="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly VSCODE_USER_TARGET="${HOME}/Library/Application Support/Code/User"
readonly BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-${HOME}/.dotfiles-backups}"

install_brew=false
install_nvim=false
install_karabiner=false
install_hammerspoon=false
install_wezterm=false
install_zsh=false
install_home=false
install_vscode=false
install_mac=false

usage() {
  cat <<EOF
用法: ${REPO_DIR}/install.sh [--brew | --nvim | --karabiner | --hammerspoon | --wezterm | --zsh | --vscode | --home | --mac]

将仓库中的配置复制到当前用户目录，并在覆盖前创建可恢复的备份；--mac 用于更新 macOS 用户级配置。

选项:
  --brew     另外使用仓库根目录的 Brewfile 安装 Homebrew 软件包
  --nvim     仅更新 ~/.config/nvim
  --karabiner 仅更新 ~/.config/karabiner
  --hammerspoon 仅更新 ~/.hammerspoon
  --wezterm  仅更新 ~/.config/wezterm
  --zsh      仅更新 ~/.config/zsh 和 ~/.zshrc
  --vscode   仅更新 VS Code 的用户快捷键
  --home     仅更新仓库 home/ 下的全部配置
  --mac      仅更新 macOS 配置
  -h, --help 显示帮助
EOF
}

while (($#)); do
  case "$1" in
    --brew) install_brew=true ;;
    --nvim) install_nvim=true ;;
    --karabiner) install_karabiner=true ;;
    --hammerspoon) install_hammerspoon=true ;;
    --wezterm) install_wezterm=true ;;
    --zsh) install_zsh=true ;;
    --vscode) install_vscode=true ;;
    --home) install_home=true ;;
    --mac) install_mac=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知选项: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ "${install_brew}" == true &&
      ( "${install_nvim}" == true || "${install_karabiner}" == true || "${install_hammerspoon}" == true || "${install_wezterm}" == true || "${install_zsh}" == true || "${install_vscode}" == true || "${install_home}" == true || "${install_mac}" == true ) ]]; then
  printf '错误: --brew 不能与 --nvim、--karabiner、--hammerspoon、--wezterm、--zsh、--vscode、--home 或 --mac 同时使用。\n' >&2
  exit 2
fi

selected_config_count=0
for selected_config in "${install_nvim}" "${install_karabiner}" "${install_hammerspoon}" "${install_wezterm}" "${install_zsh}" "${install_vscode}" "${install_home}" "${install_mac}"; do
  [[ "${selected_config}" == true ]] && ((selected_config_count += 1))
done

if ((selected_config_count > 1)); then
  printf '错误: --nvim、--karabiner、--hammerspoon、--wezterm、--zsh、--vscode、--home 和 --mac 不能同时使用。\n' >&2
  exit 2
fi

if [[ "${REPO_DIR}" == "${CONFIG_TARGET}" ]]; then
  printf '错误: 仓库不能直接位于目标配置目录 %s。\n' "${CONFIG_TARGET}" >&2
  exit 1
fi

ensure_cargo() {
  if command -v cargo >/dev/null 2>&1; then
    printf 'Cargo 已安装: %s\n' "$(command -v cargo)"
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    printf '错误: 未找到 Cargo，也未找到安装 rustup 所需的 curl。\n' >&2
    exit 1
  fi

  printf '未找到 Cargo，正在通过 rustup 安装 Rust 工具链……\n'
  curl https://sh.rustup.rs -sSf | sh
  export PATH="${HOME}/.cargo/bin:${PATH}"

  if ! command -v cargo >/dev/null 2>&1; then
    printf '错误: rustup 执行完成后仍未找到 Cargo。\n' >&2
    exit 1
  fi

  printf 'Cargo 安装完成: %s\n' "$(command -v cargo)"
}

install_tree_sitter_cli() {
  printf '正在安装 tree-sitter-cli……\n'
  cargo install tree-sitter-cli
}

ensure_uv() {
  if command -v uv >/dev/null 2>&1; then
    printf 'uv 已安装: %s\n' "$(command -v uv)"
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    printf '错误: 未找到 uv，也未找到安装 uv 所需的 curl。\n' >&2
    exit 1
  fi

  printf '未找到 uv，正在安装……\n'
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"

  if ! command -v uv >/dev/null 2>&1; then
    printf '错误: uv 安装脚本执行完成后仍未找到 uv。\n' >&2
    exit 1
  fi

  printf 'uv 安装完成: %s\n' "$(command -v uv)"
}

install_mac_config() {
  if [[ ! -f "${MAC_CONFIG_SOURCE}" ]]; then
    printf '错误: 未找到 macOS 配置脚本: %s\n' "${MAC_CONFIG_SOURCE}" >&2
    exit 1
  fi

  bash "${MAC_CONFIG_SOURCE}"
}

if ((selected_config_count == 0)); then
  ensure_cargo
  install_tree_sitter_cli
  ensure_uv
fi

if [[ "${install_mac}" == true ]]; then
  install_mac_config
  printf '\nMac 配置安装完成。\n'
  exit 0
fi

timestamp="$(date '+%Y%m%d-%H%M%S')"
backup_dir="${BACKUP_ROOT}/install-${timestamp}"
suffix=1

while [[ -e "${backup_dir}" ]]; do
  backup_dir="${BACKUP_ROOT}/install-${timestamp}-${suffix}"
  ((suffix += 1))
done

mkdir -p \
  "${backup_dir}/.config" \
  "${backup_dir}/home" \
  "${backup_dir}/vscode" \
  "${backup_dir}/.missing/config" \
  "${backup_dir}/.missing/home" \
  "${backup_dir}/.missing/vscode" \
  "${CONFIG_TARGET}"

copy_item() {
  local source_path="$1"
  local target_path="$2"

  cp -pPR -- "${source_path}" "${target_path}"
}

install_directory() {
  local source_dir="$1"
  local target_dir="$2"
  local backup_subdir="$3"
  local missing_subdir="$4"
  local only_name="${5:-}"
  local source_path name target_path

  [[ -d "${source_dir}" ]] || return 0
  mkdir -p "${target_dir}"

  while IFS= read -r -d '' source_path; do
    name="${source_path##*/}"
    [[ -z "${only_name}" || "${name}" == "${only_name}" ]] || continue
    target_path="${target_dir}/${name}"

    if [[ -e "${target_path}" || -L "${target_path}" ]]; then
      copy_item "${target_path}" "${backup_dir}/${backup_subdir}/${name}"
      rm -rf -- "${target_path}"
      printf '已备份: %s\n' "${target_path}"
    else
      : > "${backup_dir}/${missing_subdir}/${name}"
    fi

    copy_item "${source_path}" "${target_path}"
    printf '已安装: %s\n' "${target_path}"
  done < <(find "${source_dir}" -mindepth 1 -maxdepth 1 -print0)
}

install_vscode_keybindings() {
  local source_path="${VSCODE_SOURCE}/keybindings.json"
  local target_path="${VSCODE_USER_TARGET}/keybindings.json"

  if [[ ! -f "${source_path}" ]]; then
    printf '错误: 未找到 VS Code 快捷键配置: %s\n' "${source_path}" >&2
    exit 1
  fi

  mkdir -p "${VSCODE_USER_TARGET}"
  if [[ -e "${target_path}" || -L "${target_path}" ]]; then
    copy_item "${target_path}" "${backup_dir}/vscode/keybindings.json"
    rm -rf -- "${target_path}"
    printf '已备份: %s\n' "${target_path}"
  else
    : > "${backup_dir}/.missing/vscode/keybindings.json"
  fi

  copy_item "${source_path}" "${target_path}"
  printf '已安装: %s\n' "${target_path}"
}

printf '备份目录: %s\n' "${backup_dir}"

if [[ "${install_nvim}" == true ]]; then
  install_directory "${CONFIG_SOURCE}" "${CONFIG_TARGET}" ".config" ".missing/config" "nvim"
elif [[ "${install_karabiner}" == true ]]; then
  install_directory "${CONFIG_SOURCE}" "${CONFIG_TARGET}" ".config" ".missing/config" "karabiner"
elif [[ "${install_hammerspoon}" == true ]]; then
  install_directory "${HOME_SOURCE}" "${HOME}" "home" ".missing/home" ".hammerspoon"
elif [[ "${install_wezterm}" == true ]]; then
  install_directory "${CONFIG_SOURCE}" "${CONFIG_TARGET}" ".config" ".missing/config" "wezterm"
elif [[ "${install_zsh}" == true ]]; then
  install_directory "${CONFIG_SOURCE}" "${CONFIG_TARGET}" ".config" ".missing/config" "zsh"
  install_directory "${HOME_SOURCE}" "${HOME}" "home" ".missing/home" ".zshrc"
elif [[ "${install_vscode}" == true ]]; then
  install_vscode_keybindings
elif [[ "${install_home}" == true ]]; then
  install_directory "${HOME_SOURCE}" "${HOME}" "home" ".missing/home"
else
  install_directory "${CONFIG_SOURCE}" "${CONFIG_TARGET}" ".config" ".missing/config"
  install_directory "${HOME_SOURCE}" "${HOME}" "home" ".missing/home"
fi

if [[ "${install_brew}" == true ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    printf '错误: 未找到 Homebrew，配置已经安装，但未安装 Brewfile 软件包。\n' >&2
    exit 1
  fi
  brew bundle --file="${REPO_DIR}/Brewfile"
fi

printf '\n安装完成。\n'
printf '如需撤销本次安装，请运行:\n  %q %q\n' \
  "${REPO_DIR}/restore.sh" "${backup_dir}"
