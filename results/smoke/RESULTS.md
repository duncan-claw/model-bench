# Results — smoke

Time boxes: coding 120 s, tools 90 s, agentic 120 s (a box stops *new* items; one in flight may overrun).
Coding = MultiPL-E HumanEval-Ruby, same seeded order for every model. Tools = 12 single-turn cases.
Agentic = fix `tasks/slugify` (4 tests) with file/test tools, max 15 turns.

| Model | Size GB | Load s | TTFT s | tok/s | Coding pass/attempted | Tools pass/attempted (of 12) | Agentic | Agentic turns / stop | Error |
|---|---|---|---|---|---|---|---|---|---|
| kang-heewon--gemma-4-12B-agentic-fable5-composer2.5-v2-3.5x-tau2-MLX-8bit | 12 | 7.9 | — | — | 11/21 | — | not solved | 12 / time_box |  |
| ZQ-Dev--KAT-Coder-V2.5-Dev-oQ2e-fp16 | 11 | — | — | — | — | — | — | — | RuntimeError: load failed 500: {"detail" => "Model 'ZQ-Dev-- |
