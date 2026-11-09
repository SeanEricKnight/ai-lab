# PowerSpec G913 Environment Inventory

AI Lab's primary Windows workstation for local language models and video generation. Verified November 9, 2026. The inventory distinguishes installed software, completed runs, and options still to test.

## Hardware and runtime

| Item | Observed |
|---|---|
| System | PowerSpec G913 |
| CPU | AMD Ryzen 9 9900X3D, 12 cores |
| GPU | NVIDIA GeForce RTX 5080, 16 GB VRAM (16,303 MiB reported by NVIDIA) |
| System RAM | Approximately 64 GB |
| Motherboard | MSI MAG X870E TOMAHAWK WIFI (MS-7E59) |
| OS | Windows 11 26H2, build 26300.9818 |
| NVIDIA driver | 621.14 |
| Comfy | Comfy Desktop 1.1.9, ComfyUI 0.44.2, PyTorch 2.12.1+cu130 |

## Local language models

Ollama and LM Studio are installed. The following model files or manifests were present at inspection.

| Runtime | Models on disk |
|---|---|
| Ollama | `gpt-oss:20b`, `huihui_ai/qwen3.5-abliterated:9b`, `huihui_ai/gemma-4-abliterated:12b` |
| LM Studio | `mradermacher/Qwen3-14B-Base-GGUF`, Q6_K |

Inference speed, usable context, GPU offload, and remote API availability remain unmeasured. The LM Studio GGUF is a text model. Wan video generation runs separately in ComfyUI.

## Local video generation

**Verified workflow:** `Wan2.2-T2V-14B-FP8-Lightning-640`, saved as a separate ComfyUI workflow. The original Wan 2.2 14B text-to-video workflow was preserved.

- Installed assets include both Wan 2.2 T2V A14B FP8 scaled experts, the matching high- and low-noise LightX2V v1.1 four-step LoRAs, the UMT5 XXL FP8 text encoder, and the Wan 2.1 VAE.
- The original graph showed both LoRA filenames, but its Turbo switch was off. The logs showed zero patches and 10 steps per expert. Enabling Turbo in the copy selected both LoRAs and four steps total, split two per expert. The logs recorded 400 patches for each expert.
- The copy kept the same FP8 weights, encoder, VAE, 640 × 640 resolution, and five-second setting. The template renders 81 frames at 16 fps with batch size 1.

### Measured render times

| Run | Settings | Time |
|---|---|---:|
| Original FP8 runs | Turbo off, 20 steps total | 561.35 s, 521.50 s |
| FP8 Lightning benchmark | Turbo on, 4 steps total | 64.13 s |
| FP8 Lightning revised dinosaur prompt | Turbo on, 4 steps total | 65.72 s |

These are ComfyUI job times on the PowerSpec. Resolution and duration match. Prompts and seeds varied, so the roughly eightfold difference is an observed comparison and does not isolate the effect of the LoRAs or step count. A separate interrupted render was excluded.

During the original run the GPU reported about 11.6 GiB of dedicated memory used at 99% utilization. During a later Lightning sample it reported about 12.8 GiB at 100%. These are snapshots. ComfyUI reported Dynamic VRAM enabled and staged each expert separately. Windows shared-memory usage and transfer traffic were unavailable.

### What the render tests showed

The first Lightning test used a blonde portrait prompt with a misspelled dinosaur subject and produced a woman. Putting the dinosaur's anatomy first and describing the blonde hair as a wig produced a recognizable dinosaur. The rendered design had horns and a frill even though the prompt specified a T. rex. The revised prompt is saved in the Lightning copy.

### Proposed uses and untested options

- **Short cartoon shots:** Try flat fills, clean outlines, a fixed camera, and one simple movement per shot. The cartoon style has been discussed but has no saved test render yet.
- **Long explainers:** Edit to narration. Generate selected character shots with Wan and assemble them with reusable illustrations, maps, charts, captions, and timed motion graphics. At the measured 65.72 seconds per clip, 20 generated shots would take about 22 minutes of rendering, before retries and editing.
- **Image-to-video:** Try a consistent cartoon reference image to anchor the character's appearance. Wan 2.2 TI2V 5B can reuse the existing UMT5 encoder and needs its own model and VAE. The 14B image-to-video variant uses its own expert pair. Neither workflow has been benchmarked on this PC.
- **GGUF:** The ComfyUI-GGUF loader and Wan GGUF weights were absent at inspection. QuantStack's Q5_K_M pair is about 10.8 GB per expert. File size alone does not establish a speed gain, and the loader uses a different memory path. No GGUF packages or models were installed or timed.

## How the two workstations fit together

The [MacBook inventory](MACBOOK-ENVIRONMENT.md) records an M5 Pro MacBook Pro with 24 GB of unified memory. Comfy Desktop supports Apple silicon. The PowerSpec is the verified Wan render machine for now. The MacBook is an option for editing and assembly, and its local video speed and compatibility with this exact FP8 workflow remain unmeasured. Compare the same model, prompt, resolution, frame count, and seed before drawing speed or quality conclusions.

## References

- [ComfyUI Wan 2.2 workflows](https://docs.comfy.org/tutorials/video/wan/wan2_2)
- [QuantStack Wan 2.2 T2V GGUF files](https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF)
- [ComfyUI-GGUF loader](https://github.com/city96/ComfyUI-GGUF/blob/main/nodes.py)
- [Comfy Desktop for macOS](https://docs.comfy.org/installation/desktop/macos)
