# Run 9: MBP-16 check, full tool-calling and agentic attempts 6–10 (2026-10-20)

All on the **MBP-16** (M1 Max, 64 GB, oMLX 0.7.1rc1), after it was stabilised the same afternoon (see Notes).

## 1. Same-hardware check (`check/`)

Qwen3.8-27B 4-bit, all 161 problems at 8,192 tokens, the same settings as its Run 7 row on the MBP-14.

| Mac | Pass | s / answer |
|---|---|---|
| MBP-14 (Run 7) | 136/161 | 4.5 |
| MBP-16 | 136/161 | 3.2 |

**Every one of the 161 problems passed or failed the same way on both Macs**, so coding results from either Mac are
comparable for this model. The MBP-16 was faster per answer.

## 2. Speed and all 12 tool-calling cases (`tools/`)

The tools screen ran with a 15-minute box (`--tools-box 900`) instead of 90 s, so every case was reached. In Run 1
the 90-second box stopped Qwen3.8-27B 4-bit at 6 of 12 and the 8-bit at 4 of 12.

| Model | Tools | Load s | First token | tok/s |
|---|---|---|---|---|
| Qwen3.8-27B 4-bit | **12/12** | 28.7 | 29.5 s* | 24.2* |
| Qwen3.6-35B-A3B 8-bit | **12/12** | 16.0 | 2.9 s | 78.8 |
| Qwen3.6-35B-A3B 4-bit | **12/12** | 18.1 | 0.1 s | 70.4 |
| Ornith-1.5-35B-A3B MLX 4-bit | **12/12** | 16.7 | 0.5 s | 64.1 |

\* The speed screen is the first request after a load. Qwen3.8-27B 4-bit's figure looks like warm-up, not its working
speed (Splash measured about 48–50 tok/s on this Mac on 2026-10-18). Treat these as cold-start readings.

## 3. Agentic attempts 6–10 for the two finalists (`a6/`–`a10/`)

Run 2 rules (10-minute box, 30 turns, 4,096 tokens per turn), continuing Run 6's attempts 1–5.

| Model | a6 | a7 | a8 | a9 | a10 | This run | **All 10 attempts** |
|---|---|---|---|---|---|---|---|
| Qwen3.8-27B 4-bit | ✗ 30 turns, `max_turns` | ✓ 8 | ✓ 6 | ✓ 6 | ✓ 6 | 4 of 5 | **9 of 10** |
| Qwen3.6-35B-A3B 8-bit | ✗ 15 turns, `no_tool_call` | ✓ 8 | ✓ 9 | ✓ 8 | ✓ 9 | 4 of 5 | **9 of 10** |

**Caveat: the MBP-16's oMLX model settings differ from the MBP-14's,** found during this run:

| Model | Setting | MBP-14 | MBP-16 |
|---|---|---|---|
| Qwen3.6-35B-A3B 8-bit | `external_engine` | `splash` | (none: oMLX's own engine) |
| Qwen3.8-27B 4-bit | `turboquant_kv_enabled` | true | false |

So these attempts aren't a like-for-like repeat of Run 6, which ran on the MBP-14. Both failures were the first
attempt of the run; attempts 7–10 all passed.

## Notes

- **The MBP-16 had been kernel-panicking**, not "restarting oMLX" as first recorded for Run 6: 10 panics between
  2026-10-19 15:08 and 2026-10-20 15:59, each "Sleep transition timed out … Suspected bundle: IOThunderboltFamily /
  AppleThunderboltIP". The lid is closed (it runs headless) and it kept entering maintenance sleep. A Thunderbolt
  cable to a Mac mini (from the August exo cluster) was unplugged, and Mark set `pmset -a disablesleep 1
  hibernatemode 0 standby 0`. No panics since.
- No other client called the MBP-16 during Runs 6 or 9 (its log shows the sports-surfaces newsletter job overnight
  until 08:26 and the pi agent at 11:59, nothing else).
- These runs used a copy of the harness pointed at the MBP-16 (the harness then supported one oMLX host); results were
  moved into this folder.
