# Refactoring Patterns

Reference for safe, incremental refactoring during large codebase changes.

---

## Core principle

**Refactoring changes structure, not behavior.** If the observable behavior changes, it is not a refactor — it is a feature change or a bug fix. Keep these in separate commits.

## Common safe moves

| Move | What it does | Risk level |
|---|---|---|
| Extract function | Pull a block of code into a named function | Low |
| Inline function | Replace a function call with its body | Low |
| Rename | Change the name of a variable, function, class, file | Low (with IDE support) |
| Extract variable | Replace a subexpression with a named variable | Low |
| Move function | Relocate a function to a more appropriate module | Low-medium |
| Split loop | Separate a loop doing two things into two loops | Low |
| Replace conditional with polymorphism | Replace type-checking if/switch with method dispatch | Medium |
| Replace magic number with constant | Name a literal value | Low |
| Introduce parameter object | Group related parameters into a single object | Medium |
| Pull up / push down method | Move a method to a parent or child class | Medium |
| Replace nested conditional with guard clause | Invert conditions and return early | Low |
| Decompose conditional | Extract complex condition into a named function | Low |

## When to refactor

Refactor when the current structure actively impedes the change you are making:

- **Duplicated logic** that you need to modify in multiple places — extract first, then change once
- **Unclear control flow** that makes it hard to verify your change is correct
- **Mixed concerns** where the function you need to change does three things and you need to change one
- **Dead code created by your change** — remove what your change made obsolete
- **Naming that misleads** about what code actually does, causing you to misunderstand it

## When NOT to refactor

- **Adjacent code not related to your change** — leave it alone
- **"While I'm here" improvements** — file a ticket or note it; do not mix with the current change
- **Style preferences** — match existing style, do not unilaterally modernize
- **Working code you find ugly but correct** — cosmetic displeasure is not a reason
- **Code you don't fully understand** — you cannot safely restructure what you cannot reason about
- **Code without test coverage** — add tests first, or accept you cannot safely refactor it

## Refactoring with tests

```
1. Verify tests cover the behavior you are about to restructure
   - If coverage is missing, add characterization tests first
   - Characterization test: call the code, assert whatever it actually does

2. Make one structural move

3. Run tests

4. If tests pass → commit; if tests fail → revert the move and investigate

5. Repeat from step 2
```

**Never skip step 1.** Refactoring untested code is guessing.

## Large refactors: incremental commits

Break large refactors into a chain of small, independently valid commits.

Each commit must:
- [ ] Compile / parse without errors
- [ ] Pass all tests
- [ ] Be a single logical move (rename, extract, move — not all three)
- [ ] Have a commit message naming the specific move

**Example chain for "split a god class":**
```
commit 1: Extract validation logic into Validator class
commit 2: Extract persistence logic into Repository class
commit 3: Extract notification logic into Notifier class
commit 4: Remove now-empty methods from original class
```

Each commit is reviewable, revertable, and bisectable on its own.

## Strangler fig pattern

For replacing a large subsystem incrementally rather than rewriting it all at once:

```
1. Identify a seam: a boundary where the old and new code can coexist
2. Build the new implementation behind the seam
3. Route one caller at a time from old → new
4. Verify each caller works correctly after switching
5. When no callers remain on the old code, remove it
```

**Advantages:**
- The old system keeps working throughout
- You can stop partway through and still have a working system
- Each step is small and testable

**Use when:** replacing frameworks, rewriting core modules, migrating between architectures.

**Do not use when:** the change is small enough to do in one pass.

## Common traps

| Trap | Why it's dangerous | Mitigation |
|---|---|---|
| Refactoring + adding features in the same commit | If something breaks, you cannot tell if the refactor or the feature caused it | Separate commits: refactor first, then add feature |
| Refactoring untested code | No way to verify behavior is preserved | Add characterization tests first |
| Refactoring across too many files at once | Review becomes impossible, merge conflicts multiply | Limit each commit to one logical move |
| Renaming without updating all references | Broken imports, dead code, subtle bugs | Use IDE rename; grep for the old name afterward |
| Extracting too-small functions | Code becomes harder to follow, not easier | A function should do one coherent thing; 2-line extractions rarely help |
| Refactoring toward a design you haven't validated | You may restructure code toward the wrong abstraction | Refactor to make the next change easy, not toward a theoretical ideal |
| Big-bang rewrite disguised as a refactor | Combines structural change with behavior change | If you want different behavior, that is a separate change |

## Decision: refactor now vs later

```
Is the current structure blocking your change?
├── Yes → Refactor first, then make the change
└── No
    ├── Is the messy code causing bugs? → Note it for a dedicated cleanup task
    └── Is it just ugly? → Leave it alone
```
