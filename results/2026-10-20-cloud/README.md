# Run 8: cloud comparison through OpenRouter (2026-10-20)

**What:** three low-cost cloud models, chosen by Mark, through the same harness and rules as the local candidates:
speed, all 161 HumanEval-Ruby problems at 8,192 tokens (no time cap), the 12 tool-calling cases, and the agentic task
5 times under Run 2 rules (10-minute box, 30 turns, 4,096 tokens per turn).

**Why:** to see what the local builders have to beat. This overrides the 2026-10-19 scope rule "no cloud baseline",
at Mark's request (`DECISIONS.md`, 2026-10-20).

**How:** OpenRouter's OpenAI-compatible API (`config/hosts.yml` kind `cloud`). Every request carried
`provider: { data_collection: "deny" }`, so only providers that don't store or train on prompts were used
(MultiPL-E's licence forbids training use). Temperature 0, as for the local models. The cloud models ran in parallel
with each other; the Macs weren't involved. Cost: a few US cents in total for the two paid models; MiniMax was free.

## Result

| Model | Ruby pass | Pass excl. cut-off | s / answer | Cut off | Tokens / answer | Tools | Agentic (5 attempts) | First token | tok/s |
|---|---|---|---|---|---|---|---|---|---|
| z-ai/glm-5.3-flash | **154/161 (96%)** | 154/160 | 9.3 | 1 | 672 | 12/12 | **5 of 5** (7–9 turns, 60–109 s) | 0.8 s | 86 |
| deepseek/deepseek-v4.1-flash-1017 | **152/161 (94%)** | 152/159 | 11.0 | 2 | 641 | 12/12 | **5 of 5** (6–8 turns, 7–10 s) | 1.5 s | 50 |
| minimax/minimax-m3.1-flash:free | 141/161 (88%) | 141/155 | 9.2 | 6 | 850 | 11/12 | **5 of 5** (6–26 turns, 26–122 s) | 1.4 s | 45 |

For comparison, the best local model (Qwen3.6-35B-A3B 8-bit) is 151/161 at 26.1 s per answer, and the fastest
(Qwen3.8-27B 4-bit) 136/161 at 4.5 s.

## Every agentic attempt

| Model | a1 | a2 | a3 | a4 | a5 |
|---|---|---|---|---|---|
| GLM-5.3 Flash | ✓ 7 turns, 60 s | ✓ 9, 91 s | ✓ 9, 79 s | ✓ 9, 109 s | ✓ 7, 82 s |
| DeepSeek V4.1 Flash | ✓ 8, 9 s | ✓ 6, 9 s | ✓ 6, 7 s | ✓ 7, 9 s | ✓ 6, 10 s |
| MiniMax M3.1 Flash | ✓ 6, 38 s | ✓ 7, 36 s | ✓ 7, 26 s | ✓ 10, 41 s | ✓ 26, 122 s |

Attempt 1 is in this folder's JSON files (with the coding, tools and speed screens); attempts 2–5 are in `a2/`–`a5/`.

## Notes

- **Cloud speed isn't comparable to a Mac's in one way:** these calls share a provider's GPUs, and several can run at
  once. The Macs do one job at a time (README, "One job at a time").
- The first launch failed with `407 Proxy Authentication Required`: the OpenRouter key is a protected secret that the
  Gateway's egress proxy adds only for processes in a live agent session, so a job detached from the Gateway can't
  use it. Those results were discarded and the run restarted inside a session. Local runs don't use the proxy.
- Puzzles only. Real feature work is the slice-size ladder (`docs/PLANNER_BUILDER_PLAN.md`).
