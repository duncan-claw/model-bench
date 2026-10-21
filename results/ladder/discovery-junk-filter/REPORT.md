# discovery-junk-filter slice ladder: report (run of 21 Oct 2026)

*Anonymised for publication: `client-app` is the client's project, a news discovery and documentation RAG system (a private Rails 8 app). Client and people names are replaced with "the client"; example titles are reworded to a neutral topic, with the rule each one tests unchanged.*

Plan: `docs/LADDER_RUN_PROMPT_discovery-junk-filter.md`. Specs: client-app `ladder/discovery-junk-filter-specs`
(`dafc24f`). Runner: `bin/ladder` at `359169c` (Step 0: Tailwind build + `config/master.key` copy; proof on the R1 base:
3793 runs, 0 failures, 4 errors, all `undefined method 'index_title?'`). Both Macs finished all 15 attempts:
MBP-16 00:21–01:47, MBP-14 00:21–04:02, with a pause from 00:38 to 01:03 (see "Run notes").

**Pre-flight:** both Macs ran macOS 27.0.1 and oMLX 0.7.1rc1. MBP-14 ran Qwen3.8-27B 4-bit (thinking off) on `splash`;
MBP-16 ran Qwen3.6-35B-A3B 8-bit (thinking on) on `plain`. pi's log named the right model on both. Every result
JSON records the engine the table expects.

## Headline

| Rung | Qwen3.8-27B 4-bit @ MBP-14 | Qwen3.6-35B-A3B 8-bit @ MBP-16 |
|---|---|---|
| R1 `index_title?` (1 file, ≤40 lines) | 2/3 (a2 looped) | 3/3 |
| R2 `DiscoveryJunkFilter` (1 new file, ≤100) | 2/3 (a1 looped) | **1/3** (a2, a3 ran out of tokens while thinking) |
| R3 `junk_reason` (3 files, ≤150) | 3/3 | 3/3 |
| R4 settings switch (5 files, ≤250) | 3/3 | 3/3 |
| R5 whole feature (≤10 files, ≤500) | 0/3 as graded; **3/3 if the spec defect is excused** | 0/3 as graded; **2/3 if excused** (a1 ran out of tokens) |

**R5 spec defect (confirmed).** R5 requires `total_junk_count` in the diagnostics and `junk_count: 0` in each
category's stats. But `test/services/news_discovery_gemini_grounded_test.rb:138-139` and
`test/services/news_discovery_google_news_rss_test.rb:133-134` (unchanged since the app base) assert those exact key
lists. R5 also says "Do not change existing tests", and its `--allow` excludes them. So a green `bin/rails test` and a
pass are impossible together. Every R5 attempt that wrote code (5 of 6) added the new keys to those two assertion lines
and nothing more. In every one of them, verify and the full suite passed, the acceptance test was untouched, and
nothing else fell outside `--allow`.

## Every attempt

| Rung | Builder | Att. | Passed | Verify | Suite | Test file untouched | Outside allowed | Turns | Tool calls | pi s | Stop | Start state | Engine | Diffstat | Failure mode |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| R1 | qwen38-4bit@mbp14 | 1 | **yes** | True | True | True | — | 10 | 12 | 227 | toolUse | cold | splash | 1 file changed, 17 insertions(+) | — |
| R1 | qwen38-4bit@mbp14 | 2 | no | False | False | True | — | 259 | 260 | 2700 | toolUse (timeout) | cold | splash | 1 file changed, 19 insertions(+) | looped (same `rails runner` call 236×), out of time |
| R1 | qwen38-4bit@mbp14 | 3 | **yes** | True | True | True | — | 9 | 11 | 213 | toolUse | cold | splash | 1 file changed, 12 insertions(+) | — |
| R1 | qwen36-8bit@mbp16 | 1 | **yes** | True | True | True | — | 2 | 7 | 192 | toolUse | cold (no Splash cache to clear) | plain | 1 file changed, 17 insertions(+) | — |
| R1 | qwen36-8bit@mbp16 | 2 | **yes** | True | True | True | — | 4 | 10 | 224 | toolUse | cold (no Splash cache to clear) | plain | 1 file changed, 25 insertions(+) | — |
| R1 | qwen36-8bit@mbp16 | 3 | **yes** | True | True | True | — | 1 | 6 | 179 | toolUse | cold (no Splash cache to clear) | plain | 1 file changed, 20 insertions(+) | — |
| R2 | qwen38-4bit@mbp14 | 1 | no | False | False | True | — | 196 | 199 | 2700 | toolUse (timeout) | cold | splash | 1 file changed, 72 insertions(+) | looped (same `rails runner` call 175×), out of time |
| R2 | qwen38-4bit@mbp14 | 2 | **yes** | True | True | True | — | 8 | 10 | 223 | toolUse | cold | splash | 1 file changed, 76 insertions(+) | — |
| R2 | qwen38-4bit@mbp14 | 3 | **yes** | True | True | True | — | 14 | 16 | 280 | toolUse | cold | splash | 1 file changed, 75 insertions(+) | — |
| R2 | qwen36-8bit@mbp16 | 1 | **yes** | True | True | True | — | 6 | 11 | 301 | toolUse | cold (no Splash cache to clear) | plain | 1 file changed, 70 insertions(+) | — |
| R2 | qwen36-8bit@mbp16 | 2 | no | False | False | True | — | 0 | 2 | 134 | toolUse | cold (no Splash cache to clear) | plain | no changes | ran out of tokens (8,192 per turn, thinking, before first edit) |
| R2 | qwen36-8bit@mbp16 | 3 | no | False | False | True | — | 0 | 2 | 132 | toolUse | cold (no Splash cache to clear) | plain | no changes | ran out of tokens (8,192 per turn, thinking, before first edit) |
| R3 | qwen38-4bit@mbp14 | 1 | **yes** | True | True | True | — | 5 | 7 | 170 | toolUse | cold | splash | 3 files changed, 16 insertions(+), 1 deletion(-) | — |
| R3 | qwen38-4bit@mbp14 | 2 | **yes** | True | True | True | — | 4 | 7 | 186 | toolUse | cold | splash | 3 files changed, 16 insertions(+), 1 deletion(-) | — |
| R3 | qwen38-4bit@mbp14 | 3 | **yes** | True | True | True | — | 5 | 7 | 156 | toolUse | cold | splash | 3 files changed, 12 insertions(+), 1 deletion(-) | — |
| R3 | qwen36-8bit@mbp16 | 1 | **yes** | True | True | True | — | 6 | 13 | 133 | toolUse | cold (no Splash cache to clear) | plain | 3 files changed, 17 insertions(+), 1 deletion(-) | — |
| R3 | qwen36-8bit@mbp16 | 2 | **yes** | True | True | True | — | 8 | 13 | 136 | toolUse | cold (no Splash cache to clear) | plain | 3 files changed, 15 insertions(+), 1 deletion(-) | — |
| R3 | qwen36-8bit@mbp16 | 3 | **yes** | True | True | True | — | 7 | 15 | 129 | toolUse | cold (no Splash cache to clear) | plain | 3 files changed, 15 insertions(+), 1 deletion(-) | — |
| R4 | qwen38-4bit@mbp14 | 1 | **yes** | True | True | True | — | 5 | 12 | 185 | toolUse | cold | splash | 5 files changed, 16 insertions(+), 2 deletions(-) | — |
| R4 | qwen38-4bit@mbp14 | 2 | **yes** | True | True | True | — | 5 | 11 | 173 | toolUse | cold | splash | 5 files changed, 16 insertions(+), 2 deletions(-) | — |
| R4 | qwen38-4bit@mbp14 | 3 | **yes** | True | True | True | — | 3 | 11 | 171 | toolUse | cold | splash | 5 files changed, 16 insertions(+), 2 deletions(-) | — |
| R4 | qwen36-8bit@mbp16 | 1 | **yes** | True | True | True | — | 3 | 13 | 117 | toolUse | cold (no Splash cache to clear) | plain | 5 files changed, 16 insertions(+), 2 deletions(-) | — |
| R4 | qwen36-8bit@mbp16 | 2 | **yes** | True | True | True | — | 4 | 13 | 110 | stop | cold (no Splash cache to clear) | plain | 5 files changed, 16 insertions(+), 2 deletions(-) | — |
| R4 | qwen36-8bit@mbp16 | 3 | **yes** | True | True | True | — | 4 | 13 | 111 | stop | cold (no Splash cache to clear) | plain | 5 files changed, 16 insertions(+), 2 deletions(-) | — |
| R5 | qwen38-4bit@mbp14 | 1 | no | True | True | True | news_discovery_gemini_grounded_test.rb, news_discovery_google_news_rss_test.rb | 10 | 22 | 593 | toolUse | cold | splash | 9 files changed, 147 insertions(+), 11 deletions(-) | edited 2 existing tests (spec defect; verify + suite green) |
| R5 | qwen38-4bit@mbp14 | 2 | no | True | True | True | news_discovery_gemini_grounded_test.rb, news_discovery_google_news_rss_test.rb | 11 | 22 | 577 | toolUse | cold | splash | 9 files changed, 147 insertions(+), 11 deletions(-) | edited 2 existing tests (spec defect; verify + suite green) |
| R5 | qwen38-4bit@mbp14 | 3 | no | True | True | True | news_discovery_gemini_grounded_test.rb, news_discovery_google_news_rss_test.rb | 11 | 24 | 723 | toolUse | cold | splash | 9 files changed, 144 insertions(+), 11 deletions(-) | edited 2 existing tests (spec defect; verify + suite green) |
| R5 | qwen36-8bit@mbp16 | 1 | no | False | False | True | — | 0 | 8 | 213 | toolUse | cold (no Splash cache to clear) | plain | no changes | ran out of tokens (8,192 per turn, thinking, before first edit) |
| R5 | qwen36-8bit@mbp16 | 2 | no | True | True | True | news_discovery_gemini_grounded_test.rb, news_discovery_google_news_rss_test.rb | 43 | 61 | 848 | stop | cold (no Splash cache to clear) | plain | 9 files changed, 177 insertions(+), 11 deletions(-) | edited 2 existing tests (spec defect; verify + suite green) |
| R5 | qwen36-8bit@mbp16 | 3 | no | True | True | True | news_discovery_gemini_grounded_test.rb, news_discovery_google_news_rss_test.rb | 29 | 48 | 803 | stop | cold (no Splash cache to clear) | plain | 9 files changed, 177 insertions(+), 11 deletions(-) | edited 2 existing tests (spec defect; verify + suite green) |

"Start state" on MBP-16 is recorded by `bin/ladder` as `unloaded; cache clear failed`. That's harmless: Qwen3.6 runs
on the plain engine, which has no Splash cache, so the remote `rm` glob matched nothing. The models were unloaded and
the start was cold.

## Failed attempts: what went wrong (checked against LADDER.md's review checklist; diff against the rung base)

- **R1 qwen38-4bit a2:** the first edit was close: one constant, one method, 19 lines, `assess`/`clean`/`link_ratio`
  untouched. It committed (`17be006`) while one test still failed (`content_quality_index_title_test.rb:30`, the
  index-title list). Then it ran the same `bin/rails runner` probe on "search results for solar farms" 236 times
  until the 45-minute limit: a repetition loop, not a wrong approach.
- **R2 qwen38-4bit a1:** one new 72-line file in the right shape (module_function, frozen constants, keyword Struct).
  It failed only the catalogue-PDF test (`discovery_junk_filter_test.rb:78`). It then ran one `bin/rails runner`
  experiment with the catalogue word list 175 times until the timeout: the same loop as R1 a2.
- **R2 qwen36-8bit a2 and a3:** each read `content_quality.rb` and the test file, then thought until it hit the
  8,192-token per-turn cap (`stopReason: length`) before writing anything. No diff. pi treats that as the end of
  the run.
- **R5 qwen36-8bit a1:** the same: read 7 files, then ran out of the 8,192-token turn while planning. No diff.
- **R5, the five attempts with code** (qwen38 a1–a3, qwen36 a2–a3): failed only on `outside_allowed` (the spec
  defect above). Against the checklist they are clean:
  - `Result` keeps `keyword_init: true` and gains `junk_items`;
  - the filter runs in both the main loop and `accept_raws` (which receives `junk_items`);
  - `junk_count: 0` in stats and `total_junk_count` in diagnostics;
  - the job reads `Array(result.junk_items)`;
  - the view line uses `DiscoveryJunkFilter.label`;
  - no `puts`/`TODO`/`binding.irb`;
  - 144–177 lines.

  qwen36 a3 made two commits (the test-key edit separately, with an honest message); the others made one.

## Draft builder profile cards

**Qwen3.8-27B 4-bit (MBP-14, oMLX + Splash, thinking off)**
- **Envelope:** R4 as graded (5 files, ~18 lines, migration + config + controller + view). R5 (9 files, ~150 lines)
  3/3 if the spec defect is excused.
- **Phrasing that worked:** exact file paths with "find the line X, your code goes after it"; a pasted acceptance
  test; "Done means" with the two commands; "stop and call finish".
- **Weaknesses:**
  - Repetition loops on small rungs: 2 of 15 attempts sent the same `rails runner` probe 175–236 times when one
    test case resisted.
  - It doesn't stop itself, so the 45-minute timeout is the only brake. Guard with a turn limit or a
    repeated-tool-call detector.
  - It also committed before the suite was green once.
- **Context it needed:** 1–6 files of reading; no Rails API docs. Fast when it works: 3–4 minutes for R1–R4,
  about 10 for R5.
- **Runtime:** Splash engine, thinking off, 8,192 tokens per turn was enough; MBP-14.

**Qwen3.6-35B-A3B 8-bit (MBP-16, oMLX plain engine, thinking on)**
- **Envelope:** R1, R3 and R4 3/3, but **R2 only 1/3**. As graded, the largest rung passed 2 of 3 is R4. R5 2/3 if
  the defect is excused.
- **Phrasing that worked:** the same; it followed "Pattern to copy" closely. Its R4 diffs were identical across all
  three attempts.
- **Weaknesses:**
  - Runs out of its per-turn token budget while thinking before the first edit: 3 of 15 attempts, all on rungs that
    pack many rules into one file (R2's segment rules, R5's plan).
  - Every failure was that, not wrong code.
  - Verbose on R5 (29–43 turns, ~14 minutes) where Qwen3.8 took 10–11.
- **Context it needed:** reads everything listed in "Read first" up front (7 files on R5).
- **Runtime:** plain engine (Splash loops for this model); thinking on; **8,192 tokens per turn is too small with
  thinking on**. Next run: a larger cap (16k) or a thinking budget; MBP-16.

## Run notes

- **Pause on MBP-14, 00:38–01:03.** The queue's own check stopped MBP-14 after three tries of R1 a1. All three tries
  passed, but my check called each one a stack failure ("builder model was unloaded mid-attempt"). Splash cycles the
  builder (unload and reload of the same model) during a run, and the check counted that as a stack failure.
  - The Telegram session corrected `classify.py` (01:01) so that only a different model that stays loaded counts.
    It put the third try back as R1 a1 and resumed the queue.
  - R1 a1's worktree was removed when the try was set aside. Its code is still on branch
    `ladder/discovery-junk-filter-R1-qwen38-4bit-mbp14-a1`.
  - The three tries are listed in `~/Development/runs/ladder-queue/djf/stack.log`. They weren't stack failures and
    don't count either way.
- **The wake to the dashboard session failed both times** (00:38 and 04:02): OpenClaw 2026.10.4 refuses
  `openclaw agent` started from an agent's exec ("would lose inter-session attribution"). The Telegram messages did
  arrive. This report was written when Mark next opened the session.
- **Usual models restored** on both Macs (restore logged equal sets). Multica restarted at 04:02. The watchdog
  automation was removed after the run. The SMS triage poll is still disabled; a follow-up card is filed.
- **Key check:** the pi logs and result JSONs were searched for client-app's master key value: none found. The only
  `master.key` text is the spec's own sentence. Raw pi logs are git-ignored on this branch.

## Worktrees left for review

`~/Development/runs/ladder-worktrees/client-app/<tag>`, where tag is `R<n>-<builder>-<mac>-a<n>` for every row
above, except R1-qwen38-4bit-mbp14-a1 (branch only, see above). Attempt branches:
`ladder/discovery-junk-filter-<tag>`, all local, none pushed or merged.

## Edge-case probe beyond the acceptance tests (added after the run)

Every attempt that produced code was given 22 index titles, 11 PDF titles, 13 link-density mixes and a `nil` title, each
with the answer the spec's rules give (`/tmp/djf_probe3.rb`, run with `bin/rails runner` in each worktree). The acceptance
tests let these misses through.

| Attempt | Index titles | Catalogue PDFs | Link density |
|---|---|---|---|
| R1 qwen38 a2 (failed) | misses "Site Map", "Index of …", "Search Results: …" | — | — |
| R1 qwen38 a3 | misses "Search Results: …" | — | — |
| R1 qwen36 a1 / a2 / a3 | misses "Product listings" / all OK / misses "Site Map", "Sitemap - …" | — | — |
| R2 qwen38 a1 (failed) | misses "Site Map"; flags "Dallas-Fort Worth news", "Council news: …", "Hyphenated-News" | misses corporate/annual report, price list | OK |
| R2 qwen38 a2 | misses "Local news: …", "Site Map" | OK | OK |
| R2 qwen38 a3 | misses "Site Map" | flags "Cataloging …" (not a whole word) | OK |
| R2 qwen36 a1 | OK (raises on a `nil` title) | OK | OK |
| R5 qwen38 a1 | OK | flags any "report"/"list" PDF; misses "  [pdf] … minutes" (leading spaces); flags "Cataloging" | OK |
| R5 qwen38 a2 / a3 | misses "Local news: …", "Tag: …" | flags any "report"/"list" PDF; a3 misses leading-space; flags "Cataloging" | OK |
| R5 qwen36 a2 | OK | misses corporate/annual report, price list, leading-space minutes; flags "Cataloging" | OK |
| R5 qwen36 a3 | flags "Hyphenated-News" (splits on a bare hyphen) | misses leading-space minutes; flags "Cataloging" | OK |

Correction from UAT (R5 qwen36 a3): the "leading spaces before [pdf]" miss doesn't happen in the real pipeline.
Discovery tidies titles (`squish`) before the filter, so "  [pdf] Council meeting minutes" is skipped correctly. The
filter's real gaps in the full pipeline are the bare-hyphen split and part-word "catalog" matching. UAT kit:
`~/Development/runs/uat-djf/UAT.md`.

## Delivery decision (Mark, 2026-10-21)

The slice ships from **R5 Qwen3.6 a3** (`ladder/discovery-junk-filter-R5-qwen36-8bit-mbp16-a3`, `078e14b` + `7eb8de5`)
**plus R4** (`ladder/discovery-junk-filter-R4-qwen36-8bit-mbp16-a1`, `52d7618`). R1–R3 aren't merged: R5 contains its
own filter and column. Accepted to staging after UAT with known gaps, tracked in client-app backlog rows 237 (bugs
B1 false skips, B2 buried reason) and 238 (requirement: editor marks a wrong skip; corrections become training cases).

**Credit:** R5 to Qwen3.6 (a3). R4 is a tie: all six builds are identical line for line. R3: five of six identical.

**Selection heuristic used (both models built every rung; pick per rung):**
1. Graded pass, or a failure only on a confirmed spec defect.
2. Fewest misses on the edge-case probe, weighted by harm: **silent loss** (a real article skipped and never shown,
   which a scheduled run hides) counts worse than **visible junk** (an index page that reaches the editor).
3. Then the review checklist: smallest diff in budget, no stray code, honest commit messages.

On that heuristic Qwen3.8's R5 builds rank last despite clean diffs: each skips any "[PDF] … report" or "… list".

**Follow-up run (time-boxed, started 12:15):** Qwen3.6 on R2 and R5, attempts 4–6, 16,384-token reply cap, R5's
`--allow` including the two diagnostics tests. Results in `results/ladder/discovery-junk-filter-16k/`.

## Follow-up: Qwen3.6 with a 16,384-token reply cap (12:15–13:13, MBP-16)

`results/ladder/discovery-junk-filter-16k/`. Same specs and bases; R5's `--allow` also lists the two diagnostics tests.

| Rung | Attempt | Passed | Turns | pi s | Edge-case probe |
|---|---|---|---|---|---|
| R2 | a4 | yes | 7 | 438 | 1 miss: flags "[PDF] Emissions report…"; raises on a `nil` title |
| R2 | a5 | yes | 6 | 274 | all OK; raises on a `nil` title |
| R2 | a6 | yes | 4 | 387 | all OK |
| R5 | a4 | no: suite 2 failures (didn't update the two diagnostics tests; verify passed) | 29 | 638 | 3 misses |
| R5 | a5 | yes | 15 | 662 | filter only misses leading-space "[pdf]" and flags "Cataloging" |
| R5 | a6 | yes | 22 | 512 | misses corporate/annual report and price list; flags "Cataloging" |

**Reading:** the token cap was the cause. With 16k, Qwen3.6 never ran out of tokens: R2 went from 1/3 to 3/3 and R5
reached 2/3 (graded properly this time). Not one attempt stalled before writing code. Its runtime card should say
16k per reply with thinking on.

**R5 a5 against the UAT scheduled check** (`~/Development/runs/uat-djf/check_scheduled.rb`): 1 real article lost
("Cataloging…"), against a3's 2 ("Tech-News…" too), and 1 junk item let through ("  [pdf] Council meeting minutes",
leading spaces). By the harm-weighted heuristic a5 beats a3: one silent loss instead of two. Not UAT'd in the browser.

**Delivery decision revised (Mark, 2026-10-21, after the follow-up):** ship **R5 Qwen3.6 a5** (16k) instead of a3, plus
R4. Assembled on client-app `slice/discovery-junk-filter` (from `origin/main` `887de4a`; only conflicts were
`db/schema.rb` and `BACKLOG.md`); full suite 3850 runs, 0 failures, 0 errors. Credit: R5 to Qwen3.6 at 16k; R4 a tie.

## Context window (checked 2026-10-21)

- **The effective limit is 262,144 on both Macs.** oMLX 0.7.1rc1 `server.py` `_configured_max_context_window` uses a
  per-model override, else the model's native length (262,144; `max_context_window_policy` unset), and only then the
  global `sampling.max_context_window` (32,768, a fallback that wasn't used). `/v1/models` reports `max_model_len`
  262,144 for both builders.
- **No silent truncation:** oMLX rejects an oversized prompt with HTTP 400 `context_length_exceeded`.
- **pi:** `contextWindow` 98,304, so pi is the binding cap. No run reached it.
- **Used:** R1–R4 5–30k; R5 22k (Qwen3.8) and 31–65k (Qwen3.6); loops up to 82k.
- **Cost per turn** (median, from pi `durationMs`): prefix cache 96–99% from 10k up.

  | Context | Qwen3.6 (plain) | Qwen3.8 (Splash) |
  |---|---|---|
  | under 10k | 15 s (first turn, cold) | 5.4 s |
  | 20–40k | 5.7 s | 9.6 s |
  | 60k and up | 7.0 s | 13.5 s |
