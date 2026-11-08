#!/bin/bash
# Read-only MacBook inventory for AI Lab. No installs, no changes, no sudo.
# Omits serial numbers, MAC addresses, IPs, hostnames, env vars. Output: ~/code/mac-inventory-output.txt
OUT="$HOME/code/mac-inventory-output.txt"
v(){ if command -v "$1" >/dev/null 2>&1; then echo "$1: $("$@" 2>&1 | head -1)"; else echo "$1: not found"; fi; }
{
echo "## Hardware"
sw_vers
system_profiler SPHardwareDataType 2>/dev/null | grep -E "Model Name|Model Identifier|Chip|Total Number of Cores|Memory:"
system_profiler SPDisplaysDataType 2>/dev/null | grep -E "Chipset Model|Total Number of Cores|Metal"
sysctl -n hw.memsize hw.perflevel0.physicalcpu hw.perflevel1.physicalcpu iogpu.wired_limit_mb 2>&1
echo "## Storage"
diskutil info / 2>/dev/null | grep -E "File System Personality|Container Total Space|Container Free Space|Solid State"
df -h / | tail -1
echo "## Network interface types (no addresses)"
networksetup -listallhardwareports 2>/dev/null | grep "Hardware Port"
system_profiler SPAirPortDataType 2>/dev/null | grep -E "PHY Mode" | sort -u
echo "## Tools"
for c in "brew --version" "python3 --version" "uv --version" "pyenv --version" "conda --version" "node --version" "npm --version" "git --version" "gh --version" "claude --version" "codex --version" "gemini --version" "ollama --version" "lms version" "llama-cli --version" "mlx_lm.generate --help" "docker --version" "podman --version" "code --version" "ssh -V"; do set -- $c; echo "$1: $(command -v $1 >/dev/null 2>&1 && $c 2>&1 | head -1 || echo not found)"; done
ls /Applications | grep -i -E "docker|lm studio|ollama|visual studio|cursor|xcode|orbstack|claude|chatgpt|codex|draw things|comfy|diffusion"
echo "## Ollama"
ollama list 2>&1; ollama ps 2>&1
echo "## Endpoints"
echo "ollama 11434: $(curl -s -m 2 http://127.0.0.1:11434/api/version || echo down)"
echo "lmstudio 1234: $(curl -s -m 2 -o /dev/null -w '%{http_code}' http://127.0.0.1:1234/v1/models || echo down)"
echo "## SSH hosts (names only) and TCP/22 reachability"
for h in $(grep -i -E '^\s*Host\s' ~/.ssh/config 2>/dev/null | awk '{for(i=2;i<=NF;i++)print $i}' | grep -v '[*?]'); do
  t=$(ssh -G "$h" 2>/dev/null | awk '/^hostname /{print $2}'); p=$(ssh -G "$h" 2>/dev/null | awk '/^port /{print $2}')
  if nc -z -G 2 "$t" "${p:-22}" >/dev/null 2>&1; then echo "$h: reachable"; else echo "$h: unreachable"; fi
done
echo "## Git repos under ~/code, ~/Documents/Codex (paths + branch)"
find ~/code ~/Documents/Codex -maxdepth 3 -name .git -type d 2>/dev/null | sed 's#/.git$##' | while read d; do echo "$d [$(git -C "$d" branch --show-current 2>/dev/null)]"; done
} > "$OUT" 2>&1
echo "Done. Wrote $OUT"
