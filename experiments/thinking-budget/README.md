# Experiment: thinking budgets for the builders

**Status:** planned, 2026-10-20. Not started.
**Question:** how much thinking does each builder need? Can a cap, or thinking off, keep its accuracy and agentic
reliability while cutting time per answer?

## Why

- **Qwen3.6-35B-A3B 8-bit** is the most accurate local builder (151/161, agentic 9 of 10) but thinks at length:
  26 s per short answer. Overnight the clock matters less, but on real slices every turn of thinking is repeated per
  tool call, so the time adds up.
- **Qwen3.8-27B 4-bit** runs with thinking **off** (`enable_thinking: false` in its oMLX settings) and answers in about
  75 tokens: 85%, 4.5 s. Does turning thinking **on**, or on with a cap, buy accuracy at an acceptable cost?
- The 2026-10-20 cloud comparison (Run 8) puts GLM-5.3 Flash at 96% and 9 s. A tuned local model has to close some of
  that gap to earn its keep.
- Gemma-4-26B showed that more room doesn't help a model that gets stuck (`results/2026-10-20-gemma32k/`); a budget
  is the other direction.

## Knobs available

| Knob | Where | Notes |
|---|---|---|
| `enable_thinking` (on/off) | Per request (`chat_template_kwargs`) or per model in oMLX settings | Per request is preferred: no change to shared settings |
| `thinking_budget_enabled` + budget | Per model in oMLX settings | Currently off for every model on both Macs. **Unverified: whether Splash honours it** (Splash runs both builders) |
| `max_tokens` | Per request | A hard cut-off, not a budget: a cut-off answer fails |
| Prompt ("think briefly") | Per request | Cheap; reasoning models often ignore it |

Step 0 is to confirm which of these Splash actually applies (send one request each way, compare reasoning tokens).

## Method

Same harness and rules as the benchmark runs, so rows compare with `RESULTS.md`:
- **Coding:** all 161 HumanEval-Ruby problems at 8,192 tokens, no time cap. Record pass rate, pass rate excluding
  cut-offs, s per answer, reasoning tokens per answer.
- **Agentic:** the slugify task 5 times under Run 2 rules (10-minute box, 30 turns).
- **Later, the real test:** the same settings on the slice-size ladder rungs (`docs/PLANNER_BUILDER_PLAN.md`).

Variants, cheapest first:

| # | Builder | Thinking | Budget |
|---|---|---|---|
| T1 | Qwen3.6-35B-A3B 8-bit | off | — |
| T2 | Qwen3.6-35B-A3B 8-bit | on | 1,024 |
| T3 | Qwen3.6-35B-A3B 8-bit | on | 2,048 |
| T4 | Qwen3.8-27B 4-bit | on | none |
| T5 | Qwen3.8-27B 4-bit | on | 1,024 |

Baselines: Qwen3.6-35B-A3B 8-bit thinking on, no budget (Run 3: 151/161, 26.1 s); Qwen3.8-27B 4-bit thinking off
(Run 7: 136/161, 4.5 s). Both on the MBP-14 with Splash, the settings recorded in each result file.

## Stop rules (from `docs/TUNING_TODO.md`)

- Stop a variant line at the first experiment that costs **more than 5 points** of accuracy or drops agentic below
  4 of 5.
- At most half a day of effort per builder.
- Any variant that wins goes into that builder's profile card (runtime settings) and `DECISIONS.md`.

## Results

| # | Date | Mac | Pass / 161 | Pass excl. cut-off | s / answer | Reasoning tokens / answer | Agentic | Notes |
|---|---|---|---|---|---|---|---|---|
| | | | | | | | | |

Raw outputs go in this folder, one subfolder per variant (`t1/`, `t2/`, …).
