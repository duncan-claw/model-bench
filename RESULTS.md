# Results

Every result table from every run, **in the order the runs happened**, followed by a summary across runs.
Each run's own page is also kept unchanged in its folder. Built by `bin/summary`.
Method, caveats and the time/cost view: [`README.md`](README.md). Why models were kept or cut: [`DECISIONS.md`](DECISIONS.md).

<sup>(d)</sup> = since deleted from the test Mac (kept here as history).

## All results, in the order they were run

---

### Run 1: screen (2-min coding box, 1,024-token answers, 2-min agentic box)

Time boxes: coding 120 s, tools 90 s, agentic 120 s (a box stops *new* items; one in flight may overrun).
Coding = MultiPL-E HumanEval-Ruby, same seeded order for every model. Tools = 12 single-turn cases.
Agentic = fix `tasks/slugify` (4 tests) with file/test tools, max 15 turns.

**Legend: screen table**

- **Size GB**: model files on disk.
- **Load s**: seconds to load the model into memory (oMLX or LM Studio).
- **TTFT s**: time to first token, i.e. seconds from sending a prompt until the first text (or reasoning) arrives.
- **tok/s**: generation speed once output starts (tokens per second, streamed 400-token reply). High tok/s does not mean fast answers if the model reasons at length first.
- **Coding pass/attempted**: Ruby problems whose unit tests passed / problems answered inside the box. Per-answer limit 1024 tokens; answers cut off at the limit count as failures.
- **Agentic token limit**: 2048 tokens per turn.
- **Tools pass/attempted**: single-turn tool cases with the right tool (or none), right arguments and types / cases reached in the box.
- **Agentic**: whether the 4 failing tests pass at the end (**solved**) or not.
- **Agentic turns / stop**: model turns used, and why it stopped: `finish` (called done), `no_tool_call` (replied in plain text instead of using a tool, i.e. gave up), `time_box`, `max_turns`, or `error`.
- **Error**: the model could not be loaded or reached; no scores for that row.

| Model | Size GB | Load s | TTFT s | tok/s | Coding pass/attempted | Tools pass/attempted (of 12) | Agentic | Agentic turns / stop | Error |
|---|---|---|---|---|---|---|---|---|---|
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 9.7 | 4.2 | 3.18 | 25.5 | 1/3 | 7/7 | not solved | 5 / no_tool_call |  |
| fullstack-learn-lm-30b-a3b-i1 | 23 | 16.4 | 0.52 | 30.7 | 28/40 | 11/12 | not solved | 12 / time_box |  |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 | 12 | 9.3 | 1.03 | 11.9 | 5/6 | 11/11 | **solved** | 10 / time_box |  |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 12 | 6.9 | 1.37 | 17.6 | 16/26 | 12/12 | not solved | 6 / no_tool_call |  |
| mlx-community--gemma-4-26b-a4b-it-4bit | 14 | 21.0 | 3.35 | 48.7 | 1/7 | 12/12 | not solved | 5 / no_tool_call |  |
| mlx-community--IQuest-Coder-V1-14B-Instruct-8bit | 14 | 15.1 | 1.32 | 13.4 | 5/12 | 11/12 | not solved | 14 / time_box |  |
| mlx-community--IQuest-Coder-V1-40B-Loop-Instruct-8bit | 39 | 14.1 | 16.16 | 4.3 | 0/1 | 4/5 | not solved | 4 / time_box |  |
| mlx-community--Qwen3.6-35B-A3B-4bit | 19 | 9.8 | 3.33 | 75.9 | 1/9 | 12/12 | **solved** | 12 / finish |  |
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 15 | 43.1 | 39.8 | 12.4 | 19/26 | 6/6 | **solved** | 8 / finish |  |
| mlx-community--Qwen3.8-27B-8bit | 28 | 11.0 | 7.59 | 8.1 | 9/11 | 4/4 | **solved** | 5 / finish |  |
| ornith-1.5-35b-a3b | 27.9 | 19.4 | 0.52 | 21.1 | 7/8 | 12/12 | not solved | 3 / no_tool_call |  |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 18 | 22.9 | 0.17 | 45.5 | 20/25 | 12/12 | not solved | 3 / no_tool_call |  |
| qwen3-coder-30b-rails | 20 | 13.8 | 0.31 | 39.4 | 37/55 | 12/12 | not solved | 12 / time_box |  |
| Qwen3.6-35B-A3B-8bit | 35 | 32.2 | 0.25 | 50.9 | 3/9 | 12/12 | **solved** | 6 / finish |  |
| Qwopus3.6-35B-A3B-Coder-8bit | 35 | 27.9 | 0.17 | 56.3 | 5/11 | 12/12 | **solved** | 10 / finish |  |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 9.7 | 6.1 | 3.03 | 46.4 | 23/29 | 12/12 | not solved | 7 / no_tool_call |  |
| ZQ-Dev--KAT-Coder-V2.5-Dev-oQ2e-fp16 | 11 | — | — | — | — | — | — | — | RuntimeError: load failed 500: {"detail" => "Model 'ZQ-Dev-- |

---

### Run 2: extended (all 161 problems, 4,096-token answers, 60-min cap, 10-min agentic box)

Time boxes: coding 120 s, tools 90 s, agentic 120 s (a box stops *new* items; one in flight may overrun).
Coding = MultiPL-E HumanEval-Ruby, same seeded order for every model. Tools = 12 single-turn cases.
Agentic = fix `tasks/slugify` (4 tests) with file/test tools, max 15 turns.

**Legend: screen table**

- **Size GB**: model files on disk.
- **Load s**: seconds to load the model into memory (oMLX or LM Studio).
- **TTFT s**: time to first token, i.e. seconds from sending a prompt until the first text (or reasoning) arrives.
- **tok/s**: generation speed once output starts (tokens per second, streamed 400-token reply). High tok/s does not mean fast answers if the model reasons at length first.
- **Coding pass/attempted**: Ruby problems whose unit tests passed / problems answered inside the box. Per-answer limit 4096 tokens; answers cut off at the limit count as failures.
- **Agentic token limit**: 4096 tokens per turn.
- **Tools pass/attempted**: single-turn tool cases with the right tool (or none), right arguments and types / cases reached in the box.
- **Agentic**: whether the 4 failing tests pass at the end (**solved**) or not.
- **Agentic turns / stop**: model turns used, and why it stopped: `finish` (called done), `no_tool_call` (replied in plain text instead of using a tool, i.e. gave up), `time_box`, `max_turns`, or `error`.
- **Error**: the model could not be loaded or reached; no scores for that row.

| Model | Size GB | Load s | TTFT s | tok/s | Coding pass/attempted | Tools pass/attempted (of 12) | Agentic | Agentic turns / stop | Error |
|---|---|---|---|---|---|---|---|---|---|
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 9.7 | 21.4 | — | — | 74/102 | — | not solved | 21 / no_tool_call |  |
| fullstack-learn-lm-30b-a3b-i1 | 23 | 15.1 | — | — | 131/161 | — | not solved | 26 / finish |  |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 | 12 | 7.4 | — | — | 115/161 | — | not solved | 30 / max_turns |  |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 12 | 6.6 | — | — | 117/161 | — | not solved | 3 / no_tool_call |  |
| mlx-community--gemma-4-26b-a4b-it-4bit | 14 | 7.1 | — | — | 50/74 | — | **solved** | 7 / finish |  |
| mlx-community--Qwen3.6-35B-A3B-4bit | 19 | 11.5 | — | — | 81/99 | — | not solved | 5 / no_tool_call |  |
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 15 | 35.9 | — | — | 136/161 | — | **solved** | 6 / finish |  |
| mlx-community--Qwen3.8-27B-8bit | 28 | 10.8 | — | — | 138/161 | — | **solved** | 5 / finish |  |
| ornith-1.5-35b-a3b | 27.9 | 18.3 | — | — | 143/161 | — | **solved** | 6 / finish |  |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 18 | 20.8 | — | — | 135/161 | — | **solved** | 8 / finish |  |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 37 | 19.1 | 6.07 | 49.5 | 141/161 | — | not solved | 8 / no_tool_call |  |
| qwen3-coder-30b-rails | 20 | 11.4 | — | — | 9/20 | — | not solved | 30 / max_turns |  |
| Qwen3.6-35B-A3B-8bit | 35 | 30.4 | — | — | 128/151 | — | **solved** | 8 / finish |  |
| Qwopus3.6-35B-A3B-Coder-8bit | 35 | 31.8 | — | — | 118/161 | — | **solved** | 8 / finish |  |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 9.7 | 5.2 | — | — | 110/148 | — | not solved | 4 / no_tool_call |  |

#### Extended coding (all 161 problems, early stop below 50% after 20, or at the time cap)

**Legend: extended tables**

- **Pass / attempted**: Ruby problems whose unit tests passed / problems answered before the run stopped (161 = all).
- **Pass rate**: pass ÷ attempted. Accuracy only; ignores speed.
- **Pass rate excl. cut-off**: pass rate over only the answers that finished inside the token limit. A big gap from Pass rate means the model is accurate but too verbose for the limit.
- **s / problem**: average seconds per answer, including any reasoning. The real pace, unlike tok/s.
- **Solved per hour**: correct answers per hour of generation (passed × 3600 ÷ total answer seconds). Speed and accuracy in one number.
- **Hit token cap**: answers that ran into the per-answer limit of **4096 tokens** (reasoning plus code) and were cut off; those count as failures, so a high number means the pass rate is understated.
- **Token limits used in this run**: coding 4096 tokens per answer; agentic 4096 tokens per turn.
- **Stop**: `completed` (all 161), `time_cap (60 min)`, or `low_pass_rate` (below 50% after 20 problems).
- **Agentic**: whether the slugify task's 4 tests pass at the end (10-minute box, 30 turns).
- **Agentic turns / stop / s**: turns used, why it stopped (see the screen-table legend), and seconds taken.

##### By model name

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solved per hour | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 74/102 | 73% | 82% (74 of 90 finished) | 35.4 | 73.7 | 12 | time_cap (60 min) | not solved | 21 / no_tool_call / 390.0 |
| fullstack-learn-lm-30b-a3b-i1 | 131/161 | 81% | 81% (131 of 161 finished) | 2.2 | 1331.1 | 0 | completed | not solved | 26 / finish / 265.1 |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 | 115/161 | 71% | 72% (115 of 160 finished) | 19.7 | 130.5 | 1 | completed | not solved | 30 / max_turns / 331.0 |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 117/161 | 73% | 73% (117 of 161 finished) | 4.6 | 571.8 | 0 | completed | not solved | 3 / no_tool_call / 222.9 |
| mlx-community--gemma-4-26b-a4b-it-4bit | 50/74 | 68% | 98% (49 of 50 finished) | 49.4 | 49.3 | 24 | time_cap (60 min) | **solved** | 7 / finish / 44.9 |
| mlx-community--Qwen3.6-35B-A3B-4bit | 81/99 | 82% | 95% (81 of 85 finished) | 36.3 | 81.1 | 14 | time_cap (60 min) | not solved | 5 / no_tool_call / 66.6 |
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 136/161 | 85% | 84% (136 of 161 finished) | 4.4 | 692.5 | 0 | completed | **solved** | 6 / finish / 44.6 |
| mlx-community--Qwen3.8-27B-8bit | 138/161 | 86% | 86% (138 of 161 finished) | 12.6 | 244.7 | 0 | completed | **solved** | 5 / finish / 77.9 |
| ornith-1.5-35b-a3b | 143/161 | 89% | 91% (143 of 157 finished) | 19.0 | 168.7 | 4 | completed | **solved** | 6 / finish / 148.7 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 135/161 | 84% | 88% (135 of 154 finished) | 7.7 | 392.8 | 7 | completed | **solved** | 8 / finish / 79.0 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 141/161 | 88% | 90% (141 of 156 finished) | 12.1 | 261.2 | 5 | completed | not solved | 8 / no_tool_call / 167.0 |
| qwen3-coder-30b-rails | 9/20 | 45% | 45% (9 of 20 finished) | 1.4 | 1195.6 | 0 | low_pass_rate (45% after 20) | not solved | 30 / max_turns / 70.7 |
| Qwen3.6-35B-A3B-8bit | 128/151 | 85% | 96% (128 of 133 finished) | 24.0 | 127.3 | 18 | time_cap (60 min) | **solved** | 8 / finish / 65.4 |
| Qwopus3.6-35B-A3B-Coder-8bit | 118/161 | 73% | 92% (118 of 128 finished) | 18.2 | 145.2 | 33 | completed | **solved** | 8 / finish / 20.0 |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 110/148 | 74% | 87% (90 of 104 finished) | 24.5 | 109.0 | 44 | time_cap (60 min) | not solved | 4 / no_tool_call / 86.7 |

##### By pass rate (most accurate first)

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solved per hour | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| ornith-1.5-35b-a3b | 143/161 | 89% | 91% (143 of 157 finished) | 19.0 | 168.7 | 4 | completed | **solved** | 6 / finish / 148.7 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 141/161 | 88% | 90% (141 of 156 finished) | 12.1 | 261.2 | 5 | completed | not solved | 8 / no_tool_call / 167.0 |
| mlx-community--Qwen3.8-27B-8bit | 138/161 | 86% | 86% (138 of 161 finished) | 12.6 | 244.7 | 0 | completed | **solved** | 5 / finish / 77.9 |
| Qwen3.6-35B-A3B-8bit | 128/151 | 85% | 96% (128 of 133 finished) | 24.0 | 127.3 | 18 | time_cap (60 min) | **solved** | 8 / finish / 65.4 |
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 136/161 | 85% | 84% (136 of 161 finished) | 4.4 | 692.5 | 0 | completed | **solved** | 6 / finish / 44.6 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 135/161 | 84% | 88% (135 of 154 finished) | 7.7 | 392.8 | 7 | completed | **solved** | 8 / finish / 79.0 |
| mlx-community--Qwen3.6-35B-A3B-4bit | 81/99 | 82% | 95% (81 of 85 finished) | 36.3 | 81.1 | 14 | time_cap (60 min) | not solved | 5 / no_tool_call / 66.6 |
| fullstack-learn-lm-30b-a3b-i1 | 131/161 | 81% | 81% (131 of 161 finished) | 2.2 | 1331.1 | 0 | completed | not solved | 26 / finish / 265.1 |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 110/148 | 74% | 87% (90 of 104 finished) | 24.5 | 109.0 | 44 | time_cap (60 min) | not solved | 4 / no_tool_call / 86.7 |
| Qwopus3.6-35B-A3B-Coder-8bit | 118/161 | 73% | 92% (118 of 128 finished) | 18.2 | 145.2 | 33 | completed | **solved** | 8 / finish / 20.0 |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 117/161 | 73% | 73% (117 of 161 finished) | 4.6 | 571.8 | 0 | completed | not solved | 3 / no_tool_call / 222.9 |
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 74/102 | 73% | 82% (74 of 90 finished) | 35.4 | 73.7 | 12 | time_cap (60 min) | not solved | 21 / no_tool_call / 390.0 |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 | 115/161 | 71% | 72% (115 of 160 finished) | 19.7 | 130.5 | 1 | completed | not solved | 30 / max_turns / 331.0 |
| mlx-community--gemma-4-26b-a4b-it-4bit | 50/74 | 68% | 98% (49 of 50 finished) | 49.4 | 49.3 | 24 | time_cap (60 min) | **solved** | 7 / finish / 44.9 |
| qwen3-coder-30b-rails | 9/20 | 45% | 45% (9 of 20 finished) | 1.4 | 1195.6 | 0 | low_pass_rate (45% after 20) | not solved | 30 / max_turns / 70.7 |

##### By solved per hour (speed × accuracy)

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solved per hour | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| fullstack-learn-lm-30b-a3b-i1 | 131/161 | 81% | 81% (131 of 161 finished) | 2.2 | 1331.1 | 0 | completed | not solved | 26 / finish / 265.1 |
| qwen3-coder-30b-rails | 9/20 | 45% | 45% (9 of 20 finished) | 1.4 | 1195.6 | 0 | low_pass_rate (45% after 20) | not solved | 30 / max_turns / 70.7 |
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 136/161 | 85% | 84% (136 of 161 finished) | 4.4 | 692.5 | 0 | completed | **solved** | 6 / finish / 44.6 |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 117/161 | 73% | 73% (117 of 161 finished) | 4.6 | 571.8 | 0 | completed | not solved | 3 / no_tool_call / 222.9 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 135/161 | 84% | 88% (135 of 154 finished) | 7.7 | 392.8 | 7 | completed | **solved** | 8 / finish / 79.0 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 141/161 | 88% | 90% (141 of 156 finished) | 12.1 | 261.2 | 5 | completed | not solved | 8 / no_tool_call / 167.0 |
| mlx-community--Qwen3.8-27B-8bit | 138/161 | 86% | 86% (138 of 161 finished) | 12.6 | 244.7 | 0 | completed | **solved** | 5 / finish / 77.9 |
| ornith-1.5-35b-a3b | 143/161 | 89% | 91% (143 of 157 finished) | 19.0 | 168.7 | 4 | completed | **solved** | 6 / finish / 148.7 |
| Qwopus3.6-35B-A3B-Coder-8bit | 118/161 | 73% | 92% (118 of 128 finished) | 18.2 | 145.2 | 33 | completed | **solved** | 8 / finish / 20.0 |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 | 115/161 | 71% | 72% (115 of 160 finished) | 19.7 | 130.5 | 1 | completed | not solved | 30 / max_turns / 331.0 |
| Qwen3.6-35B-A3B-8bit | 128/151 | 85% | 96% (128 of 133 finished) | 24.0 | 127.3 | 18 | time_cap (60 min) | **solved** | 8 / finish / 65.4 |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 110/148 | 74% | 87% (90 of 104 finished) | 24.5 | 109.0 | 44 | time_cap (60 min) | not solved | 4 / no_tool_call / 86.7 |
| mlx-community--Qwen3.6-35B-A3B-4bit | 81/99 | 82% | 95% (81 of 85 finished) | 36.3 | 81.1 | 14 | time_cap (60 min) | not solved | 5 / no_tool_call / 66.6 |
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 74/102 | 73% | 82% (74 of 90 finished) | 35.4 | 73.7 | 12 | time_cap (60 min) | not solved | 21 / no_tool_call / 390.0 |
| mlx-community--gemma-4-26b-a4b-it-4bit | 50/74 | 68% | 98% (49 of 50 finished) | 49.4 | 49.3 | 24 | time_cap (60 min) | **solved** | 7 / finish / 44.9 |

##### Grouped by agentic result, then solved per hour

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solved per hour | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 136/161 | 85% | 84% (136 of 161 finished) | 4.4 | 692.5 | 0 | completed | **solved** | 6 / finish / 44.6 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 135/161 | 84% | 88% (135 of 154 finished) | 7.7 | 392.8 | 7 | completed | **solved** | 8 / finish / 79.0 |
| mlx-community--Qwen3.8-27B-8bit | 138/161 | 86% | 86% (138 of 161 finished) | 12.6 | 244.7 | 0 | completed | **solved** | 5 / finish / 77.9 |
| ornith-1.5-35b-a3b | 143/161 | 89% | 91% (143 of 157 finished) | 19.0 | 168.7 | 4 | completed | **solved** | 6 / finish / 148.7 |
| Qwopus3.6-35B-A3B-Coder-8bit | 118/161 | 73% | 92% (118 of 128 finished) | 18.2 | 145.2 | 33 | completed | **solved** | 8 / finish / 20.0 |
| Qwen3.6-35B-A3B-8bit | 128/151 | 85% | 96% (128 of 133 finished) | 24.0 | 127.3 | 18 | time_cap (60 min) | **solved** | 8 / finish / 65.4 |
| mlx-community--gemma-4-26b-a4b-it-4bit | 50/74 | 68% | 98% (49 of 50 finished) | 49.4 | 49.3 | 24 | time_cap (60 min) | **solved** | 7 / finish / 44.9 |
| fullstack-learn-lm-30b-a3b-i1 | 131/161 | 81% | 81% (131 of 161 finished) | 2.2 | 1331.1 | 0 | completed | not solved | 26 / finish / 265.1 |
| qwen3-coder-30b-rails | 9/20 | 45% | 45% (9 of 20 finished) | 1.4 | 1195.6 | 0 | low_pass_rate (45% after 20) | not solved | 30 / max_turns / 70.7 |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 117/161 | 73% | 73% (117 of 161 finished) | 4.6 | 571.8 | 0 | completed | not solved | 3 / no_tool_call / 222.9 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 141/161 | 88% | 90% (141 of 156 finished) | 12.1 | 261.2 | 5 | completed | not solved | 8 / no_tool_call / 167.0 |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 | 115/161 | 71% | 72% (115 of 160 finished) | 19.7 | 130.5 | 1 | completed | not solved | 30 / max_turns / 331.0 |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 110/148 | 74% | 87% (90 of 104 finished) | 24.5 | 109.0 | 44 | time_cap (60 min) | not solved | 4 / no_tool_call / 86.7 |
| mlx-community--Qwen3.6-35B-A3B-4bit | 81/99 | 82% | 95% (81 of 85 finished) | 36.3 | 81.1 | 14 | time_cap (60 min) | not solved | 5 / no_tool_call / 66.6 |
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 74/102 | 73% | 82% (74 of 90 finished) | 35.4 | 73.7 | 12 | time_cap (60 min) | not solved | 21 / no_tool_call / 390.0 |

##### Grouped by family (Qwen newest first, then Gemma), then solved per hour

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solved per hour | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| **Qwen3.8-27B** | | | | | | | | | |
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 136/161 | 85% | 84% (136 of 161 finished) | 4.4 | 692.5 | 0 | completed | **solved** | 6 / finish / 44.6 |
| mlx-community--Qwen3.8-27B-8bit | 138/161 | 86% | 86% (138 of 161 finished) | 12.6 | 244.7 | 0 | completed | **solved** | 5 / finish / 77.9 |
| **Qwen3.6-35B-A3B** | | | | | | | | | |
| Qwopus3.6-35B-A3B-Coder-8bit | 118/161 | 73% | 92% (118 of 128 finished) | 18.2 | 145.2 | 33 | completed | **solved** | 8 / finish / 20.0 |
| Qwen3.6-35B-A3B-8bit | 128/151 | 85% | 96% (128 of 133 finished) | 24.0 | 127.3 | 18 | time_cap (60 min) | **solved** | 8 / finish / 65.4 |
| mlx-community--Qwen3.6-35B-A3B-4bit | 81/99 | 82% | 95% (81 of 85 finished) | 36.3 | 81.1 | 14 | time_cap (60 min) | not solved | 5 / no_tool_call / 66.6 |
| **Qwen3.5 (fine-tunes/distills)** | | | | | | | | | |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 135/161 | 84% | 88% (135 of 154 finished) | 7.7 | 392.8 | 7 | completed | **solved** | 8 / finish / 79.0 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 141/161 | 88% | 90% (141 of 156 finished) | 12.1 | 261.2 | 5 | completed | not solved | 8 / no_tool_call / 167.0 |
| ornith-1.5-35b-a3b | 143/161 | 89% | 91% (143 of 157 finished) | 19.0 | 168.7 | 4 | completed | **solved** | 6 / finish / 148.7 |
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 74/102 | 73% | 82% (74 of 90 finished) | 35.4 | 73.7 | 12 | time_cap (60 min) | not solved | 21 / no_tool_call / 390.0 |
| **Qwen3 30B-A3B MoE (fine-tunes)** | | | | | | | | | |
| fullstack-learn-lm-30b-a3b-i1 | 131/161 | 81% | 81% (131 of 161 finished) | 2.2 | 1331.1 | 0 | completed | not solved | 26 / finish / 265.1 |
| qwen3-coder-30b-rails | 9/20 | 45% | 45% (9 of 20 finished) | 1.4 | 1195.6 | 0 | low_pass_rate (45% after 20) | not solved | 30 / max_turns / 70.7 |
| **Gemma 4** | | | | | | | | | |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 117/161 | 73% | 73% (117 of 161 finished) | 4.6 | 571.8 | 0 | completed | not solved | 3 / no_tool_call / 222.9 |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 | 115/161 | 71% | 72% (115 of 160 finished) | 19.7 | 130.5 | 1 | completed | not solved | 30 / max_turns / 331.0 |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 110/148 | 74% | 87% (90 of 104 finished) | 24.5 | 109.0 | 44 | time_cap (60 min) | not solved | 4 / no_tool_call / 86.7 |
| mlx-community--gemma-4-26b-a4b-it-4bit | 50/74 | 68% | 98% (49 of 50 finished) | 49.4 | 49.3 | 24 | time_cap (60 min) | **solved** | 7 / finish / 44.9 |


#### Weighted score: overnight builder (worked example, weights not yet agreed)

**How it is worked out**

- **Score** = 100 × the sum of (weight × component). Each component is on a 0–1 scale; the tables show each one.
- **agentic**: 1 if the agentic task was solved, else 0. One attempt per model, so treat it as a coin flip until repeated.
- **accuracy**: Pass rate (cut-off answers count as wrong).
- **throughput**: log(1 + solved per hour) ÷ log(1 + best solved per hour in this run). The log stops one very fast model swamping the rest.
- **memory**: 1 − size ÷ largest size in this run, so smaller scores higher.
- **vision**: 1 if the model's weights include an image encoder, else 0 (from the model files; not yet tested with a real image).
- **<sup>(d)</sup>** after a model name: deleted from the MBP-14 since this run (the MBP-16 may still hold a copy). Kept here as history.
- **Net per hour**: (passed − failed) ÷ hours of answering. Counts every wrong answer as cancelling a right one, because wrong code costs review or rework. Negative means it produces more wrong code than right.

##### Weights v2 (2026-10-20): adds vision, taken from memory

Score = 100 × (0.4 × agentic + 0.3 × accuracy + 0.2 × throughput + 0.05 × memory + 0.05 × vision). A model that reads images avoids handing screenshots to a second model, which costs time and memory.

| Model | Agentic (×0.4) | Accuracy (×0.3) | Throughput (×0.2) | Memory (×0.05) | Vision (×0.05) | **Score** | Solved per hour | Net per hour |
|---|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 1.0 | 0.85 | 0.91 | 0.59 | 1.0 | **91.5** | 692.5 | 565 |
| mlx-community--Qwen3.8-27B-8bit | 1.0 | 0.86 | 0.77 | 0.24 | 1.0 | **87.2** | 244.7 | 204 |
| ornith-1.5-35b-a3b <sup>(d)</sup> | 1.0 | 0.89 | 0.71 | 0.25 | 1.0 | **87.1** | 168.7 | 147 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 1.0 | 0.84 | 0.83 | 0.51 | 0.0 | **84.3** | 392.8 | 317 |
| Qwen3.6-35B-A3B-8bit | 1.0 | 0.85 | 0.67 | 0.05 | 1.0 | **84.2** | 127.3 | 104 |
| Qwopus3.6-35B-A3B-Coder-8bit | 1.0 | 0.73 | 0.69 | 0.05 | 1.0 | **81.1** | 145.2 | 92 |
| mlx-community--gemma-4-26b-a4b-it-4bit | 1.0 | 0.68 | 0.54 | 0.62 | 1.0 | **79.3** | 49.3 | 26 |
| fullstack-learn-lm-30b-a3b-i1 <sup>(d)</sup> | 0.0 | 0.81 | 1.0 | 0.38 | 0.0 | **46.3** | 1331.1 | 1026 |
| mlx-community--Qwen3.6-35B-A3B-4bit | 0.0 | 0.82 | 0.61 | 0.49 | 1.0 | **44.2** | 81.1 | 63 |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 0.0 | 0.73 | 0.88 | 0.68 | 0.0 | **42.8** | 571.8 | 357 |
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 0.0 | 0.73 | 0.6 | 0.74 | 1.0 | **42.4** | 73.7 | 46 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 0.0 | 0.88 | 0.77 | 0.0 | 0.0 | **41.8** | 261.2 | 224 |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 0.0 | 0.74 | 0.65 | 0.74 | 0.0 | **39.0** | 109.0 | 71 |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 <sup>(d)</sup> | 0.0 | 0.71 | 0.68 | 0.68 | 0.0 | **38.4** | 130.5 | 78 |
| qwen3-coder-30b-rails | 0.0 | 0.45 | 0.99 | 0.46 | 0.0 | **35.5** | 1195.6 | -266 |

##### Weights v1 (2026-10-20): first worked example

Score = 100 × (0.4 × agentic + 0.3 × accuracy + 0.2 × throughput + 0.1 × memory).

| Model | Agentic (×0.4) | Accuracy (×0.3) | Throughput (×0.2) | Memory (×0.1) | **Score** | Solved per hour | Net per hour |
|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 1.0 | 0.85 | 0.91 | 0.59 | **89.5** | 692.5 | 565 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 1.0 | 0.84 | 0.83 | 0.51 | **86.9** | 392.8 | 317 |
| mlx-community--Qwen3.8-27B-8bit | 1.0 | 0.86 | 0.77 | 0.24 | **83.4** | 244.7 | 204 |
| ornith-1.5-35b-a3b <sup>(d)</sup> | 1.0 | 0.89 | 0.71 | 0.25 | **83.4** | 168.7 | 147 |
| Qwen3.6-35B-A3B-8bit | 1.0 | 0.85 | 0.67 | 0.05 | **79.5** | 127.3 | 104 |
| mlx-community--gemma-4-26b-a4b-it-4bit | 1.0 | 0.68 | 0.54 | 0.62 | **77.4** | 49.3 | 26 |
| Qwopus3.6-35B-A3B-Coder-8bit | 1.0 | 0.73 | 0.69 | 0.05 | **76.4** | 145.2 | 92 |
| fullstack-learn-lm-30b-a3b-i1 <sup>(d)</sup> | 0.0 | 0.81 | 1.0 | 0.38 | **48.2** | 1331.1 | 1026 |
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 0.0 | 0.73 | 0.88 | 0.68 | **46.2** | 571.8 | 357 |
| SrogiLesnik--Gemma-4-19B-mlx-4Bit | 0.0 | 0.74 | 0.65 | 0.74 | **42.7** | 109.0 | 71 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 0.0 | 0.88 | 0.77 | 0.0 | **41.8** | 261.2 | 224 |
| gemma-4-12b-agentic-fable5-composer2.5-v2-3.5x-tau2 <sup>(d)</sup> | 0.0 | 0.71 | 0.68 | 0.68 | **41.7** | 130.5 | 78 |
| mlx-community--Qwen3.6-35B-A3B-4bit | 0.0 | 0.82 | 0.61 | 0.49 | **41.7** | 81.1 | 63 |
| DeepSeek-V4-Pro-Qwen3.5-9B-8bit | 0.0 | 0.73 | 0.6 | 0.74 | **41.1** | 73.7 | 46 |
| qwen3-coder-30b-rails | 0.0 | 0.45 | 0.99 | 0.46 | **37.8** | 1195.6 | -266 |

---

### Run 3: 8k re-run (coding only, 8,192-token answers, no time cap; verbose models only)

Time boxes: coding 120 s, tools 90 s, agentic 120 s (a box stops *new* items; one in flight may overrun).
Coding = MultiPL-E HumanEval-Ruby, same seeded order for every model. Tools = 12 single-turn cases.
Agentic = fix `tasks/slugify` (4 tests) with file/test tools, max 15 turns.

**Legend: screen table**

- **Size GB**: model files on disk.
- **Load s**: seconds to load the model into memory (oMLX or LM Studio).
- **TTFT s**: time to first token, i.e. seconds from sending a prompt until the first text (or reasoning) arrives.
- **tok/s**: generation speed once output starts (tokens per second, streamed 400-token reply). High tok/s does not mean fast answers if the model reasons at length first.
- **Coding pass/attempted**: Ruby problems whose unit tests passed / problems answered inside the box. Per-answer limit 8192 tokens; answers cut off at the limit count as failures.
- **Agentic token limit**: 4096 tokens per turn.
- **Tools pass/attempted**: single-turn tool cases with the right tool (or none), right arguments and types / cases reached in the box.
- **Agentic**: whether the 4 failing tests pass at the end (**solved**) or not.
- **Agentic turns / stop**: model turns used, and why it stopped: `finish` (called done), `no_tool_call` (replied in plain text instead of using a tool, i.e. gave up), `time_box`, `max_turns`, or `error`.
- **Error**: the model could not be loaded or reached; no scores for that row.

| Model | Size GB | Load s | TTFT s | tok/s | Coding pass/attempted | Tools pass/attempted (of 12) | Agentic | Agentic turns / stop | Error |
|---|---|---|---|---|---|---|---|---|---|
| mlx-community--gemma-4-26b-a4b-it-4bit | 14 | 7.5 | — | — | — | — | — | — |  |
| mlx-community--Qwen3.6-35B-A3B-4bit | 19 | 6.4 | — | — | 149/161 | — | — | — |  |
| Qwen3.6-35B-A3B-8bit | 35 | 27.3 | — | — | 151/161 | — | — | — |  |
| Qwopus3.6-35B-A3B-Coder-8bit | 35 | 28.0 | — | — | 122/161 | — | — | — |  |

#### Extended coding (all 161 problems, early stop below 50% after 20, or at the time cap)

**Legend: extended tables**

- **Pass / attempted**: Ruby problems whose unit tests passed / problems answered before the run stopped (161 = all).
- **Pass rate**: pass ÷ attempted. Accuracy only; ignores speed.
- **Pass rate excl. cut-off**: pass rate over only the answers that finished inside the token limit. A big gap from Pass rate means the model is accurate but too verbose for the limit.
- **s / problem**: average seconds per answer, including any reasoning. The real pace, unlike tok/s.
- **Solved per hour**: correct answers per hour of generation (passed × 3600 ÷ total answer seconds). Speed and accuracy in one number.
- **Hit token cap**: answers that ran into the per-answer limit of **8192 tokens** (reasoning plus code) and were cut off; those count as failures, so a high number means the pass rate is understated.
- **Token limits used in this run**: coding 8192 tokens per answer; agentic 4096 tokens per turn.
- **Stop**: `completed` (all 161), `time_cap (60 min)`, or `low_pass_rate` (below 50% after 20 problems).
- **Agentic**: whether the slugify task's 4 tests pass at the end (10-minute box, 30 turns).
- **Agentic turns / stop / s**: turns used, why it stopped (see the screen-table legend), and seconds taken.

##### By model name

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solved per hour | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.6-35B-A3B-4bit | 149/161 | 93% | 94% (149 of 159 finished) | 34.7 | 96.1 | 2 | completed | — | — |
| Qwen3.6-35B-A3B-8bit | 151/161 | 94% | 94% (151 of 160 finished) | 26.1 | 129.4 | 1 | completed | — | — |
| Qwopus3.6-35B-A3B-Coder-8bit | 122/161 | 76% | 90% (122 of 135 finished) | 26.9 | 101.4 | 26 | completed | — | — |

##### By pass rate (most accurate first)

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solved per hour | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| Qwen3.6-35B-A3B-8bit | 151/161 | 94% | 94% (151 of 160 finished) | 26.1 | 129.4 | 1 | completed | — | — |
| mlx-community--Qwen3.6-35B-A3B-4bit | 149/161 | 93% | 94% (149 of 159 finished) | 34.7 | 96.1 | 2 | completed | — | — |
| Qwopus3.6-35B-A3B-Coder-8bit | 122/161 | 76% | 90% (122 of 135 finished) | 26.9 | 101.4 | 26 | completed | — | — |

##### By solved per hour (speed × accuracy)

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solved per hour | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| Qwen3.6-35B-A3B-8bit | 151/161 | 94% | 94% (151 of 160 finished) | 26.1 | 129.4 | 1 | completed | — | — |
| Qwopus3.6-35B-A3B-Coder-8bit | 122/161 | 76% | 90% (122 of 135 finished) | 26.9 | 101.4 | 26 | completed | — | — |
| mlx-community--Qwen3.6-35B-A3B-4bit | 149/161 | 93% | 94% (149 of 159 finished) | 34.7 | 96.1 | 2 | completed | — | — |

##### Grouped by agentic result, then solved per hour

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solved per hour | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| Qwen3.6-35B-A3B-8bit | 151/161 | 94% | 94% (151 of 160 finished) | 26.1 | 129.4 | 1 | completed | — | — |
| Qwopus3.6-35B-A3B-Coder-8bit | 122/161 | 76% | 90% (122 of 135 finished) | 26.9 | 101.4 | 26 | completed | — | — |
| mlx-community--Qwen3.6-35B-A3B-4bit | 149/161 | 93% | 94% (149 of 159 finished) | 34.7 | 96.1 | 2 | completed | — | — |

##### Grouped by family (Qwen newest first, then Gemma), then solved per hour

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solved per hour | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| **Qwen3.6-35B-A3B** | | | | | | | | | |
| Qwen3.6-35B-A3B-8bit | 151/161 | 94% | 94% (151 of 160 finished) | 26.1 | 129.4 | 1 | completed | — | — |
| Qwopus3.6-35B-A3B-Coder-8bit | 122/161 | 76% | 90% (122 of 135 finished) | 26.9 | 101.4 | 26 | completed | — | — |
| mlx-community--Qwen3.6-35B-A3B-4bit | 149/161 | 93% | 94% (149 of 159 finished) | 34.7 | 96.1 | 2 | completed | — | — |


#### Weighted score: overnight builder (worked example, weights not yet agreed)

**How it is worked out**

- **Score** = 100 × the sum of (weight × component). Each component is on a 0–1 scale; the tables show each one.
- **agentic**: 1 if the agentic task was solved, else 0. One attempt per model, so treat it as a coin flip until repeated.
- **accuracy**: Pass rate (cut-off answers count as wrong).
- **throughput**: log(1 + solved per hour) ÷ log(1 + best solved per hour in this run). The log stops one very fast model swamping the rest.
- **memory**: 1 − size ÷ largest size in this run, so smaller scores higher.
- **vision**: 1 if the model's weights include an image encoder, else 0 (from the model files; not yet tested with a real image).
- **<sup>(d)</sup>** after a model name: deleted from the MBP-14 since this run (the MBP-16 may still hold a copy). Kept here as history.
- **Net per hour**: (passed − failed) ÷ hours of answering. Counts every wrong answer as cancelling a right one, because wrong code costs review or rework. Negative means it produces more wrong code than right.

##### Weights v2 (2026-10-20): adds vision, taken from memory

Score = 100 × (0.4 × agentic + 0.3 × accuracy + 0.2 × throughput + 0.05 × memory + 0.05 × vision). A model that reads images avoids handing screenshots to a second model, which costs time and memory.

| Model | Agentic (×0.4) | Accuracy (×0.3) | Throughput (×0.2) | Memory (×0.05) | Vision (×0.05) | **Score** | Solved per hour | Net per hour |
|---|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.6-35B-A3B-4bit | 0.0 | 0.93 | 0.94 | 0.46 | 1.0 | **53.8** | 96.1 | 88 |
| Qwen3.6-35B-A3B-8bit | 0.0 | 0.94 | 1.0 | 0.0 | 1.0 | **53.1** | 129.4 | 121 |
| Qwopus3.6-35B-A3B-Coder-8bit | 0.0 | 0.76 | 0.95 | 0.0 | 1.0 | **46.7** | 101.4 | 69 |

##### Weights v1 (2026-10-20): first worked example

Score = 100 × (0.4 × agentic + 0.3 × accuracy + 0.2 × throughput + 0.1 × memory).

| Model | Agentic (×0.4) | Accuracy (×0.3) | Throughput (×0.2) | Memory (×0.1) | **Score** | Solved per hour | Net per hour |
|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.6-35B-A3B-4bit | 0.0 | 0.93 | 0.94 | 0.46 | **51.1** | 96.1 | 88 |
| Qwen3.6-35B-A3B-8bit | 0.0 | 0.94 | 1.0 | 0.0 | **48.1** | 129.4 | 121 |
| Qwopus3.6-35B-A3B-Coder-8bit | 0.0 | 0.76 | 0.95 | 0.0 | **41.7** | 101.4 | 69 |

---

### Run 4: Gemma 32k (coding only, 32,768-token answers; stopped at problem 30)

**Question:** how much thinking does Gemma-4-26B need to finish these Ruby problems? Earlier runs cut it off
at 4,096 and then 8,192 tokens.

**Setup:** extended coding screen, same 161 MultiPL-E Ruby problems in the same order, limit raised to
32,768 tokens per answer, thinking on (oMLX's setting for this model), 8-hour cap.

**What happened:** the run stopped at problem 30, at 14:29, when the machine running the harness restarted
its gateway process and took the run with it. The harness then kept results in memory until the end, so
per-answer pass/fail was lost. It has since been changed to write after every 10 problems and to save on
stop. What survives:

- **Progress lines:** [`../logs/run-gemma32k.log`](results/logs/run-gemma32k.log), giving the pass rate after
  10, 20 and 30 problems.
- **Per-answer token counts and timings** from oMLX's own log:
  [`omlx-requests-snapshot.tsv`](results/2026-10-20-gemma32k/omlx-requests-snapshot.tsv).

#### Results (first 30 problems)

**Pass rate: 23 of 30 (77%).** It was 60% after 10 and 65% after 20.

| Tokens used per answer | Answers |
|---|---|
| up to 4,096 | **23** |
| 4,097 – 8,192 | 1 |
| 8,193 – 32,767 | **0** |
| ran to the 32,768 limit without finishing | **6** |

- A finished answer typically took **about 2,400 tokens and 47 s** (median).
- The 6 answers that hit the limit took **up to about 13½ minutes each** at a steady ~50 tok/s.
- Averaged over all 30, that's about 3–4½ minutes per problem. At that pace all 161 would have taken over
  8 hours.

#### What it means

- **More room doesn't help.** When Gemma-4-26B finishes, it does so within about 4,000 tokens. About 1 in 5
  answers never finishes, however much room it's given. The run didn't save the reasoning text, so looping
  isn't confirmed, but the pattern looks like runaway reasoning rather than hard problems.
- **That's a reliability problem for unattended work.** One stuck answer can hold the Mac for 13 minutes.
- **The likely fix is a thinking budget or thinking off,** not a larger limit (see
  [`../../docs/TUNING_TODO.md`](results/../docs/TUNING_TODO.md)).
- **Against the tuning gate** (≥ 90% accuracy at full length): 77% on the first 30 doesn't pass. The earlier
  "98% of finished answers" figure counted only answers that finished; the stuck ones are what pull it down.

---

## Summary across runs

### Latest evidence per model

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

### Progression: Ruby pass rate run by run

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

### Where each run's page lives

- **Run 1: screen** (2-min coding box, 1,024-token answers, 2-min agentic box): [`results/2026-10-19/RESULTS.md`](results/2026-10-19/RESULTS.md)
- **Run 2: extended** (all 161 problems, 4,096-token answers, 60-min cap, 10-min agentic box): [`results/2026-10-19-extended/RESULTS.md`](results/2026-10-19-extended/RESULTS.md)
- **Run 3: 8k re-run** (coding only, 8,192-token answers, no time cap; verbose models only): [`results/2026-10-20-8k/RESULTS.md`](results/2026-10-20-8k/RESULTS.md)
- **Run 4: Gemma 32k** (coding only, 32,768-token answers; stopped at problem 30): [`results/2026-10-20-gemma32k/README.md`](results/2026-10-20-gemma32k/README.md)
- **Run logs** for all of them (host addresses redacted): [`results/logs/`](results/logs/)

Run 2's page also has the weighted scores (v1 and v2), the family grouping and the sorted views.
Run 3 was stopped during its last model (Gemma-4-26B, rerun as Run 4), so that model has no Run 3 row.
