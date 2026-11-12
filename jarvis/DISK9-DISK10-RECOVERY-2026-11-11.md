# Jarvis — Disk 9 / Disk 10 recovery checkpoint (2026-11-11)

**Status:** Selected Disk 9 media copy **COMPLETE** per supplied Jarvis job status, **239/239 SHA-256 verification receipts**. Array redundancy **not restored**.  
**Time basis:** America/Chicago (CST, UTC−06:00).  
**Provenance:** [Sean] supplied diagnostics, terminal results, selection decisions, and final status in a November 11 handoff; [ChatGPT] documented them. This is **not** an independent live server audit. Later disk health, changes, or cleanup were not checked.

## Outcome and scope

- Job started **2026-11-11 16:07:21 CST**, completed **22:31:57 CST**; elapsed **6:24:36** including copying and verification.
- Plan ID: `disk9-selected-050788d64889`.
- Source `/mnt/disk9/media` → destination `/mnt/disk17/media`, maintaining relative paths.
- Approved selection: **239 regular files**, **486,626,133,547 bytes (453.2059 GiB)**, from **19 TV groups and 11 movie groups**. Only unmatched files explicitly included in the manifest were selected; selection did **not** mean copying entire series/movie libraries.
- Manifest SHA-256: `050788d64889771a81133f0df2e22380fcc40686ec62c31184ea10ab1b49e651`.
- Launch preflight checked source and target identities, reported **zero pre-existing selected destination paths** and **2,124.10 GiB** free on Disk 17.
- Final saved state **COMPLETE**, inactive worker lock, **239/239** verification receipts, final event `verified=239 copied_this_attempt=239 existing_this_attempt=0 reverified_this_attempt=0`. All original source files were retained.
- The last verified file was an episode of *UFO (1970)*. Its supplied SHA-256: `f656998c9d7dd28803c1f4f89f9947e076695e10309a5fe51257da6850e1cf9f`.
- Job status and final event support reporting that all 239 selected copies were source/destination SHA-256 verified. **The 239 receipt files were not individually reopened and audited in the preparing conversation.** No actual power-loss resumption test was observed.

This is a **selected-file preservation checkpoint within the same degraded array**, not an independent backup, a drive rebuild, a parity repair, or proof of complete media-library recovery. No independent off-array backup or application playback test was verified.

## Storage condition and diagnostic interpretation

At the last supplied storage assessment, **two 8 TB data slots (Disk 9 and Disk 10) were disabled and emulated** under Unraid's dual-parity arrangement. **Disk 10 is a data disk, not Parity 2.** The two disabled disks exhaust the array's nominal two-disk failure tolerance; emulated readability does not make the disabled physical drives trustworthy.

| Component | Supplied evidence and interpretation |
| --- | --- |
| Disk 9 | Seagate 8 TB data disk; 8 pending and 8 offline-uncorrectable sectors; recorded read failure and repeated short-test failure at the same LBA. SMART overall PASSED does **not** negate these findings. **Replacement candidate.** |
| Disk 10 | Seagate 8 TB data disk; zero pending, reallocated, and offline-uncorrectable sectors in reported SMART data; historical timeouts and device-statistics uncorrectable errors. Disablement cause **not established**. Investigate drive, connections, power, and controller; do not assume it is healthy. |
| Parity drives | Two 14 TB WDC parity disks. First parity disk's historical CRC counter read 525 twice with no observed increase between checks; no long-term trend established. |
| Destination | Disk 17, 8 TB WDC data disk, logical path `/mnt/disk17`. |
| Controller | LSI 9211-8i SAS2008 and HPE SAS expander. Disk 9/10 were observed on expander PHY 9/10; this does **not** prove they share a physical cable or establish a specific bad connector. |

Historical `/dev/sdX` letters can change. For any later physical recovery, verify **slot, drive serial, and current assignments** anew. No restart, re-enable, rebuild, corrective parity check, formatting, or removal of original data occurred as part of this documented copy.

## Earlier read-only comparisons

Before the selected media copy, read-only `rsync` checksum comparisons against corresponding files on Disk 17 reported:

| Emulated source | Comparison outcome |
| --- | --- |
| Disk 9 `personal` (~686 KB), `backups` (~18 GiB), `media/software` (~1.6 MB), `media/games` (~155 GiB) | Corresponding paths matched; exit 0 for each. Games comparison took **74m 48s** (14:02:02–15:16:50 CST). |
| Disk 10 `personal` (~21 KB) | Corresponding files matched except a missing `.DS_Store` metadata path on destination. |
| Disk 10 `backups` (~19 GiB) | Corresponding files matched except **two recent analytics backup files** absent from Disk 17 (dated November 10 and 11). Their existence elsewhere has not been excluded. |

These comparisons were not separate SHA-256 manifests. They establish matching contents of corresponding files tested, not full application restore, independent backup coverage, or all-data preservation. Disk 10 media was **not comprehensively inventoried/verified**.

A read-only path-and-size inventory found approximately **1,514 unmatched regular files / 4,109.69 GiB** across Disk 9 movies and TV compared with healthy array media roots. That inventory was **not** checksum verification; renamed/relocated duplicates could be counted as unmatched. The approved 239-file selection is much smaller than that inventory. Unselected data, questionable tiny movie-named files, artwork-only/subtitle-only groups, and Disk 9 `.Trash-99` were left untouched. Recommendations about retention were judgment calls, **not verified availability checks** with media indexers.

## Recovery package and audit artifacts

Working package on Jarvis: `/mnt/user/downloads/jarvis-selected-media-recovery/`.

Package components: `recover.sh`, `manifest.tsv`, `selection.txt`, `README.txt`, `validation.txt`, `SHA256SUMS.txt`. The executable script and manifest **are not embedded here**: obtain the actual package and verify its SHA-256/integrity before attempting to use it. The manifest/plan ID did not change when the quoted-INI-header parser was fixed. The original parser stopped at preflight **without copying**; corrected script passed preflight and completed the current run.

Persistent logs: `/mnt/user/downloads/jarvis-selected-media-recovery/logs/disk9-selected-050788d64889/`.

- `state.txt`: saved state and file index.
- `events.tsv`: timestamped per-file phases/results.
- `verified/NNNN.tsv`: atomic per-file SHA-256 verification receipts.
- `console.log`: worker output / preflight messages.
- `copy-logs/`: per-attempt rsync output.
- `errors.log`: errors, if any.

**Read-only status command** (only after confirming server identity and current mount context):

```bash
bash /mnt/user/downloads/jarvis-selected-media-recovery/recover.sh status
```

**Do not run `start` to repeat this completed job.** No auto-boot task was installed; historical worker PID is not a live process indicator. The script uses a guarded background worker, destination identity/free-space preflight with a 20 GiB reserve, per-file staged rsync transfers, source/destination SHA-256 checks, retained sources, existing-destination non-overwrite behavior, and resumable receipts. A power-loss restart has **not** been tested on the actual server. Local preparation included syntax checks and 15 simulated flow tests; actual native rsync was not exercised in preparation, but the native 239-file run later reported completion on Jarvis.

Preserve the **original package, manifest, and complete receipts/logs** in a separately secured location **outside Jarvis**. Do not upload raw diagnostics, private file listings, credentials, personal backups, or the entire package to this public repository without review.

## Services and boundaries

Sonarr/Radarr use logical user-share library roots; retaining original relative paths means the copied media should remain addressable under the same logical paths. This has not been established by individual playback/import tests. No Docker restarts, library reimports, changed roots, model changes, or MCP adjustments were made. The separate AI service review yielded no justified Docker changes; sampled host health was not a sustained stress test.

## Next decisions (not authorized actions)

1. **Secure independent backups** of irreplaceable data and an off-server copy of this run's package/logs. Copies on Disk 17 remain vulnerable to failure of the same degraded array.
2. **Reconcile Disk 10**: locate/preserve the two unresolved recent analytics backup files, inventory required Disk 10 media, and assess what remains without a verified safe copy.
3. **Protect all other source data** including Disk 9 unselected content and `.Trash-99`; no deletions or cleanup were authorized.
4. **Diagnose hardware before repair**: recheck current diagnostics and physical assignments, evaluate Disk 10 failure causes/connection path and Disk 9 replacement. Plan an evidence-based recovery/rebuild sequence separately; do not treat this document as permission to perform one.
5. Confirm later array/SMART status, media readability, and external backup integrity from fresh evidence. The **2026-11-11 22:31:57 CST** receipt is historical, not continuous monitoring.

## Reference context

- [Jarvis Qwen3 MoE runbook](QWEN3-MOE-OFFLOADING.md) — existing AI deployment, intentionally unchanged during recovery.
- [Private shared-mind Jarvis inventory](https://github.com/SeanEricKnight/shared-mind/blob/main/projects/jarvis/README.md) — older November 9 baseline.
- [Unraid: replacing disks in array](https://docs.unraid.net/unraid-os/using-unraid-to/manage-storage/array/replacing-disks-in-array/)
- [Unraid: shares](https://docs.unraid.net/unraid-os/using-unraid-to/manage-storage/shares/)
- [rsync manual](https://download.samba.org/pub/rsync/rsync.1)

**Evidence boundaries:** This report is based on the November 11 handoff's reported command results and completion state, not fresh authenticated inspection of Jarvis. Original diagnostics, detailed title inventories, and script/package bytes were not supplied to this GitHub-editing session.
