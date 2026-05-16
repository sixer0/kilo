---
task: project-analysis
date: 2026-05-16
agent: data-analyst
project: D:\Portfolio\lp-laravel
---

# Analisis Proyek: Landing Page Portfolio Laravel

## 📋 Ringkasan

**Nama Proyek:** `sixer0/landing-laravel` — Landing Page Portfolio  
**Developer:** Budi Kusharyanto (Sixer0)  
**Framework:** Laravel 11.x + Bootstrap 5 (via CDN)  
**Domain:** https://sixer0-bk.my.id  
**Lokasi:** Tangerang, Indonesia (WIB, Asia/Jakarta)  
**Lisensi:** MIT

---

## 🏗️ Arsitektur & Struktur

### Stack Teknologi
| Komponen | Teknologi |
|----------|-----------|
| Backend | Laravel 11.x (PHP ^7.4 \|\| ^8.1 \|\| ^8.5) |
| Frontend | Bootstrap 5.3.3 (CDN), Bootstrap Icons, jQuery 3.7.1 |
| Font | Google Fonts: Roboto + Poppins |
| Database | MySQL (default) + Redis (cache) |
| Auth | Laravel Sanctum |
| HTTP Client | Guzzle 7.8 |
| Email | SMTP Gmail (mailtrap-style config) |

### Struktur Direktori
```
lp-laravel/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Controller.php          # Base controller
│   │   │   ├── HomeController.php       # Landing + project pages
│   │   │   └── ContactController.php    # Contact form handler
│   │   └── Middleware/
│   │       └── TrustProxies.php         # Trust all proxies (for deploy behind LB)
│   ├── Mail/
│   │   └── ContactNotification.php      # Email notification for contact form
│   ├── Models/
│   │   ├── Project.php                  # Project portfolio model
│   │   └── ContactSubmission.php        # Contact form submissions
│   └── Providers/
│       ├── AppServiceProvider.php       # App bootstrap (HTTPS, timezone, Blade)
│       ├── AuthServiceProvider.php      # Auth policies (empty)
│       └── RouteServiceProvider.php     # Route registration + rate limiting
├── bootstrap/
├── config/
│   ├── app.php                          # App config
│   └── database.php                     # DB + Redis config
├── database/
│   ├── migrations/
│   │   ├── 2026_05_15_create_projects_table.php
│   │   └── 2026_05_15_create_contact_submissions_table.php
│   └── seeders/
│       └── ProjectSeeder.php           # Import from Sitejet XML or placeholders
├── resources/views/
│   ├── emails/
│   │   └── contact-notification.blade.php
│   ├── errors/
│   │   ├── 404.blade.php
│   │   └── 500.blade.php
│   ├── layouts/
│   │   └── guest.blade.php             # Main landing page (877 baris)
│   ├── legal/
│   │   ├── notice.blade.php            # Legal notice (TMG compliance)
│   │   └── privacy.blade.php           # Privacy policy
│   └── project/
│       └── show.blade.php              # Single project detail page
├── routes/
│   ├── web.php                         # 5 routes + fallback
│   └── console.php                     # Minimal (empty commands)
├── deploy.php                          # Web-based deployment UI
├── deploy-api.php                      # Deployment AJAX endpoint
├── deploy.sh                           # Shell deployment script
├── .env.example                        # Environment template
└── composer.json
```

### Catatan: Direktori yang Tidak Versioned
- `public/` — Tidak di-commit (berisi CSS, JS, images, Sitejet XML modules-1/)
- `storage/` — Tidak di-commit (logs, cache)
- `vendor/` — Tidak di-commit (Composer dependencies)
- `tests/` — Tidak ada test files

---

## 🗺️ Routes

| Method | Path | Handler | Nama Route |
|--------|------|---------|------------|
| GET | `/` | `HomeController@index` | `home` |
| POST | `/contact` | `ContactController@submit` | `contact.submit` |
| GET | `/legal-notice` | `View: legal.notice` | `legal` |
| GET | `/privacy` | `View: legal.privacy` | `privacy` |
| GET | `/project/{slug}` | `HomeController@project` | `project` |
| ANY | `*` | `Fallback -> 404` | — |

---

## 🗄️ Database Schema

### `projects` Table
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | bigint (PK) | Auto-increment |
| name | string | Nama project |
| slug | string (unique) | URL slug, auto-generated |
| description | text (nullable) | Deskripsi project |
| image | string (nullable) | URL gambar |
| image_alt | string (nullable) | Alt text gambar |
| hours_tag | string(50) (nullable) | Tag durasi (e.g., "8hrs") |
| price_tag | string(50) (nullable) | Tag harga (e.g., "$499") |
| project_url | string (nullable) | Link project eksternal |
| order | integer (default:0) | Urutan tampilan |
| is_active | boolean (default:true) | Status aktif |
| timestamps | created_at, updated_at | Waktu dibuat/diupdate |

**Index:** Composite `(is_active, order)`

### `contact_submissions` Table
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | bigint (PK) | Auto-increment |
| company | string | Nama perusahaan |
| name | string | Nama pengirim |
| phone | string | No. telepon |
| email | string | Email |
| message | text | Pesan |
| ip | string (nullable) | IP Address pengirim |
| user_agent | text (nullable) | User-Agent lengkap |
| user_agent_short | string(255) (nullable) | User-Agent (terpotong) |
| status | enum('new','read','responded','archived') | Status submission |
| timestamps | created_at, updated_at | Waktu dibuat/diupdate |

**Index:** Composite `(status, created_at)`, Single `(email)`

---

## 🧩 Komponen Utama

### 1. HomeController
- **`index()`** — Landing page. Pertama coba ambil project dari database (`Project::active()`). Jika kosong, fallback ke XML Sitejet (`modules-1/2849388066.xml`).
- **`project($slug)`** — Halaman detail project individual. 404 jika slug tidak ditemukan.
- **`loadProjectsFromXml()`** — Method protected untuk parse XML Sitejet dan return collection of objects.

### 2. ContactController
- **`submit(Request)`** — Menangani form kontak:
  - Validasi: company, name, phone, email, message, privacy, captcha
  - Captcha: matematika sederhana (number + number), hash MD5
  - Simpan ke DB via `ContactSubmission::create()`
  - Kirim email notifikasi ke `sixer0.bk@gmail.com` (failure tidak blocking)
  - Redirect dengan flash message success/error

### 3. Project Model
- **Scopes:** `active()` — filter `is_active = true`, order by `order` ASC
- **Boot events:** Auto-generate `slug` dari `name`, auto-set `order` ke max+1
- **Accessors:** `getImageUrlAttribute()` — return default image jika kosong
- **Fillable:** 11 fields

### 4. ContactSubmission Model
- **Scopes:** `active()` — filter status 'new'
- **Fillable:** 9 fields

### 5. AppServiceProvider
- Bind `path.public` ke `base_path('public')`
- Force HTTPS di production
- Blade `@dev` directive untuk environment local
- Set timezone Asia/Jakarta

---

## 🎨 Frontend

### Landing Page (`layouts/guest.blade.php`) — 877 baris
- **CSS:** Bootstrap 5.3.3, Bootstrap Icons, custom CSS variabel
- **JS:** jQuery 3.7.1, Bootstrap JS bundle, IntersectionObserver animasi
- **Sections:** Hero, Values, Services, Testimonials (carousel), Portfolio (projects), CTA, Contact Form, Footer
- **Navigasi:** Fixed navbar, smooth scrolling, active link tracking
- **Dev Badge:** Muncul di local/dev mode saja (sticky bottom-right)

### Project Detail (`project/show.blade.php`)
- Extends layouts.guest
- Breadcrumb: Home > Projects > Project Name
- Image, badges (hours, price), description, external link

### Halaman Legal
- `legal/notice.blade.php` — Legal notice (TMG §5 compliance)
- `legal/privacy.blade.php` — Privacy policy (data protection, cookies, rights)

### Email Template (`emails/contact-notification.blade.php`)
- Laravel Mail markdown component
- Menampilkan: nama, email, phone, company, message, ID, timestamp, IP, User-Agent
- Link ke admin panel: `/admin/submissions`

### Error Pages
- `404.blade.php` — Halaman tidak ditemukan (gradient, card style)
- `500.blade.php` — Internal server error (minimal)

---

## 🔐 Keamanan

| Aspek | Implementasi |
|-------|-------------|
| CSRF | Laravel @csrf pada form |
| Captcha | Matematika sederhana dengan MD5 hash |
| Validasi | Laravel validation (required, email:rfc, max) |
| Trust Proxies | Trust semua proxy (HEADER_X_FORWARDED_ALL) |
| HTTPS | Force HTTPS di production via AppServiceProvider |
| Encryption | AES-256-CBC |
| Rate Limiting | 60 requests/min untuk API (belum dipakai) |

**Catatan Keamanan:**
- Captcha menggunakan MD5 (lemah, hanya MD5 dari angka kecil)
- Admin panel di `/admin/submissions` disebut di email template tapi tidak ada implementasi routing-nya — kemungkinan belum selesai atau hanya placeholder
- Tidak ada authentication/authorization untuk akses submissions
- Tidak ada logging yang detail untuk failed attempts

---

## 🚀 Deployment

Terdapat 3 file deployment di root:
1. **`deploy.php`** — Web interface untuk one-click deployment
2. **`deploy-api.php`** — AJAX endpoint untuk deployment
3. **`deploy.sh`** — Shell script deployment

Ini adalah custom deployment system (non-standard untuk Laravel).

---

## 📊 Statistik Proyek

| Metrik | Value |
|--------|-------|
| Total PHP files | 17 |
| Blade templates | 6 |
| Controllers | 3 (base + 2 feature) |
| Models | 2 |
| Migrations | 2 |
| Service Providers | 3 |
| Middleware | 1 (TrustProxies) |
| Mailables | 1 |
| Seeders | 1 |
| Routes (web) | 5 + fallback |
| Custom Artisan Commands | 0 |
| package.json | Tidak ada (CDN-only frontend) |
| Test files | Tidak ada |

---

## 💡 Kesimpulan

Proyek ini adalah **landing page portfolio** yang dibangun dengan Laravel 11 untuk **Budi Kusharyanto (Sixer0)**, seorang IT consultant dengan 18+ tahun pengalaman. Fitur utamanya:

1. **Halaman landing** dengan hero, services, testimonials, portfolio grid, dan contact form — menggunakan Bootstrap 5 via CDN (no build step)
2. **Manajemen project** via database dengan fallback ke XML Sitejet
3. **Contact form** dengan validasi, captcha, logging, dan email notification
4. **Halaman legal** (legal notice + privacy policy)
5. **Custom deployment scripts** (web-based + shell)
6. **Tanpa autentikasi** — portofolio publik sederhana
7. **Tanpa frontend build tools** — semua via CDN untuk kemudahan hosting