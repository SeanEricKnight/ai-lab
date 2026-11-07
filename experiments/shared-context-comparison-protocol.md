# Experiment protocol: curated context vs bare prompts

**Status:** Protocol only — no tests executed or results recorded.  
**Date:** 2026-11-07  
**Author:** [ChatGPT]  
**Motivation:** [Beyond Prompt Engineering](../notes/beyond-prompt-engineering.md)

## Question and hypothesis
Does a small, relevant, versioned context bundle improve accuracy and consistency over a bare task prompt enough to justify additional tokens, cost, and latency? This is a paired exploratory benchmark, **not** a statistically powered comparison of model brands.

## Preregistered design
- Models: one named ChatGPT model, one named Claude model, and one named local LLM. Record exact model IDs, revisions, runtime, quantization, hardware, provider, and date **before** testing; do not assume the same capability or price.
- Conditions: **A (bare)** = task prompt + common fixture only; **B (curated)** = identical task prompt + common fixture + task-specific context note below. Never omit the common fixture in A: otherwise the test would confound missing task data with context quality.
- Three tasks × three models × two conditions × three independent repetitions = **54 calls**. Repeat in fresh sessions without chat history, memory, tools, retrieval, web access, or hidden shared-mind access. Disable personalization if possible; if not, record contamination risk.
- Keep the exact system instruction (`Answer only what the task requests; do not invent facts.`), prompt wording, fixture, temperature (0 where supported), max output tokens (512), and context placement fixed. Log unsupported settings. Run order should be balanced/interleaved across A/B and models, with run IDs assigned in advance. Do not retry failures silently.
- Before running, freeze this protocol and fixtures at a commit SHA. Record a SHA-256 of each submitted request, including system text and context. Record all outputs unchanged. Do not modify the rubric after inspecting results.

## Frozen tasks, fixtures, context and gold answers

### T1: Decision extraction
**Common fixture:** `Meeting log: Mon: team discussed CSV and JSON export. Tue: owner approved CSV only for v1. Wed: developer asked whether JSON was also approved; no response recorded.`  
**Task prompt:** `From the meeting log, report the approved v1 format, whether JSON is approved, and the evidence day. Use exactly three lines: Format:, JSON approved:, Evidence day:.`  
**Curated context B:** `Interpretation rule: only explicit owner approval is authoritative. A discussion or unanswered question is not approval. Answer unapproved or unconfirmed items as "No confirmed approval".`  
**Gold:** `Format: CSV`; `JSON approved: No confirmed approval`; `Evidence day: Tue`.

### T2: Document classification
**Common fixture:** `Record: "Request to change the shipping address for order 482. Customer asks for confirmation. No evidence of payment or refund."`  
**Task prompt:** `Classify this record and report whether it involves a refund. Exactly two lines: Category:; Refund:.`  
**Curated context B:** `Taxonomy: ADDRESS_CHANGE = shipping address modification; REFUND = request to return money; OTHER = neither. A mention of payment without a request for money back is not a refund. Use the exact category identifier and Yes/No.`  
**Gold:** `Category: ADDRESS_CHANGE`; `Refund: No`.

### T3: Code reasoning
**Common fixture:** `Python: def unique_count(items): return len(set(items))\nInput: ["a", "a", "b"]`  
**Task prompt:** `Give the returned integer and state whether the function preserves the order of items. Exactly two lines: Result:; Preserves order:.`  
**Curated context B:** `Interpretation rule: set removes duplicates and does not promise insertion order. Distinguish count from list output. Use Yes/No for the order answer.`  
**Gold:** `Result: 2`; `Preserves order: No`. (Order is not a meaningful property of the returned integer; score "No" as shorthand for the intermediate set not guaranteeing input order.)

**Limitation:** These are small, mostly easy tasks and curated notes include helpful interpretation rules. They test instruction/context usefulness on these fixtures, not retrieval quality, real project memory, code-writing skill, or general model superiority. The code task's order wording is somewhat ambiguous; preserve the fixed gold and flag disputes rather than retroactively changing it.

## Scoring, fixed before execution
- **Accuracy (0–4 per run):** T1: 2 points for CSV, 1 for no confirmed JSON approval, 1 for Tue. T2: 2 for ADDRESS_CHANGE, 2 for No refund. T3: 2 for integer 2, 2 for No order guarantee. Award only exact semantic matches; missing, contradictory, or invented answers score zero for that item. Record format compliance separately (0 or 1), not inside accuracy.
- **Consistency:** for each model × condition × task, compute number of repetitions matching the same normalized complete answer divided by 3; also report proportion of runs with full 4/4 accuracy. Normalize only whitespace and label capitalization, never substantive content.
- **Tokens:** record input, output, and total billed/provider-reported tokens per run; if unavailable use `NA`, not guessed token counts. For local models log tokenizer-derived counts separately and name tokenizer.
- **Cost:** calculate API marginal cost = (input tokens × applicable input rate + output tokens × output rate)/1,000,000, accounting for caching and other charges where applicable. Record rate source, currency, date, and actual billed amount if available. For subscription ChatGPT/Claude UI, per-run marginal charge may be zero while underlying economic cost is unknown; report `not comparable`, not $0 model cost. For local LLM, report electricity estimate separately only if measured watts and duration are available; amortized hardware/setup excluded and disclosed.
- **Latency:** monotonic wall-clock seconds from request dispatch to final response, including network and queue time; record time to first token separately only if instrumented. UI stopwatch results are approximate and should be labeled so.
- **Human correction:** count required factual edits (0–3 per run); adjudicator records disagreements with gold before unblinding.
- **Blind review:** mask model and condition IDs when scoring; automated exact checks may be used for the fixed answers, with manual review for semantic variants.

## Run record schema
One row per call: `run_id,task_id,model_id,model_revision,provider,condition,repetition,run_order,utc_timestamp,hardware_runtime,temperature,max_output_tokens,request_sha256,fixture_version,context_version,input_tokens,output_tokens,token_source,elapsed_seconds,ttft_seconds,price_source,estimated_api_usd,actual_billed_usd,local_energy_wh,raw_output_path,accuracy_0_4,format_0_1,corrections,reviewer_notes`. Use `NA` for unavailable measurements, never 0.

## Analysis and decision rules
- Compare B−A **within each model and task** first; report mean accuracy /4, full-correct rate, consistency, median latency, median tokens and marginal cost; show all 3 repetitions and absolute differences, not only percentages.
- **Meaningful context benefit:** B improves mean accuracy by at least 0.5/4 overall, does not reduce full-correct rate on any task, and additional cost/latency is explicitly reported. If both conditions are at ceiling, conclude `no measurable benefit on these fixtures`, not `context does not help`.
- **Local candidate for bounded use:** full 4/4 on all 18 local runs (three tasks × two conditions × three repeats), no invented facts, and no material cost/latency disadvantage for the intended deployment. This is only a candidate for a further real-world validation, **not** authorization for autonomous or consequential work.
- If missing tokens, pricing, or latency data prevent comparison, state `inconclusive on that metric`. Three repeats cannot support significance claims; avoid causal generalization beyond these fixtures.

## Execution checklist (future, not performed)
1. Choose exact models and interface (prefer API/CLI for reproducible counts and timing); verify pricing and local hardware/runtime.
2. Freeze protocol commit, copy literal fixtures/prompts/context into a versioned runner, preassign randomized balanced order, and validate logging on a dry run (clearly separate from scored runs).
3. Run 54 calls, preserve raw inputs/outputs and measurements under `experiments/results/` without credentials or private data.
4. Score blinded, resolve disputed cases, calculate paired comparisons, write reflection and a lab report. Do not claim results before evidence exists.

**Privacy:** Use only the synthetic fixtures above; do not send private shared-mind or Trexis materials to any model as part of this benchmark.
