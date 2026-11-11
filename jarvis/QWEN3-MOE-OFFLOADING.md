# Jarvis — Qwen3 30B MoE offloading runbook

**Updated:** 2026-11-10  
**Status:** Working; tuning and Unraid persistence outstanding  
**Provenance:** [Sean] supplied terminal results and Open WebUI screenshots during a ChatGPT session; [ChatGPT] compiled this runbook. This is a recorded setup, **not** a fresh authenticated server audit.  
**Related:** [HARDWARE.md](../HARDWARE.md), [shared-mind Jarvis inventory](https://github.com/SeanEricKnight/shared-mind/blob/main/projects/jarvis/README.md).

## Goal and conclusion

Run a quantized, 30B-parameter Mixture-of-Experts model on **Jarvis (Unraid, RTX 3060 12 GiB)** without fitting all model weights in GPU VRAM. Keep expert weights in CPU RAM using llama.cpp, cache selected experts in VRAM, and serve requests via the existing Open WebUI installation.

**Result:** Qwen3-30B-A3B-Instruct-2507 Q4_K_M loaded, generated responses and passed a clean Open WebUI arithmetic/correction test. llama.cpp's OpenAI-compatible endpoint works. Most recent **16K context** startup is confirmed, but no post-16K throughput benchmark is recorded.

## Verified hardware and existing services

From authenticated Jarvis inventory dated 2026-11-09 plus user's current terminal evidence:

- Unraid OS Pro 7.3.4; AMD Ryzen Threadripper 2950X (16 cores / 32 threads); **64 GiB DDR4**.
- NVIDIA RTX 3060 **12,288 MiB** VRAM, driver 620.70.06.
- Open WebUI: host `192.168.4.250:3002`, container on `jarvis-ai` Docker network.
- Ollama: host `192.168.4.250:11434`, also on `jarvis-ai`; still installed and running.
- MediaLyze already occupies host port **8081**, SABnzbd **8080**. Thus llama.cpp uses **8082:8080**.
- Model path: `/mnt/user/appdata/llama-cpp/models/Qwen3-30B-A3B-Instruct-2507-Q4_K_M.gguf`.
- Existing Unraid storage warnings (important but unrelated): Disk 9 and Disk 10 SMART critical as of Nov 9; Disk 9 had failed short self-test. Investigate backups and disk health before relying on the array for irreplaceable data.

## Model and installation

Model: `Qwen3-30B-A3B-Instruct-2507-Q4_K_M.gguf` (30.53B total parameters; MoE ~3B active per token, quantized Q4_K medium, ~18.55 GB on disk). Earlier TensorBlock download link returned HTTP 404. Replacement download was from:

```bash
mkdir -p /mnt/user/appdata/llama-cpp/models
cd /mnt/user/appdata/llama-cpp/models
curl -fL -C - --retry 5 \
  -o Qwen3-30B-A3B-Instruct-2507-Q4_K_M.gguf \
  'https://huggingface.co/unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF/resolve/main/Qwen3-30B-A3B-Instruct-2507-Q4_K_M.gguf'
```

Model file existence and successful load independently established by the later llama.cpp startup and API outputs; no cryptographic checksum captured.

Official CUDA server Docker image:

```bash
docker pull ghcr.io/ggml-org/llama.cpp:server-cuda
```

**Current successful startup command** (recreates container; do not run on a busy server without arranging downtime). This is a hand-created Docker container, not yet preserved as an Unraid application template:

```bash
docker rm -f llama-cpp

docker run -d \
  --name llama-cpp \
  --restart unless-stopped \
  --network jarvis-ai \
  --gpus all \
  -p 8082:8080 \
  -v /mnt/user/appdata/llama-cpp/models:/models:ro \
  ghcr.io/ggml-org/llama.cpp:server-cuda \
  --model /models/Qwen3-30B-A3B-Instruct-2507-Q4_K_M.gguf \
  --alias qwen3-30b-moe \
  --host 0.0.0.0 \
  --port 8080 \
  --ctx-size 16384 \
  --parallel 1 \
  --threads 12 \
  --cpu-moe \
  --moe-cache-mib 512
```

**Important:** `--cpu-moe` places experts in CPU memory; `--moe-cache-mib 512` provides a 512 MiB GPU cache. Do not reinstate `--n-gpu-layers 99`: it prevented automatic fitting and, combined with a 2048 MiB expert cache, led to CUDA out-of-memory during first attempt. Explicit layer/cache settings need empirical validation.

### Current observed startup

User-provided logs after 16K restart:

```text
init: llama threadpool init, n_threads = 12
load_model: initializing, n_slots = 1, n_ctx_slot = 16384, kv_unified = 'false'
server_run_i: model loaded
server_on_li: listening on http://0.0.0.0:8080
```

Earlier 4K and 8K configurations also loaded. During initialization `/health` and `/v1/models` returned `503 Loading model`, which was transient. The 16K build's **startup** was verified; run an actual completion at 16K to confirm end-to-end generation with current configuration.

### Check commands

```bash
docker ps -a --filter name=llama-cpp
docker logs --tail 80 llama-cpp
curl -s http://localhost:8082/health
curl -s http://localhost:8082/v1/models
nvidia-smi
```

Known model alias: `qwen3-30b-moe`. In `/v1/models`, look for `n_ctx: 16384`. During health initialization, `503` is expected. Logs should say `model loaded` and `listening`.

Simple generation smoke test:

```bash
curl -s http://localhost:8082/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"qwen3-30b-moe",
    "messages":[{"role":"user","content":"Explain the purpose of MoE models in two sentences."}],
    "max_tokens":150,
    "stream":false
  }'
```

**Security:** The llama.cpp startup logs explicitly warn that no API key is configured and all CORS origins are allowed. Host port 8082 is bound on all interfaces by `-p 8082:8080`. Keep access restricted to trusted LAN/VPN/firewall, or use an authenticated reverse proxy / bind the host port to an appropriate interface. Do **not** expose 8082 directly to the Internet.

## Open WebUI integration

Open WebUI runs on `http://192.168.4.250:3002`. In **Admin → Settings → Connections → Manage OpenAI API Connections**, an external OpenAI-compatible connection was added:

- URL: `http://llama-cpp:8080/v1` (Docker-internal name because both are on `jarvis-ai`).
- Auth: none / blank if allowed, API type: Chat Completions.
- Keep the existing Ollama connection alongside it.

Base model `qwen3-30b-moe` became available. Initial chats triggered Open WebUI built-in tools (search/memory/notes/Ask User) and exposed tool-call markup; this was **not** a pure-model test.

A custom profile was then created in **Workspace → Models → Create**:

- Name: **Qwen3 30B - Clean**; ID shown `qwen3-30b---clean` (inspect UI if an exact ID matters).
- Base model: `qwen3-30b-moe`.
- Tools: None; Skills: None; Knowledge: None; Builtin Tools: **None**, all 12 toggles off.
- System prompt blank; Advanced Params default.
- Additional Capabilities still displayed `Vision, File Upload, Code Interpreter +4` in screenshot; optionally disable tool-related capabilities for isolated reasoning tests.
- **Critical:** Choose **Qwen3 30B - Clean**, not raw `qwen3-30b-moe`, in a new chat. A screenshot of raw model later showed the unwanted “Ask User” interaction again.

## Actual benchmarks and reasoning tests

### Earlier successful completion (4K-era setting)

Chat completion prompt “Explain in two sentences how Mixture-of-Experts models work” produced 66 output tokens with:

| Metric | Captured value |
| --- | ---: |
| Generated tokens | 66 |
| Prompt tokens | 22 |
| Generation speed | **9.2596 tokens/s** |
| Prompt speed | **34.1628 tokens/s** |
| Generation time | **7019.752 ms** |

This is a **short, early** test, not sustained performance and **not** a 16K / parallel=1 benchmark.

### GPU reading on 2026-11-10 18:06 local

```text
GeForce RTX 3060: 3347 MiB / 12288 MiB, 0% GPU util, 51 C, 42 W
/app/llama-server: 3232 MiB
Xorg: 70 MiB
```

~8941 MiB unallocated at that instant. This is **idle memory usage**, not proof that an 8 GB cache will fit or improve speed. Note the system may change memory residency under load.

### Reasoning quality

- First prompt (120 requests/min, 450 MB per request, 8 sec): correctly gave 16 concurrent requests but **incorrectly answered 54,000 MB** instead of 7,200 MB.
- Reframed prompt with 2 requests/sec: correctly got 16 concurrent and 7,200 MB, explaining why 120 × 450 is not concurrent RAM.
- Independent technician critique (150 requests/min, 320 MB for 12 sec, claim 48 GB) correctly rejected 48 GB and derived **30 concurrent; 9,600 MB = 9.6 GB**.
- That outcome demonstrates working computation with framing sensitivity, not a formal quality score. The explanations occasionally called summed per-request allocation “RAM consumed over a minute,” which is imprecise.

### Context evolution

1. 4096 tokens: a WebUI test exceeded it (7592-token request).
2. 8192 tokens: successfully loaded, but accumulated chat hit 8300-token request.
3. 16384 tokens with `--parallel 1`: **model loaded** on Nov 10 as shown above. New chats avoid carrying old history; long conversations will eventually fill 16K too. Prompt + output must both fit the limit.

## Next session: continue here

1. **Preserve stable deployment.** Convert this `docker run` configuration to an Unraid user template / Compose stack and confirm restart persistence. Record resulting container image digest, not only moving `server-cuda` tag. Ensure model storage uses desired SSD/cache placement. Do not delete the working installation prematurely.
2. **Verify 16K end-to-end:** `curl /health`, `/v1/models`, then a completion. Reconfirm WebUI custom **Clean** profile with no tools.
3. **Benchmark current 512 MiB cache first** using a repeatable fixed prompt and `timings.predicted_per_second`. Record CPU utilization, GPU utilization, VRAM, time to first token, token speed, prompt/context length; compare at equal settings and after warm-up.
4. If baseline stable, try **1024 MiB cache**, later **2048 MiB** only if warranted. Recreate container to change flag and benchmark. More cache is **not necessarily faster**. Record OOM logs, rollback configuration, and comparative measurements.
5. Evaluate context-size tradeoffs (8K vs 16K, parallel slots) and whether `--load-mode none` helps: logs only **suggested** that flag for performance; not yet benchmarked. Avoid speculative optimization.
6. Investigate Unraid Disk 9/10 health warnings independently.

### Copyable timing test

```bash
curl -s http://localhost:8082/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"qwen3-30b-moe",
    "messages":[{"role":"user","content":"Explain five practical differences between a CPU and GPU for AI inference. Use approximately 300 words."}],
    "max_tokens":450,
    "stream":false
  }' | python3 -c '
import json,sys
d=json.load(sys.stdin)
if "timings" not in d:
    print(d); sys.exit(1)
t=d["timings"]
print("Generated tokens:",t["predicted_n"])
print("Generation speed:",round(t["predicted_per_second"],2),"tokens/sec")
print("Prompt speed:",round(t["prompt_per_second"],2),"tokens/sec")
'
```

### Links

- [llama.cpp Docker](https://github.com/ggml-org/llama.cpp/blob/master/docs/docker.md)
- [llama.cpp server README](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md)
- [Open WebUI llama.cpp connection](https://docs.openwebui.com/getting-started/quick-start/connect-a-provider/starting-with-llama-cpp/)
- [Qwen3 30B-A3B Unsloth GGUF](https://huggingface.co/unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF)

**Status vocabulary:** “Verified” above means user-provided command output or screenshots confirmed the specific observation. Future performance and resilience claims remain open questions.
