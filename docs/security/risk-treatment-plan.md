# Risk Treatment Plan (RTP)

**Nomor Dokumen:** ISP-007  
**Versi:** 1.0  
**Status:** Aktif  
**Berlaku Sejak:** (diisi setelah ditandatangani)  
**Terakhir Diperbarui:** 2026-06-20  
**Pemilik Dokumen:** Tech Lead  
**Referensi:** ISP-001 § 5.7, ISO/IEC 27001:2022 Klausul 6.1.3, `docs/security/threat-model.md`, `docs/pm/risk-register.md`

---

## 1. Tujuan

Dokumen ini adalah **Risk Treatment Plan (RTP)** formal yang memenuhi persyaratan ISO 27001:2022 Klausul 6.1.3. RTP mengkonsolidasikan seluruh keputusan perlakuan risiko keamanan informasi Fundara ke dalam satu dokumen yang dapat dipantau dan diaudit.

Fundara sudah memiliki `threat-model.md` (18 ancaman STRIDE) dan `risk-register.md` (32 risiko proyek termasuk 5 risiko infrastruktur). RTP ini memetakan setiap risiko keamanan informasi ke:
- **Opsi perlakuan** yang dipilih (Mitigate / Accept / Transfer / Avoid)
- **Kontrol spesifik** yang mengimplementasikan perlakuan tersebut
- **Referensi Annex A** ISO 27001:2022 yang relevan
- **Owner**, **status implementasi**, dan **target penyelesaian**

---

## 2. Opsi Perlakuan Risiko

| Opsi | Definisi | Kapan Dipilih |
|------|----------|---------------|
| **Mitigate** | Terapkan kontrol untuk mengurangi likelihood dan/atau impact | Risiko di atas ambang toleransi; ada kontrol yang layak secara biaya |
| **Accept** | Terima risiko residual tanpa kontrol tambahan | Risiko di bawah ambang toleransi; biaya kontrol melebihi benefit |
| **Transfer** | Alihkan risiko ke pihak ketiga (asuransi, kontrak, cloud provider) | Risiko yang dapat diasuransikan atau didelegasikan secara kontraktual |
| **Avoid** | Hentikan aktivitas yang menghasilkan risiko | Risiko terlalu tinggi dan tidak ada mitigasi yang memadai |

**Ambang toleransi risiko Fundara:** Risk Score ≤ 3 dapat diterima (Accept). Risk Score > 3 harus di-Mitigate. (Skala: Likelihood 1–3 × Impact 1–3 = Score 1–9, per metodologi `threat-model.md`.)

---

## 3. RTP — Ancaman Keamanan (dari `threat-model.md`)

Seluruh 18 ancaman STRIDE yang teridentifikasi dalam threat model. Urutan: score tertinggi terlebih dahulu.

| ID | Ancaman | Score Awal | Score Residual | Opsi | Kontrol Implementasi | Annex A | Owner | Status | Target |
|----|---------|-----------|---------------|------|---------------------|---------|-------|--------|--------|
| **TM-S-01** | Credential stuffing pada login endpoint Frappe | 9 | 3 | **Mitigate** | SR-AUTH-01 (password 12 kar.), SR-AUTH-04 (lockout 5 gagal/30 mnt), `fail2ban` SSH+HTTP jail, SR-AUTH-03 (2FA wajib privileged) | A.8.5 (Authentication), A.8.20 (Network security) | Tech Lead | **Implemented** | Sprint 1 |
| **TM-S-03** | Phishing Finance Manager / System Admin | 6→3 | 3 | **Mitigate** | SR-AUTH-03 (2FA TOTP — credential saja tidak cukup), HSTS mencegah HTTP downgrade; *catatan: user security awareness guide (A.6.3) belum ada — residual* | A.8.5, A.6.3 (Awareness) | Tech Lead + PM | **Partial** | Sprint 1 |
| **TM-E-01** | Field Staff menyetujui Cash Advance milik sendiri | 6→3 | 3 | **Mitigate** | A.5.3 diimplementasi: `has_permission` hook per DocType; Frappe Workflow "Allowed" role per state transition; BDD test scenarios Cash Advance; *test coverage workflow transition perlu dilengkapi sebelum go-live* | A.5.3 (Segregation of duties) | Tech Lead | **Partial** | Sprint 3 |
| **TM-I-01** | Akses tidak sah ke PII donor (field NIK, NPWP) | 6→3 | 3 | **Mitigate** | SR-AUTHZ-03: field masking via `before_load` hook; SR-AUTHZ-02: Role Permission Manager; SR-DEV-03: `has_permission()` wajib di semua whitelist; *custom report yang dibuat ad-hoc perlu code review sebelum diaktifkan* | A.5.15 (Access control), A.5.34 (PII privacy) | Tech Lead | **Partial** | Sprint 2 |
| **TM-I-02** | Data keuangan via API endpoint `@frappe.whitelist()` tanpa permission check | 6→3 | 3 | **Mitigate** | SR-DEV-03: wajib `frappe.has_permission()` atau `frappe.only_for()` di setiap whitelist method; enforced di code review; *automated lint rule (grep) di CI perlu ditambahkan* | A.8.28 (Secure coding), A.5.15 | Tech Lead | **Partial** | Sprint 2 |
| **TM-E-02** | SQL injection via `frappe.db.sql()` dengan string concatenation | 6 | 6 | **Mitigate** | SR-DEV-04: semua `frappe.db.sql()` wajib parameterized; Frappe ORM diutamakan; enforced di code review; *Bandit/static analysis tool belum di CI — perlu ditambahkan* | A.8.28 (Secure coding) | Tech Lead | **Partial** | Sprint 1 |
| **TM-E-03** | `frappe.flags.ignore_permissions = True` di production code path | 6 | 6 | **Mitigate** | SR-DEV-07: penggunaan wajib komentar justifikasi + approval TL; dilarang di production path; *automated grep CI untuk mendeteksi tanpa justifikasi belum ada* | A.8.28, A.5.36 (Compliance monitoring) | Tech Lead | **Partial** | Sprint 1 |
| **TM-R-01** | Staff menyangkal approve transaksi (repudiation) | 4 | 4 | **Mitigate** | SR-LOG-01: Document Versioning mencatat `modified_by` + timestamp setiap state transition; SR-AUTH-01: no shared accounts; *2FA belum wajib untuk semua approver role — residual risk diterima* | A.8.15 (Logging), A.5.16 (Identity management) | Tech Lead | **Partial** | Sprint 2 |
| **TM-D-01** | Heavy report generation menghabiskan resource server (DoS) | 4 | 4 | **Mitigate** | Report berat dijalankan via Frappe background job (long worker); server Profile B/C dengan 8–16 GB RAM; Nginx timeout; *per-user rate limiting untuk heavy report belum diimplementasikan — planned v0.2* | A.8.6 (Capacity management) | Tech Lead | **Partial** | v0.2 |
| **TM-D-02** | Bulk file upload menghabiskan disk (DoS) | 4 | 4 | **Mitigate** | SR-DEV-05: validasi file type + ukuran server-side; Frappe `max_file_size` dikonfigurasi; disk 150 GB SSD; backup volume terpisah; alert disk usage > 80% ke DevOps (monitoring-spec.md) | A.8.6, A.8.12 (Data leakage prevention) | Tech Lead + DevOps | **Partial** | Sprint 1 |
| **TM-T-01** | Direct database manipulation oleh insider DevOps (bypass Frappe layer) | 3 | 3 | **Mitigate + Accept** | MariaDB hanya localhost (SR-ENC-02); SSH dibatasi ke DevOps IPs via UFW; backup offsite GPG-encrypted sebagai evidence independen; *residual insider DevOps risk diterima — dialamatkan dengan ISP-003 offboarding + ISP-006 audit akses quarterly* | A.8.20, A.5.37 (Operating procedures) | DevOps | **Implemented** | Sprint 1 |
| **TM-T-02** | GL Entry manipulation post-submit | 3 | 3 | **Mitigate** | SR-LOG-03: GL Entry immutable setelah submit; reversal-only pattern menciptakan audit trail; tidak ada role yang memiliki amend permission pada GL Entry | A.5.33 (Protection of records) | Tech Lead | **Implemented** | Sprint 1 |
| **TM-S-02** | Session token theft via XSS | 3 | 3 | **Mitigate** | Frappe template output escaping; `X-Content-Type-Options: nosniff`; `X-Frame-Options: SAMEORIGIN`; session cookie HttpOnly; CSP header membatasi sumber script (SR-ENC-02) | A.8.23 (Web filtering), A.8.28 | Tech Lead | **Implemented** | Sprint 1 |
| **TM-I-03** | Backup file interception saat transfer ke offsite storage | 3 | 1 | **Mitigate** | SR-ENC-01: GPG AES-256 encrypt sebelum upload; HTTPS transport; S3 credentials di environment variable (SR-ENC-03); GPG private key di-escrow di credentials vault | A.8.24 (Encryption), A.8.20 | DevOps | **Implemented** | Sprint 1 |
| **TM-T-03** | Audit log tampering (hapus/modifikasi Activity Log) | 3 | 3 | **Mitigate** | SR-LOG-04: tidak ada role dengan delete permission pada Activity Log dan Document Version via UI; akses DB langsung dikontrol via TM-T-01 | A.5.33 | Tech Lead | **Implemented** | Sprint 1 |
| **TM-R-02** | Admin menyangkal perubahan System Settings | 3 | 3 | **Mitigate** | SR-LOG-02: System Settings changes di-log ke Frappe Activity Log; Document Versioning aktif pada Workflow DocType; jumlah System Admin dibatasi minimal | A.8.15, A.5.3 | Tech Lead | **Implemented** | Sprint 1 |
| **TM-I-04** | Data sensitif ter-expose di server log (error log atau bench log) | 3 | 1 | **Mitigate** | SR-DEV-02: larangan `frappe.log_error()` dengan nilai field sensitif di production path; `developer_mode = 0` di production; log hanya via SSH DevOps | A.8.15 | Tech Lead | **Implemented** | Sprint 1 |
| **TM-D-03** | Redis memory exhaustion (cache OOM) | 2 | 2 | **Accept** | Redis hanya localhost (tidak exposed); `maxmemory` dikonfigurasi dengan `allkeys-lru` eviction policy; Frappe TTL pada cache key standar. Risk score 2 di bawah ambang toleransi — kontrol yang ada sudah memadai | A.8.6 | DevOps | **Accepted** | — |

---

## 4. RTP — Risiko Infrastruktur (dari `risk-register.md`)

Risiko dengan implikasi langsung terhadap ketersediaan, integritas, atau kerahasiaan sistem Fundara.

| ID | Risiko | Priority | Opsi | Kontrol Implementasi | Annex A | Owner | Status | Target |
|----|--------|----------|------|---------------------|---------|-------|--------|--------|
| **RISK-INFRA-01** | Disk space exhaustion → production outage | High | **Mitigate** | Alert Netdata disk usage > 80% ke DevOps (monitoring-spec.md); backup volume terpisah; log rotation dikonfigurasi; disk 150 GB SSD per Profile B | A.8.6 (Capacity management) | DevOps | **In Progress** | Sprint 1 |
| **RISK-INFRA-02** | GPG passphrase backup hilang → semua backup tidak dapat di-restore | High | **Mitigate** | GPG private key + passphrase disimpan di credentials vault (ISP-005: L4 Terbatas); minimal 2 copy vault di lokasi berbeda; prosedur verifikasi GPG encrypt/decrypt di ISP-006 item C.3 | A.8.24 (Encryption), A.8.12 | DevOps | **In Progress** | Sprint 1 |
| **RISK-INFRA-03** | SSL certificate expired / Certbot gagal renew | Medium | **Mitigate** | Uptime Kuma monitor SSL expiry — alert bila < 30 hari tersisa; ISP-006 item I.4: verifikasi SSL expiry setiap quarterly review; Let's Encrypt auto-renew dikonfigurasi via cron | A.8.23 (Web filtering) | DevOps | **In Progress** | Sprint 1 |
| **RISK-INFRA-04** | ERPNext major upgrade (v16 → v17+) merusak custom Fundara | Medium | **Mitigate** | `docs/infra/upgrade-runbook.md` (prosedur upgrade + rollback terdokumentasi); versi di-pin di `apps.txt`; staging environment digunakan untuk test upgrade sebelum production | A.8.32 (Change management) | Tech Lead | **Implemented** | Sprint 1 |
| **RISK-INFRA-05** | Redis cache cross-site contamination (post-D-06 multi-tenancy) | Low | **Accept** | Tidak relevan hingga D-06 diimplementasikan (saat ini DEFERRED). Saat D-06 diaktifkan, wajib review arsitektur Redis: separate Redis instance per site, atau namespace isolation | A.8.6 | Tech Lead | **Accepted (pending D-06)** | Pre D-06 |

---

## 5. RTP — Risiko Proyek dengan Implikasi Keamanan Informasi

Risiko dari `risk-register.md` non-INFRA yang memiliki implikasi langsung terhadap keamanan data.

| ID | Risiko | Priority | Opsi | Kontrol Implementasi | Annex A | Owner | Status | Target |
|----|--------|----------|------|---------------------|---------|-------|--------|--------|
| **RISK-DOMAIN-04** | Data benefisiari (anak, kelompok rentan) diproses tanpa kontrol privasi memadai | High | **Mitigate** | `docs/security/data-privacy.md`: field akses dibatasi per project/PIC; consent tracking; field masking Beneficiary; hanya Project Manager + Field Staff proyek terkait yang dapat akses; ISP-005: data benefisiari kesehatan → L4 Terbatas | A.5.34 (PII protection), A.5.15, A.5.12 | Tech Lead + PM | **In Progress** | Sprint 2 |
| **RISK-QUAL-03** | Row-level security (Fund × Role) tidak diimplementasikan secara konsisten — Finance Officer kantor A bisa akses data kantor B | High | **Mitigate** | `docs/spec/permissions.md`: Conditional Permissions — scope filter per `project_manager` / `requester` di `has_permission` hook; BDD test scenario cross-fund access dikembangkan sebelum go-live | A.5.15, A.5.3 | Tech Lead | **In Progress** | Sprint 3 |
| **RISK-TECH-07** | Frappe `@whitelist` API tanpa autentikasi yang cukup berpotensi dieksploitasi dari luar | High | **Mitigate** | SR-DEV-03: semua `@frappe.whitelist()` wajib ada `has_permission()` atau `frappe.only_for()`; pentest scope `docs/security/pentest-scope.md` mencakup API fuzzing; automated grep CI (planned Sprint 1) | A.8.28, A.5.15 | Tech Lead | **In Progress** | Sprint 1 |

---

## 6. Ringkasan Status Implementasi Kontrol

| Status | Jumlah Risiko | Keterangan |
|--------|--------------|------------|
| **Implemented** | 9 | Kontrol sudah ada dan berfungsi; diverifikasi di ISP-006 |
| **Partial** | 10 | Kontrol sebagian ada; ada item lanjutan yang perlu diselesaikan sebelum go-live |
| **In Progress** | 5 | Kontrol sedang dibangun; target sprint tercantum |
| **Accepted** | 2 | Risk score di bawah toleransi atau risiko tidak relevan (D-06 deferred) |
| **Total** | **26** | |

**Risiko yang harus selesai sebelum go-live (Partial/In Progress — bukan Accept/v0.2):**
1. TM-S-03: User security awareness guide untuk NGO staff
2. TM-E-01: BDD test coverage untuk Cash Advance workflow transition
3. TM-I-01: Code review wajib untuk semua custom report yang akses Donor/Beneficiary
4. TM-I-02: Automated lint rule untuk `@whitelist` tanpa `has_permission`
5. TM-E-02: Static analysis (Bandit) di CI pipeline
6. TM-E-03: Automated grep di CI untuk `ignore_permissions` tanpa justifikasi
7. TM-R-01: 2FA diperluas ke lebih banyak approver role
8. TM-D-02: Alert disk usage > 80% dikonfigurasi di Netdata
9. RISK-INFRA-01: Disk monitoring alert aktif
10. RISK-INFRA-02: GPG passphrase escrow formal di credentials vault
11. RISK-INFRA-03: SSL expiry monitoring aktif di Uptime Kuma
12. RISK-DOMAIN-04: Field masking Beneficiary diimplementasikan
13. RISK-QUAL-03: Cross-fund access BDD test selesai
14. RISK-TECH-07: `@whitelist` audit + automated grep CI

---

## 7. Statement of Applicability (SoA) — Ringkasan

Dokumen audit lengkap ada di `docs/security/iso27001-audit.md`. Tabel berikut merangkum kontrol Annex A yang **dipilih dan diterapkan** untuk Fundara (bukan daftar 93 kontrol — hanya yang diaktifkan).

| Annex A | Kontrol | Alasan Pemilihan | Implementasi |
|---------|---------|-----------------|-------------|
| A.5.1 | Policies for information security | Wajib ISO 27001 | ISP-001 Information Security Policy |
| A.5.3 | Segregation of duties | Fundara menangani transaksi keuangan; satu orang tidak boleh approve transaksi sendiri | Frappe Workflow + `has_permission` hook |
| A.5.12 | Classification of information | Data NGO bervariasi sensitivitasnya (L1–L4) | ISP-005 Information Classification Policy |
| A.5.15 | Access control | Multi-role multi-dokumen; data perlu dibatasi per role, project, fund | RBAC `permissions.md`; SR-AUTHZ-01–04 |
| A.5.16 | Identity management | No shared accounts; user lifecycle | Frappe user management; SR-AUTH-01 |
| A.5.17 | Authentication information | Password policy, 2FA, API key rotation | SR-AUTH-01/03/05; SR-ENC-03 |
| A.5.24 | Incident management planning | Fundara menangani data donor sensitif — response plan wajib | `docs/security/incident-response.md` |
| A.5.25 | Assessment of security events | Perlu triase insiden vs false positive | IRP 4-level classification |
| A.5.26 | Response to incidents | Prosedur containment dan remediation | IRP Fase 2–4 |
| A.5.27 | Learning from incidents | Continual improvement ISMS | IRP Fase 5 Post-Incident Report |
| A.5.33 | Protection of records | GL Entry immutable; audit trail | SR-LOG-01/03/04; Frappe Document Versioning |
| A.5.34 | Privacy and protection of PII | UU PDP No. 27/2022; donor NIK/NPWP; beneficiary data | `docs/security/data-privacy.md`; field masking |
| A.5.36 | Compliance with policies | Verifikasi implementasi kontrol | ISP-006 Internal Audit Checklist |
| A.5.37 | Documented operating procedures | Deploy, upgrade, backup, monitoring harus terdokumentasi | `docs/infra/` (deploy.sh, upgrade-runbook.md, backup-recovery.md) |
| A.6.3 | Security awareness | Staf NGO perlu panduan keamanan dasar | *Planned — user-security-guide.md* |
| A.6.5 | Responsibilities after termination | Mantan developer sebagai threat actor | ISP-003 Offboarding Checklist |
| A.6.6 | NDA / confidentiality agreements | Data donor dan source code bersifat rahasia | ISP-004 NDA Template |
| A.8.5 | Secure authentication | Credential stuffing; brute force | SR-AUTH-01/03/04; fail2ban |
| A.8.6 | Capacity management | Disk exhaustion; Redis OOM; heavy reports | monitoring-spec.md; SR-DEV-05 |
| A.8.15 | Logging | Non-repudiation; forensik insiden | SR-LOG-01/02/04; Frappe Activity Log |
| A.8.20 | Network security | DB tidak exposed; SSH terbatas; internal port binding | SR-ENC-02; UFW rules; environment-spec.md |
| A.8.24 | Encryption | Backup offsite; credential storage | SR-ENC-01/03; GPG AES-256 |
| A.8.28 | Secure coding | SQL injection; XSS; privilege escalation | SR-DEV-01–07; CONTRIBUTING.md |
| A.8.32 | Change management | Upgrade ERPNext; perubahan konfigurasi | upgrade-runbook.md; DECISIONS.md; git PR process |

**Kontrol yang dikecualikan dengan justifikasi** (seluruh daftar di `iso27001-audit.md`):
- A.7.x (Physical controls): tanggung jawab hosting provider
- A.6.1 (Screening): tanggung jawab NGO deployer, bukan Fundara project
- A.5.6 (Special interest groups): tidak relevan untuk tim kecil saat ini

---

## 8. Review RTP

RTP ini direview bersamaan dengan:
- Audit internal tahunan (ISP-006) — apakah status implementasi kontrol berubah?
- Setiap perubahan scope ISMS (ISP-002) — apakah ada risiko baru?
- Setelah setiap insiden keamanan — apakah ada kontrol yang perlu ditambahkan?
- Saat D-06 (multi-tenancy) diputuskan — RISK-INFRA-05 harus direview

---

## 9. Tanda Tangan

| Peran | Nama | Tanggal | Tanda Tangan |
|-------|------|---------|--------------|
| Tech Lead (Pemilik Dokumen) | | | |
| Project Manager | | | |
| Product Owner (Pimpinan) | | | |

---

*RTP ini adalah bagian dari ISMS Fundara. Untuk rincian tiap ancaman, lihat `docs/security/threat-model.md`. Untuk rincian tiap kontrol Annex A, lihat `docs/security/iso27001-audit.md`. Untuk prosedur verifikasi implementasi kontrol, lihat `docs/security/internal-audit-checklist.md` (ISP-006).*
