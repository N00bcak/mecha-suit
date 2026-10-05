#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH= cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Uninstall from MECHA_SKILL_ROOT when provided; otherwise use the same
# portable Agent Skills root selection as install.sh.
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

claude_home() {
    if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
        printf '%s\n' "${CLAUDE_CONFIG_DIR}"
    else
        printf '%s/.claude\n' "$(user_home)"
    fi
}

SKILL_ROOT="${MECHA_SKILL_ROOT:-$(default_skill_root)}"
CLAUDE_CONFIG_ROOT="$(claude_home)"
CLAUDE_SKILL_ROOT="${CLAUDE_CONFIG_ROOT}/skills"
CLAUDE_RENDER_ROOT="${CLAUDE_CONFIG_ROOT}/.mecha-render"
UNINSTALL_CLAUDE=true
MISSING_COUNT=0
REQUESTED_SKILLS=()

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

# Remove a link only when it points at the source skill or its rendered adapter.
unlink_skill() {
    local target_path="$1"
    local label="$2"
    local source_real="$3"
    local rendered_path="${4:-}"
    local target_real

    if [ ! -e "${target_path}" ] && [ ! -L "${target_path}" ]; then
        printf '[ok] %s is not installed\n' "${label}"
        return 0
    fi

    if [ ! -L "${target_path}" ]; then
        # Real files or directories are not managed by this harness.
        printf '[skip] %s exists and is not a symlink\n' "${target_path}"
        return 0
    fi

    if target_real="$(resolve_symlink_dir "${target_path}")"; then
        if [ "${target_real}" = "${source_real}" ] || { [ -n "${rendered_path}" ] && [ -d "${rendered_path}" ] && [ "${target_real}" = "$(resolve_dir "${rendered_path}")" ]; }; then
            rm "${target_path}"
            printf '[remove] %s\n' "${target_path}"
            return 0
        fi
    fi

    # A symlink with the right name but a different target belongs to someone
    # else, so leave it in place.
    printf '[skip] %s is not managed by this library\n' "${target_path}"
}

uninstall_skill() {
    local name="$1"
    local source_dir
    local source_real
    local rendered_path

    if ! source_dir="$(skill_dir_for "${name}")"; then
        printf '[missing] %s is not a skill in this library\n' "${name}"
        # Keep processing other requested names, then exit nonzero at the end.
        MISSING_COUNT=$((MISSING_COUNT + 1))
        return 0
    fi

    source_real="$(resolve_dir "${source_dir}")"
    unlink_skill "${SKILL_ROOT}/${name}" "${name}" "${source_real}"
    [ "${UNINSTALL_CLAUDE}" = true ] || return 0

    rendered_path="${CLAUDE_RENDER_ROOT}/families/$(basename "$(dirname "${source_real}")")/${name}"
    unlink_skill "${CLAUDE_SKILL_ROOT}/${name}" "claude/${name}" "${source_real}" "${rendered_path}"
    if [ -d "${rendered_path}" ] && [ ! -L "${rendered_path}" ]; then
        rm -rf "${rendered_path}"
    fi
}

# Renamed or removed skills leave managed links that no current skill name
# matches. Remove only dangling links that point into this checkout or its render tree.
prune_stale_links() {
    local skill_root="$1"
    local link_path
    local raw_target

    [ -d "${skill_root}" ] || return 0
    for link_path in "${skill_root}"/*; do
        [ -L "${link_path}" ] && [ ! -e "${link_path}" ] || continue
        raw_target="$(readlink "${link_path}")"
        case "${raw_target}" in
            "${ROOT_DIR}/families/"*|"${CLAUDE_RENDER_ROOT}/"*)
                rm "${link_path}"
                printf '[prune] %s -> %s no longer exists\n' "${link_path}" "${raw_target}"
                ;;
        esac
    done
}

# Full uninstall also removes the Claude instruction link and render tree, but
# only when they belong to this checkout.
uninstall_claude_shared() {
    local instructions="${CLAUDE_CONFIG_ROOT}/CLAUDE.md"

    # Remove the default copy, or a link left by an earlier installer; keep
    # anything the user customized.
    if { [ -L "${instructions}" ] && [ "$(readlink "${instructions}")" = "$(codex_home)/AGENTS.md" ]; } \
        || { [ -f "${instructions}" ] && [ ! -L "${instructions}" ] && cmp -s "${ROOT_DIR}/templates/global-AGENTS.template.md" "${instructions}"; }; then
        rm "${instructions}"
        printf '[remove] %s\n' "${instructions}"
    fi
    if [ -L "${CLAUDE_RENDER_ROOT}/shared" ] && [ "$(readlink "${CLAUDE_RENDER_ROOT}/shared")" = "${ROOT_DIR}/shared" ]; then
        rm -rf "${CLAUDE_RENDER_ROOT}"
        printf '[remove] %s\n' "${CLAUDE_RENDER_ROOT}"
    fi
}

main() {
    local name

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --no-claude)
                UNINSTALL_CLAUDE=false
                ;;
            --*)
                printf '[missing] %s is not an uninstall option or skill\n' "$1" >&2
                return 1
                ;;
            *)
                REQUESTED_SKILLS+=("$1")
                ;;
        esac
        shift
    done

    if [ "${#REQUESTED_SKILLS[@]}" -eq 0 ]; then
        while IFS= read -r name; do
            uninstall_skill "${name}"
        done < <(all_skill_names)
        prune_stale_links "${SKILL_ROOT}"
        if [ "${UNINSTALL_CLAUDE}" = true ]; then
            prune_stale_links "${CLAUDE_SKILL_ROOT}"
            uninstall_claude_shared
        fi
    else
        for name in "${REQUESTED_SKILLS[@]}"; do
            uninstall_skill "${name}"
        done
    fi

    if [ "${MISSING_COUNT}" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
