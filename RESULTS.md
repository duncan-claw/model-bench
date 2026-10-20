# Results

Every run's own tables are kept unchanged in its folder (links at the bottom). This page shows the
**latest evidence per model** and **how each model's numbers changed from run to run**. Built by `bin/summary`.
Method, caveats and the time/cost view: [`README.md`](README.md). Why models were kept or cut: [`DECISIONS.md`](DECISIONS.md).

<sup>(d)</sup> = since deleted from the test Mac (kept here as history).

## Latest evidence per model

Ruby pass rate comes from the most complete run for that model: Run 3 for the verbose models, otherwise Run 2.
Agentic shows every attempt so far, in run order.

| Model | Ruby pass rate (latest) | From | s / problem | Agentic attempts | Reads images |
|---|---|---|---|---|---|
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 73% (74/102) | Run 2 | 35.4 | not solved, not solved | yes |
| fullstack-learn-lm-30b-a3b-i1 <sup>(d)</sup> | 81% (131/161) | Run 2 | 2.2 | not solved, not solved | no |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 <sup>(d)</sup> | 71% (115/161) | Run 2 | 19.7 | solved, not solved | no |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 73% (117/161) | Run 2 | 4.6 | not solved, not solved | no |
| gemma-4-26b-a4b-it-4bit | 68% (50/74) · 32k: 23/30, 6 of 30 answers never finished | Run 2 | 49.4 | not solved, solved | yes |
| Qwen3.6-35B-A3B-4bit | 93% (149/161) | Run 3 | 34.7 | solved, not solved | yes |
| Qwen3.8-27B-4bit | 85% (136/161) | Run 2 | 4.4 | solved, solved | yes |
| Qwen3.8-27B-8bit | 86% (138/161) | Run 2 | 12.6 | solved, solved | yes |
| ornith-1.5-35b-a3b <sup>(d)</sup> | 89% (143/161) | Run 2 | 19.0 | not solved, solved | yes |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 84% (135/161) | Run 2 | 7.7 | not solved, solved | no |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 88% (141/161) | Run 2 | 12.1 | not solved | no |
| qwen3-coder-30b-rails | 45% (9/20) | Run 2 | 1.4 | not solved, not solved | no |
| Qwen3.6-35B-A3B-8bit | 94% (151/161) | Run 3 | 26.1 | solved, solved | yes |
| Qwopus3.6-35B-A3B-Coder-8bit | 76% (122/161) | Run 3 | 26.9 | solved, solved | yes |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 74% (110/148) | Run 2 | 24.5 | not solved, not solved | no |

## Progression: Ruby pass rate run by run

The same model across runs. The rules changed between runs, so a jump usually means the model was given more
room, not that it got better: Run 1 stopped after 2 minutes, Run 2 cut answers at 4,096 tokens, Run 3 at 8,192.

| Model | Run 1: screen | Run 2: extended | Run 3: 8k | Run 4: 32k |
|---|---|---|---|---|
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 33% (1/3) | 73% (74/102) | — | — |
| fullstack-learn-lm-30b-a3b-i1 <sup>(d)</sup> | 70% (28/40) | 81% (131/161) | — | — |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 <sup>(d)</sup> | 83% (5/6) | 71% (115/161) | — | — |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 62% (16/26) | 73% (117/161) | — | — |
| gemma-4-26b-a4b-it-4bit | 14% (1/7) | 68% (50/74) | — | 77% (23/30) |
| Qwen3.6-35B-A3B-4bit | 11% (1/9) | 82% (81/99) | 93% (149/161) | — |
| Qwen3.8-27B-4bit | 73% (19/26) | 85% (136/161) | — | — |
| Qwen3.8-27B-8bit | 82% (9/11) | 86% (138/161) | — | — |
| ornith-1.5-35b-a3b <sup>(d)</sup> | 88% (7/8) | 89% (143/161) | — | — |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 80% (20/25) | 84% (135/161) | — | — |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | — | 88% (141/161) | — | — |
| qwen3-coder-30b-rails | 67% (37/55) | 45% (9/20) | — | — |
| Qwen3.6-35B-A3B-8bit | 33% (3/9) | 85% (128/151) | 94% (151/161) | — |
| Qwopus3.6-35B-A3B-Coder-8bit | 46% (5/11) | 73% (118/161) | 76% (122/161) | — |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 79% (23/29) | 74% (110/148) | — | — |

## The runs

- **Run 1: screen** (2-min coding box, 1,024-token answers, 2-min agentic box): [`results/2026-10-19/RESULTS.md`](results/2026-10-19/RESULTS.md)
- **Run 2: extended** (all 161 problems, 4,096-token answers, 60-min cap, 10-min agentic box): [`results/2026-10-19-extended/RESULTS.md`](results/2026-10-19-extended/RESULTS.md)
- **Run 3: 8k re-run** (coding only, 8,192-token answers, no time cap; verbose models only): [`results/2026-10-20-8k/`](results/2026-10-20-8k/)
- **Run 4: Gemma 32k** (coding only, 32,768-token answers; stopped at problem 30): [`results/2026-10-20-gemma32k/README.md`](results/2026-10-20-gemma32k/README.md)
- **Run logs** for all of them (host addresses redacted): [`results/logs/`](results/logs/)

Run 2's page also has the weighted scores (v1 and v2), the family grouping and the sorted views.
Run 3 has no table page of its own: it was stopped during its last model (Gemma-4-26B, rerun as Run 4).
