# Jarvis — Disk 9 / Disk 10 retirement checkpoint (2026-11-18)

**Status:** Copy of all unmatched Disk 9 and Disk 10 media **IN PROGRESS** (started 2026-11-18 ~12:51 CST). Disks 9 and 10 are **still disabled/emulated**. Nothing deleted, removed, rebuilt, or re-enabled.
**Time basis:** America/Chicago (CST, UTC−06:00).
**Provenance:** [Sean] directed the work; [Claude] observed JARVIS (Unraid 7.4.0, `192.168.4.250`) live through the Unraid WebGUI and web terminal. Follows [the Nov 11 recovery checkpoint](DISK9-DISK10-RECOVERY-2026-11-11.md).

## Observed state (live, 2026-11-18)

- Array started, 20 devices, 77.2 TB used of 154 TB. Server uptime was 8 hours (rebooted earlier the same day); Disk 9 and Disk 10 stayed disabled (red X) and emulated. All other disks showed 0 errors.
- Disk 10 holds `backups`, `media`, `personal`, `.Trash-99`. Emulated usage: Disk 9 4.35 TB, Disk 10 4.44 TB.

## Done today

1. **Disk 10 analytics backups preserved.** `youtube-2026-11-10.sqlite3.gz` and `youtube-2026-11-11.sqlite3.gz` existed only on Disk 10. Copied with `cp -n` to `/mnt/disk4/backups/christianity-apparently-analytics/daily/`; SHA-256 of source and copy matched for both. Originals retained.
2. **Disk 10 media inventory** (path + size vs. every array disk except 9 and 10, read-only): 892 files, **770 unmatched, 3,967.6 GiB**. Path/size matching can overcount (renamed or moved copies).
3. **Disk 9 media inventory**, same method: 16,282 files, **1,232 unmatched, 3,083.1 GiB** (after the Nov 11 copy of 239 files).

## In progress

Background job on JARVIS (`nohup setsid`, sequential), rsync `-a --partial --files-from` the unmatched lists, **no source deletion**:

| Step | Source → destination | Files | Size |
| --- | --- | --- | --- |
| 1 | Disk 9 → Disk 13 | 1,232 | 3,083 GiB |
| 2 | Disk 10 → Disk 15 | 770 | 3,967 GiB |

Each copy is followed by a checksum dry-run (`rsync -rnc --itemize-changes`) written to `verifyN.log`; an empty log means every file matched. Working directory on JARVIS: `/mnt/user/downloads/jarvis-disk9-10-move/` (`status.log`, `rsyncN.log`, `verifyN.log`, `listN.txt`, `dN-unmatched.tsv`). `status.log` ends with `ALLDONE` when finished. Disk 13 and Disk 15 each had 4.8 TB free before the job. ETA is likely days (emulated reads through dual parity).

## Risks

- Both disks are emulated, so every read depends on all other array disks. A read error elsewhere during the long copy could cause data loss on both emulated disks.
- A reboot stops the job; re-running the same rsync resumes it.
- Not re-checked today: Disk 10 `personal`; Disk 9 `personal`, `backups`, `games`, `software` (Nov 11 comparisons matched Disk 17); `.Trash-99` on both (left untouched).

## Before retiring the disks

1. `status.log` shows `ALLDONE`; `verify9.log` and `verify10.log` are empty.
2. Re-run the unmatched inventory; remaining unmatched files are understood.
3. Off-JARVIS copy of the Nov 11 recovery package/logs and this job's logs.
4. Fresh array and SMART status. Plan removal/parity handling separately; this document does not authorize it.
