#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH= cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Install into MECHA_SKILL_ROOT when provided; otherwise use Codex's per-user
# skill root. Keep this Bash-friendly for macOS, Linux, WSL, and Windows Git
# Bash/MSYS/Cygwin shells.
default_skill_root() {
    local user_home

    if [ -n "${CODEX_HOME:-}" ]; then
        printf '%s/skills\n' "${CODEX_HOME}"
        return 0
    fi

    user_home="${HOME:-}"
    case "$(uname -s 2>/dev/null || printf unknown)" in
        MINGW*|MSYS*|CYGWIN*)
            if [ -n "${USERPROFILE:-}" ]; then
                user_home="$(cygpath -u "${USERPROFILE}" 2>/dev/null || printf '%s' "${user_home}")"
            fi
            ;;
    esac

    if [ -z "${user_home}" ]; then
        printf 'MECHA_SKILL_ROOT, CODEX_HOME, or HOME must be set\n' >&2
        return 1
    fi

    printf '%s/.codex/skills\n' "${user_home}"
}

SKILL_ROOT="${MECHA_SKILL_ROOT:-$(default_skill_root)}"
MISSING_COUNT=0

# Skills are discovered by folder shape so adding a new leaf does not require
# maintaining a separate registry.
skill_files() {
    find "${ROOT_DIR}/families" -mindepth 3 -maxdepth 3 -name SKILL.md -print | sort
}

skill_dir_for() {
    local name="$1"
    local skill_file
    while IFS= read -r skill_file; do
        if [ "$(basename "$(dirname "${skill_file}")")" = "${name}" ]; then
            dirname "${skill_file}"
            return 0
        fi
    done < <(skill_files)
    return 1
}

all_skill_names() {
    local skill_file
    while IFS= read -r skill_file; do
        basename "$(dirname "${skill_file}")"
    done < <(skill_files)
}

resolve_dir() {
    local path="$1"
    (cd -P "${path}" && pwd -P)
}

# Resolve symlinks before comparing paths so relative links and physical paths
# are treated consistently.
resolve_symlink_dir() {
    local link_path="$1"
    local raw_target
    local target_path
    raw_target="$(readlink "${link_path}")"
    case "${raw_target}" in
        /*)
            target_path="${raw_target}"
            ;;
        *)
            target_path="$(dirname "${link_path}")/${raw_target}"
            ;;
    esac
    if [ -d "${target_path}" ]; then
        resolve_dir "${target_path}"
        return 0
    fi
    return 1
}

install_skill() {
    local name="$1"
    local source_dir
    local target_path
    local source_real
    local target_real

    if ! source_dir="$(skill_dir_for "${name}")"; then
        printf '[missing] %s is not a skill in this library\n' "${name}"
        # Keep processing other requested names, then exit nonzero at the end.
        MISSING_COUNT=$((MISSING_COUNT + 1))
        return 0
    fi

    mkdir -p "${SKILL_ROOT}"
    target_path="${SKILL_ROOT}/${name}"
    source_real="$(resolve_dir "${source_dir}")"

    if [ -L "${target_path}" ]; then
        if target_real="$(resolve_symlink_dir "${target_path}")" && [ "${target_real}" = "${source_real}" ]; then
            printf '[ok] %s already installed\n' "${name}"
            return 0
        fi
        # Never replace links that the user or another tool may own.
        printf '[skip] %s exists as an unrelated symlink\n' "${target_path}"
        return 0
    fi

    if [ -e "${target_path}" ]; then
        # A real file or directory at the target path is outside our ownership.
        printf '[skip] %s exists and is not managed by this library\n' "${target_path}"
        return 0
    fi

    ln -s "${source_real}" "${target_path}"
    printf '[install] %s -> %s\n' "${name}" "${source_real}"
}

main() {
    local name

    if [ "$#" -eq 0 ]; then
        while IFS= read -r name; do
            install_skill "${name}"
        done < <(all_skill_names)
    else
        for name in "$@"; do
            install_skill "${name}"
        done
    fi

    if [ "${MISSING_COUNT}" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
