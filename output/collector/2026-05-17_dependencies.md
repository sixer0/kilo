---
task: collect-dependencies-environment
date: 2026-05-17
agent: data-collector
items_collected: 8
last_updated: 2026-05-17 21:22
---

# Dependencies & Environment Report

## Project Overview

| Field | Value |
|-------|-------|
| Name | sixer0/landing-laravel |
| Description | Laravel 11 + Bootstrap Portfolio Landing Page |
| License | MIT |
| PHP Version | ^7.4 \|\| ^8.1 \|\| ^8.5 |

---

## Composer Dependencies

### Production (`require`)

| Package | Version | Purpose |
|---------|---------|---------|
| `laravel/framework` | ^11.0 | Core Laravel framework |
| `laravel/sanctum` | ^4.0 | API authentication (token-based) |
| `guzzlehttp/guzzle` | ^7.8 | HTTP client (used for API calls / external requests) |

### Development (`require-dev`)

| Package | Version | Purpose |
|---------|---------|---------|
| `fakerphp/faker` | ^1.23 | Fake data generation for seeders/tests |
| `mockery/mockery` | ^1.6 | Test mocking framework |
| `nunomaduro/collision` | ^8.1 | Pretty error reporting in CLI |
| `phpunit/phpunit` | ^10.5 | PHP unit testing framework |

### PSR-4 Autoloading

| Namespace | Path |
|-----------|------|
| `App\` | `app/` |
| `Database\Seeders\` | `database/seeders/` |

### PSR-4 Autoloading (dev)

| Namespace | Path |
|-----------|------|
| `Tests\` | `tests/` |

> **Note:** No `package.json` / Node.js dependencies found in the project root.

---

## Environment Requirements (`.env.example`)

### Application

| Variable | Value | Notes |
|----------|-------|-------|
| `APP_NAME` | `Sixer0 Portfolio` | Application label |
| `APP_ENV` | `production` | Runtime environment |
| `APP_KEY` | _(empty)_ | Must be set via `php artisan key:generate` |
| `APP_DEBUG` | `false` | Must be set to `true` in development |
| `APP_URL` | `https://landing.sixer0-bk.my.id` | Public URL |

### Logging

| Variable | Value |
|----------|-------|
| `LOG_CHANNEL` | `stack` |
| `LOG_LEVEL` | `error` |

### Database (MySQL)

| Variable | Value |
|----------|-------|
| `DB_CONNECTION` | `mysql` |
| `DB_HOST` | `127.0.0.1` |
| `DB_PORT` | `3306` |
| `DB_DATABASE` | `sixq7133_dev_cms` |
| `DB_USERNAME` | `sixq7133_Openclaw` |
| `DB_PASSWORD` | _(empty)_ |

### Cache & Session

| Variable | Value |
|----------|-------|
| `BROADCAST_DRIVER` | `log` |
| `CACHE_DRIVER` | `file` |
| `FILESYSTEM_DISK` | `local` |
| `QUEUE_CONNECTION` | `sync` |
| `SESSION_DRIVER` | `file` |
| `SESSION_LIFETIME` | `120` (minutes) |

### Mail (Log driver - no real SMTP configured)

| Variable | Value |
|----------|-------|
| `MAIL_MAILER` | `log` |
| `MAIL_HOST` | `localhost` |
| `MAIL_PORT` | `1025` |
| `MAIL_USERNAME` | `null` |
| `MAIL_PASSWORD` | `null` |
| `MAIL_FROM_ADDRESS` | `hello@example.com` |

### Redis (configured but not set as default driver)

| Variable | Value |
|----------|-------|
| `REDIS_HOST` | `127.0.0.1` |
| `REDIS_PASSWORD` | `null` |
| `REDIS_PORT` | `6379` |

---

## Database Migrations

All migrations located in `database/migrations/`.

> ⚠️ **Anomaly detected:** `contact_submissions` table has **two** migration files — `2026_05_15` (full schema) and `2026_05_17` (reduced schema). Running `2026_05_17` after `2026_05_15` would fail because the table already exists from the earlier migration. Only one should be used.

### `2026_05_17_create_users_table.php` — Table `users`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | bigint | Primary key (auto-increment) |
| `username` | string(80) | Unique |
| `password_hash` | string(255) | — |
| `display_name` | string(120) | Nullable |
| `email` | string(180) | Nullable |
| `role` | enum | `'admin'` or `'editor'`, default `admin` |
| `is_active` | boolean | Default `true` |
| `last_login_at` | timestamp | Nullable |
| `created_at` | timestamp | — |
| `updated_at` | timestamp | — |

### `2026_05_15_create_projects_table.php` — Table `projects`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | bigint | Primary key (auto-increment) |
| `name` | string | — |
| `slug` | string | Unique |
| `description` | text | Nullable |
| `image` | string | Nullable |
| `image_alt` | string | Nullable |
| `hours_tag` | string(50) | Nullable |
| `price_tag` | string(50) | Nullable |
| `project_url` | string | Nullable |
| `order` | integer | Default `0` |
| `is_active` | boolean | Default `true` |
| `created_at` | timestamp | — |
| `updated_at` | timestamp | — |

**Indexes:** Composite index on `[is_active, order]`

### `2026_05_15_create_contact_submissions_table.php` — Table `contact_submissions` (full schema)

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | bigint | Primary key (auto-increment) |
| `company` | string | — |
| `name` | string | — |
| `phone` | string | — |
| `email` | string | — |
| `message` | text | — |
| `ip` | string | Nullable |
| `user_agent` | text | Nullable |
| `user_agent_short` | string(255) | Nullable |
| `status` | enum | `'new'`, `'read'`, `'responded'`, `'archived` — default `new` |
| `created_at` | timestamp | — |
| `updated_at` | timestamp | — |

**Indexes:** Composite index on `[status, created_at]`, index on `email`

### `2026_05_17_create_contact_submissions_table.php` — Table `contact_submissions` (reduced schema — used to replace prior)

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | bigint | Primary key (auto-increment) |
| `name` | string(120) | — |
| `email` | string(255) | — |
| `message` | text | — |
| `created_at` | timestamp | — |
| `updated_at` | timestamp | — |

> ⚠️ **Anomaly detected (see above):** Only one of the two `contact_submissions` migrations should be in the migrations directory. If the older `2026_05_15` schema is desired, remove `2026_05_17`; if the reduced schema is intended, remove `2026_05_15` and re-run migrations.

---

## Database Seeders

All seeders located in `database/seeders/`.

### `ProjectSeeder.php`

Imports project data from a Sitejet XML export (`public/modules-1/2849388066.xml`) or falls back to placeholder records.

| Scenario | Behavior |
|----------|----------|
| XML file exists and parses | Reads `<item>` entries from XML, maps `title`, `enclosure[url]`, `link`, and `description` to `Project` model fields; uses `firstOrCreate` by slug |
| XML file missing or unreadable | Creates 5 placeholder projects via `Project::create()` — Photography, Data Science, Finances, Public Speaking, Coding |

**Placeholder fields:** `name`, `hours_tag` (`8hrs`/`12hrs`/`10hrs`/`6hrs`/`24hrs`), `price_tag` (`$499`/`$899`/`$799`/$399`/$1499`), `order` (1–5)

---

## Tests

No test files found (`tests/` directory not present).

---

## Composer Scripts

| Script | Command |
|--------|---------|
| `post-autoload-dump` | `Illuminate\Foundation\ComposerScripts::postAutoloadDump` |

---

## Key Gaps / Risks

| # | Issue | Severity |
|---|-------|----------|
| 1 | `APP_KEY` is empty in `.env.example` — application won't boot without running `php artisan key:generate` | High |
| 2 | `APP_DEBUG=false` in `.env.example` — no error output in production, but should be `true` in development copies | Medium |
| 3 | Database credentials (`DB_USERNAME`, `DB_DATABASE`) in `.env.example` appear production-specific — likely not correct for local development | High |
| 4 | Duplicate `contact_submissions` migration — only one should exist; the newer file `2026_05_17` has fewer fields | High |
| 5 | No `package.json` — no front-end asset pipeline (Vite, Mix, NPM) configured | Info |
| 6 | Mail uses `log` driver — contact notifications will not be sent via SMTP in this configuration | Medium |
| 7 | `REDIS_*` vars present in `.env.example` but `CACHE_DRIVER=file` — Redis is not the active cache driver | Low |

---

## Summary Checklist for Local Setup

- [ ] Run `composer install` to install PHP dependencies
- [ ] Copy `.env.example` to `.env`
- [ ] Set correct local `APP_DEBUG=true`
- [ ] Update database credentials for local dev
- [ ] Run `php artisan key:generate`
- [ ] Resolve duplicate `contact_submissions` migration
- [ ] Run `php artisan migrate --seed` to apply migrations + seeders

---
*Generated: 2026-05-17 21:22*
*Last Updated: 2026-05-17 21:22*
