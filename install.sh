#!/usr/bin/env bash

set -euo pipefail

readonly REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_SOURCE="${REPO_DIR}/.config"
readonly HOME_SOURCE="${REPO_DIR}/home"
readonly CONFIG_TARGET="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-${HOME}/.dotfiles-backups}"

install_brew=false
install_nvim=false

usage() {
  cat <<EOF
用法: ${REPO_DIR}/install.sh [--brew | --nvim]

将仓库中的配置复制到当前用户目录，并在覆盖前创建可恢复的备份。

选项:
  --brew     另外使用仓库根目录的 Brewfile 安装 Homebrew 软件包
  --nvim     仅更新 ~/.config/nvim
  -h, --help 显示帮助
EOF
}

while (($#)); do
  case "$1" in
    --brew) install_brew=true ;;
    --nvim) install_nvim=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知选项: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ "${install_brew}" == true && "${install_nvim}" == true ]]; then
  printf '错误: --brew 不能与 --nvim 同时使用。\n' >&2
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

if [[ "${install_nvim}" == false ]]; then
  ensure_cargo
  install_tree_sitter_cli
  ensure_uv
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
  "${backup_dir}/.missing/config" \
  "${backup_dir}/.missing/home" \
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

printf '备份目录: %s\n' "${backup_dir}"

if [[ "${install_nvim}" == true ]]; then
  install_directory "${CONFIG_SOURCE}" "${CONFIG_TARGET}" ".config" ".missing/config" "nvim"
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
