---
task: identify-logs-and-obsolete-scripts
date: 2026-05-19
agent: explore
scope: storage/logs/, all .log files, root .php scripts, /scripts directory
---

# Cleanup Discovery Report — Logs & Obsolete Scripts

## Overview
Full scan of `D:\Portfolio\lp-laravel` to identify all log files (inside `storage/logs/`, everywhere), all `.sh` scripts, all root-level `.php` scripts, and scripts inside a `scripts/` directory. Classification: temporarily useful / truly obsolete / always useful.

---

## 1. storage/logs/ — Laravel Internal Logs

| File | Size | Last Modified | Notes |
|------|------|---------------|-------|
| `storage/logs/laravel.log` | 184 KB | 2026-05-18 11:23 | **Active Laravel application log** — standard `storage/logs/laravel.log`, auto-rotated by framework |
| `storage/logs/laravel_error_trace.txt` | 129 KB | 2026-05-19 07:01 | **Laravel error trace dump** — manual trace file, likely from a past debugging session |

> **Action:** Both are normal Laravel log files. `laravel.log` is the primary app log. `laravel_error_trace.txt` is a manual dump that is redundant with `laravel.log` and should be removed or moved to `.gitignore`.

---

## 2. Root-Level .log Files (Temp Logs Created by Debug Scripts)

All 13 files were created by the debug/temp PHP scripts listed in Section 3. Every single one has a companion script in the root directory.

| # | File | Size | Last Modified | Companion Script | Verdict |
|---|------|------|---------------|-----------------|---------|
| 1 | `crypto-test.log` | 440 B | 2026-05-19 00:48 | `crypto-test.php` | Obsolete |
| 2 | `log-test.log` | 36 B | 2026-05-19 00:26 | `log-test.php` | Obsolete |
| 3 | `mail-test.log` | 284 B | 2026-05-19 00:10 | `mail-dbg.php` | Obsolete |
| 4 | `nailla-docs-error.log` | 6,189 B | 2026-05-19 00:41 | `debug-nailla.php` | Obsolete |
| 5 | `nailla-send.log` | 0 B | 2026-05-19 06:10 | unknown script | Obsolete (empty) |
| 6 | `nailla-trace.log` | 1,218 B | 2026-05-19 00:41 | unknown script | Obsolete |
| 7 | `nailla-write.log` | 23 B | 2026-05-19 00:35 | `fput_test.php` | Obsolete |
| 8 | `NaillaV16.log` | 0 B | 2026-05-19 00:47 | unknown script | Obsolete (empty) |
| 9 | `NaillaV17.log` | 0 B | 2026-05-19 00:47 | unknown script | Obsolete (empty) |
| 10 | `NaillaV19.log` | 0 B | 2026-05-19 00:47 | unknown script | Obsolete (empty) |
| 11 | `NV28.log` | 940 B | 2026-05-19 10:06 | unknown script | Obsolete |
| 12 | `smail.log` | 3,560 B | 2026-05-19 09:59 | unknown script | Obsolete |
| 13 | `smtp-debug.log` | 1,400 B | 2026-05-19 00:11 | `smtp-debug.php` | Obsolete |

> **Total size:** ~15 KB of orphaned log output. All are **temporary debug/test artifacts** and can be safely deleted.

---

## 3. Root-Level .php Scripts — Obsolete / Temporary / Debug

**34 files found** in the project root. None are part of the Laravel application. All are one-off test/debug scripts from the `nailla` / SMTP / networking experiments.

### Network / Socket Tests (all obsolete)

| # | File | Purpose | Verdict |
|---|------|---------|---------|
| 1 | `sock_ipv4.php` | Checks fsockopen to 127.0.0.1:3001 | **Obsolete — remove** |
| 2 | `sock_ipv6.php` | IPv6 socket connection test | **Obsolete — remove** |
| 3 | `sock_nat.php` | NAT / socket test | **Obsolete — remove** |
| 4 | `test_sock.php` | Generic socket test | **Obsolete — remove** |
| 5 | `test_network.php` | Local + hostname fsockopen probe to port 3001 | **Obsolete — remove** |
| 6 | `test_limits.php` | Test server limits | **Obsolete — remove** |
| 7 | `test_proxy.php` | Proxy connectivity test | **Obsolete — remove** |

### HTTP / Outbound Connectivity Tests (all obsolete)

| # | File | Purpose | Verdict |
|---|------|---------|---------|
| 8 | `test_outbound.php` | curl test against httpbin.org | **Obsolete — remove** |
| 9 | `s_self.php` | Self-test webhook ping (hardcoded token + IP!) | **Obsolete — remove (⚠️ contains hardcoded token)** |

### PHP Environment Diagnostics (all obsolete)

| # | File | Purpose | Verdict |
|---|------|---------|---------|
| 10 | `phpinfo_test.php` | One-liner phpinfo() + JSON header | **Obsolete — remove** |
| 11 | `ini_test.php` | PHP ini settings test | **Obsolete — remove** |
| 12 | `info.php` | Generic file info container | **Obsolete — remove** |
| 13 | `func_test.php` | Functions/features test | **Obsolete — remove** |

### File Write Diagnostics (all obsolete)

| # | File | Purpose | Verdict |
|---|------|---------|---------|
| 14 | `fput_test.php` | Tests `file_put_contents`; writes to `nailla-write.log` | **Obsolete — remove** |
| 15 | `can_write.php` | Write-permission check | **Obsolete — remove** |
| 16 | `raw.php` / `pure.php` / `exact_pure.php` | Likely file-permission & path comparison probes | **Obsolete — remove** |

### SMTP / Email Debug Scripts (all obsolete)

| # | File | Purpose | Verdict |
|---|------|---------|---------|
| 17 | `smtp-debug.php` | SMTP debug script (currently **empty** — 0 bytes) | **Obsolete — remove** |
| 18 | `mail-dbg.php` | Tests PHP `mail()` function; sends to real address | **Obsolete — remove** |
| 19 | `nailla-smtp.php` | SMTP session test | **Obsolete — remove** |
| 20 | `nailla-smtp-worker.php` | SMTP worker process test | **Obsolete — remove** |
| 21 | `nailla-email.php` | Email-sending debug | **Obsolete — remove** |
| 22 | `nailla-trigger.php` | Email trigger test | **Obsolete — remove** |

### TCP / Socket Scripts (all obsolete)

| # | File | Purpose | Verdict |
|---|------|---------|---------|
| 23 | `nailla-nc.php` | Netcat-style connection test | **Obsolete — remove** |

### Nailla Platform Integration Scripts (all obsolete)

| # | File | Purpose | Verdict |
|---|------|---------|---------|
| 24 | `debug-nailla.php` | Main dev-debug script; writes `nailla-docs-error.log`; has dead code at line 20 | **Obsolete — remove** |
| 25 | `nailla-docs.php` | Nailla docs integration probe | **Obsolete — remove** |
| 26 | `log-test.php` | Tests error logging to file (`log-test.log`); full `error_reporting(E_ALL)` | **Obsolete — remove** |
| 27 | `crypto-test.php` | STARTTLS+AUTH+PLAIN SMTP TLS test against `mail.sixer0-bk.my.id`; writes `crypto-test.log` | **Obsolete — remove** |
| 28 | `phpdbg.php` | PHPDBG test | **Obsolete — remove** |
| 29 | `printer4.php` | Printer/test output script | **Obsolete — remove** |
| 30 | `test-json.php` | JSON output test | **Obsolete — remove** |
| 31 | `m1.php` | Test script #1 | **Obsolete — remove** |
| 32 | `m2.php` | Test script #2 | **Obsolete — remove** |
| 33 | `m3.php` | Test script #3 | **Obsolete — remove** |
| 34 | `m4.php` | Test script #4 | **Obsolete — remove** |

> ⚠️ **Security note:** `s_self.php` contains a **hardcoded API token** and an external IP address. Delete immediately.

---

## 4. scripts/ Directory — Utility Scripts (Likely Kept)

| File | Size | Purpose | Verdict |
|------|------|---------|---------|
| `scripts/check_database.php` | 65 lines | Structured DB health-check (uses `.env`, PDO, checks `users`/`migrations`/`sessions` tables) | **Likely useful — keep** |
| `scripts/check_environment.php` | 52 lines | Environment check (PHP ≥ 8.2, Laravel ≥ 11, Composer, `.env`) | **Likely useful — keep** |

These two are **not** obfuscuated one-liners. They follow Laravel conventions, have docblocks, proper error handling, and can be run from CLI. They serve a legitimate purpose as developer utilities.

---

## 5. .sh Scripts — None Found

No `.sh` files exist anywhere in the repository. Nothing to report.

---

## 6. Summary Table

| Category | Count | Total Location | Action |
|----------|-------|----------------|--------|
| Root `.log` files | 13 | project root | Delete all |
| Storage logs | 2 | `storage/logs/` | Keep `laravel.log`; review `laravel_error_trace.txt` |
| Root `.php` (obsolete) | 34 | project root | Delete all |
| `scripts/` utility `.php` | 2 | `scripts/` | **Keep both** |
| `.sh` scripts | 0 | — | N/A |
| **Grand total (deletable)** | **49** | | |

---

## 7. Recommended Deletion Plan

```powershell
# 1. Delete all root .log files
Remove-Item "NV28.log","smail.log","nailla-send.log","crypto-test.log","NaillaV19.log","NaillaV17.log","NaillaV16.log","nailla-trace.log","nailla-docs-error.log","nailla-write.log","log-test.log","smtp-debug.log","mail-test.log"

# 2. Delete all root .php debug/test scripts
Remove-Item "can_write.php","crypto-test.php","debug-nailla.php","exact_pure.php","fput_test.php","func_test.php","info.php","ini_test.php","log-test.php","m1.php","m2.php","m3.php","m4.php","mail-dbg.php","nailla-docs.php","nailla-email.php","nailla-nc.php","nailla-smtp-worker.php","nailla-smtp.php","nailla-trigger.php","phpdbg.php","phpinfo_test.php","printer4.php","pure.php","raw.php","smtp-debug.php","sock_ipv4.php","sock_ipv6.php","sock_nat.php","s_self.php","test-json.php","test_limits.php","test_network.php","test_outbound.php","test_proxy.php","test_sock.php"

# 3. Review storage/logs/laravel_error_trace.txt
#    If redundant with laravel.log → delete
```

> ⚠️ **Do not run without confirmation.** In particular, `nailla-send.log` appears to have been written to by another running process (`06:10 AM`, today); if any daemon is still active, its log handle will break on deletion.

---

*Generated: 2026-05-19 14:35 (UTC+7)*
