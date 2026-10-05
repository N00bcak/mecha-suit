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

assert_contains_no_files() {
    local path="$1"
    if [ -d "${path}" ] && find "${path}" -type f -print -quit | grep -q .; then
        fail "expected ${path} to contain no files"
    fi
}

# Installed global instructions replace the template's {{MECHA_ROOT}} with
# this checkout.
rendered_global_template() {
    local root_escaped
    root_escaped="$(printf '%s' "${ROOT_DIR}" | sed 's/[\\&|]/\\&/g')"
    sed "s|{{MECHA_ROOT}}|${root_escaped}|g" "${ROOT_DIR}/templates/global-AGENTS.template.md"
}

assert_template_copy() {
    local path="$1"
    [ -f "${path}" ] && [ ! -L "${path}" ] || fail "expected ${path} to be a regular file"
    cmp -s <(rendered_global_template) "${path}" || fail "expected ${path} to match the rendered global template"
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
    PYTHONDONTWRITEBYTECODE=1 "${DEV_PYTHON}" "${ROOT_DIR}/scripts/run_outcome_evals.py" --dry-run >/dev/null
    pass "validator unit tests and host-neutral evaluation corpora"
}

architecture_checks() {
    assert_exists "${ROOT_DIR}/families/collaboration/user-interview/SKILL.md"
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
    assert_exists "${ROOT_DIR}/families/engineering/bug-diagnosis/SKILL.md"
    assert_exists "${ROOT_DIR}/families/engineering/change-review/SKILL.md"
    assert_exists "${ROOT_DIR}/families/ai/ai-pipeline/SKILL.md"
    assert_exists "${ROOT_DIR}/families/writing/prose-voice/SKILL.md"
    assert_exists "${ROOT_DIR}/families/writing/blog-writing/SKILL.md"
    assert_contains_no_files "${ROOT_DIR}/families/ml"
    assert_contains_no_files "${ROOT_DIR}/families/council"
    assert_contains_no_files "${ROOT_DIR}/families/routing"
    assert_contains_no_files "${ROOT_DIR}/families/orchestration"
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
    grep -Fxq '## Interactive Loop Contract' "${ROOT_DIR}/families/collaboration/user-interview/SKILL.md" || fail "user-interview is not an interactive loop"
    grep -Fxq '## Interactive Loop Contract' "${ROOT_DIR}/families/collaboration/product-co-design/SKILL.md" || fail "product-co-design is not an interactive loop"

    pass "task, session-overlay, and interactive-loop contracts"
}

collaboration_checks() {
    local global_instructions="${ROOT_DIR}/templates/global-AGENTS.template.md"
    local communication_evidence="${ROOT_DIR}/docs/communication-evidence.md"
    local parallel="${ROOT_DIR}/families/collaboration/parallel-subagents/SKILL.md"
    local second_opinion="${ROOT_DIR}/families/collaboration/second-opinion/SKILL.md"
    local product_research="${ROOT_DIR}/families/collaboration/product-research/SKILL.md"
    local domain_modeling="${ROOT_DIR}/families/collaboration/domain-modeling/SKILL.md"
    local decision_mapping="${ROOT_DIR}/families/collaboration/decision-mapping/SKILL.md"
    local portable_handoff="${ROOT_DIR}/families/collaboration/portable-handoff/SKILL.md"
    local product_co_design="${ROOT_DIR}/families/collaboration/product-co-design/SKILL.md"

    assert_exists "${communication_evidence}"
    grep -Fq 'Keep at most one interactive loop active.' "${product_co_design}" || fail "product co-design exclusive-loop contract is missing"
    grep -Fq 'Think as thoroughly as the task requires before writing.' "${global_instructions}" || fail "communication reasoning safeguard is missing"
    grep -Fq "Prefer the words the user used" "${global_instructions}" || fail "communication vocabulary continuity is missing"
    grep -Fq 'Do not coin labels, frameworks, categories, or slogans' "${global_instructions}" || fail "communication invented-term guard is missing"
    grep -Fq 'Use prose for an argument.' "${global_instructions}" || fail "communication discursive prose guidance is missing"
    grep -Fq 'Restore this state after interruptions' "${global_instructions}" || fail "communication continuity guidance is missing"
    grep -Fq 'Do not impose an arbitrary item limit' "${global_instructions}" || fail "communication list discipline is missing"
    grep -Fxq 'description: Delegate independent bounded subtasks concurrently and integrate their evidence into one verified outcome. Use when independent parts of a task can run in parallel.' "${parallel}" || fail "parallel-subagents description drifted"
    grep -Fxq 'description: Obtain an independent evidence-backed critique of a consequential conclusion, diagnosis, plan, or diff. Use before committing to a costly or hard-to-reverse decision.' "${second_opinion}" || fail "second-opinion description drifted"
    grep -Fxq 'description: Develop evidence-backed findings about users, workflows, terminology, alternatives, and product assumptions. Use when a product decision depends on what users or markets do.' "${product_research}" || fail "product-research description drifted"
    grep -Fxq 'description: Sharpen domain terminology and record durable decisions against scenarios, code, and evidence. Use when terms or business rules are ambiguous, overloaded, or contradict the code.' "${domain_modeling}" || fail "domain-modeling description drifted"
    grep -Fxq 'description: Map and resolve decisions blocking a long-horizon effort until it is ready for specification. Use when a large, uncertain effort has open choices that depend on each other.' "${decision_mapping}" || fail "decision-mapping description drifted"
    grep -Fxq 'description: Package verified work state into a redacted portable handoff for another session, machine, agent, or collaborator. Use when work must pause and be resumed elsewhere.' "${portable_handoff}" || fail "portable-handoff description drifted"
    assert_not_exists "${ROOT_DIR}/families/collaboration/parallel-subagents/agents/openai.yaml"
    assert_not_exists "${ROOT_DIR}/families/collaboration/second-opinion/agents/openai.yaml"
    assert_not_exists "${ROOT_DIR}/families/collaboration/product-research/agents/openai.yaml"
    assert_not_exists "${ROOT_DIR}/families/collaboration/domain-modeling/agents/openai.yaml"
    assert_not_exists "${ROOT_DIR}/families/collaboration/decision-mapping/agents/openai.yaml"
    assert_not_exists "${ROOT_DIR}/families/collaboration/portable-handoff/agents/openai.yaml"
    if grep -Eiq 'the reader has ADHD|ADHD brain' "${global_instructions}"; then
        fail "communication rules contain diagnostic framing"
    fi
    pass "collaboration routing boundaries"
}

engineering_checks() {
    local family_dir="${ROOT_DIR}/families/engineering"
    local large_skill="${family_dir}/large-codebase-change/SKILL.md"
    local prototype_skill="${family_dir}/prototype-build/SKILL.md"
    local technical_research="${family_dir}/technical-research/SKILL.md"
    local implementation_spec="${family_dir}/implementation-spec/SKILL.md"
    local work_slicing="${family_dir}/work-slicing/SKILL.md"
    local diagnosing_bugs="${family_dir}/bug-diagnosis/SKILL.md"
    local code_review="${family_dir}/change-review/SKILL.md"
    local reference

    grep -Fxq 'description: Build and verify isolated greenfield prototypes, demos, tools, or apps around one core outcome. Use when starting something new from scratch to prove an idea end to end.' "${prototype_skill}" || fail "prototype-build description drifted"
    grep -Fxq 'description: Resolve software and architecture questions through primary sources, repository evidence, and reproducible checks. Use when an engineering decision needs verified facts.' "${technical_research}" || fail "technical-research description drifted"
    grep -Fxq 'description: Turn settled intent and evidence into an accepted implementation contract with criteria, constraints, and non-goals. Use when a change needs a written spec before coding.' "${implementation_spec}" || fail "implementation-spec description drifted"
    grep -Fxq 'description: Decompose an accepted implementation contract into verifiable vertical slices with dependency edges. Use when an agreed change is too large to deliver as one step.' "${work_slicing}" || fail "work-slicing description drifted"
    grep -Fxq "description: Diagnose difficult bugs and regressions through a tight reproducer, falsifiable hypotheses, and regression evidence. Use when a failure's cause is unknown or disputed." "${diagnosing_bugs}" || fail "bug-diagnosis description drifted"
    grep -Fxq 'description: Review changes for intent fidelity, behavioral correctness and evidence, and maintainability against a fixed point. Use when asked to review a diff, branch, or pull request.' "${code_review}" || fail "change-review description drifted"

    assert_exists "${ROOT_DIR}/shared/rubrics/change-discipline.md"
    grep -Fq '`../../../shared/rubrics/change-discipline.md`' "${large_skill}" || fail "large-codebase-change does not link shared change discipline"
    grep -Fq '`../../../shared/rubrics/change-discipline.md`' "${prototype_skill}" || fail "prototype-build does not link shared change discipline"

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
        grep -Fq "\`../references/${reference}\`" "${prototype_skill}" || fail "prototype-build does not link shared ${reference}"
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
    assert_not_exists "${family_dir}/prototype-build/references/session-continuity.md"

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
    if git -C "${ROOT_DIR}" grep -q 'review-contract\.md'; then
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

    grep -Fxq 'description: Frame AI problems from raw evidence through representation, solution design, and evaluation in one initial pass. Use when the user asks for an end-to-end AI pipeline map.' "${pipeline}" || fail "ai-pipeline description drifted"
    grep -Fxq 'description: Inspect, type, clean, convert, and package raw data into a documented analysis-ready artifact. Use when raw or messy data must become a reproducible dataset before analysis.' "${family_dir}/ai-data-preparation/SKILL.md" || fail "ai-data-preparation description drifted"
    grep -Fxq 'description: Develop evidence-backed insights about data, domain structure, dynamics, labels, and solution signals. Use when patterns could change how an AI problem is framed or solved.' "${family_dir}/ai-insight-development/SKILL.md" || fail "ai-insight-development description drifted"
    grep -Fxq 'description: Design and validate features, states, constraints, knowledge, embeddings, or heuristics for AI problems. Use when choosing what an AI system should see or encode.' "${family_dir}/ai-representation-workbench/SKILL.md" || fail "ai-representation-workbench description drifted"
    grep -Fxq 'description: Formalize AI problems and choose statistical, neural, symbolic, or hybrid solutions. Use when an AI task needs a formal objective and a justified set of candidate approaches.' "${family_dir}/ai-problem-modeling/SKILL.md" || fail "ai-problem-modeling description drifted"
    grep -Fxq 'description: Construct, optimize, train, and evaluate AI solutions with coupled diagnostics and comparative evidence. Use when building, tuning, or comparing models or solvers.' "${family_dir}/ai-performance/SKILL.md" || fail "ai-performance description drifted"

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
    for status in Observed Assumed Hypothesized Proposed; do
        grep -Fq -- "- **${status}:**" "${family_dir}/references/evidence-integrity.md" || fail "evidence status is missing: ${status}"
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

    # Each leaf Workflow is its single runtime playbook; stage summaries serve
    # ai-pipeline only.
    for reference in data-preparation insight-development representation-workbench problem-modeling performance; do
        for leaf in ai-data-preparation ai-insight-development ai-representation-workbench ai-problem-modeling ai-performance; do
            if grep -Fq "\`../references/${reference}.md\`" "${family_dir}/${leaf}/SKILL.md"; then
                fail "${leaf} still loads the ${reference} stage summary"
            fi
        done
    done
    grep -Fq 'beyond the authorized compute' "${family_dir}/ai-performance/SKILL.md" || fail "ai-performance approval rule ignores authorized compute"
    grep -Fq 'beyond the authorized compute' "${family_dir}/references/performance.md" || fail "performance summary approval rule ignores authorized compute"
    assert_not_exists "${ROOT_DIR}/families/engineering/references/change-discipline.md"

    pass "AI routing, pipeline, coding, and performance contracts"
}

writing_family_checks() {
    local family_dir="${ROOT_DIR}/families/writing"
    local prose_voice="${family_dir}/prose-voice/SKILL.md"
    local blogpost="${family_dir}/blog-writing/SKILL.md"

    grep -Fxq 'description: Write and revise long-form prose with a natural, genre-aware voice while preserving meaning and evidence. Use when prose reads generic or machine-written and needs revision.' "${prose_voice}" || fail "prose-voice description drifted"
    grep -Fxq "description: Author VitePress-ready blog posts and CTF writeups in N00bcak's evidence-grounded personal voice. Use when drafting or revising a post for N00bcak's blog." "${blogpost}" || fail "blog-writing description drifted"

    assert_exists "${family_dir}/prose-voice/references/revision-patterns.md"
    assert_exists "${family_dir}/blog-writing/references/n00bcak-voice.md"
    grep -Fq '`references/revision-patterns.md`' "${prose_voice}" || fail "prose-voice revision reference is not linked"
    grep -Fq '`references/n00bcak-voice.md`' "${blogpost}" || fail "blog-writing voice reference is not linked"
    grep -Fq 'When revising or auditing substantial prose' "${prose_voice}" || fail "prose-voice progressive loading boundary is missing"
    grep -Fq 'Read `references/n00bcak-voice.md` before drafting' "${blogpost}" || fail "blog-writing voice loading rule is missing"

    assert_not_exists "${family_dir}/prose-voice/agents/openai.yaml"
    assert_not_exists "${family_dir}/blog-writing/agents/openai.yaml"
    assert_not_exists "${family_dir}/prose-voice/scripts"
    assert_not_exists "${family_dir}/blog-writing/scripts"

    grep -Fq 'Technical documentation, API references, code comments' "${prose_voice}" || fail "prose-voice technical-writing boundary is missing"
    grep -Fq 'Style is not proof of' "${prose_voice}" || fail "prose-voice authorship boundary is missing"
    grep -Fq 'title: "<post title>"' "${blogpost}" || fail "blog-writing title frontmatter is missing"
    grep -Fq 'date: YYYY-MM-DD' "${blogpost}" || fail "blog-writing date frontmatter is missing"
    grep -Fq 'Publishing, committing, or deploying' "${blogpost}" || fail "blog-writing publication boundary is missing"
    grep -Fq 'Do not use, spawn, request, or rely on subagents.' "${prose_voice}" || fail "prose-voice subagent boundary is missing"
    grep -Fq 'Do not use, spawn, request, or rely on subagents.' "${blogpost}" || fail "blog-writing subagent boundary is missing"

    pass "writing routing, progressive disclosure, and output contracts"
}

metadata_policy_checks() {
    grep -Fq '`ai-pipeline`' "${ROOT_DIR}/README.md" || fail "README metadata policy does not mention ai-pipeline"
    grep -Fq '`multi-step-governance`' "${ROOT_DIR}/docs/platform-notes.md" || fail "platform explicit-mode metadata policy is missing"
    pass "metadata policy"
}

install_uninstall_checks() {
    local tmp_root
    local unrelated_target
    local backup_path
    local custom_prompt
    local default_codex_home

    tmp_root="$(mktemp -d)"
    trap "rm -rf '${tmp_root}'" EXIT
    default_codex_home="${tmp_root}/codex-config"
    export CODEX_HOME="${default_codex_home}"
    export CLAUDE_CONFIG_DIR="${tmp_root}/claude"

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" >"${tmp_root}/install-all.out"
    cmp -s <(rendered_global_template) "${default_codex_home}/AGENTS.md" || fail "default global instructions were not installed"
    assert_symlink_to "${tmp_root}/skills/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"
    assert_symlink_to "${tmp_root}/skills/user-interview" "${ROOT_DIR}/families/collaboration/user-interview"
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
    assert_symlink_to "${tmp_root}/skills/bug-diagnosis" "${ROOT_DIR}/families/engineering/bug-diagnosis"
    assert_symlink_to "${tmp_root}/skills/change-review" "${ROOT_DIR}/families/engineering/change-review"
    assert_symlink_to "${tmp_root}/skills/ai-pipeline" "${ROOT_DIR}/families/ai/ai-pipeline"
    assert_symlink_to "${tmp_root}/skills/ai-performance" "${ROOT_DIR}/families/ai/ai-performance"
    assert_symlink_to "${tmp_root}/skills/prose-voice" "${ROOT_DIR}/families/writing/prose-voice"
    assert_symlink_to "${tmp_root}/skills/blog-writing" "${ROOT_DIR}/families/writing/blog-writing"
    PYTHONDONTWRITEBYTECODE=1 "${DEV_PYTHON}" "${ROOT_DIR}/scripts/validate_skills.py" --installed-root "${tmp_root}/skills" >"${tmp_root}/validate-installed.out"
    grep -Fq '[ok] installed runtime references' "${tmp_root}/validate-installed.out" || fail "installed runtime references were not validated"
    claude_install_checks "${tmp_root}"

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" >"${tmp_root}/install-all-again.out"
    grep -Eq '\[ok\] prototype-build already installed' "${tmp_root}/install-all-again.out" || fail "install is not idempotent"
    grep -Eq '\[ok\] global instructions already installed' "${tmp_root}/install-all-again.out" || fail "global instruction install is not idempotent"
    if grep -Ev '^\[ok\]' "${tmp_root}/install-all-again.out" | grep -q .; then
        fail "second install changed state"
    fi
    ln -s "${ROOT_DIR}/families/engineering/renamed-skill" "${tmp_root}/skills/renamed-skill"
    ln -s "${CLAUDE_CONFIG_DIR}/.mecha-render/families/collaboration/renamed-skill" "${CLAUDE_CONFIG_DIR}/skills/renamed-skill"
    ln -s "${tmp_root}/elsewhere" "${tmp_root}/skills/foreign-skill"
    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" >"${tmp_root}/install-prune.out"
    assert_not_exists "${tmp_root}/skills/renamed-skill"
    assert_not_exists "${CLAUDE_CONFIG_DIR}/skills/renamed-skill"
    [ -L "${tmp_root}/skills/foreign-skill" ] || fail "install pruned an unrelated dangling link"
    [ "$(grep -c '^\[prune\]' "${tmp_root}/install-prune.out")" = 2 ] || fail "stale managed links were not reported"
    rm "${tmp_root}/skills/foreign-skill"
    # A removed explicit-only skill leaves a real rendered directory behind.
    mkdir -p "${CLAUDE_CONFIG_DIR}/.mecha-render/families/collaboration/removed-explicit"
    printf 'stale\n' >"${CLAUDE_CONFIG_DIR}/.mecha-render/families/collaboration/removed-explicit/SKILL.md"
    ln -s "${CLAUDE_CONFIG_DIR}/.mecha-render/families/collaboration/removed-explicit" "${CLAUDE_CONFIG_DIR}/skills/removed-explicit"
    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" >"${tmp_root}/install-prune-render.out"
    assert_not_exists "${CLAUDE_CONFIG_DIR}/.mecha-render/families/collaboration/removed-explicit"
    [ ! -L "${CLAUDE_CONFIG_DIR}/skills/removed-explicit" ] || fail "install kept a link to a removed explicit-only skill"
    # Links store physical paths even when the config path contains a symlink.
    ln -s "${CLAUDE_CONFIG_DIR}" "${tmp_root}/claude-alias"
    ln -s "$(cd "${CLAUDE_CONFIG_DIR}" && pwd -P)/.mecha-render/families/collaboration/renamed-skill" "${CLAUDE_CONFIG_DIR}/skills/renamed-skill"
    CLAUDE_CONFIG_DIR="${tmp_root}/claude-alias" MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" >"${tmp_root}/install-prune-alias.out"
    [ ! -L "${CLAUDE_CONFIG_DIR}/skills/renamed-skill" ] || fail "install missed a physical-path link under a symlinked config path"
    rm "${tmp_root}/claude-alias"
    printf 'stale\n' >"${CLAUDE_CONFIG_DIR}/.mecha-render/families/collaboration/user-interview/SKILL.md"
    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/install.sh" user-interview >"${tmp_root}/install-rerender.out"
    grep -Fq 'disable-model-invocation: true' "${CLAUDE_CONFIG_DIR}/skills/user-interview/SKILL.md" || fail "install did not re-render a stale Claude adapter"

    mkdir -p "${tmp_root}/custom/skills"
    custom_prompt="custom global instructions for ${tmp_root}"
    mkdir -p "${tmp_root}/custom-codex"
    printf '%s\n' "${custom_prompt}" >"${tmp_root}/custom-codex/AGENTS.md"
    if CODEX_HOME="${tmp_root}/custom-codex" MECHA_SKILL_ROOT="${tmp_root}/custom/skills" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-custom-abort.out" 2>&1; then
        fail "install should abort when non-default global instructions exist"
    fi
    assert_not_exists "${tmp_root}/custom/skills/prototype-build"
    grep -Fq '[abort]' "${tmp_root}/install-custom-abort.out" || fail "global instruction conflict output is unclear"
    grep -Fxq "${custom_prompt}" "${tmp_root}/custom-codex/AGENTS.md" || fail "conflicting global instructions were changed"

    CODEX_HOME="${tmp_root}/custom-codex" MECHA_SKILL_ROOT="${tmp_root}/custom/skills" "${ROOT_DIR}/install.sh" --use-custom-global-instructions prototype-build >"${tmp_root}/install-custom-replace.out"
    assert_symlink_to "${tmp_root}/custom/skills/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"
    cmp -s <(rendered_global_template) "${tmp_root}/custom-codex/AGENTS.md" || fail "custom global instructions were not replaced"
    backup_path="$(grep -rlF "${custom_prompt}" "${ROOT_DIR}/.mecha/backups/global-instructions" | tail -n 1)"
    [ -n "${backup_path}" ] || fail "replaced global instructions were not backed up"
    grep -Fxq "${custom_prompt}" "${backup_path}" || fail "global instruction backup is incomplete"
    rm "${backup_path}"

    MECHA_SKILL_ROOT="${tmp_root}/selected" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-selected.out"
    assert_symlink_to "${tmp_root}/selected/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"

    MECHA_SKILL_ROOT="${tmp_root}/selected-collaboration" "${ROOT_DIR}/install.sh" user-interview parallel-subagents product-co-design second-opinion >"${tmp_root}/install-selected-collaboration.out"
    assert_symlink_to "${tmp_root}/selected-collaboration/user-interview" "${ROOT_DIR}/families/collaboration/user-interview"
    assert_symlink_to "${tmp_root}/selected-collaboration/parallel-subagents" "${ROOT_DIR}/families/collaboration/parallel-subagents"
    assert_symlink_to "${tmp_root}/selected-collaboration/product-co-design" "${ROOT_DIR}/families/collaboration/product-co-design"
    assert_symlink_to "${tmp_root}/selected-collaboration/second-opinion" "${ROOT_DIR}/families/collaboration/second-opinion"

    MECHA_SKILL_ROOT="${tmp_root}/selected-writing" "${ROOT_DIR}/install.sh" prose-voice blog-writing >"${tmp_root}/install-selected-writing.out"
    assert_symlink_to "${tmp_root}/selected-writing/prose-voice" "${ROOT_DIR}/families/writing/prose-voice"
    assert_symlink_to "${tmp_root}/selected-writing/blog-writing" "${ROOT_DIR}/families/writing/blog-writing"

    if MECHA_SKILL_ROOT="${tmp_root}/missing" "${ROOT_DIR}/install.sh" not-a-skill >"${tmp_root}/install-missing.out" 2>&1; then
        fail "missing skill install should fail"
    fi
    grep -Eq '\[missing\] not-a-skill is not a skill in this library' "${tmp_root}/install-missing.out" || fail "missing skill output is unclear"

    mkdir -p "${tmp_root}/protected"
    : >"${tmp_root}/protected/prototype-build"
    MECHA_SKILL_ROOT="${tmp_root}/protected" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-protected-file.out"
    [ ! -L "${tmp_root}/protected/prototype-build" ] || fail "install overwrote unrelated file"
    grep -Eq '\[skip\].*not managed' "${tmp_root}/install-protected-file.out" || fail "unrelated file protection output is unclear"

    mkdir -p "${tmp_root}/other-target" "${tmp_root}/protected-link"
    ln -s "${tmp_root}/other-target" "${tmp_root}/protected-link/prototype-build"
    MECHA_SKILL_ROOT="${tmp_root}/protected-link" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-protected-link.out"
    unrelated_target="$(readlink "${tmp_root}/protected-link/prototype-build")"
    [ "${unrelated_target}" = "${tmp_root}/other-target" ] || fail "install overwrote unrelated symlink"
    grep -Eq '\[skip\].*unrelated symlink' "${tmp_root}/install-protected-link.out" || fail "unrelated symlink protection output is unclear"

    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/uninstall.sh" prototype-build >"${tmp_root}/uninstall-selected.out"
    assert_not_exists "${tmp_root}/skills/prototype-build"

    ln -s "${ROOT_DIR}/families/writing/renamed-skill" "${tmp_root}/skills/renamed-skill"
    ln -s "${tmp_root}/elsewhere" "${tmp_root}/skills/foreign-skill"
    mkdir -p "${CLAUDE_CONFIG_DIR}/.mecha-render/families/collaboration/removed-explicit"
    ln -s "${CLAUDE_CONFIG_DIR}/.mecha-render/families/collaboration/removed-explicit" "${CLAUDE_CONFIG_DIR}/skills/removed-explicit"
    MECHA_SKILL_ROOT="${tmp_root}/skills" "${ROOT_DIR}/uninstall.sh" >"${tmp_root}/uninstall-all.out"
    assert_not_exists "${tmp_root}/skills/renamed-skill"
    [ ! -L "${CLAUDE_CONFIG_DIR}/skills/removed-explicit" ] || fail "full uninstall left a link to a removed rendered adapter"
    [ -L "${tmp_root}/skills/foreign-skill" ] || fail "uninstall pruned an unrelated dangling link"
    rm "${tmp_root}/skills/foreign-skill"
    assert_not_exists "${tmp_root}/skills/prototype-build"
    assert_not_exists "${tmp_root}/skills/user-interview"
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
    assert_not_exists "${tmp_root}/skills/bug-diagnosis"
    assert_not_exists "${tmp_root}/skills/change-review"
    assert_not_exists "${tmp_root}/skills/ai-pipeline"
    assert_not_exists "${tmp_root}/skills/ai-performance"
    assert_not_exists "${tmp_root}/skills/prose-voice"
    assert_not_exists "${tmp_root}/skills/blog-writing"
    assert_not_exists "${CLAUDE_CONFIG_DIR}/skills/prototype-build"
    assert_not_exists "${CLAUDE_CONFIG_DIR}/skills/user-interview"
    assert_not_exists "${CLAUDE_CONFIG_DIR}/CLAUDE.md"
    assert_not_exists "${CLAUDE_CONFIG_DIR}/.mecha-render"

    MECHA_SKILL_ROOT="${tmp_root}/no-claude" CLAUDE_CONFIG_DIR="${tmp_root}/no-claude-config" "${ROOT_DIR}/install.sh" --no-claude prototype-build >"${tmp_root}/install-no-claude.out"
    assert_symlink_to "${tmp_root}/no-claude/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"
    assert_not_exists "${tmp_root}/no-claude-config"

    mkdir -p "${tmp_root}/custom-claude"
    printf 'custom claude instructions\n' >"${tmp_root}/custom-claude/CLAUDE.md"
    if MECHA_SKILL_ROOT="${tmp_root}/custom-claude-skills" CLAUDE_CONFIG_DIR="${tmp_root}/custom-claude" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-custom-claude-abort.out" 2>&1; then
        fail "install should abort when custom Claude instructions exist"
    fi
    grep -Fq 'custom claude instructions' "${tmp_root}/custom-claude/CLAUDE.md" || fail "install modified custom Claude instructions"
    MECHA_SKILL_ROOT="${tmp_root}/custom-claude-skills" CLAUDE_CONFIG_DIR="${tmp_root}/custom-claude" "${ROOT_DIR}/install.sh" --use-custom-global-instructions prototype-build >"${tmp_root}/install-custom-claude-replace.out"
    assert_template_copy "${tmp_root}/custom-claude/CLAUDE.md"
    backup_path="$(sed -n 's/^\[backup\] previous Claude global instructions -> //p' "${tmp_root}/install-custom-claude-replace.out")"
    grep -Fq 'custom claude instructions' "${backup_path}" || fail "custom Claude instructions were not backed up"
    rm -f "${backup_path}"

    MECHA_SKILL_ROOT= CODEX_HOME="${tmp_root}/codex-home" HOME="${tmp_root}/codex-user" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-codex-home.out"
    assert_symlink_to "${tmp_root}/codex-user/.agents/skills/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"
    cmp -s <(rendered_global_template) "${tmp_root}/codex-home/AGENTS.md" || fail "CODEX_HOME global instructions were not installed"
    assert_not_exists "${tmp_root}/codex-home/skills/prototype-build"
    MECHA_SKILL_ROOT= CODEX_HOME="${tmp_root}/codex-home" HOME="${tmp_root}/codex-user" "${ROOT_DIR}/uninstall.sh" prototype-build >"${tmp_root}/uninstall-codex-home.out"
    assert_not_exists "${tmp_root}/codex-user/.agents/skills/prototype-build"

    MECHA_SKILL_ROOT= CODEX_HOME= HOME="${tmp_root}/home" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-home-default.out"
    assert_symlink_to "${tmp_root}/home/.agents/skills/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"
    cmp -s <(rendered_global_template) "${tmp_root}/home/.codex/AGENTS.md" || fail "HOME global instructions were not installed under .codex"
    MECHA_SKILL_ROOT= CODEX_HOME= CLAUDE_CONFIG_DIR= HOME="${tmp_root}/claude-home" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-claude-home-default.out"
    assert_symlink_to "${tmp_root}/claude-home/.claude/skills/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"
    assert_template_copy "${tmp_root}/claude-home/.claude/CLAUDE.md"

    mkdir -p "${tmp_root}/legacy-codex/skills"
    ln -s "${ROOT_DIR}/families/engineering/prototype-build" "${tmp_root}/legacy-codex/skills/prototype-build"
    MECHA_SKILL_ROOT= CODEX_HOME="${tmp_root}/legacy-codex" HOME="${tmp_root}/legacy-home" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-legacy-warning.out"
    assert_symlink_to "${tmp_root}/legacy-home/.agents/skills/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"
    assert_symlink_to "${tmp_root}/legacy-codex/skills/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"
    grep -Fq '[legacy] managed skill links also exist' "${tmp_root}/install-legacy-warning.out" || fail "managed legacy install did not warn"
    grep -Fq "MECHA_SKILL_ROOT=${tmp_root}/legacy-codex/skills ./uninstall.sh" "${tmp_root}/install-legacy-warning.out" || fail "legacy cleanup command is missing or incorrect"

    MECHA_SKILL_ROOT= CODEX_HOME="${tmp_root}/legacy-codex" HOME="${tmp_root}/legacy-home" "${ROOT_DIR}/uninstall.sh" prototype-build >"${tmp_root}/uninstall-preferred.out"
    assert_not_exists "${tmp_root}/legacy-home/.agents/skills/prototype-build"
    assert_symlink_to "${tmp_root}/legacy-codex/skills/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"

    rm "${tmp_root}/legacy-codex/skills/prototype-build"
    ln -s "${tmp_root}/other-target" "${tmp_root}/legacy-codex/skills/prototype-build"
    MECHA_SKILL_ROOT= CODEX_HOME="${tmp_root}/legacy-codex" HOME="${tmp_root}/legacy-home" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-unrelated-legacy.out"
    if grep -Fq '[legacy]' "${tmp_root}/install-unrelated-legacy.out"; then
        fail "unrelated legacy symlink produced a cleanup warning"
    fi

    pass "install and uninstall behavior"
    rm -rf "${tmp_root}"
    trap - EXIT
    unset CODEX_HOME CLAUDE_CONFIG_DIR
}

# Claude receives the same skills; only host adapters are rendered.
claude_install_checks() {
    local tmp_root="$1"
    local claude_skills="${CLAUDE_CONFIG_DIR}/skills"
    local rendered
    local name
    local expected_explicit
    local rendered_explicit
    local render_root="${CLAUDE_CONFIG_DIR}/.mecha-render/families"

    assert_template_copy "${CLAUDE_CONFIG_DIR}/CLAUDE.md"

    # Links from earlier installs migrate to copies without the custom flag.
    mkdir -p "${tmp_root}/migrate-claude"
    ln -s "${CODEX_HOME}/AGENTS.md" "${tmp_root}/migrate-claude/CLAUDE.md"
    MECHA_SKILL_ROOT="${tmp_root}/migrate-skills" CLAUDE_CONFIG_DIR="${tmp_root}/migrate-claude" "${ROOT_DIR}/install.sh" prototype-build >"${tmp_root}/install-migrate.out"
    assert_template_copy "${tmp_root}/migrate-claude/CLAUDE.md"
    grep -Fq '[migrate] Claude global instructions link replaced with a copy' "${tmp_root}/install-migrate.out" || fail "instruction link migration was not reported"
    cmp -s <(rendered_global_template) "${CODEX_HOME}/AGENTS.md" || fail "migration wrote through the old link"
    assert_symlink_to "${claude_skills}/prototype-build" "${ROOT_DIR}/families/engineering/prototype-build"
    for name in user-interview product-co-design multi-step-governance ai-pipeline; do
        grep -Fxq 'disable-model-invocation: true' "${claude_skills}/${name}/SKILL.md" || fail "${name} Claude adapter does not disable model invocation"
    done
    rendered="$(find "${CLAUDE_CONFIG_DIR}/.mecha-render/families" -mindepth 2 -maxdepth 2 -type d | wc -l | tr -d ' ')"
    [ "${rendered}" = 4 ] || fail "expected 4 rendered Claude adapters, got ${rendered}"
    # The installer and validator must agree on which skills are explicit.
    expected_explicit="$(cd "${ROOT_DIR}" && PYTHONDONTWRITEBYTECODE=1 "${DEV_PYTHON}" -c '
import sys
from pathlib import Path
sys.path.insert(0, "scripts")
from validate_skills import explicit_invocation, read_skill
for skill in sorted(Path("families").glob("*/*/SKILL.md")):
    frontmatter = read_skill(skill.parent)[0]
    if frontmatter and explicit_invocation(frontmatter):
        print(skill.parent.name)
' | sort)"
    rendered_explicit="$(find "${CLAUDE_CONFIG_DIR}/.mecha-render/families" -mindepth 2 -maxdepth 2 -type d -exec basename {} \; | sort)"
    [ "${expected_explicit}" = "${rendered_explicit}" ] || fail "installer and validator disagree on explicit skills"
    # Both detectors must agree on every declaration form, not just the repo's.
    # Bash 3.2 cannot source a process substitution, so evaluate the function.
    eval "$(sed -n '/^explicit_invocation()/,/^}/p' "${ROOT_DIR}/install.sh")"
    mkdir -p "${tmp_root}/explicit-forms"
    for value in 'explicit' '"explicit"' "'explicit'" 'explicit  # manual only' 'manual'; do
        printf -- '---\nname: forms\nmetadata:\n    invocation: %s\n---\n' "${value}" >"${tmp_root}/explicit-forms/SKILL.md"
        installer_says=no
        explicit_invocation "${tmp_root}/explicit-forms" && installer_says=yes
        validator_says="$(cd "${ROOT_DIR}" && PYTHONDONTWRITEBYTECODE=1 "${DEV_PYTHON}" -c '
import sys
sys.path.insert(0, "scripts")
from validate_skills import INSTALLER_EXPLICIT_RE
print("yes" if INSTALLER_EXPLICIT_RE.search(open(sys.argv[1]).read().split("---", 2)[1]) else "no")
' "${tmp_root}/explicit-forms/SKILL.md")"
        [ "${installer_says}" = "${validator_says}" ] || fail "installer and validator disagree on invocation: ${value}"
    done
    PYTHONDONTWRITEBYTECODE=1 "${DEV_PYTHON}" "${ROOT_DIR}/scripts/validate_skills.py" --claude-installed-root "${claude_skills}" >"${tmp_root}/validate-claude.out"
    grep -Fq '[ok] Claude adapters' "${tmp_root}/validate-claude.out" || fail "Claude adapters were not validated"

}

use_case_checks() {
    local use_cases="${ROOT_DIR}/shared/use-cases"
    local guide

    grep -Fq 'Never make checks pass by weakening them' "${use_cases}/software-engineering.md" || fail "software engineering check-integrity rule is missing"
    grep -Fq 'analyse the mechanism instead' "${use_cases}/ctf.md" || fail "CTF novel-challenge method is missing"
    grep -Fq 'Draw on your own knowledge deliberately.' "${use_cases}/ai.md" || fail "AI knowledge elicitation is missing"
    for guide in ctf ai; do
        grep -Fq '.mecha/logs/<slug>.md' "${use_cases}/${guide}.md" || fail "${guide} working log is missing"
        grep -Fq 'it never activates or resumes a skill' "${use_cases}/${guide}.md" || fail "${guide} working log claims authority"
    done
    grep -Fq '`.mecha/work/` records require multi-step-governance' "${ROOT_DIR}/templates/global-AGENTS.template.md" || fail "global .mecha boundary is not scoped to work records"
    pass "use-case guides and working notes"
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
    use_case_checks
    ai_family_checks
    writing_family_checks
    metadata_policy_checks
    install_uninstall_checks
}

main "$@"
