#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH= cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DEV_PYTHON="${ROOT_DIR}/.venv/bin/python"

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

development_environment_checks() {
    if [ ! -x "${DEV_PYTHON}" ]; then
        fail "development environment is missing; run 'uv sync --dev'"
    fi
    "${DEV_PYTHON}" "${ROOT_DIR}/scripts/validate_skills.py"
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
    assert_exists "${ROOT_DIR}/families/collaboration/interview-me/SKILL.md"
    assert_exists "${ROOT_DIR}/families/collaboration/low-friction-collaboration/SKILL.md"
    assert_exists "${ROOT_DIR}/families/collaboration/parallel-subagents/SKILL.md"
    assert_exists "${ROOT_DIR}/families/collaboration/product-co-design/SKILL.md"
    assert_exists "${ROOT_DIR}/families/collaboration/second-opinion/SKILL.md"
    assert_exists "${ROOT_DIR}/families/collaboration/product-research/SKILL.md"
    assert_exists "${ROOT_DIR}/families/collaboration/domain-modeling/SKILL.md"
    assert_exists "${ROOT_DIR}/families/collaboration/decision-mapping/SKILL.md"
    assert_exists "${ROOT_DIR}/families/collaboration/portable-handoff/SKILL.md"
    assert_exists "${ROOT_DIR}/families/engineering/technical-research/SKILL.md"
    assert_exists "${ROOT_DIR}/families/engineering/implementation-spec/SKILL.md"
    assert_exists "${ROOT_DIR}/families/engineering/work-slicing/SKILL.md"
    assert_exists "${ROOT_DIR}/families/engineering/diagnosing-bugs/SKILL.md"
    assert_exists "${ROOT_DIR}/families/engineering/code-review/SKILL.md"
    assert_exists "${ROOT_DIR}/families/ai/ai-pipeline/SKILL.md"
    assert_exists "${ROOT_DIR}/families/writing/humanizer/SKILL.md"
    assert_exists "${ROOT_DIR}/families/writing/blogpost-writing/SKILL.md"
    assert_not_exists "${ROOT_DIR}/families/ml"
    assert_not_exists "${ROOT_DIR}/families/council"
    assert_not_exists "${ROOT_DIR}/families/routing"
    assert_not_exists "${ROOT_DIR}/families/orchestration"
    pass "native selection and family layout"
}

subagent_boundary_checks() {
    local skill_file
    local parallel="${ROOT_DIR}/families/collaboration/parallel-subagents/SKILL.md"
    local second_opinion="${ROOT_DIR}/families/collaboration/second-opinion/SKILL.md"
    local examples="${ROOT_DIR}/shared/examples/skill-selection-examples.md"

    while IFS= read -r skill_file; do
        if [ "${skill_file}" != "${parallel}" ] && \
           [ "${skill_file}" != "${second_opinion}" ] && \
           grep -Eiq 'allowed to use subagents|may use subagents|subagent authority|spawning policy|spawn the fewest|spawn exactly|authorize subagent use|run two or more independent subtasks concurrently|obtain one independent critique' "${skill_file}"; then
            fail "active skill appears to authorize subagents: ${skill_file}"
        fi
    done < <(find "${ROOT_DIR}/families" -mindepth 3 -maxdepth 3 -name SKILL.md -print | sort)

    grep -Fq 'The main process returns the integrated outcome' "${parallel}" || fail "parallel-subagents main-process ownership is missing"
    grep -Fq 'Subagents must not spawn or request subagents.' "${parallel}" || fail "parallel-subagents nested delegation prohibition is missing"
    grep -Fq 'Require each subagent to return:' "${parallel}" || fail "parallel-subagents structured evidence return is missing"
    grep -Fq 'independent artifact or change surface' "${parallel}" || fail "parallel-subagents independence boundary is missing"
    grep -Fq 'distinct owner and non-overlapping boundary' "${parallel}" || fail "parallel-subagents ownership boundary is missing"

    grep -Fq 'The main process reports whether it accepted, rejected, or qualified' "${second_opinion}" || fail "second-opinion adjudication is missing"
    grep -Fq 'Subagents must not spawn or request subagents.' "${second_opinion}" || fail "second-opinion nested delegation prohibition is missing"
    grep -Fq 'Require the reviewer to return:' "${second_opinion}" || fail "second-opinion structured evidence return is missing"
    grep -Fq 'non-leading' "${second_opinion}" || fail "second-opinion non-leading review packet is missing"

    grep -Fq 'Check that the host exposes subagent capability.' "${parallel}" || fail "parallel-subagents host capability check is missing"
    grep -Fq 'Check that the host exposes subagent capability.' "${second_opinion}" || fail "second-opinion host capability check is missing"
    grep -Fq 'Update the independent Python and TypeScript packages in parallel' "${examples}" || fail "polyglot parallel selection example is missing"
    grep -Fq 'Research these two unrelated source sets' "${examples}" || fail "independent research selection example is missing"
    grep -Fq 'Independently review this production migration plan' "${examples}" || fail "non-leading review selection example is missing"
    grep -Fq 'Run the migration first, then update callers based on its output' "${examples}" || fail "sequential refusal selection example is missing"

    pass "subagent allowlist and contracts"
}

persistence_yield_checks() {
    assert_exists "${ROOT_DIR}/shared/rubrics/persistence-yield-rubric.md"
    pass "persistence and yield contract"
}

interaction_contract_checks() {
    local task_template="${ROOT_DIR}/templates/task-skill.template.md"
    local overlay_template="${ROOT_DIR}/templates/session-overlay.template.md"
    local loop_template="${ROOT_DIR}/templates/interactive-loop.template.md"
    local skill_file
    local skill_name
    local metadata
    local heading
    local overlay_count=0
    local loop_count=0
    local is_overlay
    local is_loop

    assert_not_exists "${ROOT_DIR}/templates/leaf-skill.template.md"
    assert_exists "${task_template}"
    assert_exists "${overlay_template}"
    assert_exists "${loop_template}"

    for template in "${task_template}" "${overlay_template}" "${loop_template}"; do
        for heading in Purpose 'Use When' 'Do Not Use' Needs Returns 'Done Conditions' 'Persistence And Yield'; do
            grep -Fxq "## ${heading}" "${template}" || fail "${template} is missing ${heading}"
        done
    done
    grep -Fxq '## Session Overlay Contract' "${overlay_template}" || fail "session overlay template marker is missing"
    grep -Fxq '## Interactive Loop Contract' "${loop_template}" || fail "interactive loop template marker is missing"

    if grep -R -Eq '^## (Stub Status|Designer Notes|Future Workflow Outline)$' "${ROOT_DIR}/families"; then
        fail "obsolete skill-development sections remain in runtime skills"
    fi
    while IFS= read -r skill_file; do
        skill_name="$(basename "$(dirname "${skill_file}")")"
        is_overlay=0
        is_loop=0
        grep -Fxq '## Session Overlay Contract' "${skill_file}" && is_overlay=1
        grep -Fxq '## Interactive Loop Contract' "${skill_file}" && is_loop=1
        [ $((is_overlay + is_loop)) -le 1 ] || fail "skill declares multiple interaction contracts: ${skill_file}"

        for heading in Purpose 'Use When' 'Do Not Use' Needs Returns 'Done Conditions' 'Persistence And Yield'; do
            grep -Fxq "## ${heading}" "${skill_file}" || fail "${skill_file} is missing core section ${heading}"
        done

        if [ "${is_overlay}" -eq 1 ] || [ "${is_loop}" -eq 1 ]; then
            metadata="$(dirname "${skill_file}")/agents/openai.yaml"
            assert_exists "${metadata}"
            grep -Fq 'allow_implicit_invocation: false' "${metadata}" || fail "explicit interaction mode is implicitly invocable: ${skill_file}"
            grep -Fq "\$${skill_name}" "${metadata}" || fail "explicit interaction metadata does not name ${skill_name}"
        fi

        if [ "${is_overlay}" -eq 1 ]; then
            overlay_count=$((overlay_count + 1))
        fi
        if [ "${is_loop}" -eq 1 ]; then
            loop_count=$((loop_count + 1))
        fi
    done < <(find "${ROOT_DIR}/families" -mindepth 3 -maxdepth 3 -name SKILL.md -print | sort)

    [ "${overlay_count}" -eq 1 ] || fail "expected one session overlay, found ${overlay_count}"
    [ "${loop_count}" -eq 2 ] || fail "expected two interactive loops, found ${loop_count}"
    grep -Fxq '## Session Overlay Contract' "${ROOT_DIR}/families/collaboration/low-friction-collaboration/SKILL.md" || fail "low-friction collaboration is not the session overlay"
    grep -Fxq '## Interactive Loop Contract' "${ROOT_DIR}/families/collaboration/interview-me/SKILL.md" || fail "interview-me is not an interactive loop"
    grep -Fxq '## Interactive Loop Contract' "${ROOT_DIR}/families/collaboration/product-co-design/SKILL.md" || fail "product-co-design is not an interactive loop"

    pass "task, session-overlay, and interactive-loop contracts"
}

collaboration_checks() {
    local interview_file="${ROOT_DIR}/families/collaboration/interview-me/SKILL.md"
    local interview_metadata="${ROOT_DIR}/families/collaboration/interview-me/agents/openai.yaml"
    local low_friction_file="${ROOT_DIR}/families/collaboration/low-friction-collaboration/SKILL.md"
    local low_friction_metadata="${ROOT_DIR}/families/collaboration/low-friction-collaboration/agents/openai.yaml"
    local low_friction_reference="${ROOT_DIR}/families/collaboration/low-friction-collaboration/references/communication-evidence.md"
    local parallel="${ROOT_DIR}/families/collaboration/parallel-subagents/SKILL.md"
    local second_opinion="${ROOT_DIR}/families/collaboration/second-opinion/SKILL.md"
    local product_research="${ROOT_DIR}/families/collaboration/product-research/SKILL.md"
    local domain_modeling="${ROOT_DIR}/families/collaboration/domain-modeling/SKILL.md"
    local decision_mapping="${ROOT_DIR}/families/collaboration/decision-mapping/SKILL.md"
    local portable_handoff="${ROOT_DIR}/families/collaboration/portable-handoff/SKILL.md"
    local product_co_design="${ROOT_DIR}/families/collaboration/product-co-design/SKILL.md"
    local product_co_design_metadata="${ROOT_DIR}/families/collaboration/product-co-design/agents/openai.yaml"

    grep -Fxq 'description: Interview the user one focused question at a time.' "${interview_file}" || fail "interview-me description is missing"
    assert_exists "${interview_metadata}"
    grep -Fq 'allow_implicit_invocation: false' "${interview_metadata}" || fail "interview-me implicit invocation is not disabled"
    grep -Fxq 'description: Make complex technical conversations easy to follow and act on without reducing reasoning depth or precision.' "${low_friction_file}" || fail "low-friction-collaboration description drifted"
    assert_exists "${low_friction_reference}"
    assert_exists "${low_friction_metadata}"
    grep -Fq 'allow_implicit_invocation: false' "${low_friction_metadata}" || fail "low-friction collaboration implicit invocation is not disabled"
    assert_exists "${product_co_design_metadata}"
    grep -Fq 'allow_implicit_invocation: false' "${product_co_design_metadata}" || fail "product co-design implicit invocation is not disabled"
    grep -Fq 'Keep at most one interactive loop active.' "${product_co_design}" || fail "product co-design exclusive-loop contract is missing"
    grep -Fq 'Think as thoroughly as the task requires before writing.' "${low_friction_file}" || fail "low-friction reasoning safeguard is missing"
    grep -Fq "Prefer the words the user used" "${low_friction_file}" || fail "low-friction vocabulary continuity is missing"
    grep -Fq 'Do not coin labels, frameworks, categories, or slogans' "${low_friction_file}" || fail "low-friction invented-term guard is missing"
    grep -Fq 'Use prose for an argument.' "${low_friction_file}" || fail "low-friction discursive prose guidance is missing"
    grep -Fq 'Restore this state after interruptions' "${low_friction_file}" || fail "low-friction continuity guidance is missing"
    grep -Fq 'Do not impose an arbitrary item limit' "${low_friction_file}" || fail "low-friction list discipline is missing"
    grep -Fq '## Edit The Language' "${low_friction_file}" || fail "low-friction Orwell editing guidance is missing"
    grep -Fq 'Do not use, spawn, request, or rely on subagents.' "${low_friction_file}" || fail "low-friction subagent boundary is missing"
    grep -Fxq 'description: Delegate independent bounded subtasks concurrently and integrate their evidence into one verified outcome.' "${parallel}" || fail "parallel-subagents description drifted"
    grep -Fxq 'description: Obtain an independent evidence-backed critique of a consequential conclusion, diagnosis, plan, or diff.' "${second_opinion}" || fail "second-opinion description drifted"
    grep -Fxq 'description: Develop evidence-backed findings about users, workflows, terminology, alternatives, and product or domain assumptions.' "${product_research}" || fail "product-research description drifted"
    grep -Fxq 'description: Sharpen domain terminology and record durable decisions against concrete scenarios, existing code, and evidence.' "${domain_modeling}" || fail "domain-modeling description drifted"
    grep -Fxq 'description: Map and resolve decisions blocking a long-horizon effort until its destination is ready for implementation specification.' "${decision_mapping}" || fail "decision-mapping description drifted"
    grep -Fxq 'description: Package verified work state into a redacted portable handoff for another session, machine, agent, or collaborator.' "${portable_handoff}" || fail "portable-handoff description drifted"
    assert_not_exists "${ROOT_DIR}/families/collaboration/parallel-subagents/agents/openai.yaml"
    assert_not_exists "${ROOT_DIR}/families/collaboration/second-opinion/agents/openai.yaml"
    assert_not_exists "${ROOT_DIR}/families/collaboration/product-research/agents/openai.yaml"
    assert_not_exists "${ROOT_DIR}/families/collaboration/domain-modeling/agents/openai.yaml"
    assert_not_exists "${ROOT_DIR}/families/collaboration/decision-mapping/agents/openai.yaml"
    assert_not_exists "${ROOT_DIR}/families/collaboration/portable-handoff/agents/openai.yaml"
    if grep -Eiq 'use (this skill )?(for|on) every message|the reader has ADHD|ADHD brain' "${low_friction_file}"; then
        fail "low-friction skill contains universal or diagnostic routing"
    fi
    pass "collaboration routing boundaries"
}

engineering_checks() {
    local family_dir="${ROOT_DIR}/families/engineering"
    local large_skill="${family_dir}/large-codebase-change/SKILL.md"
    local prototype_skill="${family_dir}/prototype-builder/SKILL.md"
    local technical_research="${family_dir}/technical-research/SKILL.md"
    local implementation_spec="${family_dir}/implementation-spec/SKILL.md"
    local work_slicing="${family_dir}/work-slicing/SKILL.md"
    local diagnosing_bugs="${family_dir}/diagnosing-bugs/SKILL.md"
    local code_review="${family_dir}/code-review/SKILL.md"
    local reference

    grep -Fxq 'description: Implement PR-ready changes in codebases above roughly 5kLoC with idiomatic, anti-bloat, and verification discipline.' "${large_skill}" || fail "large-codebase-change description drifted"
    grep -Fxq 'description: Build and verify isolated greenfield prototypes, demos, tools, or apps around one core outcome.' "${prototype_skill}" || fail "prototype-builder description drifted"
    grep -Fxq 'description: Resolve software and architecture questions through primary technical sources, repository evidence, and reproducible checks.' "${technical_research}" || fail "technical-research description drifted"
    grep -Fxq 'description: Turn settled intent and evidence into an accepted implementation contract with criteria, constraints, and non-goals.' "${implementation_spec}" || fail "implementation-spec description drifted"
    grep -Fxq 'description: Decompose an accepted implementation contract into verifiable vertical slices with explicit dependency edges.' "${work_slicing}" || fail "work-slicing description drifted"
    grep -Fxq 'description: Diagnose difficult bugs and regressions through a tight reproducer, falsifiable hypotheses, and regression evidence.' "${diagnosing_bugs}" || fail "diagnosing-bugs description drifted"
    grep -Fxq 'description: Review changes for intent fidelity, behavioral correctness and evidence, and maintainability against a fixed point.' "${code_review}" || fail "code-review description drifted"

    if grep -REiq '1''kLoC|~1''k|under about 1''k|past ~1''k' "${family_dir}"; then
        fail "obsolete prototype line-count trigger remains"
    fi

    assert_exists "${ROOT_DIR}/shared/rubrics/change-discipline.md"
    grep -Fq '`../../../shared/rubrics/change-discipline.md`' "${large_skill}" || fail "large-codebase-change does not link shared change discipline"
    grep -Fq '`../../../shared/rubrics/change-discipline.md`' "${prototype_skill}" || fail "prototype-builder does not link shared change discipline"

    for reference in \
        session-continuity.md \
        python-practices.md \
        typescript-practices.md \
        go-practices.md \
        rust-practices.md \
        systems-c-cpp-practices.md \
        java-jvm-practices.md
    do
        assert_exists "${family_dir}/references/${reference}"
        grep -Fq "\`../references/${reference}\`" "${large_skill}" || fail "large-codebase-change does not link shared ${reference}"
        grep -Fq "\`../references/${reference}\`" "${prototype_skill}" || fail "prototype-builder does not link shared ${reference}"
    done

    for reference in behavior-first-development.md design-decision-discipline.md; do
        assert_exists "${family_dir}/references/${reference}"
        grep -Fq "\`../references/${reference}\`" "${large_skill}" || fail "large-codebase-change does not link shared ${reference}"
    done

    grep -Fq 'Do not create a new scratchpad' "${family_dir}/references/session-continuity.md" || fail "legacy scratchpad boundary drifted"
    grep -Fq '`../../../shared/rubrics/lifecycle-contract.md`' "${large_skill}" || fail "large-codebase-change lifecycle contract is missing"
    grep -Fq '`../../../shared/rubrics/lifecycle-contract.md`' "${prototype_skill}" || fail "prototype-builder lifecycle contract is missing"
    grep -Fq '`../references/behavior-first-development.md`' "${large_skill}" || fail "large-codebase-change behavior-first guidance is missing"
    grep -Fq '`../references/design-decision-discipline.md`' "${large_skill}" || fail "large-codebase-change design guidance is missing"
    grep -Fq '### Phase 5: Mandatory Compression Review' "${large_skill}" || fail "large-codebase-change compression review is missing"
    grep -Fq 'Do not create or switch branches, commit, push, or open a pull request' "${large_skill}" || fail "PR-ready Git publication boundary is missing"

    for reference in \
        code-correctness.md \
        complexity-and-optimality.md \
        refactoring-patterns.md \
        software-principles.md
    do
        assert_not_exists "${family_dir}/large-codebase-change/references/${reference}"
    done
    assert_not_exists "${family_dir}/large-codebase-change/references/session-continuity.md"
    assert_not_exists "${family_dir}/prototype-builder/references/session-continuity.md"

    for skill_file in "${technical_research}" "${implementation_spec}" "${work_slicing}" "${diagnosing_bugs}" "${code_review}"; do
        assert_not_exists "$(dirname "${skill_file}")/agents/openai.yaml"
    done

    pass "engineering routing and shared references"
}

lifecycle_checks() {
    local contract="${ROOT_DIR}/shared/rubrics/lifecycle-contract.md"
    local template="${ROOT_DIR}/templates/work-index.template.md"
    local examples="${ROOT_DIR}/shared/examples/skill-selection-examples.md"
    local skill_file

    assert_exists "${contract}"
    assert_exists "${ROOT_DIR}/shared/rubrics/research-integrity.md"
    assert_exists "${template}"
    grep -Fq '`continuity`' "${contract}" || fail "continuity mode is missing"
    grep -Fq '`lifecycle`' "${contract}" || fail "lifecycle mode is missing"
    grep -Fq 'A semantic change requires explicit user authorization.' "${contract}" || fail "intent authority is missing"
    grep -Fq 'Skill selection alone is not permission to create durable state.' "${contract}" || fail "implicit lifecycle mutation boundary is missing"
    grep -Fq 'Ad-Hoc Compatibility' "${contract}" || fail "ad-hoc compatibility is missing"
    grep -Fq 'three-axis code review' "${contract}" || fail "lifecycle review gate is missing"
    grep -Fq 'supersession note' "${contract}" || fail "legacy scratchpad supersession rule is missing"
    grep -Fq '## Acceptance Criteria' "${template}" || fail "work-index acceptance criteria are missing"
    grep -Fq 'Review fixed point:' "${template}" || fail "work-index review fixed point is missing"
    grep -Fq 'Resume candidates:' "${template}" || fail "work-index resume candidates are missing"
    grep -Fq '## Revision History' "${template}" || fail "work-index revision history is missing"
    grep -Fq '.mecha/' "${ROOT_DIR}/.gitignore" || fail ".mecha ignore rule is missing"

    for skill_file in \
        "${ROOT_DIR}/families/collaboration/interview-me/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/low-friction-collaboration/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/parallel-subagents/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/product-co-design/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/product-research/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/domain-modeling/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/decision-mapping/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/portable-handoff/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/second-opinion/SKILL.md" \
        "${ROOT_DIR}/families/engineering/technical-research/SKILL.md" \
        "${ROOT_DIR}/families/engineering/implementation-spec/SKILL.md" \
        "${ROOT_DIR}/families/engineering/work-slicing/SKILL.md" \
        "${ROOT_DIR}/families/engineering/large-codebase-change/SKILL.md" \
        "${ROOT_DIR}/families/engineering/prototype-builder/SKILL.md" \
        "${ROOT_DIR}/families/engineering/diagnosing-bugs/SKILL.md" \
        "${ROOT_DIR}/families/engineering/code-review/SKILL.md"
    do
        grep -Fq 'lifecycle-contract.md' "${skill_file}" || fail "lifecycle contract link is missing in ${skill_file}"
    done

    if grep -R -Fq 'matching lifecycle record' "${ROOT_DIR}/families/collaboration" "${ROOT_DIR}/families/engineering"; then
        fail "work-record participation is incorrectly limited to lifecycle mode"
    fi

    for skill_file in \
        "${ROOT_DIR}/families/collaboration/product-research/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/domain-modeling/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/decision-mapping/SKILL.md" \
        "${ROOT_DIR}/families/collaboration/portable-handoff/SKILL.md" \
        "${ROOT_DIR}/families/engineering/technical-research/SKILL.md" \
        "${ROOT_DIR}/families/engineering/implementation-spec/SKILL.md" \
        "${ROOT_DIR}/families/engineering/work-slicing/SKILL.md" \
        "${ROOT_DIR}/families/engineering/diagnosing-bugs/SKILL.md" \
        "${ROOT_DIR}/families/engineering/code-review/SKILL.md"
    do
        grep -Fq 'Do not spawn, request, or rely on subagents.' "${skill_file}" || fail "new leaf subagent prohibition is missing in ${skill_file}"
        grep -Fq 'Persistence And Yield' "${skill_file}" || fail "new leaf persistence contract is missing in ${skill_file}"
    done

    grep -Fq '`../../../shared/rubrics/research-integrity.md`' "${ROOT_DIR}/families/collaboration/product-research/SKILL.md" || fail "product research integrity link is missing"
    grep -Fq '`../../../shared/rubrics/research-integrity.md`' "${ROOT_DIR}/families/engineering/technical-research/SKILL.md" || fail "technical research integrity link is missing"
    grep -Fq 'Implicit selection alone does not authorize filesystem writes' "${ROOT_DIR}/families/collaboration/decision-mapping/SKILL.md" || fail "decision-mapping persistence boundary is missing"
    grep -Fq 'A candidate is not activation authority' "${contract}" || fail "resume candidate authority boundary is missing"
    grep -Fq 'unfinished candidate loop' "${contract}" || fail "blocking loop resume behavior is missing"
    grep -Fq 'candidates without blocking otherwise authorized work.' "${contract}" || fail "non-blocking overlay resume behavior is missing"
    grep -Fq 'advisory resume candidates' "${ROOT_DIR}/families/collaboration/portable-handoff/SKILL.md" || fail "handoff resume-candidate behavior is missing"
    grep -Fq 'product-research' "${ROOT_DIR}/AGENTS.md" || fail "authoritative specialist inventory is stale"
    grep -Fq 'code-review' "${ROOT_DIR}/AGENTS.md" || fail "authoritative specialist inventory is stale"
    grep -Fq 'Keep native skill-selection cues in leaf frontmatter' "${ROOT_DIR}/docs/global-AGENTS.example.md" || fail "global example duplicates routing instead of deferring to frontmatter"
    grep -Fq 'unrelated ad-hoc, AI, and writing work remains' "${ROOT_DIR}/templates/repo-AGENTS.template.md" || fail "repo template leaks lifecycle behavior into other families"

    if find "${ROOT_DIR}/families/ai" "${ROOT_DIR}/families/writing" -name SKILL.md -exec grep -El 'lifecycle-contract|\.mecha/work' {} + | grep -q .; then
        fail "lifecycle behavior leaked into AI or writing leaves"
    fi

    grep -Fq 'Rename this local variable' "${examples}" || fail "ad-hoc lifecycle selection example is missing"
    grep -Fq 'Turn the decisions in this conversation' "${examples}" || fail "implementation-spec selection example is missing"
    grep -Fq 'Break this accepted implementation contract' "${examples}" || fail "work-slicing selection example is missing"
    grep -Fq 'Review the changes since main' "${examples}" || fail "code-review selection example is missing"

    pass "optional lifecycle, intent authority, and routing contracts"
}

ai_family_checks() {
    local family_dir="${ROOT_DIR}/families/ai"
    local pipeline="${family_dir}/ai-pipeline/SKILL.md"
    local pipeline_metadata="${family_dir}/ai-pipeline/agents/openai.yaml"
    local leaf
    local reference

    grep -Fxq 'description: Frame AI problems from raw evidence through representation, solution design, and evaluation in one initial pass.' "${pipeline}" || fail "ai-pipeline description drifted"
    grep -Fxq 'description: Inspect, type, clean, convert, and package raw data into a documented analysis-ready artifact.' "${family_dir}/ai-data-preparation/SKILL.md" || fail "ai-data-preparation description drifted"
    grep -Fxq 'description: Develop evidence-backed insights about data, domain structure, dynamics, labels, and candidate solution signals.' "${family_dir}/ai-insight-development/SKILL.md" || fail "ai-insight-development description drifted"
    grep -Fxq 'description: Design and validate features, states, constraints, knowledge, embeddings, or heuristics for AI problems.' "${family_dir}/ai-representation-workbench/SKILL.md" || fail "ai-representation-workbench description drifted"
    grep -Fxq 'description: Formalize AI problems and choose statistical models, neural architectures, symbolic methods, or hybrid solutions.' "${family_dir}/ai-problem-modeling/SKILL.md" || fail "ai-problem-modeling description drifted"
    grep -Fxq 'description: Construct, optimize, train, and evaluate AI solutions with coupled diagnostics and comparative evidence.' "${family_dir}/ai-performance/SKILL.md" || fail "ai-performance description drifted"

    assert_exists "${pipeline_metadata}"
    grep -Fq 'allow_implicit_invocation: false' "${pipeline_metadata}" || fail "ai-pipeline implicit invocation is not disabled"
    grep -Fq 'Write or update `ML_PIPELINE.md` at the project root.' "${pipeline}" || fail "ai-pipeline required artifact is missing"
    grep -Fq 'Do not manage later experiment iterations or automatically invoke leaves.' "${pipeline}" || fail "ai-pipeline orchestration boundary is missing"

    for reference in \
        pipeline-contract.md \
        task-regimes.md \
        evidence-integrity.md \
        ai-coding-discipline.md \
        numerical-performance.md \
        search-performance.md \
        data-preparation.md \
        insight-development.md \
        representation-workbench.md \
        problem-modeling.md \
        performance.md
    do
        assert_exists "${family_dir}/references/${reference}"
    done

    for reference in \
        pipeline-contract.md \
        task-regimes.md \
        evidence-integrity.md \
        data-preparation.md \
        insight-development.md \
        representation-workbench.md \
        problem-modeling.md \
        performance.md
    do
        grep -Fq "\`../references/${reference}\`" "${pipeline}" || fail "ai-pipeline does not link ${reference}"
    done

    for section in \
        '## Problem' \
        '## Evidence Ledger' \
        '## Data Preparation' \
        '## Insight Development' \
        '## Representation Workbench' \
        '## Problem Modeling' \
        '## Candidate Portfolio' \
        '## Performance' \
        '## Recommended Execution' \
        '## Risks and Unknowns'
    do
        grep -Fq "${section}" "${family_dir}/references/pipeline-contract.md" || fail "pipeline contract section is missing: ${section}"
    done
    for status in observed assumed hypothesized proposed; do
        grep -Fq -- "- **${status^}:**" "${family_dir}/references/evidence-integrity.md" || fail "evidence status is missing: ${status}"
    done

    for leaf in \
        ai-data-preparation \
        ai-insight-development \
        ai-representation-workbench \
        ai-problem-modeling \
        ai-performance
    do
        grep -Fq 'Never require or create it.' "${family_dir}/${leaf}/SKILL.md" || fail "${leaf} pipeline file must be advisory"
        grep -Fq '`../../../shared/rubrics/change-discipline.md`' "${family_dir}/${leaf}/SKILL.md" || fail "${leaf} does not link shared coding discipline"
        grep -Fq '`../references/ai-coding-discipline.md`' "${family_dir}/${leaf}/SKILL.md" || fail "${leaf} does not link AI coding discipline"
        [ ! -e "${family_dir}/${leaf}/agents/openai.yaml" ] || fail "${leaf} has unneeded metadata"
    done

    for leaf in \
        ai-representation-workbench \
        ai-problem-modeling \
        ai-performance
    do
        grep -Fq '`../references/numerical-performance.md`' "${family_dir}/${leaf}/SKILL.md" || fail "${leaf} lacks numerical performance guidance"
        grep -Fq '`../references/search-performance.md`' "${family_dir}/${leaf}/SKILL.md" || fail "${leaf} lacks search performance guidance"
    done

    assert_not_exists "${ROOT_DIR}/families/engineering/references/change-discipline.md"

    pass "AI routing, pipeline, coding, and performance contracts"
}

writing_family_checks() {
    local family_dir="${ROOT_DIR}/families/writing"
    local humanizer="${family_dir}/humanizer/SKILL.md"
    local blogpost="${family_dir}/blogpost-writing/SKILL.md"
    local examples="${ROOT_DIR}/shared/examples/skill-selection-examples.md"

    grep -Fxq 'description: Write and revise long-form prose with a natural, genre-aware voice while preserving meaning, evidence, and authorial intent.' "${humanizer}" || fail "humanizer description drifted"
    grep -Fxq "description: Author VitePress-ready blog posts and CTF writeups in N00bcak's evidence-grounded, adaptable personal voice." "${blogpost}" || fail "blogpost-writing description drifted"

    assert_exists "${family_dir}/humanizer/references/revision-patterns.md"
    assert_exists "${family_dir}/blogpost-writing/references/n00bcak-voice.md"
    grep -Fq '`references/revision-patterns.md`' "${humanizer}" || fail "humanizer revision reference is not linked"
    grep -Fq '`references/n00bcak-voice.md`' "${blogpost}" || fail "blogpost-writing voice reference is not linked"
    grep -Fq 'When revising or auditing substantial prose' "${humanizer}" || fail "humanizer progressive loading boundary is missing"
    grep -Fq 'Read `references/n00bcak-voice.md` before drafting' "${blogpost}" || fail "blogpost-writing voice loading rule is missing"

    assert_not_exists "${family_dir}/humanizer/agents/openai.yaml"
    assert_not_exists "${family_dir}/blogpost-writing/agents/openai.yaml"
    assert_not_exists "${family_dir}/humanizer/scripts"
    assert_not_exists "${family_dir}/blogpost-writing/scripts"

    grep -Fq 'Technical documentation, API references, code comments' "${humanizer}" || fail "humanizer technical-writing boundary is missing"
    grep -Fq 'Style is not proof of' "${humanizer}" || fail "humanizer authorship boundary is missing"
    grep -Fq 'title: "<post title>"' "${blogpost}" || fail "blogpost-writing title frontmatter is missing"
    grep -Fq 'date: YYYY-MM-DD' "${blogpost}" || fail "blogpost-writing date frontmatter is missing"
    grep -Fq 'Publishing, committing, or deploying' "${blogpost}" || fail "blogpost-writing publication boundary is missing"
    grep -Fq 'Do not use, spawn, request, or rely on subagents.' "${humanizer}" || fail "humanizer subagent boundary is missing"
    grep -Fq 'Do not use, spawn, request, or rely on subagents.' "${blogpost}" || fail "blogpost-writing subagent boundary is missing"

    grep -Fq 'Write an essay from these notes' "${examples}" || fail "humanizer authoring selection example is missing"
    grep -Fq 'Rewrite these API docs and code comments' "${examples}" || fail "humanizer exclusion example is missing"
    grep -Fq 'Draft a technical post for n00bcak.github.io' "${examples}" || fail "blogpost-writing selection example is missing"
    grep -Fq 'Tell me whether AI wrote this essay' "${examples}" || fail "authorship refusal example is missing"

    pass "writing routing, progressive disclosure, and output contracts"
}

metadata_policy_checks() {
    grep -Fq '`ai-pipeline`' "${ROOT_DIR}/CLAUDE.md" || fail "CLAUDE metadata policy does not mention ai-pipeline"
    grep -Fq '`ai-pipeline`' "${ROOT_DIR}/README.md" || fail "README metadata policy does not mention ai-pipeline"
    grep -Fq '`interview-me`, `product-co-design`, `low-friction-collaboration`, and' "${ROOT_DIR}/docs/platform-notes.md" || fail "platform explicit-mode metadata policy is missing"
    pass "metadata policy"
}

install_uninstall_checks() {
    local tmp_root
    local unrelated_target

    tmp_root="$(mktemp -d)"
    trap "rm -rf '${tmp_root}'" EXIT

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" >"${tmp_root}/install-all.out"
    assert_symlink_to "${tmp_root}/skills/prototype-builder" "${ROOT_DIR}/families/engineering/prototype-builder"
    assert_symlink_to "${tmp_root}/skills/interview-me" "${ROOT_DIR}/families/collaboration/interview-me"
    assert_symlink_to "${tmp_root}/skills/low-friction-collaboration" "${ROOT_DIR}/families/collaboration/low-friction-collaboration"
    assert_symlink_to "${tmp_root}/skills/parallel-subagents" "${ROOT_DIR}/families/collaboration/parallel-subagents"
    assert_symlink_to "${tmp_root}/skills/product-co-design" "${ROOT_DIR}/families/collaboration/product-co-design"
    assert_symlink_to "${tmp_root}/skills/second-opinion" "${ROOT_DIR}/families/collaboration/second-opinion"
    assert_symlink_to "${tmp_root}/skills/product-research" "${ROOT_DIR}/families/collaboration/product-research"
    assert_symlink_to "${tmp_root}/skills/domain-modeling" "${ROOT_DIR}/families/collaboration/domain-modeling"
    assert_symlink_to "${tmp_root}/skills/decision-mapping" "${ROOT_DIR}/families/collaboration/decision-mapping"
    assert_symlink_to "${tmp_root}/skills/portable-handoff" "${ROOT_DIR}/families/collaboration/portable-handoff"
    assert_symlink_to "${tmp_root}/skills/technical-research" "${ROOT_DIR}/families/engineering/technical-research"
    assert_symlink_to "${tmp_root}/skills/implementation-spec" "${ROOT_DIR}/families/engineering/implementation-spec"
    assert_symlink_to "${tmp_root}/skills/work-slicing" "${ROOT_DIR}/families/engineering/work-slicing"
    assert_symlink_to "${tmp_root}/skills/diagnosing-bugs" "${ROOT_DIR}/families/engineering/diagnosing-bugs"
    assert_symlink_to "${tmp_root}/skills/code-review" "${ROOT_DIR}/families/engineering/code-review"
    assert_symlink_to "${tmp_root}/skills/ai-pipeline" "${ROOT_DIR}/families/ai/ai-pipeline"
    assert_symlink_to "${tmp_root}/skills/ai-performance" "${ROOT_DIR}/families/ai/ai-performance"
    assert_symlink_to "${tmp_root}/skills/humanizer" "${ROOT_DIR}/families/writing/humanizer"
    assert_symlink_to "${tmp_root}/skills/blogpost-writing" "${ROOT_DIR}/families/writing/blogpost-writing"
    assert_exists "${tmp_root}/skills/ai-performance/../references/performance.md"
    assert_exists "${tmp_root}/skills/ai-performance/../../../shared/rubrics/change-discipline.md"

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" >"${tmp_root}/install-all-again.out"
    grep -Eq '\[ok\] prototype-builder already installed' "${tmp_root}/install-all-again.out" || fail "install is not idempotent"

    MECHA_SKILL_ROOT="${tmp_root}/selected" "${ROOT_DIR}/install.sh" prototype-builder >"${tmp_root}/install-selected.out"
    assert_symlink_to "${tmp_root}/selected/prototype-builder" "${ROOT_DIR}/families/engineering/prototype-builder"

    MECHA_SKILL_ROOT="${tmp_root}/selected-collaboration" "${ROOT_DIR}/install.sh" interview-me low-friction-collaboration parallel-subagents product-co-design second-opinion >"${tmp_root}/install-selected-collaboration.out"
    assert_symlink_to "${tmp_root}/selected-collaboration/interview-me" "${ROOT_DIR}/families/collaboration/interview-me"
    assert_symlink_to "${tmp_root}/selected-collaboration/low-friction-collaboration" "${ROOT_DIR}/families/collaboration/low-friction-collaboration"
    assert_symlink_to "${tmp_root}/selected-collaboration/parallel-subagents" "${ROOT_DIR}/families/collaboration/parallel-subagents"
    assert_symlink_to "${tmp_root}/selected-collaboration/product-co-design" "${ROOT_DIR}/families/collaboration/product-co-design"
    assert_symlink_to "${tmp_root}/selected-collaboration/second-opinion" "${ROOT_DIR}/families/collaboration/second-opinion"

    MECHA_SKILL_ROOT="${tmp_root}/selected-writing" "${ROOT_DIR}/install.sh" humanizer blogpost-writing >"${tmp_root}/install-selected-writing.out"
    assert_symlink_to "${tmp_root}/selected-writing/humanizer" "${ROOT_DIR}/families/writing/humanizer"
    assert_symlink_to "${tmp_root}/selected-writing/blogpost-writing" "${ROOT_DIR}/families/writing/blogpost-writing"

    if MECHA_SKILL_ROOT="${tmp_root}/missing" "${ROOT_DIR}/install.sh" not-a-skill >"${tmp_root}/install-missing.out" 2>&1; then
        fail "missing skill install should fail"
    fi
    grep -Eq '\[missing\] not-a-skill is not a skill in this library' "${tmp_root}/install-missing.out" || fail "missing skill output is unclear"

    mkdir -p "${tmp_root}/protected"
    : >"${tmp_root}/protected/prototype-builder"
    MECHA_SKILL_ROOT="${tmp_root}/protected" "${ROOT_DIR}/install.sh" prototype-builder >"${tmp_root}/install-protected-file.out"
    [ ! -L "${tmp_root}/protected/prototype-builder" ] || fail "install overwrote unrelated file"
    grep -Eq '\[skip\].*not managed' "${tmp_root}/install-protected-file.out" || fail "unrelated file protection output is unclear"

    mkdir -p "${tmp_root}/other-target" "${tmp_root}/protected-link"
    ln -s "${tmp_root}/other-target" "${tmp_root}/protected-link/prototype-builder"
    MECHA_SKILL_ROOT="${tmp_root}/protected-link" "${ROOT_DIR}/install.sh" prototype-builder >"${tmp_root}/install-protected-link.out"
    unrelated_target="$(readlink "${tmp_root}/protected-link/prototype-builder")"
    [ "${unrelated_target}" = "${tmp_root}/other-target" ] || fail "install overwrote unrelated symlink"
    grep -Eq '\[skip\].*unrelated symlink' "${tmp_root}/install-protected-link.out" || fail "unrelated symlink protection output is unclear"

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/uninstall.sh" prototype-builder >"${tmp_root}/uninstall-selected.out"
    assert_not_exists "${tmp_root}/skills/prototype-builder"

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/uninstall.sh" >"${tmp_root}/uninstall-all.out"
    assert_not_exists "${tmp_root}/skills/prototype-builder"
    assert_not_exists "${tmp_root}/skills/interview-me"
    assert_not_exists "${tmp_root}/skills/low-friction-collaboration"
    assert_not_exists "${tmp_root}/skills/parallel-subagents"
    assert_not_exists "${tmp_root}/skills/product-co-design"
    assert_not_exists "${tmp_root}/skills/second-opinion"
    assert_not_exists "${tmp_root}/skills/product-research"
    assert_not_exists "${tmp_root}/skills/domain-modeling"
    assert_not_exists "${tmp_root}/skills/decision-mapping"
    assert_not_exists "${tmp_root}/skills/portable-handoff"
    assert_not_exists "${tmp_root}/skills/technical-research"
    assert_not_exists "${tmp_root}/skills/implementation-spec"
    assert_not_exists "${tmp_root}/skills/work-slicing"
    assert_not_exists "${tmp_root}/skills/diagnosing-bugs"
    assert_not_exists "${tmp_root}/skills/code-review"
    assert_not_exists "${tmp_root}/skills/ai-pipeline"
    assert_not_exists "${tmp_root}/skills/ai-performance"
    assert_not_exists "${tmp_root}/skills/humanizer"
    assert_not_exists "${tmp_root}/skills/blogpost-writing"

    MECHA_SKILL_ROOT= CODEX_HOME="${tmp_root}/codex-home" "${ROOT_DIR}/install.sh" prototype-builder >"${tmp_root}/install-codex-home.out"
    assert_symlink_to "${tmp_root}/codex-home/skills/prototype-builder" "${ROOT_DIR}/families/engineering/prototype-builder"
    MECHA_SKILL_ROOT= CODEX_HOME="${tmp_root}/codex-home" "${ROOT_DIR}/uninstall.sh" prototype-builder >"${tmp_root}/uninstall-codex-home.out"
    assert_not_exists "${tmp_root}/codex-home/skills/prototype-builder"

    MECHA_SKILL_ROOT= CODEX_HOME= HOME="${tmp_root}/home" "${ROOT_DIR}/install.sh" prototype-builder >"${tmp_root}/install-home-default.out"
    assert_symlink_to "${tmp_root}/home/.codex/skills/prototype-builder" "${ROOT_DIR}/families/engineering/prototype-builder"

    pass "install and uninstall behavior"
    rm -rf "${tmp_root}"
    trap - EXIT
}

main() {
    syntax_checks
    development_environment_checks
    frontmatter_checks
    architecture_checks
    subagent_boundary_checks
    persistence_yield_checks
    interaction_contract_checks
    collaboration_checks
    engineering_checks
    lifecycle_checks
    ai_family_checks
    writing_family_checks
    metadata_policy_checks
    install_uninstall_checks
}

main "$@"
