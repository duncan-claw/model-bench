# Prompt: write slice-ladder specs for a local builder

Use this **after** the requirements and analysis for the feature are done in the session. Paste it, or say
"follow `~/Development/repos/tr-solutions/model-bench/docs/LADDER_SPEC_PROMPT.md`".

---

You are the **planner**. We've agreed the feature in this session. Now write it as a **slice ladder**: the same
feature cut into five specs of increasing size, each to be built overnight by a **local builder model**, not by you
and not by a cloud model. The point is to measure the largest slice each builder delivers reliably, so the specs
must be built for a small model and they must make pass/fail objective.

## Who the builder is

Two local models, one per MacBook Pro (M1 Max, 64 GB, oMLX, MLX 4-bit/8-bit):
- **Qwen3.8-27B 4-bit:** fast (about 4 s per short answer), solved a small 4-test fix 5 of 5 times, reads images.
- **Qwen3.6-35B-A3B 8-bit:** most accurate (94% on HumanEval-Ruby), slower (thinks at length), solved it 5 of 5.

What the evidence says about models like these:
- **They finish small, well-bounded fixes;** they have not been tested on anything bigger. That's what this measures.
- **Their failure mode is giving up:** they stop and reply in plain text. Guard against it with an explicit stop
  condition and a single command that tells them whether they are done.
- **They don't reliably recall Rails 8 APIs** (`normalizes`, `rate_limit`, `generates_token_for`, Solid Queue,
  Turbo 8 morphing, Rails 8 auth generator). If a slice needs one, **paste the relevant doc excerpt into the spec.**
- **Context is limited.** Assume about 32k tokens of working context in practice. A spec must not require reading
  more than about 6 files or 1,500 lines of existing code to do its job.
- **They copy what they see.** Point at one existing file in the app that is the pattern to copy.

## Before you write anything

1. Read `Gemfile.lock` for the real stack (Rails, Turbo, Stimulus, Solid Queue, test framework). Don't quote versions
   from READMEs or memory.
2. Record the **base commit** (`git rev-parse HEAD` on the branch we'll build from). Every rung starts from this
   same commit. Rungs do **not** build on each other, so a failure at one rung doesn't block the next.
3. Read the app's own spec conventions (e.g. `doco/specs/`, `doco/TEST_CONTRACT.md`, `AGENTS.md`) and follow its
   test framework and style. Those existing specs are written for a frontier builder. **These are deliberately
   much shorter and more literal.**

## The five rungs

| Rung | Slice | Size budget |
|---|---|---|
| R1 | One method plus its unit test, in an existing file | 1 file changed, ≤ 40 lines |
| R2 | One new file (model, concern or PORO) plus tests | 1–2 files, ≤ 100 lines |
| R3 | Two or three files: e.g. migration, model, tests | 2–3 files, ≤ 150 lines |
| R4 | A vertical slice: route, controller, view, tests | 4–6 files, ≤ 250 lines |
| R5 | The whole feature (or a coherent small feature): several slices in one spec | ≤ 10 files, ≤ 500 lines |

Choose cuts that are real pieces of this feature, so the ladder's output is useful even if only the lower rungs pass.
If the feature is too small for R5, say so and make R5 the whole feature; if it's too big, R5 is the first coherent
release of it, and say what's left.

## What every rung spec contains (in this order, short)

1. **Goal:** one or two sentences, in plain words.
2. **Base commit** and **branch to create:** `ladder/<feature>-r<N>-<builder>` (the runner fills in `<builder>`).
3. **Read first:** the exact files, at most 6, each with why. Quote an anchor line rather than relying on line numbers.
4. **Pattern to copy:** one existing file and what to copy from it.
5. **Change:** the exact files to create or edit, and for each the contract: class and method names, signatures,
   columns and types, route lines, what the view shows. Leave the implementation to the builder.
6. **Acceptance tests (provided):** a complete test file, written by you, that the builder must make pass and must
   **not edit**. Put it at its real path in the app. Cover the behaviour, not the implementation. Name the file in
   the spec and include it verbatim.
7. **Done means:** the single verification command (e.g. `bin/rails test test/models/event_test.rb`), then the
   full-suite command, both green. Then: **"When both pass, stop and call finish. Do not refactor or add anything
   else."**
8. **Not in scope:** what the builder must not touch (other files, gems, migrations outside this rung, styling).
9. **Docs supplied:** any API excerpt the builder needs (Rails 8 or app-specific), pasted, not linked.
10. **Environment notes:** anything a fresh shell needs (e.g. rbenv PATH, `RAILS_MASTER_KEY`, `bin/rails db:prepare`).

Keep each rung spec under about 120 lines, excluding the pasted test file and doc excerpts.

## Prove each rung before handing it over

For every rung, on a scratch branch from the base commit:
1. Add only the acceptance test file and run the verification command. It must **fail for the right reason**
   (missing method or route, not a syntax error or a broken fixture). Record the failure line.
2. Run the full suite with the test file added, so you know the baseline is otherwise green.
3. Delete the scratch branch. **Don't** write the implementation. The builder does that.

## Deliverables

Write, in the app repo, under `doco/specs/ladder/<feature>/` (or the app's equivalent):
- `R1.md` … `R5.md`, one spec per rung, plus the acceptance test files they include.
- `LADDER.md`: the feature in two lines, the base commit, a table of rungs (goal, files, line budget, verification
  command, red-check result), and a **review checklist** per rung (what I check when I review the builder's diff
  in the morning: e.g. no edits outside listed files, test file untouched, conventions followed).
- Don't commit to main and don't build anything. Commit the specs on a branch `ladder/<feature>-specs` and tell me
  the branch and commit.

## Report back (under 200 words)

The feature, the base commit, the five rungs in one line each, red-check results, anything that didn't fit the
budgets and how you cut it, and any doc excerpts you had to supply. Use absolute file paths.
