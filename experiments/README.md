# Experiments

Tuning and method experiments, separate from the benchmark runs in `results/`. Each experiment has its own folder
with a `README.md` (question, method, status, results table) and its raw outputs. Results that change a keep/cut call or
a builder's runtime settings are also recorded in `DECISIONS.md`.

| Experiment | Question | Status |
|---|---|---|
| [`mbp-parity/`](mbp-parity/) | Why did Qwen3.6-35B-A3B 8-bit pass on one Mac and fail on the other? | Narrowed to Splash serving state; plain engine works (2026-10-20) |
| [`thinking-budget/`](thinking-budget/) | Does capping or switching off thinking keep accuracy while cutting time, for the builders? | Planned (2026-10-20) |

Background and gates: [`docs/TUNING_TODO.md`](../docs/TUNING_TODO.md).
