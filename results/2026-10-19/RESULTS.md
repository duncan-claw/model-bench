# Results — 2026-10-19

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
