# Results — 2026-10-20-8k-b

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
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 15 | 32.9 | — | — | 136/161 | — | — | — |  |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 18 | 23.0 | — | — | 137/161 | — | — | — |  |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 37 | 19.3 | — | — | 143/161 | — | — | — |  |

## Extended coding (all 161 problems, early stop below 50% after 20, or at the time cap)

**Legend: extended tables**

- **Pass / attempted**: Ruby problems whose unit tests passed / problems answered before the run stopped (161 = all).
- **Pass rate**: pass ÷ attempted. Accuracy only; ignores speed.
- **Pass rate excl. cut-off**: pass rate over only the answers that finished inside the token limit. A big gap from Pass rate means the model is accurate but too verbose for the limit.
- **s / problem**: average seconds per answer, including any reasoning. The real pace, unlike tok/s.
- **Solve rate (/hr)**: projected correct answers per hour of Mac time at the measured pace (passed × 3600 ÷ total answer seconds). A rate, not a count: there are only 161 problems. Speed and accuracy in one number.
- **Hit token cap**: answers that ran into the per-answer limit of **8192 tokens** (reasoning plus code) and were cut off; those count as failures, so a high number means the pass rate is understated.
- **Token limits used in this run**: coding 8192 tokens per answer; agentic 4096 tokens per turn.
- **Stop**: `completed` (all 161), `time_cap (60 min)`, or `low_pass_rate` (below 50% after 20 problems).
- **Agentic**: whether the slugify task's 4 tests pass at the end (10-minute box, 30 turns).
- **Agentic turns / stop / s**: turns used, why it stopped (see the screen-table legend), and seconds taken.

### By model name

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solve rate (/hr) | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 136/161 | 85% | 84% (136 of 161 finished) | 4.5 | 671.9 | 0 | completed | — | — |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 137/161 | 85% | 88% (137 of 156 finished) | 10.0 | 306.2 | 5 | completed | — | — |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 143/161 | 89% | 91% (143 of 158 finished) | 15.5 | 206.3 | 3 | completed | — | — |

### By pass rate (most accurate first)

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solve rate (/hr) | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 143/161 | 89% | 91% (143 of 158 finished) | 15.5 | 206.3 | 3 | completed | — | — |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 137/161 | 85% | 88% (137 of 156 finished) | 10.0 | 306.2 | 5 | completed | — | — |
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 136/161 | 85% | 84% (136 of 161 finished) | 4.5 | 671.9 | 0 | completed | — | — |

### By solve rate (speed × accuracy)

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solve rate (/hr) | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 136/161 | 85% | 84% (136 of 161 finished) | 4.5 | 671.9 | 0 | completed | — | — |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 137/161 | 85% | 88% (137 of 156 finished) | 10.0 | 306.2 | 5 | completed | — | — |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 143/161 | 89% | 91% (143 of 158 finished) | 15.5 | 206.3 | 3 | completed | — | — |

### Grouped by agentic result, then solve rate

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solve rate (/hr) | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 136/161 | 85% | 84% (136 of 161 finished) | 4.5 | 671.9 | 0 | completed | — | — |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 137/161 | 85% | 88% (137 of 156 finished) | 10.0 | 306.2 | 5 | completed | — | — |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 143/161 | 89% | 91% (143 of 158 finished) | 15.5 | 206.3 | 3 | completed | — | — |

### Grouped by family (Qwen newest first, then Gemma), then solve rate

| Model | Pass / attempted | Pass rate | Pass rate excl. cut-off | s / problem | Solve rate (/hr) | Hit token cap | Stop | Agentic | Agentic turns / stop / s |
|---|---|---|---|---|---|---|---|---|---|
| **Qwen3.8-27B** | | | | | | | | | |
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 136/161 | 85% | 84% (136 of 161 finished) | 4.5 | 671.9 | 0 | completed | — | — |
| **Qwen3.5 (fine-tunes/distills)** | | | | | | | | | |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 137/161 | 85% | 88% (137 of 156 finished) | 10.0 | 306.2 | 5 | completed | — | — |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 143/161 | 89% | 91% (143 of 158 finished) | 15.5 | 206.3 | 3 | completed | — | — |


## Weighted score: overnight builder (worked example, weights not yet agreed)

**How it is worked out**

- **Score** = 100 × the sum of (weight × component). Each component is on a 0–1 scale; the tables show each one.
- **agentic**: 1 if the agentic task was solved, else 0. One attempt per model, so treat it as a coin flip until repeated.
- **accuracy**: Pass rate (cut-off answers count as wrong).
- **throughput**: log(1 + solve rate) ÷ log(1 + best solve rate in this run). The log stops one very fast model swamping the rest.
- **memory**: 1 − size ÷ largest size in this run, so smaller scores higher.
- **vision**: 1 if the model's weights include an image encoder, else 0 (from the model files; not yet tested with a real image).
- **<sup>(d)</sup>** after a model name: deleted from the MBP-14 since this run (the MBP-16 may still hold a copy). Kept here as history.
- **Net solve rate (/hr)**: projected (correct − wrong) answers per hour of Mac time, i.e. (passed − failed) ÷ hours of answering. Counts every wrong answer as cancelling a right one, because wrong code costs review or rework. Negative means it produces more wrong code than right.

### Weights v2 (2026-10-20): adds vision, taken from memory

Score = 100 × (0.4 × agentic + 0.3 × accuracy + 0.2 × throughput + 0.05 × memory + 0.05 × vision). A model that reads images avoids handing screenshots to a second model, which costs time and memory.

| Model | Agentic (×0.4) | Accuracy (×0.3) | Throughput (×0.2) | Memory (×0.05) | Vision (×0.05) | **Score** | Solve rate (/hr) | Net solve rate (/hr) |
|---|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 0.0 | 0.85 | 1.0 | 0.59 | 1.0 | **53.3** | 671.9 | 548 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 0.0 | 0.85 | 0.88 | 0.51 | 0.0 | **45.7** | 306.2 | 253 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 0.0 | 0.89 | 0.82 | 0.0 | 0.0 | **43.0** | 206.3 | 180 |

### Weights v1 (2026-10-20): first worked example

Score = 100 × (0.4 × agentic + 0.3 × accuracy + 0.2 × throughput + 0.1 × memory).

| Model | Agentic (×0.4) | Accuracy (×0.3) | Throughput (×0.2) | Memory (×0.1) | **Score** | Solve rate (/hr) | Net solve rate (/hr) |
|---|---|---|---|---|---|---|---|
| mlx-community--Qwen3.8-27B-4bit:qwen-3-8-27b-instruct | 0.0 | 0.85 | 1.0 | 0.59 | **51.3** | 671.9 | 548 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-4bit | 0.0 | 0.85 | 0.88 | 0.51 | **48.3** | 306.2 | 253 |
| ornith-ai--Ornith-1.5-35B-A3B-MLX-8bit | 0.0 | 0.89 | 0.82 | 0.0 | **43.0** | 206.3 | 180 |
