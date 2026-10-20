# MultiPL-E HumanEval-Ruby audit: model mistakes or bad tests?

Audit date 2026-10-20. Read-only: no data, results, harness or published figures were changed.

## Summary

- **112 of 161 problems** were failed by at least one model. **41 are suspects** (wrong, finished answers
  from 3 or more distinct models). All six problems that both Qwen3.6-35B-A3B 8-bit and 4-bit fail in Run 3
  (`2026-10-20-8k`) are already in those 41.
- **3 problems are confirmed broken or unfair**, and between them they cost each model up to 3 passes:
  - `HumanEval_151_double_the_difference`: **broken test (upstream)**. Integer inputs were turned into floats,
    so the test now contradicts "ignore numbers that are not integers". OpenAI's own reference solution
    fails it. No model passed.
  - `HumanEval_103_rounded_avg`: **translation artefact**. The expected values bake in Python's banker's
    rounding (`round(970.5) == 970`). Ruby's `Float#round` rounds half up (971), so idiomatic Ruby fails.
  - `HumanEval_95_check_dict_case`: **translation artefact**. The test's non-string key `5` became the string
    `"5"`. The expected `false` now relies on Python's `"5".islower() == False`; the Ruby idiom
    `k == k.downcase` gives `true`. No model passed. With the original integer key, 14 of 15 failing answers pass.
- **Harness issues** (not test bugs): 17 failed answers across 14 problems are correct code that the harness
  scored as fails. 6 are Ornith 4-bit answers whose ```` ```ruby ```` fence was never closed (only one of the
  41 suspects, `HumanEval_68_pluck`, is affected). 11 are lambdas or renamed methods that the `def` wrapper
  swallowed. These mostly hit weaker models.
- The other 38 suspects are **genuine model mistakes**. The commonest are invented Ruby APIs: `Range#join`,
  `String#count(Regexp)`, `Math.ceil`, a missing `require 'digest'`, and Python's `//` passed to `eval`.
- **Ranking:** the top four don't change (Qwen3.6-35B-A3B 8-bit, then 4-bit, then Ornith-1.5, then Ornith 8-bit).
  Dropping the 3 problems (A) lifts most models by 1 to 2 points and changes nothing at the top. Crediting the harness
  fails as well moves Ornith 4-bit (8k) above Qwen3.8-27B 8-bit for 5th, and lifts fullstack-learn-lm-30b from
  13th to 7th. That last jump is a policy question (see "Harness issues"). **Even after every correction the best
  score is 154/161; nobody reaches 161.**

## Scope and method

- Runs read (all with `finished_at`): `results/2026-10-19-extended/` (4,096 tokens), `results/2026-10-20-8k/`
  and `results/2026-10-20-8k-b/` (8,192), `results/2026-10-20-mbp16-check/`. That's 21 run files with coding
  results and 15 distinct models (`2026-10-20-8k/mlx-community--gemma-4-26b-a4b-it-4bit.json` has no coding screen).
- A failure counts as "wrong" only if `hit_cap` is false. Answers cut off at the token limit are listed separately
  in the appendix. A model counts once per problem even if it failed it in several runs.
- All 552 failing answers were re-run as stored (answer, then the original tests) in
  `docker run --rm -i --network none -m 512m --cpus 1 ruby:3.4-slim-bookworm`, fed on stdin, to get the failing
  assertion and the actual value. None timed out.
- The Ruby prompts and tests were compared with openai/human-eval `HumanEval.jsonl` and with MultiPL-E's
  `datasets/originals-with-cleaned-doctests/*.py` (read from GitHub; nothing was uploaded anywhere).
- Re-scoring: (A) drop the 3 unfair problems from both the passes and the attempts; (B) keep all problems, re-test
  the 3 against corrected tests, and re-test every other finished fail with a lenient extractor. The lenient
  extractor strips an unclosed opening fence and calls through a returned lambda or method name. The scratch
  scripts live in `/tmp/mbaudit/` (outside the repo).

Model key: Q3.6-8b = Qwen3.6-35B-A3B-8bit, Q3.6-4b = mlx-community Qwen3.6-35B-A3B-4bit, Q3.8-4b/-8b =
Qwen3.8-27B 4/8-bit, Ornith-1.5 = ornith-1.5-35b-a3b, Ornith-4b/-8b = Ornith-1.5-35B-A3B-MLX 4/8-bit,
Qwopus = Qwopus3.6-35B-A3B-Coder-8bit, FSL-30B = fullstack-learn-lm-30b-a3b-i1, G4-19B = SrogiLesnik Gemma-4-19B,
G4-12B-ag / -8b = gemma-4-12b-agentic-fable5 (base / kang-heewon MLX 8-bit), G4-26B = gemma-4-26b-a4b-it-4bit,
DSV4-9B = DeepSeek-V4-Pro-Qwen3.5-9B-8bit, QC30-rails = qwen3-coder-30b-rails.

## Suspects (41)

| Problem | Wrong / attempted | Verdict | Evidence (one line) |
|---|---:|---|---|
| `151_double_the_difference` | 14/15 | **Broken test (upstream)** | Test passes `[5.0, 4.0]` and expects 25, but the prompt says to ignore non-integers. Upstream changed Python's `[5, 4]` to floats; the OpenAI reference solution returns 0. 19 of 20 failing answers pass the original integer test |
| `103_rounded_avg` | 13/15 | **Translation artefact** | `(964, 977)` expects 970: Python `round(970.5)` is 970 (banker's), Ruby `970.5.round` is 971. 11 of 13 failing models (15 of 18 answers) pass when either rounding is accepted |
| `15_string_sequence` | 11/15 | Genuine | `(0..n).join(" ")`: `Range#join` doesn't exist (`NoMethodError`) |
| `95_check_dict_case` | 11/11 | **Translation artefact** | Python key `5` became `"5"`; `"5" == "5".downcase` is true in Ruby. 10 of 11 failing models (14 of 15 answers) pass with the original integer key |
| `145_order_by_points` | 10/15 | Ambiguous prompt (upstream), counted as genuine | "Sum of digits" doesn't say how to treat negatives, but the prompt's own example `[-1, -11, 1, -12, 11]` only works if the first digit carries the sign. Failing answers return `[1, -1, 11, -11, -12]` (absolute digits) |
| `93_encode` | 8/14 | Genuine | `"TEST"` gives `"tGst"` (vowel shifted but its case not swapped) and similar slips |
| `153_Strongest_Extension` | 7/13 | Genuine | `String#count` called with a Regexp or Range, or with no argument |
| `160_do_algebra` | 6/13 | Genuine | `eval("7 // 3 * 4")`: `//` is a regexp literal in Ruby. Others evaluate strictly left to right (got 15, not 9). The prompt does list `//` as floor division, so the test is fair, though it's harder in Ruby than in Python |
| `84_solve` | 5/14 | Genuine | Answers return `1000.to_s(2)`; the example shows `"1"`. (The translation dropped Python's "the sum of digits will be 1" line, but the examples still settle it) |
| `113_odd_count` | 5/12 | Genuine | `"7".odd?` (`NoMethodError`), wrong template substitution |
| `132_is_nested` | 5/12 | Genuine | `"[[]"` returns true; the test matches the Python original |
| `158_find_max` | 5/12 | Genuine | Picks `"of"` over `"string"`; `String#uniq` |
| `162_string_to_md5` | 5/13 | Genuine (see note) | `NameError: uninitialized constant Digest`: no `require 'digest'`. The 10 passing answers include it |
| `163_generate_integers` | 5/11 | Genuine | `(2, 10)` gives `[2, 4, 6, 8, 10]`, but the prompt asks for even *digits* |
| `104_unique_digits` | 4/15 | Genuine | `"1".odd?`, `String#none?` |
| `108_count_nums` | 4/15 | Genuine | `[-1, -2, 0]` gives 2: ignores the "first signed digit is negative" rule stated in the prompt |
| `115_max_fill` | 4/13 | Genuine | Sums the whole grid instead of rounding up per row (got 1, not 2) |
| `127_intersection` | 4/12 | Genuine | `[-1, 1]` and `[0, 4]` give "YES": an intersection of length 1 isn't prime |
| `130_tri` | 4/14 | Genuine | Wrong recurrence or `nil` arithmetic |
| `141_file_name_check` | 4/12 | Genuine | `String#count(Range)` (`TypeError`) |
| `49_modp` | 4/13 | Genuine | `Integer#modpow` doesn't exist; wrong value |
| `54_same_chars` | 4/15 | Genuine | Compares counts, not sets |
| `83_starts_one_ends` | 4/12 | Genuine | `n = 2` gives 179 / 17 / 19 instead of 18 |
| `91_is_bored` | 4/12 | Genuine | Counts "Is the sky blue?" as starting with "I" |
| `101_words_string` | 3/15 | Genuine | `Regexp#+`; an empty token; a syntax error |
| `106_f` | 3/11 | Genuine | Ornith answers contain `reduce(0, :)` (`:+` missing, so `SyntaxError`); see "Other observations" |
| `119_match_parens` | 3/11 | Genuine | Returns `true`/`false` instead of "Yes"/"No" |
| `129_minPath` | 3/14 | Genuine | `Array#<`; undefined variable (9 more were cut off) |
| `133_sum_squares` | 3/12 | Genuine | `Math.ceil` doesn't exist in Ruby |
| `134_check_if_last_char_is_a_letter` | 3/14 | Genuine | Q3.6-8b returns `nil` from `=~ && …` where `false` is expected; others misread the rule |
| `135_can_arrange` | 3/14 | Genuine | Returns the first drop, not the last |
| `148_bf` | 3/12 | Genuine | Returns `"Venus"` instead of `["Venus"]`; reversed order |
| `1_separate_paren_groups` | 3/12 | Genuine | Q3.6-8b resets the buffer on every `)`, giving `[")", ")", "()", ")"]` |
| `24_largest_divisor` | 3/15 | Genuine | Returns 2 for 3; `Range#reverse` |
| `64_vowels_count` | 3/13 | Genuine | `"keY"` gives 1: misses the upper-case final Y |
| `65_circular_shift` | 3/13 | Genuine | `String#rotate`; returns an Array |
| `66_digitSum` | 3/12 | Genuine | `nil` coercion; `String#upcase?` |
| `68_pluck` | 3/14 | **Mixed: 2 genuine, 1 harness** | Ornith-4b's answer is correct but its fence was left open, so the harness ran `` ```ruby `` as code (`SyntaxError`). Stripping the fence passes 8/8 assertions |
| `81_numerical_letter_grade` | 3/14 | Genuine | Wrong grade boundaries |
| `89_encrypt` | 3/13 | Genuine | Returns `"108109"` (character codes joined) |
| `99_closest_integer` | 3/14 | Genuine | `-15.5` gives -17 or 16; `Float#frac` |

## Effect on pass rates

(A) drops `151`, `103` and `95` from both passes and attempts. (B) keeps all problems: those three are
re-tested against corrected tests, and other finished fails are re-tested with the lenient extractor.
Ranks are across all 21 run files. Equal rates (for example Q3.8-4b's three identical runs) tie, so their order
within the tie is arbitrary. Runs that attempted fewer than 161 problems were stopped by the time cap, so their
rates are on a smaller sample.

| Model | Run | Published | Excl. 3 unfair problems (A) | Re-scored (B) | Rank: pub → A → B |
|---|---|---:|---:|---:|---|
| Q3.6-8b | `2026-10-20-8k` | 151/161 = 93.8% | 151/158 = 95.6% | 154/161 = 95.7% (+3 test, +0 harness) | 1 → 1 → 1 |
| Q3.6-4b | `2026-10-20-8k` | 149/161 = 92.5% | 149/158 = 94.3% | 151/161 = 93.8% (+2 test, +0 harness) | 2 → 2 → 2 |
| Ornith-1.5 | `2026-10-19-extended` | 143/161 = 88.8% | 143/158 = 90.5% | 145/161 = 90.1% (+2 test, +0 harness) | 3 → 3 → 3 |
| Ornith-8b | `2026-10-19-extended` | 141/161 = 87.6% | 141/158 = 89.2% | 144/161 = 89.4% (+2 test, +1 harness) | 4 → 4 → 4 |
| Q3.8-8b | `2026-10-19-extended` | 138/161 = 85.7% | 138/158 = 87.3% | 141/161 = 87.6% (+3 test, +0 harness) | 5 → 5 → 6 |
| Ornith-4b | `2026-10-20-8k-b` | 137/161 = 85.1% | 136/158 = 86.1% | 142/161 = 88.2% (+2 test, +3 harness) | 6 → 8 → 5 |
| Q3.6-8b | `2026-10-19-extended` | 128/151 = 84.8% | 128/149 = 85.9% | 130/151 = 86.1% (+2 test, +0 harness) | 7 → 10 → 12 |
| Q3.8-4b | `2026-10-19-extended` | 136/161 = 84.5% | 136/158 = 86.1% | 139/161 = 86.3% (+3 test, +0 harness) | 8 → 6 → 9 |
| Q3.8-4b | `2026-10-20-8k-b` | 136/161 = 84.5% | 136/158 = 86.1% | 139/161 = 86.3% (+3 test, +0 harness) | 9 → 7 → 10 |
| Q3.8-4b | `2026-10-20-mbp16-check` | 136/161 = 84.5% | 136/158 = 86.1% | 139/161 = 86.3% (+3 test, +0 harness) | 10 → 9 → 11 |
| Ornith-4b | `2026-10-19-extended` | 135/161 = 83.9% | 134/158 = 84.8% | 140/161 = 87.0% (+2 test, +3 harness) | 11 → 11 → 8 |
| Q3.6-4b | `2026-10-19-extended` | 81/99 = 81.8% | 81/97 = 83.5% | 82/99 = 82.8% (+1 test, +0 harness) | 12 → 12 → 13 |
| FSL-30B | `2026-10-19-extended` | 131/161 = 81.4% | 131/158 = 82.9% | 140/161 = 87.0% (+3 test, +6 harness) | 13 → 13 → 7 |
| Qwopus | `2026-10-20-8k` | 122/161 = 75.8% | 122/158 = 77.2% | 125/161 = 77.6% (+3 test, +0 harness) | 14 → 14 → 14 |
| G4-19B | `2026-10-19-extended` | 110/148 = 74.3% | 110/146 = 75.3% | 114/148 = 77.0% (+2 test, +2 harness) | 15 → 15 → 15 |
| Qwopus | `2026-10-19-extended` | 118/161 = 73.3% | 118/158 = 74.7% | 121/161 = 75.2% (+3 test, +0 harness) | 16 → 16 → 16 |
| G4-12B-ag-8b | `2026-10-19-extended` | 117/161 = 72.7% | 117/158 = 74.1% | 120/161 = 74.5% (+3 test, +0 harness) | 17 → 17 → 17 |
| DSV4-9B | `2026-10-19-extended` | 74/102 = 72.5% | 74/100 = 74.0% | 75/102 = 73.5% (+1 test, +0 harness) | 18 → 18 → 18 |
| G4-12B-ag | `2026-10-19-extended` | 115/161 = 71.4% | 115/158 = 72.8% | 118/161 = 73.3% (+2 test, +1 harness) | 19 → 19 → 19 |
| G4-26B | `2026-10-19-extended` | 50/74 = 67.6% | 50/72 = 69.4% | 51/74 = 68.9% (+1 test, +0 harness) | 20 → 20 → 20 |
| QC30-rails | `2026-10-19-extended` | 9/20 = 45.0% | 9/18 = 50.0% | 12/20 = 60.0% (+2 test, +1 harness) | 21 → 21 → 21 |

**Does the ranking change?** Not at the top. Q3.6-8b (8k), then Q3.6-4b (8k), then Ornith-1.5, then
Ornith-8b hold places 1 to 4 under every scoring. Below that:
- (A) only reshuffles the cluster between 85.9% and 86.1% (Q3.6-8b's 4k run, Q3.8-4b, Ornith-4b). Ornith-4b (8k-b) loses its 103 pass under (A), because it was the
  only model that implemented banker's rounding; under (B) it gets it back.
- (B) puts Ornith-4b (8k-b) above Q3.8-8b for 5th: it gains 3 harness credits for its unclosed fences. B also lifts
  FSL-30B from 13th to 7th: 6 of its fails are correct lambdas that the `def` wrapper turned into a returned `Proc`.
  Whether to credit those is a policy choice, because the system prompt asks for "the complete Ruby method" and a
  lambda isn't one.
- Q3.6-8b's gap over Q3.6-4b stays at 2 to 3 problems under every scoring.

## Confirmed problems: details

### 1. `HumanEval_151_double_the_difference`: broken test (upstream)

- Prompt: `# in the array that are odd. Ignore numbers that are negative or not integers.`
- Test: `assert_equal(25, candidate.call([5.0, 4.0]))`, plus `[0.2, 3.0, 5.0] → 34` and
  `[-9.0, …, 9.0] → 165`
- openai/human-eval original: `assert candidate([5, 4]) == 25`, `candidate([0.2, 3, 5]) == 34`,
  `lst = list(range(-99, 100, 2))`. MultiPL-E's `originals-with-cleaned-doctests/HumanEval_151_double_the_difference.py`
  types the argument as `List[float]` and rewrites every literal as a float, which turns the integers the test was
  about into non-integers. The test is broken in Python too: OpenAI's canonical solution
  (`"." not in str(i)`) returns 0 for `[5.0, 4.0]`, `[0.2, 3.0, 5.0]` and the `[-9.0 … 9.0]` list
  (run with `python3 -I`, reference code only).
- Proof (Q3.6-8b, Run 3: `lst.select { |n| n.is_a?(Integer) && n > 0 && n.odd? }.sum { |n| n**2 }`):

```
$ docker run --rm -i --network none -m 512m --cpus 1 ruby:3.4-slim-bookworm ruby < /tmp/mbaudit/proof/151_orig.rb
<25> expected but was
<0>
1 tests, 2 assertions, 1 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
$ docker run --rm -i --network none -m 512m --cpus 1 ruby:3.4-slim-bookworm ruby < /tmp/mbaudit/proof/151_fixed.rb
1 tests, 7 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
```

  The fixed test restores Python's original values: `[5, 4] → 25`, `[0.1, 0.2, 0.3] → 0`, `[-10, -20, -30] → 0`,
  `[-1, -2, 8] → 0`, `[0.2, 3, 5] → 34`, `(-99..99).step(2).to_a → 166650`. 19 of the 20 finished failing answers
  pass it. The one that doesn't (Ornith-8b) is a genuine mistake: it doesn't drop negative odd numbers.

### 2. `HumanEval_103_rounded_avg`: translation artefact (rounding mode)

- Prompt: `# Round the answer to the nearest integer and convert that to binary.`
- Tests: `assert_equal("0b1111001010", candidate.call(964, 977))` (mean 970.5) and
  `assert_equal("0b1111100100", candidate.call(996, 997))` (mean 996.5)
- The expected values come from Python's `round`, which rounds half to even: `round(970.5) == 970`,
  `round(996.5) == 996`. Ruby's `Float#round` rounds half up: `970.5.round == 971`, `996.5.round == 997`.
  Banker's rounding needs `round(half: :even)`, and nothing in the prompt asks for it. The test is identical in
  Python, where it is fair, because `round` is the obvious call there.
- Proof (Q3.6-8b, Run 3: `format("0b%b", ((n + m) / 2.0).round)`). The fixed test accepts either tie result
  (`assert_includes([…1010, …1011], …)`):

```
$ docker run --rm -i --network none -m 512m --cpus 1 ruby:3.4-slim-bookworm ruby < /tmp/mbaudit/proof/103_orig.rb
<"0b1111001010"> expected but was
<"0b1111001011">
1 tests, 3 assertions, 1 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
$ docker run --rm -i --network none -m 512m --cpus 1 ruby:3.4-slim-bookworm ruby < /tmp/mbaudit/proof/103_fixed.rb
1 tests, 12 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
$ … ruby -e 'p [970.5.round, 996.5.round, 970.5.round(half: :even)]'
[971, 997, 970]
```

- The only passes on the original test are Ornith-4b's two runs, which hand-code round-half-to-even. That looks
  like a memorised dataset quirk rather than a reading of the prompt.

### 3. `HumanEval_95_check_dict_case`: translation artefact (key type)

- Prompt: `# Given a hash, return true if all keys are strings in lower case or all keys are strings in upper case`.
  Its own example still uses an integer key: `check_dict_case.call({"a" => "apple", 8 => "banana", "a" => "apple"}) → false`.
- Test: `assert_equal(false, candidate.call({"p" => "pineapple", "5" => "banana", "a" => "apple"}))`
- openai/human-eval original: `candidate({"p":"pineapple", 5:"banana", "a":"apple"}) == False`, which checks a
  *non-string* key. MultiPL-E's cleaned original types the argument as `Dict[str, str]` and changes the key to
  `"5"`, while leaving `5:` in the assertion message. Python still expects `False` only because `"5".islower()`
  is `False`. The usual Ruby check, `"5" == "5".downcase`, is `true`. So the case now tests whether a model copies
  Python's `str.islower` semantics, which the prompt never states.
- Proof (Q3.6-8b, Run 3: `keys.all? { |k| k.is_a?(String) && k == k.downcase } || …upcase…`). The fixed test
  restores the integer key `5`:

```
$ docker run --rm -i --network none -m 512m --cpus 1 ruby:3.4-slim-bookworm ruby < /tmp/mbaudit/proof/95_orig.rb
<false> expected but was
<true>
1 tests, 3 assertions, 1 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
$ docker run --rm -i --network none -m 512m --cpus 1 ruby:3.4-slim-bookworm ruby < /tmp/mbaudit/proof/95_fixed.rb
1 tests, 7 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
```

### 4. Harness issues (model-bench, not MultiPL-E)

**Unclosed fence (6 answers, all Ornith-4b: `68_pluck`, `110_exchange`, `120_maximum`, in both its runs).**
The answer opens with ```` ```ruby ```` and ends at `end` with `finish_reason: "stop"`, never closing the fence.
`program` in `lib/screens/coding.rb` needs a closing fence for its regex to match, so it falls back to the whole
reply, and the fence line causes a `SyntaxError`.

```
$ docker run --rm -i --network none -m 512m --cpus 1 ruby:3.4-slim-bookworm ruby < /tmp/mbaudit/proof/68_orig.rb
-: -:1: syntax errors found (SyntaxError)
    |   ^ unexpected '`', expecting end-of-input
$ docker run --rm -i --network none -m 512m --cpus 1 ruby:3.4-slim-bookworm ruby < /tmp/mbaudit/proof/68_lenient.rb
1 tests, 8 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
```

**Lambda or renamed method wrapped in `def` (11 answers).** When the reply has no `def <name>`, the harness wraps
it in the prompt's `def … end`. If the reply is a lambda, the method then returns the `Proc`
(FSL-30B ×6, G4-19B `53_add`, Ornith-8b `23_strlen`). If it defines a method with another name, the method returns
that name as a `Symbol` (G4-12B-ag `def minSubarraySum`, G4-19B `def list_sort`, QC30-rails `def call`). The
lambdas are partly provoked by the translation: MultiPL-E writes every Ruby docstring example as `name.call(…)`.
`list_sort` comes from the upstream Python docstring of `149_sorted_list_sum`, which uses the wrong name.
Example: `/tmp/mbaudit/proof/29_orig.rb` returns `#<Proc … (lambda)>`, and `/tmp/mbaudit/proof/29_lenient.rb`
(calls through the returned `Proc`) passes 2/2 assertions.

Suggested harness change, for you to decide: also accept an unclosed opening fence in `program`. Leave lambdas
and renamed methods as fails, or count them separately; they really don't answer the request for "the complete
Ruby method".

## Other observations (not counted)

- **`162_string_to_md5` and `require`.** Q3.6-8b, Q3.6-4b, Qwopus and all three Ornith builds fail only because
  they don't `require 'digest'`. With it prepended, all 9 failing answers pass. The system prompt says "Reply with
  only the complete Ruby method", which discourages top-level requires, but the 10 passing answers show it can be
  done (inside or above the `def`). It's counted as a model mistake here. If you ever let the harness prepend
  stdlib requires, both Qwen3.6 builds gain one problem each, so the ranking is unchanged.
- **Ornith `:+` → `:`.** In 4 answers (`106_f` ×3, `139_special_factorial`) the Ornith builds write `reduce(0, :)`,
  which is a `SyntaxError`. Across all their answers Ornith never once writes `:+)`, while Qwen and Qwopus answers
  use it without trouble. That points to a tokenizer or detokenizer quirk specific to Ornith rather than a reasoning
  error, but `raw_content` is only stored for cut-off answers, so it can't be confirmed from the results.
  Counted as model mistakes.
- **`84_solve`**: the Ruby prompt dropped Python's explanatory lines ("For N = 1000, the sum of digits will be 1…").
  The examples still settle the meaning, so it's counted as a genuine mistake, but it is a weaker prompt than the
  Python one.
- **`145_order_by_points`** is under-specified in the original HumanEval as well (how do negative digits count?),
  but its own example settles it.
- **Cut-off answers dominate several "hard" problems:** `140_fix_spaces` (10 cut off), `129_minPath` (9),
  `145` (8). Those are verbosity fails, not correctness fails, and are listed in the appendix.
- No failing answer hit the 10 s sandbox limit.

## Suggested upstream issue (nuprl/MultiPL-E), not opened

> **Title:** HumanEval_151 and HumanEval_95: cleaned originals change test semantics (affects all languages)
>
> In `datasets/originals-with-cleaned-doctests/`:
>
> 1. `HumanEval_151_double_the_difference.py` annotates `lst: List[float]` and rewrites the test literals as
>    floats (`[5.0, 4.0] == 25`, `[0.2, 3.0, 5.0] == 34`, and `range(-99, 100, 2)` replaced by
>    `[-9.0, …, 9.0] == 165`). The docstring says to "ignore numbers that are … not integers", so with float
>    inputs every expected value except 0 is wrong. The original HumanEval canonical solution returns 0 on all
>    three. Suggest `List[Union[int, float]]` (or `List[int]` plus a separate float case) and the original values.
> 2. `HumanEval_95_check_dict_case.py` annotates `Dict[str, str]` and changes the non-string key `5` to `"5"`
>    (the assert message still says `5:`). The case expecting `False` now depends on Python's
>    `"5".islower() == False`. Idiomatic checks in other languages (Ruby `k == k.downcase`, JS
>    `k === k.toLowerCase()`) return true. Suggest dropping the case or keeping a non-string key where the target
>    language allows mixed keys.
> 3. (Ruby-specific, lower priority) `HumanEval_103_rounded_avg` expects Python's round-half-to-even at
>    `(964, 977)` and `(996, 997)`. Ruby's `Float#round` rounds half up. Suggest adding a note to the prompt
>    ("round half to even") or avoiding .5 means in the tests.
>
> Found while auditing 15 local models on humaneval-rb: no model passed 151 or 95 with a finished answer, and
> restoring the original inputs makes 19/20 and 14/15 of the failing answers pass.

## Appendix: full failure matrix (112 problems)

"Wrong" = failed with a finished answer (`hit_cap: false`) in at least one run. "Cut off only" = models whose only
failures on that problem were cut off at the token limit. 12 problems were failed only by cut-off answers.

| # | Problem | Wrong (finished) | Attempted by | Models wrong | Cut off only (hit_cap) |
|---|---|---:|---:|---|---|
| 1 | `HumanEval_151_double_the_difference` | 14 | 15 | DSV4-9B, FSL-30B, G4-12B-ag, G4-12B-ag-8b, G4-19B, Ornith-1.5, Ornith-4b, Ornith-8b, Q3.6-4b, Q3.6-8b, Q3.8-4b, Q3.8-8b, QC30-rails, Qwopus | G4-26B |
| 2 | `HumanEval_103_rounded_avg` | 13 | 15 | DSV4-9B, FSL-30B, G4-12B-ag, G4-12B-ag-8b, G4-19B, G4-26B, Ornith-8b, Q3.6-4b, Q3.6-8b, Q3.8-4b, Q3.8-8b, QC30-rails, Qwopus | Ornith-1.5 |
| 3 | `HumanEval_15_string_sequence` | 11 | 15 | FSL-30B, G4-12B-ag, G4-12B-ag-8b, Ornith-1.5, Ornith-4b, Ornith-8b, Q3.6-4b, Q3.6-8b, Q3.8-4b, QC30-rails, Qwopus | — |
| 4 | `HumanEval_95_check_dict_case` | 11 | 11 | FSL-30B, G4-12B-ag, G4-12B-ag-8b, Ornith-1.5, Ornith-4b, Ornith-8b, Q3.6-4b, Q3.6-8b, Q3.8-4b, Q3.8-8b, Qwopus | — |
| 5 | `HumanEval_145_order_by_points` | 10 | 15 | DSV4-9B, FSL-30B, G4-12B-ag, G4-12B-ag-8b, G4-19B, Q3.6-4b, Q3.6-8b, Q3.8-4b, Q3.8-8b, QC30-rails | G4-26B, Ornith-1.5, Ornith-4b, Ornith-8b, Qwopus |
| 6 | `HumanEval_93_encode` | 8 | 14 | FSL-30B, G4-12B-ag, G4-12B-ag-8b, Ornith-1.5, Ornith-8b, Q3.6-8b, Q3.8-8b, Qwopus | G4-19B, G4-26B, Q3.6-4b |
| 7 | `HumanEval_153_Strongest_Extension` | 7 | 13 | DSV4-9B, G4-12B-ag, G4-12B-ag-8b, G4-19B, Ornith-8b, Q3.8-4b, Q3.8-8b | — |
| 8 | `HumanEval_160_do_algebra` | 6 | 13 | FSL-30B, G4-12B-ag, G4-12B-ag-8b, Ornith-4b, Q3.8-4b, Q3.8-8b | DSV4-9B, G4-19B, Q3.6-4b, Qwopus |
| 9 | `HumanEval_84_solve` | 5 | 14 | FSL-30B, G4-12B-ag, G4-12B-ag-8b, G4-19B, Q3.8-4b | — |
| 10 | `HumanEval_113_odd_count` | 5 | 12 | G4-12B-ag, G4-12B-ag-8b, Q3.6-4b, Q3.8-4b, Q3.8-8b | Q3.6-8b, Qwopus |
| 11 | `HumanEval_132_is_nested` | 5 | 12 | FSL-30B, G4-12B-ag, G4-12B-ag-8b, Q3.8-4b, Q3.8-8b | G4-19B, Ornith-4b, Q3.6-8b, Qwopus |
| 12 | `HumanEval_158_find_max` | 5 | 12 | G4-12B-ag-8b, Ornith-4b, Q3.8-4b, Q3.8-8b, Qwopus | — |
| 13 | `HumanEval_162_string_to_md5` | 5 | 13 | Ornith-1.5, Ornith-4b, Q3.6-4b, Q3.6-8b, Qwopus | — |
| 14 | `HumanEval_163_generate_integers` | 5 | 11 | FSL-30B, G4-12B-ag, G4-12B-ag-8b, Q3.8-4b, Q3.8-8b | Ornith-8b, Qwopus |
| 15 | `HumanEval_49_modp` | 4 | 13 | Ornith-1.5, Ornith-4b, Q3.8-4b, Q3.8-8b | G4-19B |
| 16 | `HumanEval_54_same_chars` | 4 | 15 | FSL-30B, G4-12B-ag, G4-12B-ag-8b, QC30-rails | DSV4-9B |
| 17 | `HumanEval_83_starts_one_ends` | 4 | 12 | G4-12B-ag, G4-12B-ag-8b, Q3.8-4b, Q3.8-8b | G4-19B |
| 18 | `HumanEval_91_is_bored` | 4 | 12 | G4-12B-ag-8b, G4-19B, Q3.8-4b, Q3.8-8b | Qwopus |
| 19 | `HumanEval_104_unique_digits` | 4 | 15 | G4-12B-ag, G4-12B-ag-8b, Q3.8-4b, QC30-rails | — |
| 20 | `HumanEval_108_count_nums` | 4 | 15 | FSL-30B, G4-12B-ag-8b, G4-19B, QC30-rails | G4-26B, Q3.6-4b, Q3.6-8b, Qwopus |
| 21 | `HumanEval_115_max_fill` | 4 | 13 | FSL-30B, G4-12B-ag-8b, Q3.8-4b, Q3.8-8b | G4-19B |
| 22 | `HumanEval_127_intersection` | 4 | 12 | FSL-30B, Ornith-8b, Q3.8-4b, Q3.8-8b | Q3.6-8b |
| 23 | `HumanEval_130_tri` | 4 | 14 | FSL-30B, G4-12B-ag, G4-12B-ag-8b, Q3.8-8b | DSV4-9B, G4-19B, G4-26B, Q3.6-4b, Q3.6-8b, Qwopus |
| 24 | `HumanEval_141_file_name_check` | 4 | 12 | G4-12B-ag-8b, Ornith-1.5, Ornith-4b, Ornith-8b | G4-19B, Q3.6-8b, Qwopus |
| 25 | `HumanEval_1_separate_paren_groups` | 3 | 12 | G4-12B-ag, G4-12B-ag-8b, Q3.6-8b | G4-19B |
| 26 | `HumanEval_24_largest_divisor` | 3 | 15 | FSL-30B, G4-19B, Q3.8-4b | — |
| 27 | `HumanEval_64_vowels_count` | 3 | 13 | DSV4-9B, Ornith-1.5, Q3.8-4b | — |
| 28 | `HumanEval_65_circular_shift` | 3 | 13 | G4-12B-ag, Ornith-8b, Qwopus | Q3.6-4b |
| 29 | `HumanEval_66_digitSum` | 3 | 12 | FSL-30B, Q3.8-4b, Q3.8-8b | G4-19B, Qwopus |
| 30 | `HumanEval_68_pluck` | 3 | 14 | G4-12B-ag, G4-12B-ag-8b, Ornith-4b | — |
| 31 | `HumanEval_81_numerical_letter_grade` | 3 | 14 | DSV4-9B, FSL-30B, G4-12B-ag | G4-26B, Qwopus |
| 32 | `HumanEval_89_encrypt` | 3 | 13 | DSV4-9B, G4-12B-ag-8b, Q3.8-4b | G4-19B, Qwopus |
| 33 | `HumanEval_99_closest_integer` | 3 | 14 | DSV4-9B, G4-12B-ag-8b, Q3.8-8b | G4-19B, G4-26B, Q3.6-8b, Qwopus |
| 34 | `HumanEval_101_words_string` | 3 | 15 | DSV4-9B, Q3.8-4b, Qwopus | G4-26B |
| 35 | `HumanEval_106_f` | 3 | 11 | G4-12B-ag, Ornith-4b, Ornith-8b | — |
| 36 | `HumanEval_119_match_parens` | 3 | 11 | FSL-30B, G4-12B-ag, G4-12B-ag-8b | Q3.6-8b |
| 37 | `HumanEval_129_minPath` | 3 | 14 | FSL-30B, G4-12B-ag, G4-12B-ag-8b | G4-19B, G4-26B, Ornith-4b, Ornith-8b, Q3.6-4b, Q3.6-8b, Qwopus |
| 38 | `HumanEval_133_sum_squares` | 3 | 12 | Ornith-4b, Ornith-8b, Q3.6-4b | — |
| 39 | `HumanEval_134_check_if_last_char_is_a_letter` | 3 | 14 | FSL-30B, G4-12B-ag, Q3.6-8b | DSV4-9B, G4-19B, G4-26B, Q3.6-4b, Qwopus |
| 40 | `HumanEval_135_can_arrange` | 3 | 14 | G4-12B-ag-8b, Ornith-4b, Q3.8-8b | — |
| 41 | `HumanEval_148_bf` | 3 | 12 | Ornith-1.5, Ornith-4b, Ornith-8b | G4-19B |
| 42 | `HumanEval_0_has_close_elements` | 2 | 14 | Q3.8-4b, Q3.8-8b | — |
| 43 | `HumanEval_5_intersperse` | 2 | 13 | Q3.6-4b, Qwopus | Q3.6-8b |
| 44 | `HumanEval_10_make_palindrome` | 2 | 14 | DSV4-9B, G4-12B-ag-8b | Q3.6-4b, Qwopus |
| 45 | `HumanEval_19_sort_numbers` | 2 | 15 | G4-12B-ag-8b, QC30-rails | G4-26B |
| 46 | `HumanEval_26_remove_duplicates` | 2 | 14 | G4-12B-ag, G4-12B-ag-8b | — |
| 47 | `HumanEval_29_filter_by_prefix` | 2 | 15 | FSL-30B, QC30-rails | — |
| 48 | `HumanEval_37_sort_even` | 2 | 14 | DSV4-9B, G4-12B-ag | G4-19B, G4-26B, Q3.6-4b, Q3.6-8b |
| 49 | `HumanEval_43_pairs_sum_to_zero` | 2 | 14 | G4-12B-ag, Ornith-4b | — |
| 50 | `HumanEval_53_add` | 2 | 12 | G4-12B-ag, G4-19B | — |
| 51 | `HumanEval_57_monotonic` | 2 | 12 | G4-12B-ag, Ornith-1.5 | — |
| 52 | `HumanEval_62_derivative` | 2 | 12 | Ornith-4b, Q3.6-4b | — |
| 53 | `HumanEval_63_fibfib` | 2 | 14 | G4-12B-ag, Ornith-1.5 | G4-26B |
| 54 | `HumanEval_71_triangle_area` | 2 | 14 | DSV4-9B, FSL-30B | G4-19B |
| 55 | `HumanEval_76_is_simple_power` | 2 | 13 | G4-12B-ag-8b, G4-19B | DSV4-9B, Qwopus |
| 56 | `HumanEval_77_iscube` | 2 | 11 | G4-12B-ag-8b, Q3.8-8b | — |
| 57 | `HumanEval_78_hex_key` | 2 | 14 | DSV4-9B, G4-12B-ag | — |
| 58 | `HumanEval_97_multiply` | 2 | 15 | FSL-30B, G4-12B-ag-8b | — |
| 59 | `HumanEval_110_exchange` | 2 | 12 | Ornith-4b, Ornith-8b | G4-19B, Qwopus |
| 60 | `HumanEval_114_minSubArraySum` | 2 | 14 | G4-12B-ag, G4-12B-ag-8b | — |
| 61 | `HumanEval_118_get_closest_vowel` | 2 | 14 | G4-12B-ag, G4-12B-ag-8b | DSV4-9B, G4-26B, Q3.6-4b, Qwopus |
| 62 | `HumanEval_120_maximum` | 2 | 13 | FSL-30B, Ornith-4b | — |
| 63 | `HumanEval_122_add_elements` | 2 | 14 | DSV4-9B, Ornith-4b | — |
| 64 | `HumanEval_125_split_words` | 2 | 12 | G4-12B-ag-8b, G4-19B | — |
| 65 | `HumanEval_128_prod_signs` | 2 | 13 | G4-12B-ag-8b, Qwopus | DSV4-9B, Ornith-1.5, Ornith-4b, Ornith-8b |
| 66 | `HumanEval_131_digits` | 2 | 15 | G4-12B-ag, G4-12B-ag-8b | — |
| 67 | `HumanEval_139_special_factorial` | 2 | 14 | G4-12B-ag-8b, Ornith-1.5 | — |
| 68 | `HumanEval_140_fix_spaces` | 2 | 14 | G4-12B-ag, G4-12B-ag-8b | DSV4-9B, G4-19B, G4-26B, Ornith-1.5, Ornith-4b, Ornith-8b, Q3.6-8b, Qwopus |
| 69 | `HumanEval_143_words_in_sentence` | 2 | 14 | G4-12B-ag, Ornith-8b | — |
| 70 | `HumanEval_146_specialFilter` | 2 | 15 | G4-19B, Qwopus | — |
| 71 | `HumanEval_147_get_max_triples` | 2 | 14 | DSV4-9B, G4-12B-ag | G4-26B, Q3.6-4b, Q3.6-8b, Qwopus |
| 72 | `HumanEval_7_filter_by_substring` | 1 | 12 | FSL-30B | — |
| 73 | `HumanEval_9_rolling_max` | 1 | 14 | Qwopus | G4-26B |
| 74 | `HumanEval_13_greatest_common_divisor` | 1 | 12 | Q3.8-8b | — |
| 75 | `HumanEval_16_count_distinct_characters` | 1 | 15 | QC30-rails | — |
| 76 | `HumanEval_23_strlen` | 1 | 13 | Ornith-8b | — |
| 77 | `HumanEval_30_get_positive` | 1 | 15 | FSL-30B | — |
| 78 | `HumanEval_33_sort_third` | 1 | 14 | G4-12B-ag | DSV4-9B |
| 79 | `HumanEval_34_unique` | 1 | 13 | FSL-30B | — |
| 80 | `HumanEval_36_fizz_buzz` | 1 | 12 | Q3.8-4b | G4-12B-ag, Ornith-4b, Q3.6-8b |
| 81 | `HumanEval_39_prime_fib` | 1 | 12 | G4-12B-ag | Q3.6-4b, Q3.6-8b, Qwopus |
| 82 | `HumanEval_42_incr_list` | 1 | 13 | FSL-30B | — |
| 83 | `HumanEval_52_below_threshold` | 1 | 12 | FSL-30B | — |
| 84 | `HumanEval_59_largest_prime_factor` | 1 | 14 | G4-12B-ag-8b | Qwopus |
| 85 | `HumanEval_70_strange_sort_list` | 1 | 14 | G4-12B-ag | — |
| 86 | `HumanEval_72_will_it_fly` | 1 | 14 | G4-12B-ag | — |
| 87 | `HumanEval_75_is_multiply_prime` | 1 | 12 | G4-12B-ag-8b | G4-19B |
| 88 | `HumanEval_80_is_happy` | 1 | 12 | G4-12B-ag-8b | — |
| 89 | `HumanEval_82_prime_length` | 1 | 13 | Ornith-1.5 | Q3.6-4b |
| 90 | `HumanEval_85_add` | 1 | 14 | G4-12B-ag | — |
| 91 | `HumanEval_87_get_row` | 1 | 15 | QC30-rails | Q3.6-4b |
| 92 | `HumanEval_96_count_up_to` | 1 | 13 | DSV4-9B | Qwopus |
| 93 | `HumanEval_98_count_upper` | 1 | 14 | Ornith-4b | — |
| 94 | `HumanEval_112_reverse_delete` | 1 | 14 | G4-12B-ag | — |
| 95 | `HumanEval_116_sort_array` | 1 | 12 | G4-12B-ag | Ornith-4b, Qwopus |
| 96 | `HumanEval_117_select_words` | 1 | 14 | Qwopus | DSV4-9B |
| 97 | `HumanEval_126_is_sorted` | 1 | 14 | G4-12B-ag | DSV4-9B, G4-26B, Q3.6-8b, Qwopus |
| 98 | `HumanEval_149_sorted_list_sum` | 1 | 12 | G4-19B | — |
| 99 | `HumanEval_150_x_or_y` | 1 | 12 | G4-19B | — |
| 100 | `HumanEval_161_solve` | 1 | 12 | Ornith-1.5 | — |
| 101 | `HumanEval_6_parse_nested_parens` | 0 | 14 | — | G4-26B |
| 102 | `HumanEval_17_parse_music` | 0 | 12 | — | G4-19B |
| 103 | `HumanEval_21_rescale_to_unit` | 0 | 12 | — | Qwopus |
| 104 | `HumanEval_46_fib4` | 0 | 14 | — | G4-19B, G4-26B |
| 105 | `HumanEval_47_median` | 0 | 14 | — | DSV4-9B, G4-26B, Qwopus |
| 106 | `HumanEval_56_correct_bracketing` | 0 | 13 | — | G4-19B |
| 107 | `HumanEval_58_common` | 0 | 15 | — | G4-26B |
| 108 | `HumanEval_94_skjkasdkd` | 0 | 12 | — | Qwopus |
| 109 | `HumanEval_123_get_odd_collatz` | 0 | 13 | — | G4-19B |
| 110 | `HumanEval_137_compare_one` | 0 | 12 | — | Qwopus |
| 111 | `HumanEval_142_sum_squares` | 0 | 14 | — | G4-26B |
| 112 | `HumanEval_154_cycpattern_check` | 0 | 12 | — | Qwopus |

## Reproduction

Scratch files (outside the repo, not committed): `/tmp/mbaudit/matrix.py` (failure matrix),
`/tmp/mbaudit/digest.py` (failing assertion per answer), `/tmp/mbaudit/rescore.py` (corrected tests and lenient
re-scoring), `/tmp/mbaudit/proof/*.rb` (the proof files above). Model code was only ever run in
`ruby:3.4-slim-bookworm` with `--network none -m 512m`, fed on stdin.
