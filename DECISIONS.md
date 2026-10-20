# Decisions log

Why models were kept, cut or changed, and the evidence each call rested on. Newest first.
The numbers live in `results/<run>/RESULTS.md`; this file records the reasoning.

## 2026-10-20

- **Gemma-4-26B at 32,768 tokens: more room doesn't help** (`results/2026-10-20-gemma32k/`). It passed 23 of the
  first 30. 23 answers finished within 4,096 tokens and 1 within 8,192; **6 ran the full 32,768 tokens without
  finishing**, up to ~13½ minutes each. It **fails the tuning gate's accuracy test** (77% against ≥ 90%). Its
  earlier "98% of finished answers" ignored the stuck ones. Any further Gemma work starts with a thinking budget
  or thinking off, not a bigger limit. The run ended at problem 30 when the Mac mini's OpenClaw Gateway restarted,
  taking the harness process with it.
- **Harness hardened:** coding results are written after every 10 problems and saved on SIGTERM, and the last
  3,000 characters of any cut-off answer are kept, to check for looping. Lesson: long runs must be started
  independently of the Gateway (a detached job), not from an agent's shell.
- **Splash results added to the README** (Qwen3.8-27B 4-bit: 2.6× faster generation, cold-prompt wait halved;
  measured 2026-10-18 with the separate omlx-bench script on the MBP-16, alongside an oMLX 0.7.0→0.7.1rc1 update).

- **Published publicly** at https://github.com/duncan-claw/model-bench (made public 2026-10-20, history squashed to one commit).
  It's a single-commit snapshot, because local history contains host addresses. Host addresses moved
  to the git-ignored `config/hosts.yml`, with `config/hosts.example.yml` as the template. Run logs and
  one-off queue scripts are untracked. Added an MIT licence for the code and MultiPL-E's licence for
  `data/`, which forbids using it as ML training data. The README now leads with hardware, results
  and caveats. The local repo keeps full history; GitHub gets snapshots.

- **One model per Mac, on its own** (agreed with Mark). The two MBPs run in parallel (different
  models or different jobs) rather than splitting one model across them with exo. Reason: the link
  between non-RDMA Macs is the bottleneck. The August exo cluster ran Qwen3.8-27B at about 3.5 tok/s
  across two nodes. exo's changes since (v1.0.69–v1.0.71 and the October commits on main) don't touch
  that link: they're batching, memory, stability, and tensor-parallel fixes aimed at Thunderbolt/RDMA
  clusters. Models must fit one 64 GB Mac, so 4- to 8-bit versions of 31–35B models are the ceiling.
  Gemma-4-31B bf16 (~62 GB) doesn't fit.

- **Speed tuning parked as a gated TODO** (`docs/TUNING_TODO.md`). Gemma-4-26B is 98% accurate on
  finished answers but writes about 2,700 tokens per answer. Tuning (thinking off or budget, Gemma 4 MTP
  drafter, prompt, RAG) only happens if the 8k re-run shows accuracy ≥ 90% and ≥ 3 points above
  Qwen3.8-27B 4-bit, the agentic task passes at least 2 of 3 times, and the required speed-up is ≤ 10×.

- **Vision added to the weighting (v2: agentic 0.4, accuracy 0.3, throughput 0.2, memory 0.05,
  vision 0.05).** Mark's reasoning: handing image context to a second model costs time and
  resources. The 0.05 came out of memory, which matters less with one model loaded on a 64 GB MBP.
  The v1 table is kept underneath. Effect: Qwen3.8-27B 4-bit stays first (91.4). Ornith MLX 4-bit
  drops from 2nd to 4th (84.2), behind Qwen3.8-27B 8-bit and the deleted Ornith GGUF, because the
  MLX Ornith builds have no image encoder. Vision status comes from each model's files, recorded
  as `vision:` in `config/models.yml`; no model has been tested with a real image yet.

- **KAT-Coder V2.5 deleted from the MBP-14** (11 GB). It was parked on 2026-10-19 because oMLX
  wouldn't load it. Its config declares a vision model but its weights contain no vision part,
  so oMLX's engine refuses it. The MBP-16 copy and OpenClaw's config entry (which points at the MBP-16) are left alone.

- **Ornith-1.5-35B-A3B GGUF (6-bit) deleted** (28 GB, plus its image adapter) and removed from
  OpenClaw's config. Grounds: the MLX-only preference, and the weighted score. Ornith MLX 4-bit
  scored 86.6 against the GGUF's 82.9, at 2.3× the throughput (393 vs 169 solved/hour), for
  5 points less accuracy (84% vs 89%). The GGUF's extra accuracy is now the target for Ornith MLX 8-bit.
  Lost with it: image input (the GGUF's mmproj vision adapter); no MLX Ornith on disk reads images.

- **MLX only, no GGUF, as the default.** Mark's preference: MLX is native to Apple Silicon,
  and one serving stack (oMLX) means fewer moving parts. The factory will later add Rails/Ruby API
  RAG, app introspection (models, routes), git-log reading, bug reproduction, log review and
  ticket updates, so the model layer should stay simple. The only GGUF left on disk is
  `qwen3-coder-30b-rails`, kept for a later Rails-specific test in Avalon Speedway.
- **Weighted score added as a worked example** (overnight builder: agentic 0.4, accuracy 0.3,
  throughput 0.2, memory 0.1) plus a "net per hour" column. The weights are not agreed yet.
  The score exists to make the trade-offs visible, not to decide on its own.
- **Ornith-1.5-35B-A3B MLX 8-bit downloaded** (`ornith-ai/Ornith-1.5-35B-A3B-MLX-8bit`, 37 GB).
  The aim is to see whether it matches the GGUF 6-bit's accuracy (89%) at close to MLX 4-bit speed
  (393 solved/hour). If it does, it replaces both. Queued behind the 8k re-run.
- **8,192-token coding re-run** for Qwopus, Qwen3.6-35B-A3B 8-bit and 4-bit, and Gemma-4-26B.
  All four were ≥ 90% on answers that finished, but many answers were cut off at 4,096 tokens,
  so their headline pass rates understate them. No 60-minute cap, so the run shows how long
  a full 161-problem pass really takes.
- **Deleted from the MBP-14:**
  - FullStack-Learn-LM-30B-A3B GGUF (23 GB). The fastest coder (1,331 solved/hour), but it called
    `finish` with the tests still failing, and it's GGUF.
  - Gemma-4-12B agentic GGUF (12.7 GB). It duplicated the MLX copy, which was 4× as productive
    (572 vs 131 solved/hour) at the same accuracy (73% vs 71%).
  - Both were also removed from OpenClaw's config.
- **Ornith MLX 4-bit kept.** The 2026-08-25 "inconsistent" note didn't reproduce: it solved the
  agentic task in both runs.

## 2026-10-19

- **Scope for stages 1 and 2:** models ≥ 9B, judged on coding, tools and agentic work. No cloud
  baseline (cloud flash models are known to win). No thresholds: gather data, decide later.
- **KAT-Coder V2.5 parked.** oMLX's Splash engine treats it as a vision model with no vision tower,
  and wouldn't load it even with `trust_remote_code` and `model_type_override: llm`.
- **Extended run rules:** all 161 problems; stop below 50% after 20; 60-minute cap; 10-minute,
  30-turn agentic task.
  - Not run: IQuest-14B (42% in the screen) and IQuest-40B (about 4.5 min per problem).
- **Deleted before benchmarking:** IQuest-40B-Loop 4-bit (failed its August bake-off) and
  Llama-3.2-3B 4-bit and 8-bit (too small). Also Gemma-4-12B coder (downloaded by mistake).
