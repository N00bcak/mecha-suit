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
    PYTHONDONTWRITEBYTECODE=1 "${DEV_PYTHON}" "${ROOT_DIR}/scripts/validate_skills.py"
    PYTHONDONTWRITEBYTECODE=1 "${DEV_PYTHON}" -m unittest discover -s "${ROOT_DIR}/tests"
    for corpus in "${ROOT_DIR}"/evals/*.json; do
        PYTHONDONTWRITEBYTECODE=1 "${DEV_PYTHON}" "${ROOT_DIR}/scripts/run_interaction_evals.py" --corpus "${corpus}" --split all --dry-run >/dev/null
    done
    pass "validator unit tests and host-neutral evaluation corpora"
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
    pass "subagent allowlist and contracts"
}

interaction_contract_checks() {
    local task_template="${ROOT_DIR}/templates/task-skill.template.md"
    local overlay_template="${ROOT_DIR}/templates/session-overlay.template.md"
    local loop_template="${ROOT_DIR}/templates/interactive-loop.template.md"
    local heading

    assert_not_exists "${ROOT_DIR}/templates/leaf-skill.template.md"
    assert_exists "${task_template}"
    assert_exists "${overlay_template}"
    assert_exists "${loop_template}"

    for template in "${task_template}" "${overlay_template}" "${loop_template}"; do
        for heading in Purpose 'Do Not Use' Needs Returns 'Done Conditions' Progress; do
            grep -Fxq "## ${heading}" "${template}" || fail "${template} is missing ${heading}"
        done
    done
    grep -Fxq '## Session Overlay Contract' "${overlay_template}" || fail "session overlay template marker is missing"
    grep -Fxq '## Interactive Loop Contract' "${loop_template}" || fail "interactive loop template marker is missing"

    if grep -R -Eq '^## (Stub Status|Designer Notes|Future Workflow Outline)$' "${ROOT_DIR}/families"; then
        fail "obsolete skill-development sections remain in runtime skills"
    fi
    grep -Fxq '## Session Overlay Contract' "${ROOT_DIR}/families/collaboration/low-friction-collaboration/SKILL.md" || fail "low-friction collaboration is not the session overlay"
    grep -Fxq '## Interactive Loop Contract' "${ROOT_DIR}/families/collaboration/interview-me/SKILL.md" || fail "interview-me is not an interactive loop"
    grep -Fxq '## Interactive Loop Contract' "${ROOT_DIR}/families/collaboration/product-co-design/SKILL.md" || fail "product-co-design is not an interactive loop"

    pass "task, session-overlay, and interactive-loop contracts"
}

collaboration_checks() {
    local low_friction_file="${ROOT_DIR}/families/collaboration/low-friction-collaboration/SKILL.md"
    local low_friction_reference="${ROOT_DIR}/families/collaboration/low-friction-collaboration/references/communication-evidence.md"
    local parallel="${ROOT_DIR}/families/collaboration/parallel-subagents/SKILL.md"
    local second_opinion="${ROOT_DIR}/families/collaboration/second-opinion/SKILL.md"
    local product_research="${ROOT_DIR}/families/collaboration/product-research/SKILL.md"
    local domain_modeling="${ROOT_DIR}/families/collaboration/domain-modeling/SKILL.md"
    local decision_mapping="${ROOT_DIR}/families/collaboration/decision-mapping/SKILL.md"
    local portable_handoff="${ROOT_DIR}/families/collaboration/portable-handoff/SKILL.md"
    local product_co_design="${ROOT_DIR}/families/collaboration/product-co-design/SKILL.md"

    assert_exists "${low_friction_reference}"
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

    grep -Fxq 'description: Implement PR-ready changes to established code above roughly 10kLoC with idiomatic, anti-bloat, and verification discipline.' "${large_skill}" || fail "large-codebase-change description drifted"
    grep -Fxq 'description: Build and verify isolated greenfield prototypes, demos, tools, or apps around one core outcome.' "${prototype_skill}" || fail "prototype-builder description drifted"
    grep -Fxq 'description: Resolve software and architecture questions through primary technical sources, repository evidence, and reproducible checks.' "${technical_research}" || fail "technical-research description drifted"
    grep -Fxq 'description: Turn settled intent and evidence into an accepted implementation contract with criteria, constraints, and non-goals.' "${implementation_spec}" || fail "implementation-spec description drifted"
    grep -Fxq 'description: Decompose an accepted implementation contract into verifiable vertical slices with explicit dependency edges.' "${work_slicing}" || fail "work-slicing description drifted"
    grep -Fxq 'description: Diagnose difficult bugs and regressions through a tight reproducer, falsifiable hypotheses, and regression evidence.' "${diagnosing_bugs}" || fail "diagnosing-bugs description drifted"
    grep -Fxq 'description: Review changes for intent fidelity, behavioral correctness and evidence, and maintainability against a fixed point.' "${code_review}" || fail "code-review description drifted"

    if grep -REiq '((1k|1,000|5k|5,000)(LoC|[[:space:]-]+maintained[[:space:]-]+source[[:space:]-]+lines?)|(~|under about |past ~)(1k|1,000|5k|5,000))' "${family_dir}"; then
        fail "obsolete engineering line-count threshold remains"
    fi

    assert_exists "${ROOT_DIR}/shared/rubrics/change-discipline.md"
    grep -Fq '`../../../shared/rubrics/change-discipline.md`' "${large_skill}" || fail "large-codebase-change does not link shared change discipline"
    grep -Fq '`../../../shared/rubrics/change-discipline.md`' "${prototype_skill}" || fail "prototype-builder does not link shared change discipline"

    for reference in \
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

    assert_not_exists "${family_dir}/references/session-continuity.md"
    grep -Fq 'authoritative layer' "${large_skill}" || fail "large-codebase-change authoritative-layer guidance is missing"
    grep -Fq 'PR-ready does not authorize publishing' "${large_skill}" || fail "PR-ready publication boundary is missing"
    grep -Fq 'commits, branches, pushes, or pull' "${large_skill}" || fail "PR-ready Git operation boundary is incomplete"

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
    local governor="${ROOT_DIR}/families/collaboration/multi-step-governance/SKILL.md"

    assert_exists "${contract}"
    assert_exists "${template}"
    assert_exists "${governor}"
    grep -Fq 'sole record writer' "${contract}" || fail "governor authority is missing"
    grep -Fq 'Governor:' "${template}" || fail "work-index governor field is missing"
    grep -Fq 'lifecycle-contract.md' "${governor}" || fail "governor lifecycle contract is missing"
    if rg -q 'review-contract\.md' "${ROOT_DIR}"; then
        fail "removed review contract is still referenced"
    fi
    grep -Fq 'does not inspect a diff' "${contract}" || fail "review judgment boundary is missing from lifecycle contract"
    grep -Fq 'Do not inspect a diff' "${governor}" || fail "review judgment boundary is missing from governor"
    if find "${ROOT_DIR}/families" -name SKILL.md ! -path '*/multi-step-governance/SKILL.md' -exec grep -El 'lifecycle-contract|\.mecha/work' {} + | grep -q .; then
        fail "lifecycle behavior leaked into contributors"
    fi
    pass "governor lifecycle authority and contributor boundaries"
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

    pass "writing routing, progressive disclosure, and output contracts"
}

metadata_policy_checks() {
    grep -Fq '`ai-pipeline`' "${ROOT_DIR}/CLAUDE.md" || fail "CLAUDE metadata policy does not mention ai-pipeline"
    grep -Fq '`ai-pipeline`' "${ROOT_DIR}/README.md" || fail "README metadata policy does not mention ai-pipeline"
    grep -Fq '`multi-step-governance`' "${ROOT_DIR}/docs/platform-notes.md" || fail "platform explicit-mode metadata policy is missing"
    pass "metadata policy"
}

install_uninstall_checks() {
    local tmp_root
    local unrelated_target
    local backup_path
    local custom_prompt

    tmp_root="$(mktemp -d)"
    trap "rm -rf '${tmp_root}'" EXIT

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" >"${tmp_root}/install-all.out"
    cmp -s "${ROOT_DIR}/templates/global-AGENTS.template.md" "${tmp_root}/AGENTS.md" || fail "default global instructions were not installed"
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
    grep -Eq '\[ok\] global instructions already installed' "${tmp_root}/install-all-again.out" || fail "global instruction install is not idempotent"

    mkdir -p "${tmp_root}/custom/skills"
    custom_prompt="custom global instructions for ${tmp_root}"
    printf '%s\n' "${custom_prompt}" >"${tmp_root}/custom/AGENTS.md"
    if MECHA_SKILL_ROOT="${tmp_root}/custom/skills" "${ROOT_DIR}/install.sh" prototype-builder >"${tmp_root}/install-custom-abort.out" 2>&1; then
        fail "install should abort when non-default global instructions exist"
    fi
    assert_not_exists "${tmp_root}/custom/skills/prototype-builder"
    grep -Fq '[abort]' "${tmp_root}/install-custom-abort.out" || fail "global instruction conflict output is unclear"
    grep -Fxq "${custom_prompt}" "${tmp_root}/custom/AGENTS.md" || fail "conflicting global instructions were changed"

    MECHA_SKILL_ROOT="${tmp_root}/custom/skills" "${ROOT_DIR}/install.sh" --use-custom-global-instructions prototype-builder >"${tmp_root}/install-custom-replace.out"
    assert_symlink_to "${tmp_root}/custom/skills/prototype-builder" "${ROOT_DIR}/families/engineering/prototype-builder"
    cmp -s "${ROOT_DIR}/templates/global-AGENTS.template.md" "${tmp_root}/custom/AGENTS.md" || fail "custom global instructions were not replaced"
    backup_path="$(rg -l -F "${custom_prompt}" "${ROOT_DIR}/.mecha/backups/global-instructions" | tail -n 1)"
    [ -n "${backup_path}" ] || fail "replaced global instructions were not backed up"
    grep -Fxq "${custom_prompt}" "${backup_path}" || fail "global instruction backup is incomplete"
    rm "${backup_path}"

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
    cmp -s "${ROOT_DIR}/templates/global-AGENTS.template.md" "${tmp_root}/codex-home/AGENTS.md" || fail "CODEX_HOME global instructions were not installed"
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
    architecture_checks
    subagent_boundary_checks
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
