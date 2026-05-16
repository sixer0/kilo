# OpenClaw Configuration

Repository untuk menyimpan semua konfigurasi OpenClaw yang sudah dikustomisasi.

## 📁 Struktur Repository

```
├── AGENTS.md                   # Panduan workspace dan aturan
├── SOUL.md                     # Identitas dan kepribadian agent
├── USER.md                     # Informasi tentang pengguna
├── MEMORY.md                   # Memori jangka panjang
├── IDENTITY.md                 # Konfigurasi identitas
├── TOOLS.md                    # Daftar tools dan environment
├── HEARTBEAT.md                # Checklist heartbeat
├── .gitignore                  # File yang di-ignore
│
├── agents/                     # Definisi agent kustom
│   ├── nailla-cs.yaml         # Agent customer service Nailla
│   └── sixerbot-cs.yaml       # Agent customer service SixerBot
│
├── memory/                     # Sistem memori
│   ├── refs/                  # Referensi mendalam
│   │   ├── nailla-agent-setup.md
│   │   ├── office-utils.md
│   │   └── onedrive-excel-workflow.md
│   └── tasks/                 # Log tugas harian
│
├── scripts/                    # Utility scripts
│   ├── office_utils.py        # Manipulasi xlsx/docx/pptx/pdf
│   ├── chat-widget.js         # Frontend chat widget
│   ├── nailla-api.php         # Backend API untuk Nailla
│   └── setup-nailla-agent.js  # Setup script Nailla agent
│
├── skills/                     # Custom skills
│   └── ms365/                # Microsoft 365 integration
│
└── .clawhub/                   # Lock file ClawHub
```

## 🚀 Setup

1. Clone repository ini
2. Konfigurasi OpenClaw di `/root/.openclaw/openclaw.json`
3. Sesuaikan file konfigurasi sesuai kebutuhan

## 📦 Skills yang Tersedia

### Microsoft 365
```bash
cd skills/ms365
openclaw plugins install .
```

## 🔒 Keamanan

⚠️ **JANGAN** commit file dengan token sensitif.
Gunakan `.gitignore` untuk melindungi konfigurasi rahasia.

## 📝 Changelog

Lihat [CHANGELOG.md](CHANGELOG.md) untuk riwayat perubahan.