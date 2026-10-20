# Run 6: agentic ×5 for the builder candidates (2026-10-20)

**What:** the agentic task only (`tasks/slugify`, 4 failing Minitest tests), repeated until each of the five builder
candidates had **5 attempts under Run 2 settings**: 10-minute box, up to 30 turns, 4,096 tokens per turn. Each model's
Run 2 attempt counts as its first; Ornith 8-bit's Run 5 attempt counts as its second. Run 1 attempts (2-minute box,
15 turns) are not counted, because the rules were different.

**Why:** one or two attempts couldn't separate the candidates. Ornith 8-bit failed and then passed under identical
settings (Runs 2 and 5), so results vary between attempts even at temperature 0. The tuning gate asks for at least 2 of 3.

**Where:** all attempts ran on the MBP-14, except Qwen3.8-27B 4-bit's attempt in `a1`, which ran on the MBP-16
(same hardware, oMLX 0.7.1rc1, Splash). The plan was to split the run across both MacBook Pros. The MBP-16 lane was
stopped after that one attempt: its oMLX server restarted by itself at 15:59, during Qwen3.6-35B-A3B 8-bit's attempt,
and that Mac was also serving other jobs from its pinned model. The interrupted attempt is not counted. The remaining
MBP-16 attempts were run on the MBP-14.

## Result

| Model | Run 2 | Run 5 | Run 6 attempts | **Solved** | Turns when solved | Time when solved | Failures |
|---|---|---|---|---|---|---|---|
| Qwen3.8-27B 4-bit | ✓ | — | ✓ ✓ ✓ ✓ | **5 of 5** | 6, 6, 6, 6, 6 | 45–117 s | — |
| Qwen3.6-35B-A3B 8-bit | ✓ | — | ✓ ✓ ✓ ✓ | **5 of 5** | 8, 7, 6, 7, 8 | 48–81 s | — |
| Ornith-1.5-35B-A3B MLX 4-bit | ✓ | — | ✓ ✓ ✗ ✓ | **4 of 5** | 8, 7, 16, 6 | 79–201 s | 1 × gave up (`no_tool_call`, 11 turns) |
| Qwen3.6-35B-A3B 4-bit | ✗ | — | ✓ ✗ ✓ ✓ | **3 of 5** | 9, 9, 10 | 72–87 s | 2 × gave up (`no_tool_call`, 5 and 8 turns) |
| Ornith-1.5-35B-A3B MLX 8-bit | ✗ | ✓ | ✓ ✗ ✓ | **3 of 5** | 15, 8, 8 | 109–174 s | 2 × gave up (`no_tool_call`, 8 and 14 turns) |

✓ solved (all 4 tests pass), ✗ not solved. Every failure was the same: the model replied in plain text instead of
calling a tool, and stopped. None ran out of time or turns.

## Every attempt in this run

| Attempt | Model | Mac | Solved | Turns | Stop | Seconds |
|---|---|---|---|---|---|---|
| a1 | Qwen3.6-35B-A3B 4-bit | MBP-14 | ✓ | 9 | finish | 82 |
| a1 | Qwen3.8-27B 4-bit | MBP-16 | ✓ | 6 | finish | 117 |
| a1 | Ornith-1.5 MLX 8-bit | MBP-14 | ✓ | 8 | finish | 109 |
| a2 | Qwen3.6-35B-A3B 4-bit | MBP-14 | ✗ | 8 | no_tool_call | 110 |
| a2 | Ornith-1.5 MLX 8-bit | MBP-14 | ✗ | 14 | no_tool_call | 269 |
| a2 | Qwen3.8-27B 4-bit | MBP-14 | ✓ | 6 | finish | 98 |
| a2 | Qwen3.6-35B-A3B 8-bit | MBP-14 | ✓ | 7 | finish | 81 |
| a2 | Ornith-1.5 MLX 4-bit | MBP-14 | ✓ | 7 | finish | 111 |
| a3 | Qwen3.6-35B-A3B 4-bit | MBP-14 | ✓ | 9 | finish | 87 |
| a3 | Ornith-1.5 MLX 8-bit | MBP-14 | ✓ | 8 | finish | 161 |
| a3 | Qwen3.8-27B 4-bit | MBP-14 | ✓ | 6 | finish | 115 |
| a3 | Qwen3.6-35B-A3B 8-bit | MBP-14 | ✓ | 6 | finish | 74 |
| a3 | Ornith-1.5 MLX 4-bit | MBP-14 | ✓ | 16 | finish | 201 |
| a4 | Qwen3.6-35B-A3B 4-bit | MBP-14 | ✓ | 10 | finish | 72 |
| a4 | Qwen3.8-27B 4-bit | MBP-14 | ✓ | 6 | finish | 113 |
| a4 | Qwen3.6-35B-A3B 8-bit | MBP-14 | ✓ | 7 | finish | 66 |
| a4 | Ornith-1.5 MLX 4-bit | MBP-14 | ✗ | 11 | no_tool_call | 161 |
| a5 | Qwen3.6-35B-A3B 8-bit | MBP-14 | ✓ | 8 | finish | 48 |
| a5 | Ornith-1.5 MLX 4-bit | MBP-14 | ✓ | 6 | finish | 86 |

Attempt folders `a1`–`a5` hold one JSON file per model (full tool calls) and the harness's own table. Logs:
`results/logs/run-2026-10-20-agentic5-*.log` (`mbp14` = first MBP-14 lane, `mbp14b` = the MBP-16 lane's models
rerun on the MBP-14, `mbp16` = the stopped MBP-16 lane).

## Notes

- Qwen3.8-27B 4-bit took about twice as long per attempt here (98–117 s) as in Run 2 (45 s), with the same 6 turns.
  Not investigated; load order and cache state differ between runs.
- The Weights v2 summary below still uses Run 2's single agentic result. Whether to score agentic as solved ÷ attempts
  is an open decision.

## Correction (added later on 2026-10-20)

Two statements above about the MBP-16 were wrong, and are corrected here rather than edited, to keep the record:
- **It wasn't an oMLX restart.** The whole Mac kernel-panicked and rebooted at 15:59 ("Sleep transition timed out …
  Suspected bundle: IOThunderboltFamily"), one of 10 such panics since 2026-10-19 15:08. Cause and fix: Run 9's page.
- **It wasn't serving other jobs during this run.** Its log shows no other client between 15:54 and 15:59; the
  newsletter job had last called it at 08:26.
- Also found later: its oMLX settings for Qwen3.6-35B-A3B 8-bit (no Splash) and Qwen3.8-27B 4-bit (TurboQuant KV off)
  differ from the MBP-14's. The interrupted attempt is kept in `mbp16-stopped/` and is not counted.
