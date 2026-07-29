#!/usr/bin/env bash

set -euo pipefail

readonly REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_SOURCE="${REPO_DIR}/.config"
readonly HOME_SOURCE="${REPO_DIR}/home"
readonly CONFIG_TARGET="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-${HOME}/.dotfiles-backups}"

install_brew=false

usage() {
  cat <<EOF
用法: ${REPO_DIR}/install.sh [--brew]

将仓库中的配置复制到当前用户目录，并在覆盖前创建可恢复的备份。

选项:
  --brew     另外使用仓库根目录的 Brewfile 安装 Homebrew 软件包
  -h, --help 显示帮助
EOF
}

while (($#)); do
  case "$1" in
    --brew) install_brew=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知选项: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ "${REPO_DIR}" == "${CONFIG_TARGET}" ]]; then
  printf '错误: 仓库不能直接位于目标配置目录 %s。\n' "${CONFIG_TARGET}" >&2
  exit 1
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
  local source_path name target_path

  [[ -d "${source_dir}" ]] || return 0

  while IFS= read -r -d '' source_path; do
    name="${source_path##*/}"
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

install_directory "${CONFIG_SOURCE}" "${CONFIG_TARGET}" ".config" ".missing/config"
install_directory "${HOME_SOURCE}" "${HOME}" "home" ".missing/home"

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
