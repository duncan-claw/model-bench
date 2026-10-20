# Experiment: why did Qwen3.6-35B-A3B 8-bit pass on one Mac and fail on the other?

**Date:** 2026-10-20 evening. **Status:** cause narrowed to Splash serving state; working setting found.

## Symptom

After moving Qwen3.6-35B-A3B 8-bit to the Splash engine on the MBP-16 (to match the MBP-14), the agentic task
(slugify, Run 2 rules) failed 3 of 3 on the MBP-16 while the MBP-14 passed 3 of 3. Every failure was identical:
turn 1 `list_files` (94 tokens), turn 2 two `read_file` calls (75 tokens), turn 3 thinks until the per-turn limit
and is cut off before calling a tool (`no_tool_call`).

## What was tested

| # | Test | Result |
|---|---|---|
| 1 | Model files, draft model, Splash version and settings, Splash launch flags on both Macs | Identical (sizes and hashes), apart from cache size |
| 2 | Both services stopped, all of `~/.omlx/cache` emptied (83 GB / 422 GB), restarted, 3 attempts each | **Both Macs 0 of 3**, same failure. Not a Mac difference: the MBP-14's earlier passes came with a warm cache |
| 3 | The exact failed turn-3 request (from oMLX's trace log) replayed alone with curl, limits 4k / 8k / 32k, ×10 | **Passes every time** (491 or 1,858 tokens, ends in a tool call) |
| 4 | The exact logged turn 1 → 2 → 3 bodies replayed in order after a fresh model load, ×3; after emptying the model's Splash cache, ×3; after a full cold service restart, ×2 | **Passes every time.** Turn 2 gives 74 tokens (live harness: 75), turn 3 gives 19 tokens and calls `run_tests` |
| 5 | The harness itself, same state, ×2 | **Fails every time** (4,096, cut off) |
| 6 | Harness with a 2 s pause before every turn | Fails 2 of 2: not a timing race |
| 7 | What the harness actually sends, captured (`captures/req-1..3.json`) | Byte-identical to the logged bodies apart from tool-call IDs; same 865 prompt tokens |
| 8 | The captured harness turn-3 request replayed alone ×3, and with the log's IDs swapped in | Passes every time |
| 9 | Harness with 8,192 tokens per turn ×3 | Fails 3 of 3: turn 3 runs to 8,192 too. **It loops; it isn't borderline** |
| 10 | Qwen3.6-35B-A3B 8-bit back on oMLX's plain engine (MBP-16), harness ×3 | **Passes 3 of 3** (15, 10, 6 turns) |

## Reading

- At temperature 0, with Splash, this model's output depends on what Splash has just processed, not only on the
  request: the same turn-3 request passes when sent on its own and loops when it follows the same run's turns 1 and 2.
  The live sequence is itself repeatable (94, 75, loop, every time from cold), but a replayed sequence diverges at turn 2.
  Likely suspects inside Splash: prefix-cache reuse across turns or the DFlash2 draft model's speculative state. Not
  isolated further (time-boxed).
- **So Run 6's 5 of 5 for this model on the MBP-14 reflected a warm Splash state**, not a reliable model. Its honest
  cold-start figure on Splash is 0 of 9 at 4,096 and 0 of 3 at 8,192.
- Qwen3.8-27B 4-bit (thinking off) is unaffected: it passes on Splash on both Macs from cold.
- On the plain engine, Qwen3.6-35B-A3B 8-bit passes from cold (3 of 3 here; 4 of 5 in Run 9).

## Consequences

- Qwen3.6-35B-A3B 8-bit should run on oMLX's **plain engine**, not Splash, for agentic work, until Splash is fixed or
  the cause found. MBP-16 reverted 2026-10-20 20:53 (backup `model_settings.json.bak-20261020-splash36`). The MBP-14
  still has it on Splash: pending Mark's OK.
- **Every builder benchmark and ladder attempt should start from a known state** (service restarted, Splash cache
  emptied, or at least recorded), and results should say which.
- Worth reporting upstream to Splash (inco.ai) with `captures/` as the reproduction. Not done.

## Speed: plain engine vs Splash (MBP-16, oMLX 0.7.1rc1, omlx-bench, cold)

| Model | Engine | Short answer: tok/s | 37.8k prompt: reading tok/s | First word, 37.8k prompt | Agentic from cold |
|---|---|---|---|---|---|
| Qwen3.6-35B-A3B 8-bit | plain | 75 | 453 | 83 s | 7 of 8 |
| Qwen3.6-35B-A3B 8-bit | Splash + DFlash2 | 134 | 672 | 56 s | 0 of 16 |
| Qwen3.8-27B 4-bit | plain | 19 | 84 | 7.5 min | not tested |
| Qwen3.8-27B 4-bit | Splash + DFlash2 | 56 | 167 | 3.8 min | passes |

Qwen3.8-27B 4-bit plain was measured on 0.7.1rc1 (2026-10-20, temporary switch, restored to Splash afterwards). It
matches the 18 Oct 0.7.0 figures (19.1 tok/s, 84 tok/s, 451 s), so **the whole speed-up is Splash, not the oMLX
upgrade**: about 3× generation and 2× long-prompt reading for this dense model, against 1.5–1.8× for the MoE Qwen3.6.

**Issue log (for a possible upstream report later; not filed, Mark 2026-10-20):** Splash M1 1.3.2-m1.1 with
oMLX 0.7.1rc1, Qwen3.6-35B-A3B 8-bit + DFlash2 draft, int8 KV, temperature 0: in a multi-turn tool-calling sequence the
third request loops to the token limit, while the identical request sent alone completes (`captures/`). Repeatable from
a cold cache on two M1 Max Macs (macOS 26.6.2 and 27.0.1). Qwen3.8-27B 4-bit with thinking off is unaffected.

## Files

- `replay_turn3.rb`: replays a reconstructed turn 3 with no limit (used for test 3's first pass).
- `captures/`: the logged failed turn-3 body (`turn3.json`), the harness's own three requests (`req-1..3.json`) and the
  ID-swapped variant. They contain only the slugify task and tool definitions.
- `replay-mbp16-splash.json`: test 3 output.
