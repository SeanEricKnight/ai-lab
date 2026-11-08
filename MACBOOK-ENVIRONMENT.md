# MacBook Environment Inventory

Canonical record of Sean's MacBook Pro. Verified 2026-11-08 by Claude using read-only commands (`scripts/mac-inventory.sh`, run by Sean in Terminal) plus a read-only look at `~/.ollama`, `~/.lmstudio` and `~/code`. Nothing was installed, downloaded, or changed. Serials, MAC/IP addresses, hostnames and env vars were deliberately not collected.

Labels: **[Measured]** observed on the machine · **[Estimate]** reasoned, not tested · **[Recommendation]** judgment.

## Hardware [Measured]

| Item | Value |
|---|---|
| Model | MacBook Pro, identifier `Mac17,8` |
| Chip | Apple M5 Pro |
| CPU cores | 18 (6 "Super" + 12 "Performance", as reported by macOS) |
| GPU cores | 20, Metal 4 |
| Unified memory | 24 GB (25,769,803,776 bytes) |
| GPU wired-memory limit (`iogpu.wired_limit_mb`) | 0 = macOS default (not raised) |
| Storage | ~1 TB SSD (994.6 GB container), APFS; 763.5 GB free on 2026-11-08 |
| macOS | 27.2, build 26B123 |
| Wi-Fi | Supports 802.11 a/b/g/n/ac/ax/be (Wi-Fi 7) |
| Other interfaces | Thunderbolt ports; three Ethernet adapters listed (en3–en5; types not identified) |

## Software [Measured]

Checked from a non-login `bash`; a tool in a non-standard location may show as "not found".

| Tool | Status |
|---|---|
| Homebrew | 7.0.11 |
| Python | 3.15.2 (uv-managed, `~/.local/bin`); Apple CLT Python 3.9.6 untouched. See `shared-mind/memory/mac-python.md` |
| uv | 0.13.5 (Homebrew) |
| Git / GitHub CLI | Apple Git 2.54.0 / gh 2.102.0 |
| OpenSSH | 10.5p1 |
| Ollama | 0.40.15, app installed, API up on localhost:11434, no model loaded at check time |
| LM Studio | App + `lms` CLI present. Local server (port 1234) was not running. No MCP servers configured |
| VS Code | App installed; `code` CLI not on PATH |
| Claude.app, ChatGPT.app | Installed |
| Not found on PATH | node, npm, claude (Claude Code), codex, gemini, docker, podman, pyenv, conda, llama-cli, mlx_lm |

LM Studio runtimes installed: llama.cpp 2.54–2.71 (Metal) and MLX 1.13–1.14 (Metal, incl. "nax" builds). MLX is available only inside LM Studio; no standalone MLX toolchain.

## Local models [Measured]

Ollama (~39 GB on disk):

| Model | Size |
|---|---|
| `qwen3.8:27b` | 18 GB |
| `gemma4:12b` | 7.7 GB |
| `huihui_ai/qwen3.5-abliterated:9b` | 6.6 GB |
| `dolphin3:8b` | 4.9 GB |
| `qwen3.5:4b` | 4.0 GB |

LM Studio (~7.8 GB): `lmstudio-community/Qwen3.5-9B-GGUF` Q6_K (7.4 GB) plus vision projector (0.9 GB).

No inference speed or memory-pressure tests have been run.

## Projects and repos [Measured]

- `~/Documents/Codex/agent-repos/`: `ops-claude`, `ops-codex`, `analytics-claude`, `analytics-codex` (branches `claude/` or `codex/mac-access-setup-2026-10-21`).
- `~/code`: no Git repos within 3 levels; contains notes and a `tools/` folder (unpacked gh).
- Four Python venvs are known broken (see `shared-mind/memory/mac-python.md`).

## Connectivity [Measured]

- SSH config contains one host, `jarvis`. TCP/22 was **unreachable** from the Mac at check time (cause unknown: off-LAN, SSH disabled, or name resolution).
- PowerSpec G913 (Windows 11): **reachable by IPv4 from the Mac on 2026-11-08**, confirmed by Sean's Terminal output (4/4 ICMP replies, 0% packet loss, average round-trip 6.789 ms). Its human-readable `PowerSpec` hostname did not resolve on the Mac. The address is deliberately omitted from this repository per inventory privacy rules. This verifies IP connectivity only, not remote-shell or AI API access.
- No PowerSpec SSH host alias or remote AI endpoint was configured at the time of the initial inventory; current remote-service status remains unverified.

## Local AI capability

**Usable model memory [Estimate].** macOS caps GPU-wired memory below total RAM by default; assume roughly 16–18 GB for model + KV cache, with the rest for macOS and apps. Memory bandwidth was not measured.

**Practical sizes [Estimate, untested]:**
- Comfortable: 3–9B at Q4–Q6 (4–7.5 GB), long contexts fine.
- Workable: 12–14B at Q4–Q5 (~8–10 GB).
- Tight: the installed 18 GB `qwen3.8:27b` leaves little room for context or other apps; expect slowdown or pressure. Needs a test before relying on it.
- Not practical: 30B+ at useful quality; large-context 27B.

**Runtime [Recommendation].** MLX usually beats llama.cpp on Apple silicon for comparable quantizations, but that is unmeasured here. LM Studio already ships both MLX and llama.cpp, so compare without installing anything. Keep Ollama for its API and scripting. Pick the default only after benchmarks.

**MacBook vs RTX 5080 workstation [Recommendation].**
- MacBook: portable, offline, private drafting/summaries/classification, small-model agents, quick experiments, ≤14B models.
- PowerSpec G913: larger or faster models, long contexts, batch jobs, anything that must run unattended or in parallel.
- Reaching PowerSpec models from the Mac needs Ollama on the PowerSpec bound to the LAN, or better an SSH port-forward. Not configured; nothing was exposed.

**JARVIS [Recommendation].** It is not an inference box. Use it for backups and model-file mirrors, Docker services (vector DB, UI, schedulers), git mirrors, logs and long-running automation.

**Reducing paid API use [Recommendation].** Send bulk, low-stakes work to local models: classification, tagging, first-pass summaries, embeddings, boilerplate, draft rewrites. Keep high-stakes reasoning and verification on frontier models. Do not assume ChatGPT or Claude subscriptions include API credits; measure real API spend before claiming savings.

## Open items (not verified)

- PowerSpec name resolution, remote administration, and AI API access; why `jarvis` SSH is unreachable. PowerSpec IPv4 connectivity has been confirmed; its address remains local-only and is intentionally not committed.
- Whether Node, Claude Code, Codex, Docker or the VS Code CLI exist outside PATH.
- Memory bandwidth, tokens/s, and practical context limits for each installed model.
- Meaning of the three Ethernet adapters.

## Next experiment (proposed)

Benchmark one model (`Qwen3.5-9B`) across Ollama, LM Studio llama.cpp and LM Studio MLX: tokens/s, time to first token, peak memory, at 4k and 16k context. Then test whether `qwen3.8:27b` fits. Record as `EXP-0002`.

Re-run `scripts/mac-inventory.sh` to refresh the [Measured] sections.
