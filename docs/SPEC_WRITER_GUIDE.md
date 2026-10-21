# Writing a ladder spec: the spec writer's checklist

**For:** the agent (or person) who writes rung specs for local builders. Most of a rung's outcome is decided here:
in the discovery-junk-filter ladder (21 Oct 2026), the failures with a cause outside the model were all spec-side.
Each step below names the failure it prevents.

The builder is treated like a capable junior: told exactly what to read, what to copy and when it's done, and
never asked to discover the codebase's shape. Behaviour prompts ("be careful", "definition of done", personas)
don't work on these models; structure and specific facts do (avalon-speedway `docs/archive/SCOREBOARD.md`,
`docs/KNOWLEDGE_STRATEGY.md`).

## 1. Orient from the framework, not by walking files

Run `bin/rails-orient APP --models … --routes … --tests …` (model-bench). It prints:
- `bin/rails about` and `stats`;
- `routes -g` for the feature;
- Active Record reflection per model: associations, validations, enums, list constants, callbacks, scopes, columns;
- the nearest existing tests.

Read that before opening any file. For deeper dives: `bin/rails routes --expanded`, `bin/rails middleware`,
`bin/rails initializers`, and the `schema.rb` block for each table.
*Prevents:* a spec built on a guessed model shape. Avalon: 20 of 26 runs never read `db/schema.rb`.

## 2. Find the blast radius before fixing the fence

For every name the change touches (a Struct member, a hash key, a column, a constant, a method), grep the
**existing** tests and callers:
`git grep -n 'diagnostics\.keys\|junk_count' test app`.

Any existing test that asserts on it either goes into `--allow`, with the spec saying how to update it, or the
change is redesigned.
*Prevents:* R5's contradiction. Two diagnostics tests asserted exact key lists the spec required changing, while
the spec forbade editing tests; 0 of 6 could pass. `rails-orient` listed both files under "Nearest existing tests".

## 3. Prove the fence with a reference build

Before release, build the rung once yourself (or with a cloud model) on the base branch. Then check:
- the acceptance test and the full suite are green;
- `git diff --name-only` is inside `--allow`;
- the line count is inside the budget.

Record it in LADDER.md as "reference: N files, M lines". Throw the code away; never give it to the builder.
*Prevents:* unpassable rungs, and budgets set by guesswork.

## 4. Turn every rule into test rows, both ways

For each clause of a rule ("split on spaced dashes", "whole words", "leading spaces allowed"), put at least one
title that must match and one look-alike that must not in the acceptance test. Add a **Look-alikes** table to the
spec:

| Looks like | Is | Because |
|---|---|---|
| "Dallas-Fort Worth news" | article | a bare hyphen is not a separator |
| "[PDF] Cataloging emissions" | article | "catalog" must be a whole word |
| "  [pdf] Council minutes" | catalogue | leading spaces are allowed |

*Prevents:* builds that pass the test but break the rule. Every R5 build missed at least one stated rule; one test
row each would have caught them. Models satisfy the assertions they see.

## 5. The red check, with the runner's prerequisites

Run the acceptance test and the full suite at the base. Record the exact counts and error messages in LADDER.md.
Make sure the runner sets up what a fresh worktree lacks (for client-app: Tailwind build, `master.key`).
*Prevents:* suite failures that have nothing to do with the builder (385 errors before Step 0).

## 6. Write the builder-facing spec

In this order, short:
1. **Not in scope first** (files and areas it must not touch). Cheap models skip a DO NOT section at the end.
2. **Goal**, one paragraph, in domain words.
3. **Read first:** file plus the exact line to find (`find the line def link_ratio(text)`). Paste the relevant
   `rails-orient` lines for the models involved (≤ 2 KB). Don't paste the whole pack.
4. **Pattern to copy:** one existing example per change.
5. **Change:** numbered, per file, with the facts it relies on pasted (Rails API behaviour, the existing helper's
   meaning).
6. **Look-alikes** table (§4).
7. **Acceptance test**, pasted.
8. **Done means:** the two commands, then "stop and call finish". Add one move-on line: *"If a test still fails
   after two fixes, stop probing; change the code and rerun the test."* (Avalon: an instruction to move from
   investigating to editing took a task from 0 edits to a pass, 3 of 3.)

Keep each rung to one decision. Budget from the reference build, plus about 50%.

## 7. What not to put in a spec
- Large retrieved docs: 12 KB made no difference and cost 52% more steps.
- "Definition of done" prose: made things worse.
- Personas.
- Hints that solve the rung.
- The reference build.

## 8. Before release (LADDER.md)
- [ ] Per rung: base branch and commit (test file only), runner line, budget from the reference build.
- [ ] Red check counts recorded; reference build green, inside `--allow`.
- [ ] Every rule clause has a must-match and a must-not-match row.
- [ ] Every existing test asserting on a touched name is in `--allow` (with instructions) or the design avoids it.
- [ ] A review checklist per rung for the morning, plus the reading rule for results, written before the run.
