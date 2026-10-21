# Plan: frontier planner + local builder

**Status:** proposed 2026-10-20. Next step once the Ornith 8-bit and Gemma 32k runs have reported.

## The shape (Mark, 2026-10-20)

- A **frontier model** (subscription) is the planner. It breaks a feature into specs a **local builder**
  model can deliver. We already know the planner can do this for *cloud* builders: the cloud flash builder
  (Colin) delivered SPEC-005-B end to end in September.
- The experiment answers two questions:
  1. **Which local model is the best builder?**
  2. **What does the planner need to know about that builder** to size and phrase specs so the builder
     does everything it's capable of, and nothing beyond it?
- The output isn't a leaderboard. It's a **builder profile** per model that goes into the planner's context.

## Starting point (already known)

An earlier internal note (August 2026, *Agent-Executor Pair Prompt Model*)
set out this pattern and some first slicing rules:
- one primary file and one verification command per slice;
- about 150 lines of change at most;
- an explicit "if tests pass, stop" instruction;
- route by task type.

Its model matrix is out of date: the models and quantisations have changed, and it was measured on one tiny slice.

model-bench (2026-10-19/20) adds:
- Ruby accuracy and pace per model;
- agentic finish rate on a small fix;
- how verbose each model is (tokens per answer, cut-offs);
- each model's failure mode:
  - **gives up** by replying in plain text;
  - **loops** on edits;
  - **declares done with tests failing**;
  - **runs out of tokens** while thinking.

## Candidate builders (MLX, one per Mac)

| Model | Why it's in |
|---|---|
| Qwen3.8-27B 4-bit | Best all-rounder: 85%, 4.4 s/problem, finishes the agentic task, reads images |
| Qwen3.6-35B-A3B 8-bit | Most accurate: 94% at 8,192 tokens, finishes the agentic task, reads images; slow (26 s/problem) |
| Ornith-1.5-35B-A3B MLX (4-bit or 8-bit, whichever wins today) | Built for coding agents, finishes the agentic task; text only |

## The experiment: a slice-size ladder

The planner writes specs for one real feature at graded sizes. Each candidate builder runs every rung
overnight, with the same harness, tools and verification command.

| Rung | Slice |
|---|---|
| 1 | One method plus its unit test, in an existing file |
| 2 | One new file (model or service) plus tests |
| 3 | Two or three files: model, migration, tests |
| 4 | A vertical slice: route, controller, view, tests |
| 5 | A small whole feature: several slices in one spec |

**Recorded per rung:**
- pass or fail against the verification command;
- turns used and wall time;
- tokens;
- the failure mode, if it failed;
- **your review and fix minutes**.

**Result:** each builder's **capability envelope**, i.e. the largest rung it passes reliably (at least 2 of
3 runs), and how it fails just above that rung.

## The builder profile (what the planner is given)

For each builder, a short, factual card:
- **Envelope:** the largest reliable slice size, in files, lines and steps.
- **Phrasing that works:** e.g. an explicit stop condition, naming the exact test command, giving file paths.
- **Known weaknesses:**
  - Rails 8 APIs it doesn't recall (e.g. `rate_limit`, `normalizes`), and so needs docs supplied;
  - how verbose it is, and the token budget it needs;
  - which failure modes to guard against.
- **Context it needs:** RAG excerpts, app models and routes, conventions.
- **Runtime settings:** thinking on or off or budget, token limit, turn limit, and which Mac.

The planner reads the card when writing specs. When a builder fails, the failure goes back into its card,
which is the start of the self-learning loop.

## Lessons from the August bake-off (the client's project, SPEC-024-1)

The August 2026 local-model bake-off ran real the client's project specs in worktrees (`client-bench-*`). Reports are in
`~/.openclaw/workspace/doco/model-ops/benchmarks/` (`2026-08-26_GEMMA12B_FINAL.md`, `..._PREFLIGHT.md`,
`2026-08-28_QWEN38_FORENSIC_REPORT.md`, `2026-09-07_LEMANS_AGENTIC_FORENSIC_REPORT.md`, `BENCHMARK_METHODOLOGY.md`).
What carries over to the ladder:
- **Verify model routing before every run.** OpenClaw silently fell back to a cloud model when a local model ID didn't
  match its provider config; a "Gemma" run was really DeepSeek. `bin/ladder` runs pi with a per-run config naming one
  model, and records the engine; the orchestrator must still check the model in pi's log.
- **Context limits and token caps are config, not model, failures.** Gemma's first run died at a stale 32K context cap;
  Qwen3.8 ran out of context after 138 turns. Size rungs to stay well inside the context, and record prompt size per turn.
- **Tool-format leaks** (IQuest, Gemma run 2) and **serving-stack bugs** (oMLX 0.6.3 TTL bug) looked like model
  failures. The 2026-10-20 Splash finding (`experiments/mbp-parity/`) is the same class. Suspect the stack first.
- **Fast-fail limits** (prompt size, turns, elapsed time, swap growth) and a pre-flight and post-run checklist per attempt.

## Out of scope for now

Speed tuning (`docs/TUNING_TODO.md`), fine-tuning, and tickets/bug work. Tickets come later, once apps have
customers, and are a likely good fit for local overnight agents.
