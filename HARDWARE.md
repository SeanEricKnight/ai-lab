# AI Lab Hardware

## PowerSpec G913

Primary AI development and local-LLM workstation.

- AMD Ryzen 9 9900X3D
- NVIDIA GeForce RTX 5080
- Runs local LLMs and primary AI development workloads

## MacBook

Portable AI Lab workstation. Verified 2026-11-08. Full inventory: [MACBOOK-ENVIRONMENT.md](MACBOOK-ENVIRONMENT.md).

- MacBook Pro (`Mac17,8`), Apple M5 Pro: 18 CPU cores (6 Super + 12 Performance), 20 GPU cores, Metal 4
- 24 GB unified memory
- ~1 TB SSD, APFS
- macOS 27.2 (26B123)
- Local models via Ollama and LM Studio (llama.cpp and MLX runtimes)

## JARVIS

Unraid-based lab infrastructure.

Primary roles:

- Storage
- Linux testing
- Docker workloads
- Infrastructure experimentation
- Supporting services for AI Lab

Known platform details from the founding-day diagnostics:

- AMD Ryzen Threadripper 2950X (16 cores)
- 64 GiB DDR4
- 154 TB array capacity at the time of the founding-day snapshot

JARVIS is part of the lab, but it is not the primary local-LLM inference machine.
