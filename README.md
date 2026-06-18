# Kilo/Open Code Configuration

Workspace ini berisi konfigurasi Kilo/Open Code untuk menjalankan agen AI, skill kustom, perintah khusus, dan dokumentasi kerja.

## Ringkasan Project

- **Nama:** Kilo/Open Code Configuration
- **Tujuan:** Menyimpan konfigurasi global, prompt agen, skill, perintah, memory, dan dokumentasi teknis.
- **Dependencies:** `@kilocode/plugin` dan `jest` untuk testing dasar.
- **Model utama:** `kilo/nex-agi/nex-n2-pro:free`
- **Model kecil/fallback:** `kilo/stepfun/step-3.7-flash:free`

## Struktur Direktori

```text
.
├── AGENTS.md                         # Aturan workspace, memory, permissions, dan dokumentasi
├── SOUL.md                           # Kepribadian dan prinsip agent
├── MEMORY.md                         # Indeks memory global
├── IDENTITY.md                       # Identitas agent: Lunne, Oracle
├── HEARTBEAT.md                      # Catatan heartbeat
├── kilo.jsonc                        # Konfigurasi utama Kilo: model, permissions, agents, skills
├── package.json                      # Dependencies npm
│
├── agent/                            # Prompt agen kustom
│   ├── master-controller.md          # Orkestrator utama
│   ├── pm-controller.md              # Orkestrator PM/BA
│   ├── document-controller.md        # Orkestrator dokumen
│   ├── trading-controller.md         # Controller trading
│   ├── task-architect.md             # Perancang task blueprint
│   └── ...
│
├── command/                          # Perintah Kilo khusus
│   ├── plan.md                       # Perintah planning
│   ├── explore.md                    # Perintah eksplorasi codebase
│   ├── search-code.md                # Perintah pencarian kode
│   ├── explain.md                    # Perintah penjelasan kode
│   ├── refactor.md                   # Perintah refactor
│   ├── security.md                   # Perintah review keamanan
│   ├── test-gen.md                   # Perintah generate test
│   └── ...
│
├── docs/                             # Dokumentasi task dan hasil kerja
│   ├── 2026_06_11_upgrade-skill-list/
│   ├── 2026_06_12_upgrade-skill-list-tier2/
│   ├── 2026_06_12_upgrade-skill-list-tier3/
│   ├── 2026_06_12_map-skills-to-agents/
│   └── 2026_06_12_audit-skill-registration/
│
├── skills/                           # Skill kustom Kilo
│   ├── agent-md-refactor/
│   ├── canvas-design/
│   ├── content-research-writer/
│   ├── docx/
│   ├── image-enhancer/
│   ├── pdf/
│   ├── pptx/
│   ├── xlsx/
│   └── ...
│
├── output/                           # Output hasil kerja
│   ├── docs/
│   └── trading-agent/
│
└── test/                             # Test dasar
    ├── hello.js
    └── test_delegation_simulation.js
```

## Konfigurasi Utama

File utama: `kilo.jsonc`

### Model

| Setting | Value |
|---------|-------|
| `model` | `kilo/nex-agi/nex-n2-pro:free` |
| `small_model` | `kilo/stepfun/step-3.7-flash:free` |

### Permissions

Workspace ini mengizinkan operasi berikut:

- `read`, `glob`, `grep`, `list`
- `edit`
- `bash`
- `skill`
- `task`
- `websearch`, `webfetch`
- `codesearch`
- `todowrite`
- Puppeteer: `navigate`, `screenshot`, `click`, `fill`, `select`, `hover`, `evaluate`

### Agents

Kategori utama:

| Kategori | Agent |
|----------|-------|
| Primary controller | `master-controller`, `master-controller-free` |
| PM/BA | `pm-controller`, `pm-analyst`, `pm-planner`, `pm-verifier`, `pm-writer` |
| Development | `coder-execution`, `verifier`, `senior-code-reviewer`, `test-expert`, `security-review` |
| Infrastructure | `git-specialist`, `docker-specialist`, `database-specialist` |
| Dokumen | `document-controller`, `document-reader`, `document-writer`, `document-converter`, `document-reviewer`, `document-analyst` |
| Data | `data-analyst`, `data-collector`, `explore`, `task-architect`, `request-translator` |
| Image | `image-specialist`, `image-analyst` |
| Trading | `trading-controller`, `trading/demo-tester-agent`, `trading/portfolio-monitor-agent`, `trading/technical-analysis-agent` |
| Default | `ask`, `plan`, `debug`, `orchestrator`, `code` |

## Skill yang Terdaftar

Skill digunakan untuk memperluas kemampuan agen tanpa mengulang logika workflow di prompt.

### Orchestration

- `orchestrator-worker`
- `plan-and-execute`
- `checkpoint-resume`
- `self-healing-loop`
- `context-engineering`

### Development

- `reflection-loop`
- `dry-run-verify-fix`
- `eval-driven-improver`
- `skill-creator-kilo`
- `tool-design-optimizer`

### Safety

- `human-in-loop-gate`
- `security-review-gate`

### Domain/Utility

- `agent-md-refactor`
- `canvas-design`
- `content-research-writer`
- `docx`
- `image-enhancer`
- `mcp-integration`
- `pdf`
- `pptx`
- `xlsx`

## Memory System

Memory disimpan di `MEMORY.md` dan folder `memory/`.

```text
MEMORY.md              # Indeks utama
memory/
  YYYY-MM-DD.md        # Daily log
  refs/                # Referensi teknis mendalam
  tasks/               # Task report dan compaction snapshot
```

Gunakan `MEMORY.md` sebagai titik masuk untuk konteks project, pelajaran penting, dan status kerja lintas sesi.

## Perintah Khusus

Perintah tersedia di folder `command/`.

| Perintah | File |
|----------|------|
| Planning | `command/plan.md` |
| Explore codebase | `command/explore.md` |
| Search code | `command/search-code.md` |
| Explain code | `command/explain.md` |
| Refactor | `command/refactor.md` |
| Security review | `command/security.md` |
| Generate tests | `command/test-gen.md` |
| Git status | `command/git-status.md` |
| Git log | `command/git-log.md` |
| Dependencies | `command/deps.md` |
| Performance | `command/perf.md` |
| Rollback | `command/rollback.md` |
| Docs | `command/doc.md` |
| Quick review | `command/quick-review.md` |
| Trading | `command/trading.md` |

## Dokumentasi

Dokumentasi task disimpan di `docs/` dengan format folder:

```text
docs/
  YYYY_MM_DD_task_title/
    README.md
    analysis_result.md
    implementation_plan.md
    implementation_report.md
    mapping_matrix.md
    final_report.md
    status_tasks.md
```

Dokumentasi aktif yang sudah ada:

- `docs/2026_06_11_upgrade-skill-list/` — upgrade daftar skill awal.
- `docs/2026_06_12_upgrade-skill-list-tier2/` — upgrade skill tier 2.
- `docs/2026_06_12_upgrade-skill-list-tier3/` — upgrade skill tier 3.
- `docs/2026_06_12_map-skills-to-agents/` — mapping skill ke agent.
- `docs/2026_06_12_audit-skill-registration/` — audit dan refactor skill registration.

## Catatan Keamanan

- Jangan commit token, API key, credential, atau data sensitif.
- Gunakan `.gitignore` untuk melindungi konfigurasi rahasia.
- Untuk operasi destruktif seperti delete, uninstall, reset, atau akses eksternal, minta konfirmasi terlebih dahulu.
- Jika ada temuan keamanan kritis, hentikan eksekusi dan gunakan `security-review-gate`.

## Changelog

### 2026-06-18

- README diperbarui agar sesuai dengan workspace Kilo/Open Code saat ini.
- Mengganti isi lama tentang konfigurasi Ollama/Qwen dengan dokumentasi aktual `kilo.jsonc`, agent, command, skill, memory, dan docs.
