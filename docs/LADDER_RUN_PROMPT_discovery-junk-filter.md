# Prompt: run the discovery-junk-filter slice ladder (client-app × model-bench)

You are the orchestrator for an overnight slice-ladder run on the Mac mini. You run specs against local builder
models and record results. You never write app code yourself and you never edit an acceptance test.

## Read first
1. `~/Development/repos/model-bench/docs/PLANNER_BUILDER_PLAN.md`: what the ladder measures, the builder
   profile card you produce, and the August lessons (verify model routing; suspect the serving stack first).
2. `~/Development/repos/model-bench/docs/MAC_SERVING.md`: how the two MacBook Pros serve models. Follow it;
   don't install, upgrade or reconfigure oMLX or Splash.
3. `~/Development/repos/model-bench/experiments/mbp-parity/README.md`: why Qwen3.6-35B-A3B 8-bit must run
   on oMLX's **plain** engine (on Splash it loops in multi-turn work from cold: 0 of 16).
4. `~/Development/repos/model-bench/bin/ladder`: the runner. Read it end to end. It makes a worktree from
   `--base`, unloads every model on the chosen Mac, empties that builder's Splash cache, loads the builder, runs pi with
   a per-run config, then verifies independently and writes one result JSON (with `start_state`, `macos`, `omlx`,
   `engine`). It does **not** restore the Mac's usual models: you do that at the end.
5. In client-app, branch `ladder/discovery-junk-filter-specs`, folder `doco/specs/ladder/discovery-junk-filter/`:
   `LADDER.md` first (rung table, per-rung base branches, runner lines, review checklist), then `R1.md`–`R5.md`.
   Main doesn't have these files. The base branches `ladder/discovery-junk-filter-r1-base` … `r5-base` are local on
   the mini (not on GitHub). Make a worktree for the specs:
   ```
   git -C ~/Development/repos/client-app worktree add \
     ~/Development/runs/ladder-specs ladder/discovery-junk-filter-specs
   ```
   and pass `--spec ~/Development/runs/ladder-specs/doco/specs/ladder/discovery-junk-filter/R<N>.md`.

## Step 0: fix the runner (model-bench, commit it)
`LADDER.md` "Runner prerequisites": a fresh client-app worktree needs, after `bin/rails db:prepare`,
`bin/rails tailwindcss:build` and a copy of `config/master.key` from `--repo` into the worktree. Without them 385 tests
error ("Missing Active Record encryption credential", "The asset 'tailwind.css' was not found") and every `--suite`
check fails for reasons unrelated to the builder. Add both to `bin/ladder` right after the `db:prepare` line.
Prove it: in a throwaway worktree of `ladder/discovery-junk-filter-r1-base` with those steps applied, `bin/rails test`
must show exactly 4 errors (all "undefined method 'index_title?'") and 0 failures. Remove the throwaway worktree.
Don't change anything else in `bin/ladder`. Commit in model-bench (don't publish; the operator publishes).

## Step 1: pre-flight, per Mac
Builders and Macs (one model per Mac, both run at once):

| Builder (`--builder`) | Model | Mac | Engine it must report |
|---|---|---|---|
| `qwen38-4bit@mbp14` | Qwen3.8-27B 4-bit, thinking off | MBP-14 (`mbp14-omlx` in `config/hosts.yml`) | `splash` |
| `qwen36-8bit@mbp16` | Qwen3.6-35B-A3B 8-bit, thinking on | MBP-16 (`mbp16-omlx`) | `plain` |

For each Mac: oMLX healthy (`curl <base>/health`), the intended model loads, and after a one-line smoke prompt through
pi (the same flags `bin/ladder` uses) pi's log names that model, not a fallback. Check the engine with
`pgrep -f 'splash serve'` on that Mac (present = splash). If Qwen3.6 shows `splash`, **stop and report**: don't change
oMLX settings yourself. Record macOS, oMLX version and engine per Mac. Note each Mac's loaded models before you start
(you restore them at the end). If a Mac is down, run the other and say so.

## Step 2: the runs
Use the five runner lines in `LADDER.md` verbatim (base branch, `--verify`, `--suite`, `--test-file`, `--allow`), with
`--spec` pointing at the ladder-specs worktree, `--builder` from the table above, and
`--out results/ladder/discovery-junk-filter` (relative to model-bench).
- **Order:** attempt 1 of R1→R5 on both builders (the two Macs concurrently; rungs serial per Mac). Then attempts 2 and
  3 of every rung, so each rung has 3 attempts per builder (`--attempt N`). `--timeout-min 45` (60 for R5).
- **Run each Mac's queue as a detached job** (`bash -c 'set -m; nohup <queue-script> >log 2>&1 &'`), independent of the
  OpenClaw Gateway: a Gateway restart kills anything started from an agent's shell. Write a queue script per Mac that
  runs its rungs in order and touches a `.done` file; poll the result JSONs, don't hold one long turn.
- **Rules:** never edit the worktree, the app or a test file to get a pass; no hints to the builder; never push attempt
  branches; never deploy; never touch main.
- **Stack failures:** if an attempt fails on the stack (model not loaded, wrong model in pi's log, Splash on Qwen3.6,
  context cap, tool-format leak, oMLX error, Mac unreachable), record it as a stack failure, fix only what you're
  allowed to (reload the model, rerun), rerun that attempt, and don't count it against the builder. Anything that needs
  an oMLX settings change: stop that Mac's queue and report.

## Step 3: report
Write `results/ladder/discovery-junk-filter/REPORT.md` in model-bench:
- a table: rung × builder × attempt → passed, verify, suite, test_file_untouched, outside_allowed, turns, tool_calls,
  pi_seconds, stop reason, start_state, engine, failure mode (gave up in plain text / looped / declared done with tests
  failing / ran out of tokens or time / stack);
- for each failed attempt, three lines on what the diff did wrong (use `LADDER.md`'s review checklist; read the attempt
  branch's diff against its base);
- a draft builder profile card per model in the `PLANNER_BUILDER_PLAN.md` shape: envelope (largest rung passed at least
  2 of 3), phrasing that worked, weaknesses seen, context it needed, runtime settings (engine, thinking, token limits,
  Mac).

Don't merge any attempt branch. Leave the worktrees for morning review and list their paths in the report.
At the end, put each Mac's usual models back (the ones you noted in Step 1) through oMLX's admin API.
Stop when the report is written, or when both Macs are unusable; say which.
