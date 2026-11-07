# Beyond Prompt Engineering: Context, Agents, and AI Systems

**AI Lab research note — 2026-11-07**  
**Status:** Working synthesis and proposed experiment; not an approved architecture or completed implementation.  
**Author:** [ChatGPT]

## Thesis

Prompt engineering is not disappearing. It is becoming one part of a broader discipline: designing the information, tools, execution processes, and checks around AI models so they can accomplish work reliably.

The practical shift is from **“What words should I put in the prompt?”** to **“What system lets this model produce trustworthy results, at acceptable cost, with appropriate human control?”**

Terminology is still evolving. The categories below overlap; they are not universally agreed chronological stages.

## Four overlapping disciplines

| Discipline | Central question | Typical concerns |
|---|---|---|
| Prompt engineering | What instructions should the model receive? | Task definition, examples, constraints, output format |
| Context engineering | What should the model know *at this moment*? | Retrieval, project files, memory, relevance, context size, freshness |
| Agent engineering / orchestration | How should the model carry out multistep work? | Tools, planning, state, checkpoints, permissions, retries, handoffs |
| AI systems engineering | How do we keep the whole workflow effective? | Evaluation, reproducibility, model routing, cost, latency, security, monitoring |

**Emerging adjacent concept:** intent engineering — making objectives, priorities, authority boundaries, and trade-offs explicit. Useful framing, but not yet a settled discipline or standard term.

## Why the shift matters

A polished prompt cannot compensate for missing or stale facts, poorly scoped tool permissions, an unreliable retrieval pipeline, or the absence of outcome verification. A longer prompt is not necessarily a better prompt. Stronger models may need *less* elaborate prompting, while the surrounding system becomes more important.

The hard problem is increasingly *system reliability*, not simply *prompt eloquence*.

## Application to this AI Lab

Relevant existing assets:

- **ChatGPT:** candidate for research, critique, synthesis, and evaluation.
- **Claude:** candidate for implementation and code-focused work.
- **Local LLM(s):** candidates for lower-cost, privacy-conscious, bounded routine tasks, subject to testing.
- **`SeanEricKnight/shared-mind`:** shared instructions and cross-assistant context, with existing authority and privacy boundaries.
- **`SeanEricKnight/ai-lab`:** canonical home for experiments, evidence, decisions, and lab reports.

These are **proposed roles, not fixed capabilities or verified integrations**. Route work according to measured performance, not brand assumptions. Local models are not automatically cheaper after hardware, electricity, setup, and maintenance costs are considered.

### Proposed workflow

1. Define one task and explicit acceptance criteria.
2. Supply the same controlled, versioned context to candidate models.
3. Run comparable attempts with reproducible inputs.
4. Score correctness, completeness, citation/evidence quality, latency, token usage, monetary cost, and required human correction.
5. Compare results against a baseline; note failure modes and uncertainties.
6. Use the least expensive reliable configuration for each task class, with human approval for consequential actions.
7. Record evidence, reflection, and next iteration in AI Lab.

### First experiment: Does shared context improve performance?

**Hypothesis:** A small, relevant, versioned context bundle improves accuracy and consistency compared with a bare prompt, without disproportionate token or latency cost.

**Design:**

- Choose three representative, non-sensitive tasks: summarizing a project decision, producing a small code change with tests, and classifying a routine document.
- For each model, compare (A) baseline prompt, (B) prompt plus relevant curated context, and (C) prompt plus larger unfiltered context.
- Keep task wording, evaluation rubric, and source material constant; record model/version/settings and run date.
- Repeat each condition enough times to detect unstable outcomes; do not infer general superiority from one run.
- Evaluate outputs blind to model identity where feasible; separately record tool access and environment differences.
- Log prompt/input tokens, output tokens, elapsed time, API cost where applicable, correctness score, and human fixes.
- Do not feed private work material to an unapproved model or service.

**Success criterion:** Identify whether curated context meaningfully improves verified results and whether a local model can safely take over any bounded task without degrading quality.

**Deliverables:** experiment protocol, test cases, scored results, reflection, and a short lab report. No performance conclusions until measurements exist.

## Engineering cautions

- Context quality matters more than indiscriminate context volume.
- Agreement between ChatGPT and Claude is not independent verification.
- Tool access requires least-privilege permissions, confirmation for consequential actions, and auditability.
- A successful demo is not a reliable autonomous workflow.
- Model routing should be driven by measured quality and total cost, not assumptions.
- Preserve project-specific instructions and canonical sources; avoid duplicating stale memory into multiple repositories.
- Distinguish owner decisions, assistant proposals, observations, and verified results.

## Research leads and verification

This note captures a conceptual trend, not a systematic literature review. Before citing precise adoption rates or claims about a specific model release, independently verify the primary publication and its date. Useful starting points:

- Anthropic, *Building effective agents* — https://www.anthropic.com/engineering/building-effective-agents
- Anthropic engineering articles on context engineering — https://www.anthropic.com/engineering
- LangChain articles and surveys on agents, evaluation, and context engineering — https://blog.langchain.com/
- OpenAI, *A practical guide to building agents* — https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/

## Bottom line

**Stop treating the prompt as the product. Treat the entire AI workflow as the product.**

For this lab, learn context engineering first, agent orchestration second, and evaluation engineering throughout. Build, verify, learn, repeat.
