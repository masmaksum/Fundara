# Fundara — Environment Specification

**Audience:** DevOps engineer / system administrator  
**Purpose:** Reference document for provisioning and operating Fundara environments  
**Stack:** ERPNext v16 / Frappe Framework / Ubuntu Server 24.04.4 LTS  
**Last updated:** 2026-06-19

---

## Overview

Fundara maintains three environments that mirror the delivery pipeline:

| Environment | Alias | Purpose |
|---|---|---|
| Development | `dev` | Local developer workstations and feature branches |
| Staging | `staging` | Pre-production integration, QA, and migration testing |
| Production | `prod` | Live data; real users; NGO operations |

Environments are isolated at the network, database, and data level. Production data must **never** be copied to Development. Staging may use anonymized exports only (see Data Policy below).

---

## 1. Development Environment

### 1.1 Purpose and Users

| Item | Value |
|---|---|
| Purpose | Day-to-day development, feature testing, DocType authoring, report development |
| Users | Fundara developers (individual workstations or shared dev VM) |
| Data | Synthetic / sample dataset; developer mode enabled |
| Uptime requirement | None — best effort |

### 1.2 Server Specification

Development runs on a developer laptop or a lightweight shared VM. Docker-based bench is also acceptable.

| Resource | Minimum | Recommended |
|---|---|---|
| CPU | 2 vCPU | 4 vCPU |
| RAM | 4 GB | 8 GB |
| Disk | 40 GB SSD | 80 GB SSD |
| OS | Ubuntu 24.04 LTS (or macOS with bench) | Ubuntu 24.04 LTS |
| Network | Local only or VPN | Local only or VPN |

### 1.3 Software Versions

All environments target the same pinned versions. Dev is the first to receive version bumps for testing.

| Component | Version |
|---|---|
| Ubuntu | 24.04.4 LTS |
| Python | 3.12.x |
| Node.js | 18.x LTS |
| npm | bundled with Node.js 18 |
| Yarn | 1.22.x |
| MariaDB | 10.11.x |
| Redis | 7.x |
| Nginx | 1.24.x (nginx.org mainline PPA) |
| Frappe | version-16 branch |
| ERPNext | version-16 branch |
| Fundara | main / feature branch |
| wkhtmltopdf | 0.12.6 (with patched Qt) |
| Certbot | latest via snap |

### 1.4 Frappe Bench Configuration

```ini
# bench/config/common_site_config.json (dev)
{
  "developer_mode": 1,
  "db_host": "localhost",
  "redis_cache": "redis://localhost:13000",
  "redis_queue": "redis://localhost:11000",
  "redis_socketio": "redis://localhost:12000",
  "socketio_port": 9000,
  "webserver_port": 8000,
  "restart_supervisor_on_update": true,
  "serve_default_site": true
}
```

| Parameter | Dev value |
|---|---|
| `developer_mode` | `1` (enabled) |
| Web workers (gunicorn) | 2 |
| Background workers | 1 short, 1 long, 1 default |
| Scheduler | Enabled |
| Socket.IO port | 9000 |
| Web port | 8000 (served directly, no Nginx in simple dev setup) |

For multi-developer or shared dev VM: configure Nginx in front of bench (same as staging).

### 1.5 Network and Firewall

Development runs locally or behind a firewall. No public exposure is expected.

| Port | Service | Access |
|---|---|---|
| 8000 | Frappe web (direct) | Localhost / LAN only |
| 9000 | Socket.IO | Localhost / LAN only |
| 3306 | MariaDB | Localhost only |
| 6379 | Redis | Localhost only |
| 22 | SSH (if shared VM) | Developer team IPs only |

UFW rules for shared dev VM:

```bash
ufw default deny incoming
ufw allow from <developer_subnet> to any port 22
ufw allow from <developer_subnet> to any port 8000
ufw allow from <developer_subnet> to any port 9000
ufw enable
```

### 1.6 SSL/TLS

Not required for development. Use plain HTTP on port 8000.  
If testing SSL-dependent features (payment callbacks, webhooks): use a self-signed certificate or `mkcert` locally.

### 1.7 Environment Variables and Config Differences from Production

| Variable / Setting | Dev value | Production value |
|---|---|---|
| `developer_mode` | `1` | `0` |
| `db_password` | simple local password | strong random 32-char |
| `admin_password` | `admin` | strong random |
| Mail server | Disabled or local MailHog | Configured SMTP relay |
| Error reporting | Console / bench logs | Sentry or log aggregator |
| Backup | Not mandatory | Mandatory, automated |
| HTTPS | No | Mandatory |
| `disable_website_cache` | `1` (optional) | `0` |
| `allow_cors` | `*` (optional for API dev) | Restricted origin list |

### 1.8 Data Policy

- Dev uses **synthetic sample data only**.
- A fixture-based sample dataset (`fixtures/sample_data/`) is loaded during bench setup.
- No production or staging data may be imported to dev, even anonymized.
- Developers must not store real donor, beneficiary, or financial data on workstations.

### 1.9 Access Policy

| Method | Rule |
|---|---|
| Local workstation | Developer owns the machine; no restriction |
| Shared dev VM | SSH key only; no password auth; no root login |
| SSH user | Dedicated `frappe` OS user; `sudo` allowed for developers |
| Key management | Each developer registers their own public key |

### 1.10 Backup Policy

Not required. Dev data is disposable.  
Developers are expected to version-control fixtures and patches, not DB snapshots.

---

## 2. Staging Environment

### 2.1 Purpose and Users

| Item | Value |
|---|---|
| Purpose | Integration testing, migration validation, UAT, backup/restore drills, upgrade testing |
| Users | QA engineers, tech lead, project manager for acceptance testing |
| Data | Anonymized export from production, or production-scale synthetic data |
| Uptime requirement | Business hours; best effort outside hours |

### 2.2 Server Specification

Staging mirrors production sizing at minimum profile (Profile B: Small NGO).

| Resource | Minimum | Recommended |
|---|---|---|
| CPU | 2 vCPU | 4 vCPU |
| RAM | 4 GB | 8 GB |
| Disk | 80 GB SSD | 150 GB SSD |
| OS | Ubuntu Server 24.04.4 LTS | Ubuntu Server 24.04.4 LTS |
| Network | Private VPC or VPN-gated | Private VPC or VPN-gated |
| Public access | HTTPS only via subdomain | HTTPS only via subdomain |

### 2.3 Software Versions

Same pinned versions as production (see table in section 1.3). Staging may receive version bumps **one sprint ahead** of production to validate upgrades.

### 2.4 Frappe Bench Configuration

```ini
# bench/config/common_site_config.json (staging)
{
  "developer_mode": 0,
  "db_host": "localhost",
  "redis_cache": "redis://localhost:13000",
  "redis_queue": "redis://localhost:11000",
  "redis_socketio": "redis://localhost:12000",
  "socketio_port": 9000,
  "webserver_port": 8000,
  "restart_supervisor_on_update": true,
  "serve_default_site": true
}
```

| Parameter | Staging value |
|---|---|
| `developer_mode` | `0` (disabled) |
| Web workers (gunicorn) | 2 |
| Background workers | 1 short, 1 long, 1 default |
| Scheduler | Enabled |
| Nginx | Enabled, proxying port 80/443 to bench |
| Socket.IO port | 9000 (internal) |

### 2.5 Network and Firewall

| Port | Service | Access |
|---|---|---|
| 80 | HTTP (redirect to HTTPS) | Public (redirect only) |
| 443 | HTTPS | Restricted: team IPs + automated test runners |
| 22 | SSH | DevOps / tech lead IPs only |
| 3306 | MariaDB | Localhost only |
| 6379 | Redis | Localhost only |
| 8000 | Frappe web | Localhost only (Nginx proxies externally) |
| 9000 | Socket.IO | Localhost only (Nginx proxies externally) |

UFW rules:

```bash
ufw default deny incoming
ufw allow from <devops_ips> to any port 22
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

Consider restricting port 443 to team IP ranges if staging should not be publicly reachable.

### 2.6 SSL/TLS

- HTTPS via Let's Encrypt on `staging-[orgname].fundara.id`.
- Auto-renewal via `certbot renew` cron (twice daily, standard certbot timer).
- Certificate is per-site; wildcard certificate optional if many staging sites exist.
- Minimum TLS version: TLS 1.2. Recommended: TLS 1.3 preferred, TLS 1.2 allowed.
- HSTS: enabled in Nginx staging config (same header as production).

Nginx SSL snippet (same template as production):

```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

### 2.7 Environment Variables and Config Differences from Production

| Variable / Setting | Staging value | Production value |
|---|---|---|
| `developer_mode` | `0` | `0` |
| `db_password` | Separate staging credential | Separate production credential |
| `admin_password` | Separate staging credential | Separate production credential |
| Mail server | Staging SMTP relay or Mailtrap | Production SMTP relay |
| Error reporting | Logs; optional Sentry staging project | Sentry production project |
| Backup | Daily automated (same mechanism as prod) | Daily automated + offsite |
| HTTPS | Mandatory | Mandatory |
| 2FA enforcement | Optional (follow same policy as prod) | Mandatory for Finance/Admin roles |
| `maintenance_mode` | May be toggled during upgrade tests | Only during planned maintenance |

### 2.8 Data Policy

- Staging may use an **anonymized export** from production.
- Anonymization rules:
  - Donor names → `Donor-XXXX` (hash-based)
  - Staff names → `Staff-XXXX`
  - Phone/email → replaced with staging placeholders
  - Financial amounts → preserved for realistic volume testing (not anonymized)
  - Beneficiary names → removed or replaced with synthetic names
- Raw production data (un-anonymized) must **never** reside on staging disk.
- Anonymized data import process must be documented and run by a lead engineer only.
- Alternatively, staging may use a **production-scale synthetic dataset** generated from fixtures.

### 2.9 Access Policy

| Method | Rule |
|---|---|
| SSH | SSH key only; no password auth; no root login |
| SSH user | `frappe` OS user; `sudo` for DevOps only |
| Web UI | HTTPS; Frappe user accounts separate from production |
| Key management | DevOps and tech lead keys only; no developer keys by default |
| Staging URL | Shared internally; not indexed by search engines (`robots.txt: Disallow: /`) |

### 2.10 Backup Policy

Staging backups are for restore-drill purposes, not long-term retention.

| Item | Policy |
|---|---|
| Frequency | Daily automated via `bench backup --with-files` |
| Retention | 7 days local |
| Offsite | Not required (staging data is not production data) |
| Restore drill | Mandatory before each production release |

---

## 3. Production Environment

### 3.1 Purpose and Users

| Item | Value |
|---|---|
| Purpose | Live system for real NGO operations |
| Users | NGO staff, finance team, program team, management, donors (portal) |
| Data | Real donor, financial, beneficiary, and grant data |
| Uptime requirement | 99.5% during business hours; monitoring and alerting required |

### 3.2 Server Specification

#### Profile B — Small NGO (default for single-org deployment)

| Resource | Specification |
|---|---|
| CPU | 4 vCPU |
| RAM | 8 GB (16 GB recommended) |
| Disk | 150 GB SSD (NVMe preferred) |
| OS | Ubuntu Server 24.04.4 LTS |
| Network | Public IP with firewall; VPC preferred |
| Additional | Separate backup volume or remote backup target |

#### Profile C — Medium NGO / Network (separated DB)

| Resource | App Server | DB Server |
|---|---|---|
| CPU | 4–8 vCPU | 4–8 vCPU |
| RAM | 8–16 GB | 16–32 GB |
| Disk | 100 GB SSD | 300 GB SSD/NVMe |
| OS | Ubuntu 24.04.4 LTS | Ubuntu 24.04.4 LTS |

### 3.3 Software Versions

Same as section 1.3. Production runs **pinned, tested versions only**.  
Version upgrades require staging validation before applying to production.

### 3.4 Frappe Bench Configuration

```ini
# bench/config/common_site_config.json (production)
{
  "developer_mode": 0,
  "db_host": "localhost",
  "redis_cache": "redis://localhost:13000",
  "redis_queue": "redis://localhost:11000",
  "redis_socketio": "redis://localhost:12000",
  "socketio_port": 9000,
  "webserver_port": 8000,
  "restart_supervisor_on_update": true,
  "serve_default_site": true
}
```

| Parameter | Production value |
|---|---|
| `developer_mode` | `0` |
| Web workers (gunicorn) | 4 (scale with RAM: ~1 worker per 2 GB RAM) |
| Background workers | 2 short, 1 long, 1 default |
| Scheduler | Enabled |
| Nginx | Enabled, TLS termination |
| Socket.IO | Enabled; proxied by Nginx |

Gunicorn worker count formula: `max(2, (RAM_GB / 2))`

For production with 8 GB RAM: 4 workers.  
For production with 16 GB RAM: 8 workers.

### 3.5 Network and Firewall

| Port | Service | Access |
|---|---|---|
| 22 | SSH | DevOps IPs only (allowlist in UFW) |
| 80 | HTTP | Public (redirect to 443 only) |
| 443 | HTTPS | Public |
| 3306 | MariaDB | Localhost only (never public) |
| 6379 | Redis | Localhost only (never public) |
| 8000 | Frappe web | Localhost only |
| 9000 | Socket.IO | Localhost only |

UFW rules:

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow from <devops_ip_1> to any port 22
ufw allow from <devops_ip_2> to any port 22
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

Additional hardening:
- `fail2ban` with SSH and Nginx jail enabled.
- Port 22 may be moved to a non-standard port (e.g., 2222) for SSH obscurity.
- Outbound: allow 25/465/587 for email relay, 443 for Let's Encrypt ACME, 443 for offsite backup.

### 3.6 SSL/TLS

- HTTPS mandatory. No plain HTTP access beyond redirect.
- Let's Encrypt via Certbot (`certbot --nginx` or standalone).
- Auto-renewal: certbot systemd timer (checks twice daily).
- Minimum TLS version: TLS 1.2. TLS 1.3 preferred.
- HSTS header: `max-age=31536000; includeSubDomains`.
- OCSP stapling: enabled.
- DH parameter: `openssl dhparam -out /etc/nginx/dhparam.pem 2048`.

Nginx SSL block (production):

```nginx
ssl_certificate     /etc/letsencrypt/live/<site>/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/<site>/privkey.pem;
ssl_dhparam         /etc/nginx/dhparam.pem;
ssl_protocols       TLSv1.2 TLSv1.3;
ssl_ciphers         ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers on;
ssl_session_cache   shared:SSL:10m;
ssl_session_timeout 10m;
ssl_stapling        on;
ssl_stapling_verify on;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options SAMEORIGIN;
add_header X-Content-Type-Options nosniff;
```

### 3.7 Environment Variables and Config Differences

Production has the most restrictive configuration.

| Variable / Setting | Production value |
|---|---|
| `developer_mode` | `0` |
| `db_password` | Strong random 32-char; stored in site config only |
| `admin_password` | Strong random; stored in password manager |
| Mail server | Configured SMTP relay (e.g., Mailgun, SES, Postfix) |
| 2FA | Mandatory for Finance, Admin, System Manager roles |
| Error reporting | Sentry DSN configured |
| `maintenance_mode` | `0`; set to `1` only during planned windows |
| Frappe error log | Rotated, retained 30 days |
| `disable_website_cache` | `0` |
| `allow_cors` | Explicit origin allowlist only |

Production secrets must **never** be committed to git. Store in:
- `sites/<sitename>/site_config.json` (MariaDB password, Redis URIs)
- Server-side environment variables for external service keys
- A secrets manager (HashiCorp Vault, AWS Secrets Manager) for advanced setups

### 3.8 Data Policy

- Production contains **real data**. All access is logged.
- No export of full production database to any environment without explicit approval and immediate anonymization.
- Bench backup archives are encrypted before offsite transfer.
- Data retention follows the organization's data governance policy.
- GDPR / local privacy regulation compliance is the responsibility of the deploying organization.

### 3.9 Access Policy

| Method | Rule |
|---|---|
| SSH | SSH key only; password auth disabled (`PasswordAuthentication no` in sshd_config) |
| Root login | Disabled (`PermitRootLogin no`) |
| SSH user | `frappe` OS user only; `sudo` limited to DevOps lead |
| Web UI | HTTPS; Frappe roles enforced; 2FA for privileged roles |
| Database | No direct external access; bench user only |
| Key management | Centralized; revoke keys immediately on offboarding |
| `fail2ban` | Enabled for SSH; ban after 5 failed attempts, 1-hour ban |

Recommended: configure SSH to use AllowUsers:

```
AllowUsers frappe
```

### 3.10 Backup Policy

| Item | Policy |
|---|---|
| Frequency | Daily automated (cron at 02:00 local time) |
| Scope | MariaDB dump + private files + public files + site config |
| Command | `bench --site <sitename> backup --with-files --compress` |
| Local retention | 7 days on-disk |
| Offsite | Encrypted archive pushed to S3-compatible storage (Wasabi, Backblaze B2, MinIO) |
| Offsite retention | 30 days standard; 12 months for monthly archives |
| Restore drill | Monthly; documented in runbook |
| Alert on failure | Email / Telegram alert if backup cron fails |

Backup encryption: `gpg --symmetric --cipher-algo AES256` before upload.

---

## 4. Site Naming Convention

### 4.1 Scheme

| Environment | Pattern | Example |
|---|---|---|
| Development | `fundara-[orgname].local` | `fundara-yayasanabc.local` |
| Staging | `staging-[orgname].fundara.id` | `staging-yayasanabc.fundara.id` |
| Production | `[orgname].fundara.id` | `yayasanabc.fundara.id` |

Rules:
- `[orgname]` is lowercase alphanumeric, hyphens allowed, no underscores.
- Maximum 20 characters for `[orgname]` to keep URLs manageable.
- Production subdomain is the canonical URL communicated to end users.

### 4.2 Bench Site Name

The Frappe site name must match the DNS hostname exactly:

```bash
# Production
bench new-site yayasanabc.fundara.id

# Staging
bench new-site staging-yayasanabc.fundara.id

# Development
bench new-site fundara-yayasanabc.local
```

---

## 5. DNS Requirements

### 5.1 Production

| Record type | Name | Value | TTL |
|---|---|---|---|
| A | `[orgname].fundara.id` | Production server IP | 3600 |
| CNAME (optional) | `www.[orgname].fundara.id` | `[orgname].fundara.id` | 3600 |

### 5.2 Staging

| Record type | Name | Value | TTL |
|---|---|---|---|
| A | `staging-[orgname].fundara.id` | Staging server IP | 3600 |

### 5.3 Development

Development uses `/etc/hosts` on the developer machine, not public DNS:

```
127.0.0.1  fundara-[orgname].local
```

For shared dev VM accessible over LAN:

```
<dev_vm_ip>  fundara-[orgname].local
```

### 5.4 Wildcard DNS (optional, for multi-site)

If running multiple sites on one bench, a wildcard record simplifies DNS management:

| Record type | Name | Value |
|---|---|---|
| A | `*.fundara.id` | Server IP |
| A | `fundara.id` | Server IP |

---

## 6. Port Mapping Summary

| Port | Protocol | Service | Dev | Staging | Production |
|---|---|---|---|---|---|
| 22 | TCP | SSH | LAN only | DevOps IPs | DevOps IPs |
| 80 | TCP | HTTP (redirect) | No | Yes | Yes |
| 443 | TCP | HTTPS | No | Yes | Yes |
| 8000 | TCP | Frappe web | LAN only | Localhost | Localhost |
| 9000 | TCP | Socket.IO | LAN only | Localhost | Localhost |
| 3306 | TCP | MariaDB | Localhost | Localhost | Localhost |
| 6379 | TCP | Redis (default) | Localhost | Localhost | Localhost |
| 11000 | TCP | Redis queue | Localhost | Localhost | Localhost |
| 12000 | TCP | Redis socketio | Localhost | Localhost | Localhost |
| 13000 | TCP | Redis cache | Localhost | Localhost | Localhost |

---

## 7. Environment Comparison Matrix

| Feature | Development | Staging | Production |
|---|---|---|---|
| Developer mode | On | Off | Off |
| HTTPS | No | Yes | Yes |
| SSL certificate | None / self-signed | Let's Encrypt | Let's Encrypt |
| Public DNS | No | Yes (restricted) | Yes |
| Real user data | No | No (anonymized only) | Yes |
| 2FA | Optional | Optional (matches prod policy) | Mandatory (privileged roles) |
| Automated backup | No | Yes (7-day local) | Yes (7-day local + offsite) |
| Monitoring | No | Optional | Mandatory |
| `fail2ban` | No | Optional | Yes |
| SSH root login | N/A | Disabled | Disabled |
| SSH password auth | N/A | Disabled | Disabled |
| Mail sending | Disabled / local | Mailtrap or staging relay | Production SMTP relay |
| Scheduler | Yes | Yes | Yes |
| Background workers | Yes | Yes | Yes |
| Gunicorn workers | 2 | 2 | 4+ |
| Nginx | Optional | Yes | Yes |
| Supervisor | Optional | Yes | Yes |
| Certbot | No | Yes | Yes |
| Offsite backup | No | No | Yes |
