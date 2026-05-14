#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH= cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Uninstall from MECHA_SKILL_ROOT when provided; otherwise use the same
# Codex-first root selection as install.sh.
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

# Skills are discovered by folder shape so uninstall stays aligned with the
# current library without a separate registry.
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

# Resolve symlinks before comparing paths so uninstall only removes links that
# point back into this checkout.
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

uninstall_skill() {
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

    target_path="${SKILL_ROOT}/${name}"
    source_real="$(resolve_dir "${source_dir}")"

    if [ ! -e "${target_path}" ] && [ ! -L "${target_path}" ]; then
        printf '[ok] %s is not installed\n' "${name}"
        return 0
    fi

    if [ ! -L "${target_path}" ]; then
        # Real files or directories are not managed by this harness.
        printf '[skip] %s exists and is not a symlink\n' "${target_path}"
        return 0
    fi

    if target_real="$(resolve_symlink_dir "${target_path}")" && [ "${target_real}" = "${source_real}" ]; then
        rm "${target_path}"
        printf '[remove] %s\n' "${target_path}"
        return 0
    fi

    # A symlink with the right name but a different target belongs to someone
    # else, so leave it in place.
    printf '[skip] %s is not managed by this library\n' "${target_path}"
}

main() {
    local name

    if [ "$#" -eq 0 ]; then
        while IFS= read -r name; do
            uninstall_skill "${name}"
        done < <(all_skill_names)
    else
        for name in "$@"; do
            uninstall_skill "${name}"
        done
    fi

    if [ "${MISSING_COUNT}" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
