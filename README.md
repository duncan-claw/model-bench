# model-bench

Light, time-boxed screens for choosing **local LLMs on Apple Silicon** for a Ruby/Rails software
factory: a frontier model plans, and a local model on a Mac builds. The aim is **data for
keep/cut decisions**, not a leaderboard. Every keep/cut call and the reasoning behind it is in
[`DECISIONS.md`](DECISIONS.md).

**Hardware:** MacBook Pro M1 Max, 64 GB, one model loaded at a time, served by
[oMLX](https://github.com/jundot/omlx) (MLX). A few GGUF models were run through LM Studio for comparison.

## Headline results (October 2026)

Ruby coding is all 161 [MultiPL-E](https://github.com/nuprl/MultiPL-E) HumanEval-Ruby problems, one attempt
each at temperature 0. The agentic task is a small multi-turn fix: make 4 failing Minitest tests pass
using file and test tools. Full tables: [`results/2026-10-19-extended/RESULTS.md`](results/2026-10-19-extended/RESULTS.md)
and [`results/2026-10-20-8k/`](results/2026-10-20-8k/). The data and tasks are linked under
[Evaluation data, tasks and models](#evaluation-data-tasks-and-models), so you can judge how relevant they are to your own work.

**Waiting time** is what you'd feel using these as a daily driver. Each answer is one short Ruby method;
the times are for a single request with the model already loaded.

| Model (MLX) | Ruby pass rate | Typical wait per answer | 1 in 10 answers waits longer than | Longest wait | Agentic fix (time taken) | Reads images |
|---|---|---|---|---|---|---|
| Qwen3.8-27B 4-bit | 85% | **4 s** | 6 s | 59 s | solved (45 s) | yes |
| Qwen3.8-27B 8-bit | 86% | 10 s | 19 s | 116 s | solved (78 s) | yes |
| Qwen3.6-35B-A3B 8-bit (8,192-token answers) | **94%** | 23 s | 45 s | 81 s | solved (65 s) | yes |
| Qwen3.6-35B-A3B 4-bit (8,192-token answers) | 93% | 32 s | 59 s | 110 s | 1 of 2 runs (67 s) | yes |
| Ornith-1.5-35B-A3B 4-bit | 84% | 5 s | 13 s | 59 s | solved (79 s) | no |
| Ornith-1.5-35B-A3B 8-bit | 88% | 7 s | 21 s | 83 s | not solved (gave up after 167 s) | no |
| Gemma-4-26B-A4B 4-bit (4,096 tokens, 60-min cap) | 68% (98% of finished answers) | 53 s | 76 s | 77 s* | solved (45 s) | yes |

\* Capped by the 4,096-token limit. With room to finish, single Gemma-4-26B answers took up to 166 s.

**One job at a time.** These numbers are for one request on one model. On a 64 GB Mac that is the real
working pattern, and it's the biggest practical limit for a daily driver:
- **While the model is thinking, you wait.** A second request, from your editor, a chat, or an overnight agent,
  either queues behind it or shares the GPU and slows both. We didn't measure concurrent requests; plan as if
  the Mac does one job at a time.
- **One big model at a time.** A 35 GB model leaves no room for a second. Switching models costs 6–36 s of
  loading, every time.
- **Thinking models stretch the wait.** Qwen3.6 and Gemma-4-26B are the most accurate, but a 30–60 s typical
  wait per small answer adds up quickly in interactive use. They suit unattended, overnight queues better than
  pair-programming.
- **A cloud model has none of these limits:** you can run several jobs at once.

### What it costs: the Mac's time vs yours

Accuracy and speed trade against different budgets. Machine time on a Mac you already own is cheap,
especially overnight. **Your time spent reviewing and fixing wrong output is not.** The same results,
seen that way:

| Model (MLX) | All 161 problems take | Correct per hour | Wrong per hour | Wrong per 100 answers | Review cost per 100 answers* |
|---|---|---|---|---|---|
| Qwen3.8-27B 4-bit | 12 min | 693 | 127 | 16 | 160 min |
| Qwen3.8-27B 8-bit | 34 min | 245 | 41 | 14 | 140 min |
| Qwen3.6-35B-A3B 8-bit | 70 min | 129 | 9 | **6** | **60 min** |
| Qwen3.6-35B-A3B 4-bit | 93 min | 96 | 8 | 7 | 70 min |
| Ornith-1.5-35B-A3B 4-bit | 21 min | 393 | 76 | 16 | 160 min |
| Ornith-1.5-35B-A3B 8-bit | 32 min | 261 | 37 | 12 | 120 min |
| Gemma-4-26B-A4B 4-bit (4,096 tokens) | 133 min† | 49 | 24 | 32† | 320 min† |

\* Assumes **10 minutes of a person's time to find and fix each wrong answer**. Swap in your own figure:
the ranking depends on it.
† Includes answers cut off at the token limit; on finished answers Gemma-4-26B was 98% correct.

**How to read it:**
- **Overnight, the clock barely matters.** In a 10-hour night, even the slowest model here gets through its
  problems several times over. What lands on your desk in the morning is the wrong answers, and the most
  accurate model produces a third as many as the fastest.
- **During the day, or with a deep queue, throughput matters again.** Qwen3.8-27B 4-bit produces the most
  correct answers per hour by far.
- **The hardware:** a MacBook Pro M1 Max 64 GB is about A$2,500. That's roughly A$200 a month over one year,
  or A$70 a month over three, plus a few dollars of electricity overnight. That's what local has to beat:
  about the same money a month buys a lot of cloud API tokens, and cloud models are generally more accurate.
  Local wins on fixed cost at high volume, on privacy, and on hardware you already own.
- These are short, single-function problems. Real feature work is much larger per task, so treat the
  per-hour figures as relative, not as a forecast.

What surprised us:
- **4-bit vs 8-bit barely mattered** for Qwen3.8-27B (85% vs 86%) but cost 3× the time and 2× the memory.
- **"Thinking" models lose on the clock, not on accuracy.** Gemma-4-26B and Qwen3.6 are among the most
  accurate when they finish, but they write 2,000–8,000+ tokens per answer. Generation speed (tok/s) was never
  the bottleneck; volume was.
- **Fine-tunes didn't beat their bases** on plain Ruby: a Qwen3.6 coding fine-tune scored 76% against its
  base's 94%, and a Rails-tuned 30B scored 45%.
- **Single-turn tool calling is easy** (most models 12/12). **Finishing a multi-step task isn't:** several
  models gave up halfway and answered in plain text.

Caveats: plain-Ruby puzzles (no Rails conventions), one agentic attempt per model, one machine.
See "How accuracy is counted" below.

## Requirements

- Ruby 3.4 (runner) and Docker (model-written code runs in a throwaway `ruby:3.4-slim-bookworm`
  container with no network).
- An OpenAI-compatible server for each host. For oMLX, ssh access to the Mac, so the runner can read
  the API key and load/unload models.
- `cp config/hosts.example.yml config/hosts.yml` and fill in your hosts. That file is git-ignored.

## Scope (agreed 2026-10-19)

- **Stage 1 + 2 (now):** models of 9B and above, judged on coding, tool calling and agentic work.
- **Later:** models under 9B, judged on assistant and research roles.
- **Stage 3 (heavier agentic runs):** only for finalists, after the Stage 1 + 2 data has been reviewed.
- No cloud baseline (we already know cloud flash models win), no pass/fail thresholds. Raw data only.

## Screens (about 6 minutes per model)

| Screen | What it is | Box |
|---|---|---|
| speed | One streamed prompt, 400 tokens out: time to first token, tokens/s | ~1 request |
| coding | MultiPL-E HumanEval-Ruby (161 problems), same seeded order for every model; works through problems until the box closes, then runs the unit tests | 120 s |
| tools | 12 single-turn tool-calling cases: right tool or none, right arguments and types, parallel calls | 90 s |
| agentic | `tasks/slugify`: 4 failing Minitest tests; tools `list_files`, `read_file`, `write_file`, `run_tests`, `finish`; max 15 turns | 120 s |

A box stops *new* items starting; a request already in flight is allowed to finish.
The number attempted inside the box is part of the result, because a slow model gets
through less work in the same time.

Model-written code runs only in a throwaway `ruby:3.4-slim-bookworm` container with no
network, 512 MB of memory and 1 CPU.

## Run

```bash
export PATH="$HOME/.rbenv/versions/3.4.1/bin:$PATH"
bin/bench --run 2026-10-19                    # every non-pending model in config/models.yml
bin/bench --only gemma --run test --screens speed,tools
bin/bench --include-pending --only fullstack  # GGUF models via LM Studio
bin/report 2026-10-19                         # rebuild results/<run>/RESULTS.md
```

For oMLX hosts the runner unloads everything, loads the one model under test, and at the
end puts back whatever was loaded before (oMLX's pinned model). The oMLX API key is read
from the MBP's `~/.omlx/settings.json` over ssh and only held in memory.

GGUF models are served by LM Studio on the MBP-14, which shares the GPU with oMLX.
Don't run both at once.

## Layout

- `bin/bench`, `bin/report`: the runner and the table builder
- `lib/client.rb`: OpenAI-compatible client that bypasses the proxy
- `lib/screens/*.rb`: the four screens
- `lib/sandbox.rb`: the container that runs model-written code
- `config/models.yml`: the models under test; `config/hosts.example.yml`: template for your host addresses
- `data/multipl-e-humaneval-rb.jsonl`: from [nuprl/MultiPL-E](https://github.com/nuprl/MultiPL-E)
  (`humaneval-rb`, test split), under its own licence ([`data/LICENSE-MultiPL-E`](data/LICENSE-MultiPL-E)):
  BSD 3-Clause, with the restriction that it **may not be used as training data** for any machine learning model
- `tasks/slugify/`: the agentic task
- `results/<run>/`: one JSON file per model (including generated code and tool calls), plus `RESULTS.md`

## How accuracy is counted (coding screen)

1. Each problem is a MultiPL-E HumanEval-Ruby task: a comment describing the method plus its `def` line.
2. The model answers once at temperature 0, asked for only the complete Ruby method in a code block.
3. The harness takes the code block. If only the method body came back, it wraps it in the original `def … end`.
4. The problem's own `test/unit` tests are appended, and the file runs in a throwaway Ruby 3.4 container
   (no network, 10 s limit).
5. A problem **passes only if every assertion passes**. Each of these is a fail: a wrong case, a syntax or
   runtime error, a timeout, an answer cut off at the token limit, or a request error.

- **Pass rate** = passed ÷ attempted. This is the "accuracy" component of the weighted score.
- **Pass rate excl. cut-off** = passed ÷ answers that finished inside the token limit.

What this hides:

- **Different sample sizes:** models stopped by the time cap are scored on fewer problems (the same
  first N, in a fixed seeded order).
- **Verbosity counts as inaccuracy:** cut-off answers count as fails.
- **All or nothing:** 6 of 7 cases right scores the same as code that doesn't run.
- **One attempt per problem.**
- **Plain-Ruby algorithms only:** no Rails conventions, no existing-codebase work, no style judgement.
- **Answer extraction** depends on a code block being returned. One failure was spot-checked as a genuine
  mistake; extraction hasn't been audited across all answers.

Open choice (2026-10-20): the weighted score uses **pass rate**, so verbosity is penalised. That fits
overnight work, where running out of room fails the job. The alternative is pass rate excl. cut-off,
which measures pure correctness.

## Licence

Code: MIT ([`LICENSE`](LICENSE)). Benchmark problems in `data/`: MultiPL-E's licence (see above).

## Run logs

The raw run logs are in [`results/logs/`](results/logs/). Host addresses are replaced with
`<mac-host>` and home-folder paths with `~` by [`bin/redact-logs`](bin/redact-logs); nothing else is
changed. Things to know when reading them:

- **`run-2026-10-19.log`, 19:29–19:31:** the four GGUF models score 0 across the board. That was
  a connection failure, not the models: LM Studio's server only accepted local connections, so every
  request was refused. The real GGUF results are in the block that follows (19:32–19:54), after the
  runner was changed to start LM Studio on the Mac's network address.
- **KAT-Coder V2.5 load errors** (`ERROR RuntimeError: load failed 500`): oMLX's engine treats it as a
  vision model with no vision part and won't load it. The model was parked and isn't in any table.
- **`run-2026-10-20-8k.log` ends during Gemma-4-26B:** that run was stopped on purpose after about
  10 problems, to run Ornith 8-bit first. Gemma-4-26B was then rerun with a 32,768-token limit
  (`run-gemma32k.log`) to measure how much thinking it needs.
- **`run-2026-10-19-extended.log` ends with a Ruby stack trace:** an encoding bug in `bin/report`,
  fixed the same morning. The benchmark run itself had completed.

## Evaluation data, tasks and models

Everything the results rest on, so you can check how well it fits your own work:

- **Ruby coding problems:** [MultiPL-E](https://github.com/nuprl/MultiPL-E) (Northeastern University and others),
  a translation of OpenAI's [HumanEval](https://github.com/openai/human-eval) into 18+ languages. We used the
  Ruby set: [`nuprl/MultiPL-E`, config `humaneval-rb`](https://huggingface.co/datasets/nuprl/MultiPL-E/viewer/humaneval-rb)
  (161 problems; local copy in [`data/`](data/)). These are short, algorithmic, single-method problems
  translated from Python, so they test general Ruby coding, not Rails or idiomatic Ruby.
- **Tool-calling cases:** 12 single-turn cases, written for this repo:
  [`lib/screens/tools.rb`](lib/screens/tools.rb).
- **Agentic task:** a tiny Ruby library with 4 failing Minitest tests, written for this repo:
  [`tasks/slugify/`](tasks/slugify/). The harness is [`lib/screens/agentic.rb`](lib/screens/agentic.rb).
- **Models** (all MLX, from Hugging Face):
  [Qwen3.8-27B 4-bit](https://huggingface.co/mlx-community/Qwen3.8-27B-4bit),
  [Qwen3.8-27B 8-bit](https://huggingface.co/mlx-community/Qwen3.8-27B-8bit),
  [Qwen3.6-35B-A3B 8-bit](https://huggingface.co/mlx-community/Qwen3.6-35B-A3B-8bit),
  [Qwen3.6-35B-A3B 4-bit](https://huggingface.co/mlx-community/Qwen3.6-35B-A3B-4bit),
  [Ornith-1.5-35B-A3B 4-bit](https://huggingface.co/ornith-ai/Ornith-1.5-35B-A3B-MLX-4bit),
  [Ornith-1.5-35B-A3B 8-bit](https://huggingface.co/ornith-ai/Ornith-1.5-35B-A3B-MLX-8bit),
  [Gemma-4-26B-A4B 4-bit](https://huggingface.co/mlx-community/gemma-4-26b-a4b-it-4bit).
  Every other model tested is listed in [`config/models.yml`](config/models.yml).
- **Serving:** [oMLX](https://github.com/jundot/omlx) for MLX models; LM Studio for the GGUF comparisons.

For heavier, Rails-specific agentic evals, see [rails/ai-evals](https://github.com/rails/ai-evals): seeded
defects in a real Rails app, each with a hidden test.
