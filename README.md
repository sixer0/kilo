# Kilo Code - AI Model Configuration

# ==========================================================
# KONFIGURASI MODEL AI UNTUK KILO CODE
# ==========================================================

## Model yang Tersedia (Qwen 3.5)

| Model | Ukuran | Status | Direkomendasikan |
|-------|--------|--------|------------------|
| qwen3.5:4b | 4GB | ✅ Tersedia | ✅ Ya |
| qwen3.5:9b | 7-10GB | ✅ Tersedia | ✅ Ya |
| gemma4:latest | 9.6GB | ✅ Tersedia | ❌ Tidak |

## Konfigurasi Aktif

**Provider:** Ollama (local)  
**Model:** qwen3.5:4b  
**Base URL:** http://localhost:11434  
**Parameters:**  
- Temperature: 0.7  
- Max Tokens: 4096  

## Verifikasi Setup

### 1. Cek Ollama Running
```bash
# Jalankan Ollama jika belum running
ollama serve
```

### 2. Cek Model Tersedia
```bash
ollama list
# Output harus menampilkan: qwen3.5:4b
```

### 3. Test Koneksi
```bash
curl http://localhost:11434/api/tags
# Harus menampilkan daftar model
```

### 4. Test Chat dengan Ollama
```bash
ollama run qwen3.5:4b
```

## Setup Model Baru (Jika Diperlukan)

### Download Qwen 3.5 4B
```bash
ollama pull qwen3.5:4b
```

### Download Qwen 3.5 9B (lebih besar)
```bash
ollama pull qwen3.5:9b
```

### Download Model Lain
```bash
ollama pull <model-name>
```

## File Konfigurasi

| File | Deskripsi |
|------|-----------|
| `models.json` | Konfigurasi model provider |
| `provider-config.yaml` | Konfigurasi provider lengkap |
| `agent/trading/user-config.yaml` | Konfigurasi utama dengan AI section |

## Troubleshooting

### Model Tidak Terdeteksi
- Pastikan Ollama sudah running: `ollama list`
- Jika belum, jalankan Ollama
- Update konfigurasi model

### Koneksi Gagal
- Pastikan Ollama running di `http://localhost:11434`
- Cek firewall/antivirus tidak block port 11434

### Performance Lemah
- Coba model yang lebih kecil (4B vs 9B)
- Tambah RAM untuk model besar
- Sesuaikan `max_tokens` dan `temperature`

## Kontak & Dokumentasi

- Dokumentasi Ollama: https://ollama.ai
- Dokumentasi Qwen: https://ollama.ai/library/qwen
