# TODO: speed tuning for verbose, accurate models (Gemma 4 first)

**Update (2026-10-20 evening):** the thinking-budget work now has its own experiment area with its plan and results
table: [`experiments/thinking-budget/`](../experiments/thinking-budget/README.md). It targets the two builders
(Qwen3.6-35B-A3B 8-bit and Qwen3.8-27B 4-bit) rather than Gemma.

**Status (2026-10-20):** Gemma-4-26B fails the accuracy gate at full length (77% of the first 30 at 32,768
tokens; about 1 answer in 5 never finishes). If it's revisited, start with a thinking budget (experiment 2),
not a larger limit. Qwen3.6-35B-A3B passes the accuracy gate (94% 8-bit, 93% 4-bit at 8,192 tokens); its
agentic gate (2 of 3) isn't tested yet.

**Original status:** not started. Blocked on the 8,192-token re-run (`results/2026-10-20-8k/`), which
shows each model's accuracy when it can run until it finishes. Created 2026-10-20.

## Why

On the 2026-10-19 extended run, Gemma-4-26B-A4B was correct on **98% (49 of 50)** of the answers it
finished, and it solved the agentic task. But it averaged about **2,700 tokens and 49 s per problem**,
so its pass rate fell to 68% (cut-offs) and it reached only 74 of 161 problems in an hour.

The bottleneck is **token volume, not decode speed**: 48.7 tok/s is already quick. Qwen3.8-27B 4-bit
answers in about 75 tokens. If Gemma-26B kept its accuracy at a fraction of the tokens, it would be a
strong all-rounder, and it also reads images.

The same question applies to the other verbose models: Qwen3.6-35B-A3B (4-bit and 8-bit) and Qwopus.

## Step 0: the gate (decide whether tuning is worth the time)

Tuning can make a model **faster, never more accurate**. MTP is output-identical; switching thinking
off or capping it usually costs some accuracy. So only tune a model whose accuracy is already worth
having. Use the 8k re-run results:

1. **Accuracy gate:** pass rate over all 161 problems, at 8,192 tokens with no time cap, must be
   **≥ 90% and at least 3 points above the incumbent** (Qwen3.8-27B 4-bit: 85%, 4.4 s/problem).
   If not, stop: there is no accuracy premium to buy speed for.
2. **Agentic gate:** it must solve the agentic task. Run it 3 times; it needs at least 2 of 3.
3. **Payback gate:** required speed-up = model's s/problem ÷ incumbent's s/problem.
   - ≤ 3×: worth tuning. Thinking budget or MTP alone could get there.
   - 3–10×: worth one experiment (thinking off or budget). Stop if it fails.
   - > 10×: stop. Even thinking off plus MTP is unlikely to close the gap.
4. **Time box:** at most half a day of effort per model. After each experiment, stop if accuracy
   drops by **more than 5 points** or the agentic task stops passing.

One-line heuristic: **tune only if (accuracy premium ≥ 3 points) and (agentic passes) and
(required speed-up ≤ 10×); stop at the first experiment that costs > 5 points.**

## Experiments, in order (cheapest first)

Every experiment uses the same harness: extended coding (161 problems) plus the agentic task × 3.
Record s/problem, tokens/answer, pass rate, pass rate excl. cut-off and agentic passes.

1. **Thinking off, per request.** Pass `enable_thinking: false` to the chat template on the request.
   Don't change oMLX's global setting: oMLX currently has `enable_thinking: True` set for
   `mlx-community--gemma-4-26b-a4b-it-4bit`, while the model's template default is off, and something
   else may rely on that. Expect 5–10× fewer tokens; accuracy loss unknown.
2. **Thinking budget.** oMLX has a per-model `thinking_budget_enabled` option (currently off). Try caps
   of 1,024 and 2,048 tokens. This is the middle ground between on and off.
3. **MTP drafter (speculative decoding).** Google's Multi-Token Prediction drafters: a small 4-layer
   "assistant" model drafts several tokens and Gemma 4 verifies them in one pass. Up to **3× faster
   with byte-identical output at temperature 0**, so there's no accuracy risk.
   - **MLX drafter:** `mlx-community/gemma-4-26B-A4B-it-assistant-bf16` (from `google/gemma-4-26B-A4B-it-assistant`,
     mlx-vlm 0.4.5). Recommended `--draft-block-size 6` for single requests.
   - **Caveat from Google's docs:** for the **MoE 26B A4B, at batch size 1** each drafted token can
     activate different experts, so verification loads extra expert weights. *"The 26B A4B drafter may
     not yield speedups on hardware platforms without good parallelism."* That's our case (one request
     at a time on an M1 Max), so measure it; don't assume.
   - **Unverified:** whether oMLX can use it. oMLX has `mtp_enabled` / `vlm_mtp_enabled` settings, but
     Gemma isn't served by Splash. Also unverified: whether the bf16 drafter pairs with our **4-bit**
     target (the model card's example pairs it with the bf16 target).
4. **Prompt.** Ask it to "think briefly" and return only code. Cheap, but reasoning models often ignore
   length instructions.
5. **Context / RAG** (factory stage). Rails and Ruby API excerpts, app routes and models. This should
   shorten reasoning on real work. Caution: in September, injecting docs correlated with *more* looping.
   Test it on factory tasks, not on this coding screen.

For Qwen3.6-35B-A3B and Qwopus, the equivalents are thinking off/budget (Qwen's template supports
`enable_thinking`), plus the draft models already on the MBP-14: `incoai/Qwen3.6-35B-A3B-DFlash2`
(and `z-lab/Qwen3.8-27B-DFlash2` for Qwen3.8). oMLX `dflash_enabled` is currently off. In August,
MTP gave no gain on Qwen3.8 at 4-bit, so measure rather than assume.

## Sources

- Google blog, *Accelerating Gemma 4: faster inference with multi-token prediction drafters* (5 May 2026):
  https://blog.google/innovation-and-ai/technology/developers-tools/multi-token-prediction-gemma-4/
- Google docs, *Speed-up Gemma 4 with Multi-Token Prediction* (page marked deprecated in favour of gemma.ai):
  https://ai.google.dev/gemma/docs/mtp/overview
- MLX drafter: https://huggingface.co/mlx-community/gemma-4-26B-A4B-it-assistant-bf16
