# Gemma-4-26B-A4B 4-bit at 32,768 tokens per answer (2026-10-20)

**Question:** how much thinking does Gemma-4-26B need to finish these Ruby problems? Earlier runs cut it off
at 4,096 and then 8,192 tokens.

**Setup:** extended coding screen, same 161 MultiPL-E Ruby problems in the same order, limit raised to
32,768 tokens per answer, thinking on (oMLX's setting for this model), 8-hour cap.

**What happened:** the run stopped at problem 30, at 14:29, when the machine running the harness restarted
its gateway process and took the run with it. The harness then kept results in memory until the end, so
per-answer pass/fail was lost. It has since been changed to write after every 10 problems and to save on
stop. What survives:

- **Progress lines:** [`../logs/run-gemma32k.log`](../logs/run-gemma32k.log), giving the pass rate after
  10, 20 and 30 problems.
- **Per-answer token counts and timings** from oMLX's own log:
  [`omlx-requests-snapshot.tsv`](omlx-requests-snapshot.tsv).

## Results (first 30 problems)

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

## What it means

- **More room doesn't help.** When Gemma-4-26B finishes, it does so within about 4,000 tokens. About 1 in 5
  answers never finishes, however much room it's given. The run didn't save the reasoning text, so looping
  isn't confirmed, but the pattern looks like runaway reasoning rather than hard problems.
- **That's a reliability problem for unattended work.** One stuck answer can hold the Mac for 13 minutes.
- **The likely fix is a thinking budget or thinking off,** not a larger limit (see
  [`../../docs/TUNING_TODO.md`](../../docs/TUNING_TODO.md)).
- **Against the tuning gate** (≥ 90% accuracy at full length): 77% on the first 30 doesn't pass. The earlier
  "98% of finished answers" figure counted only answers that finished; the stuck ones are what pull it down.
