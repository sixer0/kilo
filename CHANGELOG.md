# Changelog

Semua perubahan penting pada repository ini akan didokumentasikan di file ini.

Format: [Keep a Changelog](https://keepachangelog.com/id-ID/)

## [2026-05-15]

### Ditambahkan
- **Agent Nailla CS** (`agents/nailla-cs.yaml`) - Agent customer service untuk portfolio Sixer0
  - Personality: Perempuan, usia 23 tahun, ramah dan professional
  - Aturan: No pricing, no detailed tech tutorials, escalation untuk hiring interest
- **Agent SixerBot CS** (`agents/sixerbot-cs.yaml`) - Agent customer service alternatif
- **Memory System** (`memory/refs/`, `memory/tasks/`) - Sistem dokumentasi terstruktur
  - `nailla-agent-setup.md` - Panduan setup agent Nailla
  - `office-utils.md` - Dokumentasi office utilities
  - `onedrive-excel-workflow.md` - Workflow Excel dengan OneDrive
- **Scripts**
  - `office_utils.py` - Manipulasi file xlsx/docx/pptx/pdf + chart generation
  - `chat-widget.js` - Frontend chat widget untuk website
  - `nailla-api.php` - Backend API untuk routing pesan
  - `setup-nailla-agent.js` - Script setup agent
- **Skills**
  - `skills/ms365/` - Microsoft 365 integration skill (updated)
- **Documentation**
  - `AGENTS.md` - Panduan workspace
  - `SOUL.md` - Identitas agent
  - `USER.md` - Informasi pengguna
  - `IDENTITY.md` - Konfigurasi identitas
  - `TOOLS.md` - Environment dan tools
  - `MEMORY.md` - Memori jangka panjang
  - `HEARTBEAT.md` - Checklist heartbeat

### Diubah
- Struktur repository diorganisir lebih terstruktur
- `.gitignore` diperbarui untuk mengecualikan:
  - `openclaw-config/` (repo terpisah untuk config rahasia)
  - `__pycache__/`, `*.pyc` (Python cache)

### Dihapus
- Struktur lama `workspace-backup/` digantikan dengan struktur langsung di root

## Repository Info

- **Nama**: myagent-config
- **Pemilik**: sixer0
- **Tujuan**: Menyimpan konfigurasi OpenClaw yang dikustomisasi