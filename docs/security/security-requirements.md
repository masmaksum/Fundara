# Fundara Security Requirements

**Version:** 1.0
**Last Updated:** 2026-06-19
**Audience:** Tech Lead, Developer, DevOps
**Status:** Non-negotiable — all requirements must be satisfied before go-live

These requirements are derived from:
- `docs/spec/permissions.md` — role definitions and permission matrix
- `docs/infra/environment-spec.md` — infrastructure topology and configuration
- `DECISIONS.md` — architecture decisions (ERPNext v16, multi-currency, one site per org)

---

## 1. Authentication

### SR-AUTH-01: Password Policy

- Minimum 12 characters
- Must contain: uppercase letter, lowercase letter, number, symbol
- No reuse of last 6 passwords
- **Implementation:** ERPNext System Settings + Frappe password policy (`frappe.utils.password`)
- **Where to configure:** Setup > System Settings > Password tab

### SR-AUTH-02: Session Management

- Session timeout: 8 hours of inactivity (aligned to NGO workday)
- Session invalidated on logout — server-side token revocation via Redis session store
- No session persistence across browser restarts by default
- Concurrent session limit: configurable per role; default 3 sessions per user
- **Implementation:** Frappe session settings + Redis session store (`redis://localhost:13000`)

### SR-AUTH-03: Two-Factor Authentication

- **Required for:** System Admin, Finance Manager, Management / Executive
- **Optional for:** all other roles
- Method: TOTP — Google Authenticator / Authy compatible (RFC 6238)
- **Implementation:** Frappe built-in 2FA (`frappe.two_factor_auth`)
- Backup codes: must be generated at enrollment and stored securely by the user (not in the system)
- Production enforcement: `common_site_config.json` → `"enable_two_factor_auth": 1`; role list in System Settings

### SR-AUTH-04: Login Attempt Limiting

- Lock account after 5 consecutive failed login attempts
- Lockout duration: 30 minutes
- Notify System Admin via email when lockout is triggered (uses configured SMTP relay)
- **Implementation:** Setup > System Settings > Login Attempts Before Ban = 5
- Complements `fail2ban` SSH jail configured per `environment-spec.md` section 3.9

### SR-AUTH-05: API Key Authentication

- API keys used **only** for automated integrations (monitoring health endpoint, backup scripts, scheduled reports)
- API keys stored in server-side environment variables — never in source code or git repository
- API keys scoped to the minimum required role (never System Admin unless technically unavoidable; document exception)
- Rotate API keys every 90 days; rotation is a calendar reminder owned by the Tech Lead
- Every API key usage creates an entry in the Frappe Audit Log (automated via Frappe API key middleware)

---

## 2. Authorization

### SR-AUTHZ-01: Principle of Least Privilege

- Every user receives the minimum role required for their job function as defined in `docs/spec/permissions.md`
- No shared accounts — one Frappe user per human
- Role assignment requires approval from Finance Manager or System Admin before activation
- User access reviewed quarterly; inactive accounts (no login > 60 days) are disabled

### SR-AUTHZ-02: Role-Based Access Control Implementation

- All roles and permissions implemented exactly as specified in `docs/spec/permissions.md` (Role Permission Manager per DocType per Role)
- No direct database queries that bypass the Frappe permission layer
- `frappe.flags.ignore_permissions = True` is **prohibited** in production code paths; permitted only in migration scripts and fixture loaders, and must have an explicit justification comment in the same code block
- Conditional permissions (Project Manager scoped to own project, Field Staff own-records-only, amount thresholds) implemented as `has_permission` hooks in DocType controllers — not as UI-only restrictions

### SR-AUTHZ-03: Field-Level Security

- PII fields (donor NPWP/NIK, beneficiary name/ID/health data, staff salary and bank account) are masked for roles without explicit access
- **Implementation:** Frappe field-level permission or `before_load` controller hook
- Masked fields display `"***"` — not null or empty string — to prevent distinguishing "empty value" from "hidden value"
- Affected DocTypes: Donor, Beneficiary, Staff Profile (salary/bank), Grant Agreement (beneficiary references)

### SR-AUTHZ-04: Document-Level Security

- Field Staff: read/write access limited to Cash Advance, Advance Liquidation, Activity, and Evidence Document records where `requester == frappe.session.user` or they are listed as PIC/team member
- Project Manager: read/write access limited to documents linked to Projects where they are the assigned `project_manager`
- Donor Relationship Manager: write access to Grant and Donor Report limited to records where they are the listed `grant_manager`
- **Implementation:** `has_permission` hook per DocType — access restrictions enforced server-side, not UI-only
- Audit role has read access across all records regardless of project/fund scope filters (per `permissions.md`)

---

## 3. Data Encryption

### SR-ENC-01: Encryption at Rest

- **Sensitive columns** (NPWP, health data fields, bank account numbers): encrypted at application level using Frappe's `frappe.utils.password.encrypt()` (AES-256) before storage
- **Backup files:** GPG-encrypted with AES-256 (`--cipher-algo AES256`) before offsite transfer — per `environment-spec.md` section 3.10
- **File attachments** (uploaded invoices, scanned receipts, evidence documents): stored in Frappe's `private/files/` directory, served only via Frappe's authenticated file download endpoint — never exposed from the public web root
- Minimum key size: AES-256

### SR-ENC-02: Encryption in Transit

- All web traffic: TLS 1.2 minimum, TLS 1.3 preferred — enforced in Nginx SSL block per `environment-spec.md` section 3.6
- SSL certificate: Let's Encrypt via Certbot with auto-renewal (systemd timer checks twice daily)
- HTTP → HTTPS redirect enforced at Nginx level (port 80 responds only with 301)
- Internal bench ports (8000, 9000) bound to localhost only — accessible only via Nginx reverse proxy (per `environment-spec.md` section 3.5)
- MariaDB (port 3306) and Redis (6379, 11000, 12000, 13000): localhost only, never exposed publicly
- For Profile C (separated DB server): MariaDB connections use SSL

### SR-ENC-03: Secret Management

- Database password, Redis connection URIs, `site_config.json` secrets: stored in `sites/<sitename>/site_config.json` (file permission 640, owner `frappe` user) or server-side environment variables
- External service API keys (SMTP, Sentry DSN, S3 credentials): stored in server-side environment variables
- Advanced deployments: HashiCorp Vault or cloud secrets manager
- **Never committed to git** — `.gitignore` must exclude `site_config.json` and `.env` files
- Encryption key rotation: annually as a scheduled maintenance task; immediately on suspected compromise

---

## 4. Audit Logging

### SR-LOG-01: Transaction Audit Trail

- Every submittable DocType (Cash Advance, Advance Liquidation, Purchase Order, Fund, Fund Allocation, Fund Transfer, Grant, Grant Agreement, Budget, Budget Revision) has full version history via Frappe Document Versioning (`track_changes = 1` in DocType definition)
- Version history is read-only — no role including System Admin can delete version entries via the Frappe UI
- Each version record captures: changed by (user), changed fields (old value → new value), timestamp (UTC)

### SR-LOG-02: Access Audit Log

- Login events (success and failure), logout events: logged to Frappe Activity Log with source IP
- Failed login attempts: logged with username, source IP, and timestamp — accessible to System Admin and Audit role
- Role assignment and deactivation events: logged
- System Settings changes: logged
- Retention: minimum 2 years — Activity Log records must not be purged before this threshold

### SR-LOG-03: Financial Audit Log

- Every GL Entry created by Frappe accounting is immutable once submitted — no GL Entry can be deleted; reversal creates a new offsetting entry
- Fund balance changes are traceable to individual GL Entries (linked via `voucher_type` / `voucher_no`)
- Cash Advance lifecycle events (Submitted, Approved, Paid, Liquidated, Rejected) logged with the approving user on each transition
- All GL Entry records accessible to Audit role (read-only, no scope filter)

### SR-LOG-04: Log Protection

- Frappe Activity Log and Document Versioning: Audit role has read-only access; no role has delete permission on these tables via the Frappe permission layer
- Server logs (`/var/log/nginx/`, `/home/frappe/frappe-bench/logs/`): accessible to DevOps only via SSH — not accessible via Frappe UI or any web endpoint
- Log file permissions: nginx logs `640 root:adm`; bench logs `640 frappe:frappe`
- Log rotation: `logrotate` configured; bench error log retained 30 days (per `environment-spec.md` section 3.7)

---

## 5. Security by Configuration — ERPNext / Frappe Settings Checklist

All settings below must be verified on the production site before go-live. Use Setup > System Settings unless another location is specified.

| Setting | Required Value | Location |
|---|---|---|
| Allow Login Using | Email and Username | System Settings > Login tab |
| Session Expiry | 08:00 | System Settings > Session tab |
| Allow HTTP | Disabled | System Settings (also enforced at Nginx) |
| Login Attempts Before Ban | 5 | System Settings > Security tab |
| Ban Duration (minutes) | 30 | System Settings > Security tab |
| Two Factor Authentication | Enabled | System Settings > Security tab |
| Roles Required for 2FA | System Admin, Finance Manager, Management | System Settings > Security tab |
| Ignore User Permissions if Missing | Disabled | System Settings > Permissions tab |
| Allow all DocTypes for Global Search | Disabled | System Settings > Search tab |
| `developer_mode` | 0 | `common_site_config.json` |
| `allow_cors` | Explicit origin allowlist | `site_config.json` or Nginx |
| Content-Security-Policy | Strict (frame-ancestors 'self'; no inline scripts from unknown origin) | Nginx config |
| X-Frame-Options | SAMEORIGIN | Nginx config (already in `environment-spec.md` SSL block) |
| X-Content-Type-Options | nosniff | Nginx config (already in `environment-spec.md` SSL block) |
| Strict-Transport-Security | max-age=31536000; includeSubDomains | Nginx config (already in `environment-spec.md` SSL block) |
| OCSP Stapling | on | Nginx SSL config (already in `environment-spec.md` section 3.6) |

---

## 6. Development Security Requirements

These requirements apply during development and code review. They are enforced by the Tech Lead in pull request review.

- **SR-DEV-01:** No production data in development or staging environments. Dev uses synthetic sample data only; staging uses anonymized export only — per `environment-spec.md` sections 1.8 and 2.8.
- **SR-DEV-02:** No `print()` statements or `frappe.log_error()` calls that include sensitive field values (NPWP, passwords, health data, GL amounts) in production code paths.
- **SR-DEV-03:** Every `@frappe.whitelist()` decorated method must include an explicit `frappe.has_permission()` check or `frappe.only_for()` guard before executing any data operation. No unauthenticated whitelisted endpoints.
- **SR-DEV-04:** All `frappe.db.sql()` calls must use parameterized queries (`frappe.db.sql(query, (param1, param2))`) — string concatenation into SQL queries is prohibited.
- **SR-DEV-05:** File uploads must validate file type and size server-side (MIME type check + extension allowlist) — client-side validation alone is insufficient.
- **SR-DEV-06:** No hardcoded credentials, tokens, API keys, or passwords in source code. Pre-commit hook must scan for common secret patterns (use `gitleaks` or `detect-secrets`).
- **SR-DEV-07:** `frappe.flags.ignore_permissions = True` usage requires a code comment with: the reason it is needed, the JIRA/GitHub issue reference, and the name of the Tech Lead who approved it.

---

## 7. Dependency Security

- **SR-DEP-01:** ERPNext and Frappe pinned to specific tested versions in `apps.json` / `requirements.txt`. No floating `version-16` branch without a pinned commit SHA in production deploys.
- **SR-DEP-02:** Python dependencies: `pip audit` run monthly in CI pipeline. Results reviewed by Tech Lead.
- **SR-DEP-03:** Node dependencies: `npm audit` run monthly in CI pipeline. Results reviewed by Tech Lead.
- **SR-DEP-04:** Ubuntu system packages: `unattended-upgrades` enabled for security patches only (not automatic full upgrades). Per `environment-spec.md` section 3.4 hardening notes.
- **SR-DEP-05:** Any dependency with a CVE of severity HIGH or CRITICAL triggers an immediate notification to the Tech Lead. Resolution SLA: patch within 7 days for CRITICAL, 30 days for HIGH.
- **SR-DEP-06:** Before each production release: run `bench update --requirements` against the staging environment and verify no dependency conflicts.

---

## Compliance Note

Fundara deployments that handle personal data of Indonesian citizens (donor NIK/NPWP, beneficiary identity) are subject to UU PDP (Undang-Undang Perlindungan Data Pribadi No. 27 Tahun 2022). Data governance, retention policy, and consent management are the responsibility of the deploying organization. The technical controls in this document support but do not substitute for organizational PDP compliance.
