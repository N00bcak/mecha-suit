#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH= cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

fail() {
    printf '[fail] %s\n' "$*" >&2
    exit 1
}

pass() {
    printf '[ok] %s\n' "$*"
}

assert_exists() {
    local path="$1"
    [ -e "${path}" ] || fail "expected ${path} to exist"
}

assert_not_exists() {
    local path="$1"
    [ ! -e "${path}" ] && [ ! -L "${path}" ] || fail "expected ${path} to be absent"
}

assert_symlink_to() {
    local link_path="$1"
    local expected_target="$2"
    local actual_target
    [ -L "${link_path}" ] || fail "expected ${link_path} to be a symlink"
    actual_target="$(cd -P "$(dirname "$(readlink "${link_path}")")" 2>/dev/null && pwd -P)/$(basename "$(readlink "${link_path}")")"
    expected_target="$(cd -P "${expected_target}" && pwd -P)"
    actual_target="$(cd -P "${actual_target}" && pwd -P)"
    [ "${actual_target}" = "${expected_target}" ] || fail "expected ${link_path} -> ${expected_target}, got ${actual_target}"
}

syntax_checks() {
    bash -n "${ROOT_DIR}/install.sh"
    bash -n "${ROOT_DIR}/uninstall.sh"
    bash -n "${ROOT_DIR}/test.sh"
    pass "shell syntax"
}

frontmatter_checks() {
    local skill_file
    local folder_name
    local declared_name

    while IFS= read -r skill_file; do
        folder_name="$(basename "$(dirname "${skill_file}")")"
        declared_name="$(awk -F': *' '/^name: / { print $2; exit }' "${skill_file}" | tr -d '"')"
        [ -n "${declared_name}" ] || fail "missing frontmatter name in ${skill_file}"
        [ "${folder_name}" = "${declared_name}" ] || fail "frontmatter name mismatch in ${skill_file}: ${declared_name}"
    done < <(find "${ROOT_DIR}/families" -mindepth 3 -maxdepth 3 -name SKILL.md -print | sort)

    pass "skill frontmatter names"
}

architecture_checks() {
    assert_exists "${ROOT_DIR}/families/routing/task-router/SKILL.md"
    assert_exists "${ROOT_DIR}/families/routing/task-clarifier/SKILL.md"
    assert_exists "${ROOT_DIR}/families/council/interdisciplinary-council/SKILL.md"
    assert_exists "${ROOT_DIR}/families/collaboration/interview-me/SKILL.md"
    assert_exists "${ROOT_DIR}/families/collaboration/product-co-design/SKILL.md"
    assert_not_exists "${ROOT_DIR}/families/orchestration"
    pass "routing, council, and collaboration layout"
}

subagent_boundary_checks() {
    local skill_file

    while IFS= read -r skill_file; do
        case "${skill_file}" in
            */families/council/interdisciplinary-council/SKILL.md)
                continue
                ;;
        esac

        if grep -Eiq 'allowed to use subagents|may use subagents|subagent authority|spawning policy|spawn the fewest' "${skill_file}"; then
            fail "non-council skill appears to authorize subagents: ${skill_file}"
        fi
    done < <(find "${ROOT_DIR}/families" -mindepth 3 -maxdepth 3 -name SKILL.md -print | sort)

    pass "subagent boundaries"
}

persistence_yield_checks() {
    assert_exists "${ROOT_DIR}/shared/rubrics/persistence-yield-rubric.md"
    grep -Eq '^## Council Persistence Contract$' "${ROOT_DIR}/families/council/interdisciplinary-council/SKILL.md" || fail "council persistence contract is missing"
    grep -Eq '^## Persistence And Yield$' "${ROOT_DIR}/templates/leaf-skill.template.md" || fail "leaf template persistence section is missing"
    grep -Eq 'exhausted_bounded_inquiry' "${ROOT_DIR}/families/council/interdisciplinary-council/SKILL.md" || fail "council exhausted inquiry status is missing"
    grep -Eq 'next_distinct_attempt' "${ROOT_DIR}/templates/council-subagent.template.md" || fail "council subagent progress field is missing"
    pass "persistence and yield contract"
}

council_eligibility_checks() {
    local council_file="${ROOT_DIR}/families/council/interdisciplinary-council/SKILL.md"
    local leaf

    grep -Eq '^Currently eligible inherited leaves:$' "${council_file}" || fail "council eligible inherited leaf list is missing"
    for leaf in \
        product-co-design \
        large-codebase-change \
        prototype-builder \
        ctf-triage \
        reverse-ctf \
        pwn-ctf \
        crypto-ctf \
        web-ctf \
        forensics-ctf \
        ai-ctf \
        misc-ctf
    do
        grep -Fq -- "- \`${leaf}\`" "${council_file}" || fail "council eligible leaf is missing: ${leaf}"
    done
    grep -Fq 'Do not inherit from `task-router`, `task-clarifier`, `interview-me`, or any stub' "${council_file}" || fail "council non-specialist exclusion is missing"
    pass "council eligible inherited leaves"
}

collaboration_checks() {
    local interview_file="${ROOT_DIR}/families/collaboration/interview-me/SKILL.md"
    local router_file="${ROOT_DIR}/families/routing/task-router/SKILL.md"

    grep -Fxq 'description: NEVER CALL THIS SKILL.' "${interview_file}" || fail "interview-me manual-only frontmatter guard is missing"
    grep -Fq '`interview-me` is explicit-invocation-only. Never select it through routing.' "${router_file}" || fail "router interview-me exclusion is missing"
    grep -Fq '| Product idea, service, workflow, or experience needs concept shaping' "${router_file}" || fail "product-co-design route is missing"
    pass "collaboration routing boundaries"
}

metadata_policy_checks() {
    grep -Fq 'fully authored CTF specialists' "${ROOT_DIR}/CLAUDE.md" || fail "CLAUDE metadata policy does not mention CTF specialist metadata"
    grep -Fq 'fully authored CTF specialists currently use Codex metadata' "${ROOT_DIR}/README.md" || fail "README metadata policy does not mention CTF specialist metadata"
    grep -Fq 'Collaboration and engineering leaves, and ML stubs, currently rely on frontmatter only.' "${ROOT_DIR}/docs/platform-notes.md" || fail "platform metadata policy is missing"
    pass "metadata policy"
}

stub_skill_checks() {
    local skill_file

    while IFS= read -r skill_file; do
        grep -Eq '^## Persistence And Yield$' "${skill_file}" || fail "persistence section is missing in ${skill_file}"
        if grep -Eq '^## Stub Status$' "${skill_file}"; then
            grep -Fq 'This is a stub. NEVER CALL THIS SKILL.' "${skill_file}" || fail "stub warning is missing in ${skill_file}"
        fi
    done < <(find "${ROOT_DIR}/families/collaboration" "${ROOT_DIR}/families/engineering" "${ROOT_DIR}/families/ctf" "${ROOT_DIR}/families/ml" -mindepth 2 -maxdepth 2 -name SKILL.md -print | sort)

    grep -Eq 'Do not route directly to stub specialist leaves\.' "${ROOT_DIR}/families/routing/task-router/SKILL.md" || fail "router stub guardrail is missing"
    grep -Eq 'Do not use stub specialist leaves as council subagents\.' "${ROOT_DIR}/families/council/interdisciplinary-council/SKILL.md" || fail "council stub guardrail is missing"
    pass "stub guardrails"
}

install_uninstall_checks() {
    local tmp_root
    local unrelated_target

    tmp_root="$(mktemp -d)"
    trap "rm -rf '${tmp_root}'" EXIT

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" >"${tmp_root}/install-all.out"
    assert_symlink_to "${tmp_root}/skills/task-router" "${ROOT_DIR}/families/routing/task-router"
    assert_symlink_to "${tmp_root}/skills/interdisciplinary-council" "${ROOT_DIR}/families/council/interdisciplinary-council"
    assert_symlink_to "${tmp_root}/skills/interview-me" "${ROOT_DIR}/families/collaboration/interview-me"
    assert_symlink_to "${tmp_root}/skills/product-co-design" "${ROOT_DIR}/families/collaboration/product-co-design"

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" >"${tmp_root}/install-all-again.out"
    grep -Eq '\[ok\] task-router already installed' "${tmp_root}/install-all-again.out" || fail "install is not idempotent"

    MECHA_SKILL_ROOT="${tmp_root}/selected" "${ROOT_DIR}/install.sh" task-router >"${tmp_root}/install-selected.out"
    assert_symlink_to "${tmp_root}/selected/task-router" "${ROOT_DIR}/families/routing/task-router"
    assert_not_exists "${tmp_root}/selected/task-clarifier"

    MECHA_SKILL_ROOT="${tmp_root}/selected-collaboration" "${ROOT_DIR}/install.sh" interview-me product-co-design >"${tmp_root}/install-selected-collaboration.out"
    assert_symlink_to "${tmp_root}/selected-collaboration/interview-me" "${ROOT_DIR}/families/collaboration/interview-me"
    assert_symlink_to "${tmp_root}/selected-collaboration/product-co-design" "${ROOT_DIR}/families/collaboration/product-co-design"

    if MECHA_SKILL_ROOT="${tmp_root}/missing" "${ROOT_DIR}/install.sh" not-a-skill >"${tmp_root}/install-missing.out" 2>&1; then
        fail "missing skill install should fail"
    fi
    grep -Eq '\[missing\] not-a-skill is not a skill in this library' "${tmp_root}/install-missing.out" || fail "missing skill output is unclear"

    mkdir -p "${tmp_root}/protected"
    : >"${tmp_root}/protected/task-router"
    MECHA_SKILL_ROOT="${tmp_root}/protected" "${ROOT_DIR}/install.sh" task-router >"${tmp_root}/install-protected-file.out"
    [ ! -L "${tmp_root}/protected/task-router" ] || fail "install overwrote unrelated file"
    grep -Eq '\[skip\].*not managed' "${tmp_root}/install-protected-file.out" || fail "unrelated file protection output is unclear"

    mkdir -p "${tmp_root}/other-target" "${tmp_root}/protected-link"
    ln -s "${tmp_root}/other-target" "${tmp_root}/protected-link/task-router"
    MECHA_SKILL_ROOT="${tmp_root}/protected-link" "${ROOT_DIR}/install.sh" task-router >"${tmp_root}/install-protected-link.out"
    unrelated_target="$(readlink "${tmp_root}/protected-link/task-router")"
    [ "${unrelated_target}" = "${tmp_root}/other-target" ] || fail "install overwrote unrelated symlink"
    grep -Eq '\[skip\].*unrelated symlink' "${tmp_root}/install-protected-link.out" || fail "unrelated symlink protection output is unclear"

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/uninstall.sh" task-router >"${tmp_root}/uninstall-selected.out"
    assert_not_exists "${tmp_root}/skills/task-router"
    assert_symlink_to "${tmp_root}/skills/task-clarifier" "${ROOT_DIR}/families/routing/task-clarifier"

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/uninstall.sh" >"${tmp_root}/uninstall-all.out"
    assert_not_exists "${tmp_root}/skills/task-clarifier"
    assert_not_exists "${tmp_root}/skills/interdisciplinary-council"
    assert_not_exists "${tmp_root}/skills/interview-me"
    assert_not_exists "${tmp_root}/skills/product-co-design"

    MECHA_SKILL_ROOT= CODEX_HOME="${tmp_root}/codex-home" "${ROOT_DIR}/install.sh" task-router >"${tmp_root}/install-codex-home.out"
    assert_symlink_to "${tmp_root}/codex-home/skills/task-router" "${ROOT_DIR}/families/routing/task-router"
    MECHA_SKILL_ROOT= CODEX_HOME="${tmp_root}/codex-home" "${ROOT_DIR}/uninstall.sh" task-router >"${tmp_root}/uninstall-codex-home.out"
    assert_not_exists "${tmp_root}/codex-home/skills/task-router"

    MECHA_SKILL_ROOT= CODEX_HOME= HOME="${tmp_root}/home" "${ROOT_DIR}/install.sh" task-router >"${tmp_root}/install-home-default.out"
    assert_symlink_to "${tmp_root}/home/.codex/skills/task-router" "${ROOT_DIR}/families/routing/task-router"

    pass "install and uninstall behavior"
    rm -rf "${tmp_root}"
    trap - EXIT
}

main() {
    syntax_checks
    frontmatter_checks
    architecture_checks
    subagent_boundary_checks
    persistence_yield_checks
    council_eligibility_checks
    collaboration_checks
    metadata_policy_checks
    stub_skill_checks
    install_uninstall_checks
}

main "$@"
