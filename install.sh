#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH= cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Installed global instructions name this checkout so their use-case stubs
# resolve on every host; the template keeps a portable placeholder.
render_global_instructions() {
    local root_escaped
    root_escaped="$(printf '%s' "${ROOT_DIR}" | sed 's/[\\&|]/\\&/g')"
    sed "s|{{MECHA_ROOT}}|${root_escaped}|g" "${ROOT_DIR}/templates/global-AGENTS.template.md"
}

GLOBAL_INSTRUCTIONS_SOURCE="$(mktemp "${TMPDIR:-/tmp}/mecha-global.XXXXXX")"
trap 'rm -f "${GLOBAL_INSTRUCTIONS_SOURCE}"' EXIT
render_global_instructions >"${GLOBAL_INSTRUCTIONS_SOURCE}"

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

claude_home() {
    if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
        printf '%s\n' "${CLAUDE_CONFIG_DIR}"
    else
        printf '%s/.claude\n' "$(user_home)"
    fi
}

SKILL_ROOT="${MECHA_SKILL_ROOT:-$(default_skill_root)}"
CODEX_CONFIG_ROOT="$(codex_home)"
LEGACY_SKILL_ROOT="${CODEX_CONFIG_ROOT}/skills"
CLAUDE_CONFIG_ROOT="$(claude_home)"
CLAUDE_SKILL_ROOT="${CLAUDE_CONFIG_ROOT}/skills"
# Rendered Claude adapters mirror the repository shape so relative runtime
# references such as ../references/ and ../../../shared/ still resolve.
CLAUDE_RENDER_ROOT="${CLAUDE_CONFIG_ROOT}/.mecha-render"
INSTALL_CLAUDE=true
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
    local prefix="${2:-AGENTS}"
    local backup_dir="${ROOT_DIR}/.mecha/backups/global-instructions"
    local timestamp
    local backup_path
    local suffix=0

    timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
    backup_path="${backup_dir}/${prefix}-${timestamp}.md"
    while [ -e "${backup_path}" ]; do
        suffix=$((suffix + 1))
        backup_path="${backup_dir}/${prefix}-${timestamp}-${suffix}.md"
    done

    (umask 077 && mkdir -p "${backup_dir}" && cp "${source_path}" "${backup_path}")
    printf '%s\n' "${backup_path}"
}

# Both hosts get a regular-file copy: Claude Code skips a symlinked
# ~/.claude/CLAUDE.md in some sessions, so links are never used here.
provision_global_instructions() {
    local target_path="$1"
    local prefix="$2"
    local label="$3"
    local backup_path

    # Links from earlier installs that still show the default template are
    # converted without the custom-instructions flag.
    if [ -L "${target_path}" ] && cmp -s "${GLOBAL_INSTRUCTIONS_SOURCE}" "${target_path}"; then
        rm "${target_path}"
        printf '[migrate] %s link replaced with a copy\n' "${label}"
    fi

    if [ ! -e "${target_path}" ] && [ ! -L "${target_path}" ]; then
        mkdir -p "$(dirname "${target_path}")"
        cp "${GLOBAL_INSTRUCTIONS_SOURCE}" "${target_path}"
        printf '[install] %s -> %s\n' "${label}" "${target_path}"
        return 0
    fi

    if [ -f "${target_path}" ] && [ ! -L "${target_path}" ] && [ ! -s "${target_path}" ]; then
        cp "${GLOBAL_INSTRUCTIONS_SOURCE}" "${target_path}"
        printf '[install] %s -> %s\n' "${label}" "${target_path}"
        return 0
    fi

    if [ -f "${target_path}" ] && [ ! -L "${target_path}" ] && cmp -s "${GLOBAL_INSTRUCTIONS_SOURCE}" "${target_path}"; then
        printf '[ok] %s already installed\n' "${label}"
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

    # Back up the content, then remove the path so a link is never written through.
    backup_path="$(backup_global_instructions "${target_path}" "${prefix}")"
    rm "${target_path}"
    cp "${GLOBAL_INSTRUCTIONS_SOURCE}" "${target_path}"
    printf '[replace] %s -> %s\n' "${label}" "${target_path}"
    printf '[backup] previous %s -> %s\n' "${label}" "${backup_path}"
}

# The portable metadata.invocation declaration is inert until a host adapter
# enforces it; read it from frontmatter only.
explicit_invocation() {
    # Accept the forms the validator allows: optional quotes and a trailing comment.
    awk -v q="'" '
        BEGIN { pattern = "^[[:space:]]+invocation:[[:space:]]*[\"" q "]?explicit[\"" q "]?[[:space:]]*(#.*)?$" }
        NR == 1 { next }
        /^---/ { exit }
        $0 ~ pattern { found = 1 }
        END { exit !found }
    ' "$1/SKILL.md"
}

# Render a Claude copy of SKILL.md with host frontmatter; every other entry
# links back to the source so only SKILL.md is regenerated.
render_claude_skill() {
    local source_dir="$1"
    local family_dir
    local render_family
    local rendered
    local entry

    family_dir="$(dirname "${source_dir}")"
    render_family="${CLAUDE_RENDER_ROOT}/families/$(basename "${family_dir}")"
    rendered="${render_family}/$(basename "${source_dir}")"

    mkdir -p "${render_family}"
    ln -sfn "${ROOT_DIR}/shared" "${CLAUDE_RENDER_ROOT}/shared"
    rm -rf "${rendered}"
    mkdir "${rendered}"
    for entry in "${source_dir}"/*; do
        [ "$(basename "${entry}")" = SKILL.md ] || ln -s "${entry}" "${rendered}/$(basename "${entry}")"
    done
    awk '
        NR == 1 { in_frontmatter = 1; print; next }
        in_frontmatter && /^---/ {
            print "disable-model-invocation: true"
            in_frontmatter = 0
        }
        { print }
    ' "${source_dir}/SKILL.md" >"${rendered}/SKILL.md"

    for entry in "${family_dir}"/*; do
        if [ ! -e "${render_family}/$(basename "${entry}")" ] && [ ! -L "${render_family}/$(basename "${entry}")" ]; then
            ln -s "${entry}" "${render_family}/$(basename "${entry}")"
        fi
    done
    printf '%s\n' "${rendered}"
}

managed_link_target() {
    case "$1" in
        "${ROOT_DIR}/families/"*|"${CLAUDE_RENDER_ROOT}/"*|"$(physical_render_root)/"*)
            return 0
            ;;
    esac
    return 1
}

link_skill() {
    local skill_root="$1"
    local link_name="$2"
    local source_real="$3"
    local label="$4"
    local target_path
    local target_real

    mkdir -p "${skill_root}"
    target_path="${skill_root}/${link_name}"

    if [ -L "${target_path}" ]; then
        if target_real="$(resolve_symlink_dir "${target_path}")" && [ "${target_real}" = "${source_real}" ]; then
            printf '[ok] %s already installed\n' "${label}"
            return 0
        fi
        # Links into this checkout or its render tree are ours; repoint them
        # when a skill's explicit status changes. Never replace other links.
        if managed_link_target "$(readlink "${target_path}")"; then
            ln -sfn "${source_real}" "${target_path}"
            printf '[update] %s -> %s\n' "${label}" "${source_real}"
            return 0
        fi
        printf '[skip] %s exists as an unrelated symlink\n' "${target_path}"
        return 0
    fi

    if [ -e "${target_path}" ]; then
        # A real file or directory at the target path is outside our ownership.
        printf '[skip] %s exists and is not managed by this library\n' "${target_path}"
        return 0
    fi

    ln -s "${source_real}" "${target_path}"
    printf '[install] %s -> %s\n' "${label}" "${source_real}"
}

install_skill() {
    local name="$1"
    local source_dir
    local source_real
    local claude_source
    local stale_render

    if ! source_dir="$(skill_dir_for "${name}")"; then
        printf '[missing] %s is not a skill in this library\n' "${name}"
        # Keep processing other requested names, then exit nonzero at the end.
        MISSING_COUNT=$((MISSING_COUNT + 1))
        return 0
    fi

    source_real="$(resolve_dir "${source_dir}")"
    link_skill "${SKILL_ROOT}" "${name}" "${source_real}" "${name}"
    [ "${INSTALL_CLAUDE}" = true ] || return 0

    claude_source="${source_real}"
    if explicit_invocation "${source_real}"; then
        claude_source="$(resolve_dir "$(render_claude_skill "${source_real}")")"
    fi
    link_skill "${CLAUDE_SKILL_ROOT}" "${name}" "${claude_source}" "claude/${name}"

    # A skill that is no longer explicit must not keep a disabled render.
    stale_render="${CLAUDE_RENDER_ROOT}/families/$(basename "$(dirname "${source_real}")")/${name}"
    if [ "${claude_source}" = "${source_real}" ] && [ -d "${stale_render}" ] && [ ! -L "${stale_render}" ]; then
        rm -rf "${stale_render}"
        printf '[prune] %s is no longer explicit\n' "${stale_render}"
    fi
}

# Rendered adapters of removed skills are real directories, so links to them
# never dangle. Remove each render whose source skill is gone first.
prune_stale_renders() {
    local rendered
    local family
    local name

    [ -d "${CLAUDE_RENDER_ROOT}/families" ] || return 0
    for rendered in "${CLAUDE_RENDER_ROOT}"/families/*/*; do
        [ -d "${rendered}" ] && [ ! -L "${rendered}" ] || continue
        family="$(basename "$(dirname "${rendered}")")"
        name="$(basename "${rendered}")"
        if [ ! -f "${ROOT_DIR}/families/${family}/${name}/SKILL.md" ]; then
            rm -rf "${rendered}"
            printf '[prune] %s no longer has a source skill\n' "${rendered}"
        fi
    done
}

# Links store the physical render path, which differs from CLAUDE_RENDER_ROOT
# when the Claude config path contains a symlink.
physical_render_root() {
    local parent
    parent="$(dirname "${CLAUDE_RENDER_ROOT}")"
    if [ -d "${parent}" ]; then
        printf '%s/%s\n' "$(cd "${parent}" && pwd -P)" "$(basename "${CLAUDE_RENDER_ROOT}")"
    else
        printf '%s\n' "${CLAUDE_RENDER_ROOT}"
    fi
}

# Renamed or removed skills leave managed links to paths that no longer exist.
# Remove only dangling links that point into this checkout or its render tree.
prune_stale_links() {
    local skill_root="$1"
    local link_path
    local raw_target
    local render_real

    [ -d "${skill_root}" ] || return 0
    render_real="$(physical_render_root)"
    for link_path in "${skill_root}"/*; do
        [ -L "${link_path}" ] && [ ! -e "${link_path}" ] || continue
        raw_target="$(readlink "${link_path}")"
        case "${raw_target}" in
            "${ROOT_DIR}/families/"*|"${CLAUDE_RENDER_ROOT}/"*|"${render_real}/"*)
                rm "${link_path}"
                printf '[prune] %s -> %s no longer exists\n' "${link_path}" "${raw_target}"
                ;;
        esac
    done
}

main() {
    local name

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --use-custom-global-instructions)
                USE_CUSTOM_GLOBAL_INSTRUCTIONS=true
                ;;
            --no-claude)
                INSTALL_CLAUDE=false
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

    provision_global_instructions "$(global_instructions_path)" AGENTS "global instructions"
    prune_stale_links "${SKILL_ROOT}"
    if [ "${INSTALL_CLAUDE}" = true ]; then
        provision_global_instructions "${CLAUDE_CONFIG_ROOT}/CLAUDE.md" CLAUDE "Claude global instructions"
        prune_stale_renders
        prune_stale_links "${CLAUDE_SKILL_ROOT}"
    fi

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
