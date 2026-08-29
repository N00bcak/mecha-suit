#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH= cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
GLOBAL_INSTRUCTIONS_SOURCE="${ROOT_DIR}/templates/global-AGENTS.template.md"

# Install into MECHA_SKILL_ROOT when provided; otherwise use the portable
# per-user Agent Skills root. Keep this Bash-friendly for macOS, Linux, WSL,
# and Windows Git Bash/MSYS/Cygwin shells.
user_home() {
    local user_home
    user_home="${HOME:-}"
    case "$(uname -s 2>/dev/null || printf unknown)" in
        MINGW*|MSYS*|CYGWIN*)
            if [ -n "${USERPROFILE:-}" ]; then
                user_home="$(cygpath -u "${USERPROFILE}" 2>/dev/null || printf '%s' "${user_home}")"
            fi
            ;;
    esac

    if [ -z "${user_home}" ]; then
        printf 'MECHA_SKILL_ROOT or HOME must be set\n' >&2
        return 1
    fi

    printf '%s\n' "${user_home}"
}

default_skill_root() {
    printf '%s/.agents/skills\n' "$(user_home)"
}

codex_home() {
    if [ -n "${CODEX_HOME:-}" ]; then
        printf '%s\n' "${CODEX_HOME}"
    else
        printf '%s/.codex\n' "$(user_home)"
    fi
}

SKILL_ROOT="${MECHA_SKILL_ROOT:-$(default_skill_root)}"
CODEX_CONFIG_ROOT="$(codex_home)"
LEGACY_SKILL_ROOT="${CODEX_CONFIG_ROOT}/skills"
MISSING_COUNT=0
USE_CUSTOM_GLOBAL_INSTRUCTIONS=false
REQUESTED_SKILLS=()

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

global_instructions_path() {
    printf '%s/AGENTS.md\n' "${CODEX_CONFIG_ROOT}"
}

managed_legacy_install_exists() {
    local name
    local source_dir
    local target_path
    local source_real
    local target_real

    [ "${SKILL_ROOT}" != "${LEGACY_SKILL_ROOT}" ] || return 1
    while IFS= read -r name; do
        source_dir="$(skill_dir_for "${name}")"
        target_path="${LEGACY_SKILL_ROOT}/${name}"
        [ -L "${target_path}" ] || continue
        source_real="$(resolve_dir "${source_dir}")"
        if target_real="$(resolve_symlink_dir "${target_path}")" && [ "${target_real}" = "${source_real}" ]; then
            return 0
        fi
    done < <(all_skill_names)
    return 1
}

warn_about_legacy_install() {
    if managed_legacy_install_exists; then
        printf '[legacy] managed skill links also exist under %s; Codex may expose duplicate skills\n' "${LEGACY_SKILL_ROOT}"
        printf '[action] MECHA_SKILL_ROOT=%q ./uninstall.sh\n' "${LEGACY_SKILL_ROOT}"
    fi
}

backup_global_instructions() {
    local source_path="$1"
    local backup_dir="${ROOT_DIR}/.mecha/backups/global-instructions"
    local timestamp
    local backup_path
    local suffix=0

    timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
    backup_path="${backup_dir}/AGENTS-${timestamp}.md"
    while [ -e "${backup_path}" ]; do
        suffix=$((suffix + 1))
        backup_path="${backup_dir}/AGENTS-${timestamp}-${suffix}.md"
    done

    (umask 077 && mkdir -p "${backup_dir}" && cp "${source_path}" "${backup_path}")
    printf '%s\n' "${backup_path}"
}

provision_global_instructions() {
    local target_path
    local backup_path

    target_path="$(global_instructions_path)"
    if [ ! -e "${target_path}" ] && [ ! -L "${target_path}" ]; then
        mkdir -p "$(dirname "${target_path}")"
        cp "${GLOBAL_INSTRUCTIONS_SOURCE}" "${target_path}"
        printf '[install] global instructions -> %s\n' "${target_path}"
        return 0
    fi

    if [ -f "${target_path}" ] && [ ! -s "${target_path}" ]; then
        cp "${GLOBAL_INSTRUCTIONS_SOURCE}" "${target_path}"
        printf '[install] global instructions -> %s\n' "${target_path}"
        return 0
    fi

    if [ -f "${target_path}" ] && cmp -s "${GLOBAL_INSTRUCTIONS_SOURCE}" "${target_path}"; then
        printf '[ok] global instructions already installed\n'
        return 0
    fi

    if [ "${USE_CUSTOM_GLOBAL_INSTRUCTIONS}" != true ]; then
        printf '[abort] %s contains non-default global instructions; rerun with --use-custom-global-instructions to back up and replace it\n' "${target_path}" >&2
        return 1
    fi

    if [ ! -f "${target_path}" ]; then
        printf '[abort] %s is not a regular global instruction file\n' "${target_path}" >&2
        return 1
    fi

    backup_path="$(backup_global_instructions "${target_path}")"
    cp "${GLOBAL_INSTRUCTIONS_SOURCE}" "${target_path}"
    printf '[replace] global instructions -> %s\n' "${target_path}"
    printf '[backup] previous global instructions -> %s\n' "${backup_path}"
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

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --use-custom-global-instructions)
                USE_CUSTOM_GLOBAL_INSTRUCTIONS=true
                ;;
            --*)
                printf '[missing] %s is not an install option or skill\n' "$1" >&2
                return 1
                ;;
            *)
                REQUESTED_SKILLS+=("$1")
                ;;
        esac
        shift
    done

    provision_global_instructions

    if [ "${#REQUESTED_SKILLS[@]}" -eq 0 ]; then
        while IFS= read -r name; do
            install_skill "${name}"
        done < <(all_skill_names)
    else
        for name in "${REQUESTED_SKILLS[@]}"; do
            install_skill "${name}"
        done
    fi

    if [ "${MISSING_COUNT}" -gt 0 ]; then
        exit 1
    fi

    warn_about_legacy_install
}

main "$@"
