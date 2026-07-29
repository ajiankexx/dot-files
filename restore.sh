#!/usr/bin/env bash

set -euo pipefail

readonly REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_TARGET="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-${HOME}/.dotfiles-backups}"

usage() {
  cat <<EOF
用法:
  ${REPO_DIR}/restore.sh [备份目录]
  ${REPO_DIR}/restore.sh --list

不传备份目录时，恢复 ${BACKUP_ROOT} 中最新的安装备份。
EOF
}

list_backups() {
  if [[ ! -d "${BACKUP_ROOT}" ]]; then
    printf '尚无安装备份: %s\n' "${BACKUP_ROOT}"
    return 0
  fi

  find "${BACKUP_ROOT}" \
    -mindepth 1 -maxdepth 1 -type d -name 'install-*' -print | sort
}

latest_backup() {
  local latest

  [[ -d "${BACKUP_ROOT}" ]] || return 1
  latest="$(
    find "${BACKUP_ROOT}" \
      -mindepth 1 -maxdepth 1 -type d -name 'install-*' -print |
      sort |
      tail -n 1
  )"
  [[ -n "${latest}" ]] || return 1
  printf '%s\n' "${latest}"
}

copy_item() {
  local source_path="$1"
  local target_path="$2"

  cp -pPR -- "${source_path}" "${target_path}"
}

restore_existing() {
  local backup_subdir="$1"
  local target_dir="$2"
  local source_path name target_path

  while IFS= read -r -d '' source_path; do
    name="${source_path##*/}"
    target_path="${target_dir}/${name}"
    rm -rf -- "${target_path}"
    copy_item "${source_path}" "${target_path}"
    printf '已恢复: %s\n' "${target_path}"
  done < <(find "${backup_dir}/${backup_subdir}" -mindepth 1 -maxdepth 1 -print0)
}

remove_previously_missing() {
  local missing_subdir="$1"
  local target_dir="$2"
  local marker_path name target_path

  while IFS= read -r -d '' marker_path; do
    name="${marker_path##*/}"
    target_path="${target_dir}/${name}"

    if [[ -e "${target_path}" || -L "${target_path}" ]]; then
      rm -rf -- "${target_path}"
      printf '已移除: %s\n' "${target_path}"
    fi
  done < <(find "${backup_dir}/${missing_subdir}" -mindepth 1 -maxdepth 1 -print0)
}

case "${1:-}" in
  --list)
    list_backups
    exit 0
    ;;
  -h|--help)
    usage
    exit 0
    ;;
esac

if [[ -n "${1:-}" ]]; then
  backup_dir="${1}"
else
  if ! backup_dir="$(latest_backup)"; then
    printf '错误: 在 %s 中找不到安装备份。\n' "${BACKUP_ROOT}" >&2
    exit 1
  fi
fi

if [[ ! -d "${backup_dir}/.config" ||
      ! -d "${backup_dir}/home" ||
      ! -d "${backup_dir}/.missing/config" ||
      ! -d "${backup_dir}/.missing/home" ]]; then
  printf '错误: 不是有效的 dotfiles 安装备份: %s\n' "${backup_dir}" >&2
  exit 1
fi

mkdir -p "${CONFIG_TARGET}"

printf '正在使用备份: %s\n' "${backup_dir}"

restore_existing ".config" "${CONFIG_TARGET}"
restore_existing "home" "${HOME}"
remove_previously_missing ".missing/config" "${CONFIG_TARGET}"
remove_previously_missing ".missing/home" "${HOME}"

printf '\n恢复完成。\n'
