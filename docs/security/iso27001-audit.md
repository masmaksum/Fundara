# AUDIT KEPATUHAN ISO 27001:2022
## Fundara — Fund-Centric ERP untuk NGO

```
Tanggal audit   : 19 Juni 2026
Auditor         : Internal (berdasarkan dokumen proyek)
Versi dokumen   : 1.0
Status          : DRAFT — belum diverifikasi oleh auditor eksternal
```

---

## 1. Executive Summary

### Objek Audit

Dokumen ini adalah **gap analysis kepatuhan ISO/IEC 27001:2022** terhadap Fundara — sebuah *fund-centric* ERP untuk organisasi non-pemerintah (NGO/YPN/LSM) yang dibangun di atas ERPNext v16 dan Frappe Framework. Audit ini mengevaluasi **dokumentasi proyek** dan **fitur keamanan yang direncanakan** dalam implementasi, bukan kode yang sudah berjalan di produksi.

**Penting untuk dipahami:** ISO 27001:2022 adalah standar untuk *Information Security Management System* (ISMS) **organisasi**, bukan untuk *software product*. Sertifikasi ISO 27001 yang sesungguhnya dilakukan oleh badan sertifikasi terakreditasi eksternal (seperti BSI, Bureau Veritas, atau TÜV) terhadap **organisasi yang menjalankan Fundara** — bukan terhadap software Fundara itu sendiri. Audit ini menilai sejauh mana dokumentasi Fundara menyediakan fondasi teknis dan governance yang memadai sebagai dasar implementasi keamanan, sehingga sebuah organisasi yang mengadopsi Fundara memiliki titik awal yang kuat menuju kepatuhan ISO 27001.

### Referensi Standar

Audit ini mengacu pada **ISO/IEC 27001:2022** (bukan edisi 2013). Perbedaan signifikan antara kedua edisi meliputi: penambahan 11 kontrol baru di Annex A (termasuk kontrol cloud services, threat intelligence, dan ICT supply chain); penggabungan beberapa kontrol yang sebelumnya terpisah; dan perubahan struktur Annex A dari 14 klausul menjadi 4 tema (Organizational, People, Physical, Technological).

### Ringkasan Hasil

Evaluasi dilakukan terhadap **93 kontrol** yang berlaku dalam ISO 27001:2022 (Klausul 4–10 + Annex A). Distribusi status:

| Status | Jumlah Kontrol | Persentase |
|---|---|---|
| ✅ **Sesuai** | ~33 | ~35% |
| ⚠️ **Sebagian** | ~28 | ~30% |
| ❌ **Belum Ada** | ~19 | ~20% |
| **N/A** | ~13 | ~15% |

*Catatan: Angka di atas adalah estimasi berdasarkan analisis dokumen per 19 Juni 2026. Jumlah pasti dikonfirmasi di bagian detail masing-masing klausul dan Annex A.*

### Top 5 Gap Paling Kritikal

Gap berikut adalah yang paling mendesak untuk ditutup sebelum go-live atau sebelum organisasi pengguna memulai proses sertifikasi:

1. **Tidak ada Information Security Policy formal (A.5.1, Klausul 5.2).** Dokumen `security-requirements.md` berperan *de facto* sebagai kebijakan, tetapi bukan dokumen kebijakan yang berdiri sendiri, ditandatangani pimpinan, dan dikomunikasikan ke seluruh pemangku kepentingan. Ini adalah *showstopper* untuk sertifikasi ISO 27001.

2. **Tidak ada Risk Treatment Plan (RTP) formal (Klausul 6.1.3).** Fundara memiliki threat model dan risk register yang baik, tetapi tidak ada dokumen yang secara eksplisit memetakan setiap risiko ke kontrol ISO 27001 spesifik, PIC, anggaran mitigasi, dan timeline implementasi. RTP adalah persyaratan wajib standar.

3. **Tidak ada program Internal Audit ISMS (Klausul 9.2).** Tanpa siklus audit internal, tidak ada mekanisme untuk memverifikasi bahwa kontrol yang direncanakan benar-benar diimplementasikan dan berfungsi. Ini juga *showstopper* untuk sertifikasi.

4. **Tidak ada Acceptable Use Policy / AUP (A.5.10).** Pengguna akhir NGO tidak memiliki panduan tertulis tentang apa yang boleh dan tidak boleh dilakukan dengan data dan sistem. Untuk software yang menangani data donor dan benefisiari yang sensitif, AUP adalah kontrol organisasi fundamental.

5. **Tidak ada Business Continuity Plan formal (A.5.29, A.5.30).** Prosedur backup dan restore sudah ada dan baik (`backup-recovery.md`), tetapi BCP yang mencakup skenario kegagalan yang lebih luas, peran selama gangguan, komunikasi krisis, dan pengujian berkala belum terdokumentasi.

### Rekomendasi Utama

Berdasarkan gap analysis ini, rekomendasi prioritas untuk tim Fundara dan organisasi yang akan mengadopsinya:

1. **Jangka pendek (sebelum go-live, 0–4 minggu):** Susun Information Security Policy 1–2 halaman yang mencakup komitmen pimpinan, prinsip keamanan, dan referensi ke dokumen teknis yang ada. Dokumen ini tidak harus panjang — kualitas dan komitmen yang menjadi kunci.

2. **Jangka pendek (sebelum go-live, 0–4 minggu):** Buat Risk Treatment Plan yang memetakan 27 risiko dari `risk-register.md` dan 16 ancaman dari `threat-model.md` ke kontrol Annex A ISO 27001:2022, lengkap dengan PIC dan target penyelesaian.

3. **Jangka menengah (1–3 bulan setelah go-live):** Implementasikan program Internal Audit ISMS minimal setahun sekali, menggunakan dokumen ini sebagai checklist awal.

4. **Jangka menengah (1–3 bulan setelah go-live):** Susun Acceptable Use Policy untuk pengguna akhir NGO, dan integrasikan ke dalam proses onboarding pengguna.

5. **Jangka menengah (1–3 bulan setelah go-live):** Lengkapi Business Continuity Plan dengan skenario gangguan di luar kegagalan teknis (kehilangan staf kunci, bencana alam, gangguan penyedia hosting).

---

## 2. Ruang Lingkup Audit

### Objek Audit

- **Dokumentasi proyek Fundara** yang tersimpan di repositori `masmaksum/Fundara`
- **Fitur keamanan yang direncanakan** dalam implementasi Frappe/ERPNext v16
- **Arsitektur dan desain keamanan** sebagaimana tercermin dalam dokumen spesifikasi

### Referensi Standar

- **ISO/IEC 27001:2022** — Information security, cybersecurity and privacy protection — Information security management systems — Requirements
- **ISO/IEC 27002:2022** — sebagai panduan implementasi untuk Annex A kontrol

### Batasan Audit

- Audit ini **menilai dokumen**, bukan kode yang sudah berjalan. Beberapa kontrol yang bergantung pada implementasi aktual belum dapat diverifikasi secara teknis.
- **Kontrol A.7 (Physical Controls)** sebagian besar tidak relevan untuk software product dan ditandai N/A. Tanggung jawab keamanan fisik berada pada penyedia hosting/datacenter.
- **Kebijakan HR organisasi pengguna** (rekrutmen, pelatihan, terminasi) adalah tanggung jawab masing-masing NGO yang mengadopsi Fundara.
- **Infrastruktur fisik datacenter** adalah tanggung jawab penyedia hosting (Hetzner, AWS, Biznet, atau setara).

### Dokumen yang Dievaluasi

| Kategori | Dokumen |
|---|---|
| Keamanan | `docs/security/security-requirements.md`, `docs/security/threat-model.md`, `docs/security/data-privacy.md`, `docs/security/incident-response.md`, `docs/security/owasp-checklist.md`, `docs/security/pentest-scope.md` |
| Spesifikasi | `docs/spec/permissions.md`, `docs/spec/workflows.md`, `docs/spec/doctypes/` |
| Infrastruktur | `docs/infra/environment-spec.md`, `docs/infra/backup-recovery.md`, `docs/infra/deploy.sh`, `docs/infra/monitoring-spec.md`, `docs/infra/upgrade-runbook.md` |
| Manajemen Proyek | `docs/pm/raci.md`, `docs/pm/risk-register.md`, `docs/pm/complexity.md`, `docs/pm/definition-of-done.md` |
| QA | `docs/qa/test-plan.md`, `docs/qa/bug-severity-matrix.md`, `docs/qa/regression-checklist.md` |
| Akuntansi | `docs/accounting/` (ISAK 35 mapping) |
| Umum | `DECISIONS.md`, `READINESS.md`, `CONTRIBUTING.md`, `README.md` |

### Yang Tidak Dicakup

- Infrastruktur fisik datacenter (tanggung jawab hosting provider)
- Kebijakan HR dan rekrutmen organisasi pengguna NGO (tanggung jawab organisasi yang deploy)
- Penilaian terhadap kode sumber yang sudah ditulis (audit ini bersifat dokumen-sentris)
- Sertifikasi formal (di luar cakupan; memerlukan badan sertifikasi eksternal terakreditasi)

---

## 3. Metodologi

### Pendekatan Evaluasi

Setiap kontrol ISO 27001:2022 dievaluasi terhadap dua dimensi:
1. **Apakah ada dokumen yang mengatur kontrol tersebut?** — menilai kelengkapan dokumentasi
2. **Apakah ada implementasi teknis yang direncanakan?** — menilai kesiapan teknis

Status ditentukan berdasarkan *evidence* yang dapat diidentifikasi di repositori Fundara:
- ✅ **Sesuai** — kontrol sudah tercakup penuh oleh dokumen atau fitur Fundara
- ⚠️ **Sebagian** — ada coverage sebagian, ada gap yang perlu ditutup
- ❌ **Belum Ada** — kontrol belum tercakup sama sekali
- **N/A** — kontrol tidak berlaku untuk konteks Fundara (software product, bukan organisasi yang disertifikasi)

### Kriteria Gap

Gap dinilai berdasarkan kritikalitas terhadap operasi NGO yang menangani:
- Data donor sensitif (NIK, NPWP, jumlah donasi)
- Data benefisiari (termasuk anak dan kelompok rentan)
- Data keuangan organisasi (Fund, GL Entry, Grant)

Gap yang dapat menyebabkan pelanggaran UU PDP No. 27/2022, kegagalan audit donor, atau hilangnya kepercayaan pemangku kepentingan diprioritaskan lebih tinggi.

---

## 4. ISO 27001:2022 Clauses 4–10 — Main Body Requirements

Klausul 4–10 adalah **persyaratan utama standar** yang wajib dipenuhi organisasi untuk mendapatkan sertifikasi. Untuk Fundara sebagai software product, klausul ini dievaluasi sebagai panduan desain governance dan arsitektur keamanan yang akan mendukung organisasi pengguna.

---

### Clause 4: Context of the Organization

| Sub-clause | Judul | Status | Evidence / Dokumen Fundara | Gap / Catatan |
|---|---|---|---|---|
| 4.1 | Understanding the organization and its context | ⚠️ **Sebagian** | `README.md` (visi produk, konteks NGO Indonesia), `DECISIONS.md` (keputusan arsitektur yang mencerminkan konteks bisnis) | Tidak ada dokumen formal "context of organization" yang mengidentifikasi isu internal/eksternal secara sistematis sesuai format ISO 27001 (internal: budaya, kemampuan, governance; eksternal: regulasi, teknologi, pasar). Konteks NGO Indonesia tersebar di beberapa dokumen tanpa konsolidasi |
| 4.2 | Understanding the needs and expectations of interested parties | ⚠️ **Sebagian** | Roadmap (stakeholder: donor, benefisiari, staf NGO), `docs/pm/raci.md` (8 role dengan tanggung jawab terdefinisi), `docs/security/data-privacy.md` (mengidentifikasi subjek data dan hak mereka) | Tidak ada *stakeholder register* formal yang mendokumentasikan: siapa saja pemangku kepentingan, kebutuhan dan ekspektasi keamanan informasi per pemangku kepentingan, dan mana yang relevan untuk ISMS |
| 4.3 | Determining the scope of the ISMS | ✅ **Sesuai** | `docs/security/isms-scope.md` (ISP-002 v1.0 — scope ISMS formal: pernyataan ruang lingkup, batas teknologi/fisik/organisasi, daftar pengecualian dengan justifikasi, antarmuka eksternal, gambaran siklus PDCA, pihak berkepentingan, konteks organisasi). `docs/infra/environment-spec.md` (detail teknis aset). | **(Gap telah ditutup 2026-06-20)** Dokumen scope ISMS berdiri sendiri, mencakup: aset yang dicakup (kode, staging, produksi, backup, monitoring, kredensial, data NGO), pengecualian yang justified (hosting fisik, upstream ERPNext, IT internal NGO), antarmuka eksternal dan kontrol di setiap antarmuka, kondisi yang memicu revisi scope. **Menunggu tanda tangan Pimpinan (PO).** |
| 4.4 | Information security management system | ❌ **Belum Ada** | — | Tidak ada **ISMS Policy Document** yang mengintegrasikan semua komponen keamanan menjadi satu sistem yang terkelola. Dokumen `security-requirements.md` adalah spesifikasi teknis, bukan ISMS yang mencakup siklus PDCA (Plan-Do-Check-Act). Gap ini adalah yang paling fundamental: tanpa ISMS framework, semua kontrol lain berdiri sendiri-sendiri tanpa integrasi |

---

### Clause 5: Leadership

| Sub-clause | Judul | Status | Evidence / Dokumen Fundara | Gap / Catatan |
|---|---|---|---|---|
| 5.1 | Leadership and commitment | ⚠️ **Sebagian** | `docs/pm/raci.md` (Tech Lead sebagai *Accountable* untuk keputusan keamanan teknis), `CONTRIBUTING.md` (komitmen developer terhadap standar keamanan), `docs/pm/definition-of-done.md` (security checklist di MVP DoD menunjukkan komitmen manajerial) | Tidak ada **pernyataan komitmen pimpinan (management statement)** terhadap keamanan informasi yang ditandatangani. ISO 27001:2022 Klausul 5.1 secara eksplisit mensyaratkan demonstrasi *leadership and commitment* dari pimpinan tertinggi — dalam konteks proyek ini, ini berarti pernyataan resmi dari Product Owner atau pimpinan organisasi yang mengadopsi Fundara |
| 5.2 | Policy | ✅ **Sesuai** | `docs/security/is-policy.md` (ISP-001 v1.0 — Information Security Policy formal: tujuan ISMS, ruang lingkup, 12 area kebijakan, tujuan terukur, peran & tanggung jawab, pelanggaran, pengecualian, jadwal review, referensi dokumen turunan, blok tanda tangan pimpinan). `docs/security/security-requirements.md` (implementasi teknis kontrol). | **(Gap telah ditutup 2026-06-20)** IS Policy formal tersedia sebagai dokumen terdokumentasi (ISP-001). Mencakup seluruh 6 persyaratan Klausul 5.2: (a) sesuai tujuan organisasi, (b) komitmen memenuhi persyaratan keamanan, (c) komitmen peningkatan berkelanjutan, (d) tersedia sebagai informasi terdokumentasi, (e) dikomunikasikan dalam organisasi, (f) tersedia untuk pihak berkepentingan. **Menunggu tanda tangan Pimpinan (PO) untuk berlaku efektif.** |
| 5.3 | Organizational roles, responsibilities and authorities | ✅ **Sesuai** | `docs/pm/raci.md` (RACI matrix 25 aktivitas × 8 role proyek: PO, PM, TL, DEV, QA, FE, PE, UX), `docs/spec/permissions.md` (13 role RBAC dengan tanggung jawab terdefinisi per DocType), `docs/security/threat-model.md` (trust level per aktor dan tanggung jawab keamanan) | Struktur peran dan tanggung jawab terdokumentasi dengan baik. RACI mencakup siklus penuh proyek. Permission matrix mencakup 13 role × 30+ DocType dengan penjelasan tanggung jawab per role |

---

### Clause 6: Planning

| Sub-clause | Judul | Status | Evidence / Dokumen Fundara | Gap / Catatan |
|---|---|---|---|---|
| 6.1.1 | General — actions to address risks and opportunities | ✅ **Sesuai** | `docs/pm/risk-register.md` (27 risiko dalam 5 kategori: Technical, Domain, Scope, Delivery, Quality), `docs/security/threat-model.md` (16 ancaman STRIDE dengan risk score), `docs/pm/definition-of-done.md` (security gate di setiap sprint) | Proses identifikasi risiko dan peluang sudah ada dan terdokumentasi dengan baik. Risk register mencakup kategori risiko yang luas, bukan hanya keamanan informasi |
| 6.1.2 | Information security risk assessment | ✅ **Sesuai** | `docs/security/threat-model.md` (metodologi STRIDE; risk matrix Likelihood × Impact; 18 ancaman dengan risk score 2–9; residual risk per ancaman), `docs/pm/risk-register.md` (27 risiko dengan likelihood, impact, dan priority terdokumentasi) | Metodologi penilaian risiko keamanan informasi ada dan terdokumentasi. STRIDE analysis memberikan pendekatan sistematis. Risk scoring konsisten. Dokumentasi aset yang dilindungi (9 kategori aset dengan sensitivitas) memenuhi persyaratan inventarisasi aset untuk risk assessment |
| 6.1.3 | Information security risk treatment | ⚠️ **Sebagian** | `docs/security/security-requirements.md` (mitigasi teknis per kategori risiko), `docs/security/threat-model.md` (mitigasi per ancaman STRIDE dengan residual risk), `docs/infra/backup-recovery.md` (risk treatment untuk availability) | Tidak ada **Risk Treatment Plan (RTP)** formal yang memenuhi persyaratan Klausul 6.1.3: (a) pilihan treatment per risiko (accept/transfer/avoid/reduce), (b) kontrol Annex A yang dipilih dan justifikasinya, (c) Statement of Applicability (SoA). Mitigasi tersebar di berbagai dokumen tanpa konsolidasi formal dalam satu RTP. Ini adalah **gap kritikal #2** |
| 6.2 | Information security objectives and planning to achieve them | ❌ **Belum Ada** | — | Tidak ada dokumen formal **security objectives** yang memenuhi persyaratan: (a) konsisten dengan kebijakan keamanan informasi, (b) dapat diukur, (c) mempertimbangkan persyaratan keamanan yang berlaku, (d) dipantau, (e) dikomunikasikan, (f) diperbarui sesuai kebutuhan. Tidak ada target KPI keamanan yang terukur (misalnya: waktu patch CVE Critical ≤ 7 hari, uptime 99.5%, MTTD insiden ≤ 4 jam) |
| 6.3 | Planning of changes | ⚠️ **Sebagian** | `docs/dev/git-branching.md` (strategi branch dan PR process), `docs/infra/upgrade-runbook.md` (prosedur upgrade terdokumentasi), `DECISIONS.md` (perubahan arsitektur dikelola secara formal) | Tidak ada **change management policy** formal yang mencakup evaluasi dampak keamanan untuk setiap perubahan. Proses PR dan DECISIONS.md adalah praktik yang baik, tetapi belum secara eksplisit mewajibkan security impact assessment untuk setiap perubahan signifikan |

---

### Clause 7: Support

| Sub-clause | Judul | Status | Evidence / Dokumen Fundara | Gap / Catatan |
|---|---|---|---|---|
| 7.1 | Resources | ⚠️ **Sebagian** | `docs/pm/complexity.md` (estimasi 145 dev-days, alokasi resource per konteks), `docs/pm/raci.md` (8 role dengan alokasi tanggung jawab), `docs/pm/risk-register.md` (RISK-DELIV-01 mengidentifikasi ketersediaan domain expert sebagai risiko kritis) | Tidak ada **resource plan khusus untuk keamanan** yang mengalokasikan waktu, anggaran, dan personel untuk aktivitas keamanan: penetration testing, security review, audit, training. Sumber daya proyek didokumentasikan dari perspektif delivery, bukan perspektif ISMS |
| 7.2 | Competence | ⚠️ **Sebagian** | `CONTRIBUTING.md` (panduan kompetensi developer), `docs/dev/local-setup.md` (setup environment yang mengindikasikan kompetensi teknis minimum), `docs/security/security-requirements.md` (SR-DEV-* mensyaratkan pengetahuan keamanan spesifik Frappe) | Tidak ada **kompetensi minimum keamanan** yang didokumentasikan per role. Persyaratan keamanan untuk developer ada (SR-DEV), tetapi tidak ada matrik kompetensi formal, tidak ada proses verifikasi kompetensi, dan tidak ada ketentuan untuk peran non-teknis (PM, QA, domain expert) |
| 7.3 | Awareness | ⚠️ **Sebagian** | `CONTRIBUTING.md` (SR-DEV rules untuk developer — security awareness khusus developer), `docs/security/security-requirements.md` (menjelaskan kontrol teknis yang perlu dipahami tim), `docs/security/threat-model.md` (awareness tentang ancaman dan aktor) | Tidak ada **security awareness program** untuk pengguna akhir NGO. Awareness yang ada hanya untuk developer/DevOps. Tidak ada: materi onboarding keamanan untuk staf NGO, panduan penggunaan sistem yang aman untuk pengguna biasa, training plan berkala, atau mekanisme pengujian awareness (misalnya: phishing simulation) |
| 7.4 | Communication | ⚠️ **Sebagian** | `docs/pm/raci.md` (alur komunikasi antar peran proyek), `docs/security/incident-response.md` (prosedur notifikasi selama insiden: war room, Kominfo/BSSN, subjek data), `docs/security/data-privacy.md` (komunikasi dengan subjek data) | Tidak ada **communication plan formal untuk ISMS** yang mendefinisikan: apa yang dikomunikasikan, kapan, kepada siapa, oleh siapa, dan melalui saluran apa — untuk komunikasi internal dan eksternal terkait keamanan informasi di luar konteks insiden |
| 7.5 | Documented information | ✅ **Sesuai** | `READINESS.md` (inventaris komprehensif semua dokumen: status, owner, tanggal), 50+ file dokumentasi terstruktur, Git version control (setiap perubahan terlacak dengan author, timestamp, dan pesan commit), format yang konsisten (Markdown dengan header versi dan tanggal) | Pengelolaan informasi terdokumentasi sudah baik. Dokumentasi di-version control, terstruktur, dan mudah ditemukan. Setiap dokumen keamanan memiliki versi, tanggal update, dan audience |

---

### Clause 8: Operation

| Sub-clause | Judul | Status | Evidence / Dokumen Fundara | Gap / Catatan |
|---|---|---|---|---|
| 8.1 | Operational planning and control | ✅ **Sesuai** | `docs/infra/deploy.sh` (deployment script), `docs/infra/environment-spec.md` (spesifikasi 3 profile deployment), `docs/dev/dev-workflow.md` (alur pengembangan), `docs/pm/definition-of-done.md` (DoD dengan security gates), `docs/infra/upgrade-runbook.md` (prosedur upgrade operasional) | Perencanaan dan kontrol operasional terdokumentasi dengan baik untuk siklus development dan deployment. Security gate di DoD memastikan keamanan dipertimbangkan di setiap sprint |
| 8.2 | Information security risk assessment (periodic) | ⚠️ **Sebagian** | `docs/pm/risk-register.md` (Top 5 untuk *weekly PM monitoring*), `docs/security/threat-model.md` (STRIDE analysis komprehensif), `docs/security/incident-response.md` (review tahunan disebutkan di header dokumen) | Tidak ada **jadwal formal periodic risk assessment** yang terdokumentasi. Review insidental disebutkan tetapi tidak ada: frekuensi yang ditetapkan, trigger untuk reassessment (misalnya: perubahan sistem signifikan, insiden, perubahan regulasi), format output reassessment, dan PIC yang bertanggung jawab |
| 8.3 | Information security risk treatment | ⚠️ **Sebagian** | `docs/security/security-requirements.md` (implementasi mitigasi teknis), `docs/infra/backup-recovery.md` (risk treatment untuk availability dan recovery) | Gap sama dengan Klausul 6.1.3: tidak ada RTP formal yang mengkonsolidasikan semua treatment decisions. Implementasi teknis ada dan baik, tetapi tidak terikat ke risk treatment decisions secara formal |

---

### Clause 9: Performance Evaluation

| Sub-clause | Judul | Status | Evidence / Dokumen Fundara | Gap / Catatan |
|---|---|---|---|---|
| 9.1 | Monitoring, measurement, analysis and evaluation | ⚠️ **Sebagian** | `docs/infra/monitoring-spec.md` (Netdata + Uptime Kuma untuk monitoring infrastruktur), `docs/qa/test-plan.md` (8 metrik kualitas terdokumentasi), `docs/security/threat-model.md` (risk score sebagai metrik) | Tidak ada **security-specific KPI** yang dimonitor secara berkelanjutan. Monitoring yang ada berfokus pada availability dan performa, bukan keamanan informasi. Gap: tidak ada metrik untuk jumlah security incident per periode, Mean Time to Detect (MTTD), Mean Time to Respond (MTTR), jumlah CVE terbuka, atau tingkat keberhasilan patch dalam SLA |
| 9.2 | Internal audit | ✅ **Sesuai** | `docs/security/internal-audit-checklist.md` (ISP-006 v1.0 — **BARU 2026-06-20**) — Program audit + checklist operasional: (a) Program audit: frekuensi tahunan + quarterly akses review + trigger-based, persyaratan independensi auditor, 6-langkah siklus audit (plan → prepare → execute → report → corrective action → verify); (b) Checklist 50 item dalam 8 domain: A. Governance (7 item), B. Akses & Identitas (9 item), C. Backup & Recovery (6 item), D. Patch & Vulnerability (5 item), E. Server & Jaringan (7 item), F. Keamanan Kode (6 item), G. Manajemen Insiden (4 item), H. Privasi Data (6 item); (c) Setiap item: cara verifikasi konkret (perintah CLI spesifik), bukti yang diharapkan, kolom status S/P/T/N; (d) Template temuan, skor ringkasan (≥90% = baik), jadwal audit, riwayat audit antar edisi | **(Gap telah ditutup 2026-06-20)** Audit pertama dijadwalkan 3 bulan setelah go-live. |
| 9.3 | Management review | ❌ **Belum Ada** | — | Tidak ada **prosedur management review ISMS**. ISO 27001:2022 Klausul 9.3 mewajibkan review berkala oleh pimpinan yang mencakup: status tindakan dari review sebelumnya, perubahan isu internal/eksternal, kinerja dan efektivitas ISMS, umpan balik dari pemangku kepentingan, hasil risk assessment. Tidak ada dokumen yang mendefinisikan frekuensi, agenda, atau output review manajemen |

---

### Clause 10: Improvement

| Sub-clause | Judul | Status | Evidence / Dokumen Fundara | Gap / Catatan |
|---|---|---|---|---|
| 10.1 | Continual improvement | ⚠️ **Sebagian** | `docs/security/incident-response.md` (Fase 5 Lessons Learned dengan format post-incident report), `docs/qa/regression-checklist.md` (checklist perbaikan berkala), `docs/pm/risk-register.md` (risiko di-review dan diperbarui) | Tidak ada **program continual improvement formal untuk ISMS**. Lessons learned dari insiden ada, tetapi tidak ada mekanisme sistematis untuk mengintegrasikan pembelajaran ke dalam perbaikan ISMS secara berkelanjutan — misalnya: proses tindak lanjut dari audit findings, mekanisme review efektivitas kontrol, atau roadmap peningkatan keamanan berbasis metrik |
| 10.2 | Nonconformity and corrective action | ⚠️ **Sebagian** | `docs/qa/bug-severity-matrix.md` (siklus penanganan bug dengan SLA per severity level), `docs/security/incident-response.md` (Fase 4 remediasi dan Fase 5 tindakan preventif) | Tidak ada **prosedur formal nonconformity dan corrective action** khusus untuk ISMS. Prosedur yang ada (bug lifecycle, incident remediation) adalah praktik yang baik, tetapi tidak secara eksplisit: mendefinisikan apa yang dianggap nonconformity dalam konteks ISMS, mewajibkan analisis root cause untuk setiap nonconformity, atau mensyaratkan verifikasi bahwa corrective action efektif |

---

## 5. Annex A — A.5 Organizational Controls (37 Kontrol)

Annex A.5 mencakup 37 kontrol organisasi yang berkaitan dengan kebijakan, peran, proses, dan hubungan eksternal. Ini adalah bagian terbesar Annex A dan paling relevan untuk Fundara sebagai software product yang dirancang untuk mendukung governance NGO.

| ID | Kontrol | Status | Evidence Fundara | Gap |
|---|---|---|---|---|
| **A.5.1** | Policies for information security | ✅ **Sesuai** | `docs/security/is-policy.md` (ISP-001 v1.0 — 350 baris, 12 area kebijakan, tujuan terukur, peran & tanggung jawab, jadwal review tahunan, referensi ke 8 dokumen turunan). `docs/security/security-requirements.md` (implementasi teknis). | **(Gap telah ditutup 2026-06-20)** Kebijakan Keamanan Informasi formal tersedia. IS Policy menjadi *parent policy* bagi semua dokumen keamanan turunan. **Menunggu tanda tangan Pimpinan (PO) untuk berlaku efektif.** |
| **A.5.2** | Information security roles and responsibilities | ✅ **Sesuai** | `docs/pm/raci.md` (RACI matrix 25 aktivitas × 8 role proyek), `docs/spec/permissions.md` (13 role RBAC dengan tanggung jawab eksplisit per DocType), `docs/security/threat-model.md` (trust level dan tanggung jawab per aktor) | Peran dan tanggung jawab keamanan terdefinisi dengan baik untuk konteks proyek dan operasional sistem |
| **A.5.3** | Segregation of duties | ✅ **Sesuai** | `docs/spec/workflows.md` (multi-level approval workflow), `docs/spec/permissions.md` (Finance Officer ≠ Finance Manager; Conditional Permissions: staf yang mengajukan Cash Advance ≠ yang menyetujui ≠ yang membayar; Procurement Officer tidak bisa submit PO tanpa Finance Manager co-approval di atas Rp 200 juta) | Pemisahan tugas diimplementasikan secara sistematis dalam RBAC dan workflow. Approval cascade mencegah satu orang mengontrol seluruh siklus transaksi |
| **A.5.4** | Management responsibilities | ⚠️ **Sebagian** | `docs/pm/raci.md` (tanggung jawab pimpinan proyek terdefinisi), `CONTRIBUTING.md` (Tech Lead sebagai *gatekeeper* keamanan kode), `docs/pm/definition-of-done.md` (PM memastikan security gates terpenuhi) | Tidak ada dokumen **management responsibilities khusus untuk keamanan informasi** yang menetapkan: kewajiban pimpinan untuk menegakkan kebijakan keamanan, konsekuensi ketidakpatuhan, dan bagaimana pimpinan mendukung implementasi ISMS dalam operasional harian |
| **A.5.5** | Contact with authorities | ❌ **Belum Ada** | `docs/security/incident-response.md` menyebutkan Kominfo dan BSSN sebagai penerima notifikasi insiden (dengan URL website), `docs/security/data-privacy.md` merujuk UU PDP dan kewajiban pelaporan ke Kominfo | Tidak ada **daftar kontak authorities resmi** dengan: nama kontak person, nomor telepon/email langsung, prosedur eskalasi, dan SLA respons yang diharapkan. URL website saja tidak cukup untuk insiden darurat yang memerlukan notifikasi cepat dalam 14 hari (UU PDP) atau 72 jam (GDPR untuk data warga EU) |
| **A.5.6** | Contact with special interest groups | **N/A** | — | Kontrol ini mensyaratkan keanggotaan dalam kelompok kepentingan keamanan (ISAC, forum keamanan industri, dll.). Relevan untuk organisasi besar dengan tim keamanan dedicated. Untuk proyek software NGO dengan tim kecil, kontrol ini bersifat aspirasional dan tidak wajib di tahap awal. Dapat ditinjau kembali jika Fundara berkembang menjadi platform yang dioperasikan oleh entitas komersial |
| **A.5.7** | Threat intelligence | ⚠️ **Sebagian** | `docs/security/threat-model.md` (STRIDE analysis komprehensif sebagai *baseline* threat intelligence), `docs/infra/deploy.sh` (referensi UFW dan fail2ban sebagai respons terhadap threat landscape), `docs/security/security-requirements.md` (SR-DEP-05: monitoring CVE dengan SLA) | Tidak ada **proses berkelanjutan** untuk mengikuti threat intelligence feeds. Threat model yang ada adalah snapshot saat dokumen ditulis. Tidak ada: langganan ke security advisories ERPNext/Frappe, monitoring CVE database secara otomatis, atau mekanisme update threat model saat landscape berubah |
| **A.5.8** | Information security in project management | ✅ **Sesuai** | `docs/pm/raci.md` (QA dan TL memiliki tanggung jawab keamanan eksplisit dalam setiap fase proyek), `docs/pm/definition-of-done.md` (security checklist di MVP DoD: SR-DEV rules, pentest scope, security requirements review), `docs/pm/risk-register.md` (risiko keamanan terintegrasi dalam risk register proyek), `docs/security/security-requirements.md` (persyaratan non-negotiable sebelum go-live) | Keamanan sudah diintegrasikan ke dalam lifecycle manajemen proyek. DoD dengan security gate memastikan keamanan bukan afterthought |
| **A.5.9** | Inventory of information and other associated assets | ⚠️ **Sebagian** | `docs/security/threat-model.md` (tabel 9 kategori aset dengan sensitivitas, contoh data, dan lokasi teknis), `docs/security/data-privacy.md` (inventaris PII: 8 kategori data dengan DocType, field, sensitivitas, dan dasar pemrosesan) | Tidak ada **asset register formal** yang mencakup semua aset informasi dengan: owner per aset, klasifikasi lengkap (Public/Internal/Confidential/Restricted), lokasi penyimpanan, nilai aset, dan mekanisme disposal. Inventaris yang ada fokus pada data PII dan aset kritis — aset pendukung (konfigurasi sistem, source code, dokumentasi) belum tercakup |
| **A.5.10** | Acceptable use of information and other associated assets | ❌ **Belum Ada** | — | Tidak ada **Acceptable Use Policy (AUP)** untuk pengguna Fundara. AUP adalah kontrol fundamental yang mendefinisikan: apa yang boleh dan tidak boleh dilakukan pengguna dengan data dan sistem, konsekuensi pelanggaran, dan tanggung jawab pengguna dalam menjaga keamanan akun. Ini adalah **gap kritikal #4** — terutama penting untuk NGO yang menggunakan sistem ini untuk menangani data donor dan benefisiari |
| **A.5.11** | Return of assets | **N/A** | — | Kontrol ini mensyaratkan prosedur pengembalian aset saat hubungan kerja berakhir. Relevan untuk aset fisik (laptop, badge) dalam organisasi. Untuk software product, aspek relevannya (pencabutan akses saat offboarding) sudah dicakup di SR-AUTHZ-01 (akun tidak aktif 60 hari di-disable) dan threat model TM (mantan karyawan sebagai aktor tidak dipercaya) |
| **A.5.12** | Classification of information | ✅ **Sesuai** | `docs/security/information-classification.md` (ISP-005 v1.0 — **BARU 2026-06-20**) — skema 4 tingkat: L4 Terbatas / L3 Rahasia / L2 Internal / L1 Publik. Mencakup: kriteria per tingkat, tabel klasifikasi komponen utama Fundara (20+ komponen), pemetaan dari skema lama (Kritis/Sangat Tinggi/Tinggi → L4/L3), aturan penanganan per tingkat (storage/transmisi/akses/pencetakan/pemusnahan), panduan klasifikasi informasi baru (decision tree + aturan komposit), panduan pelabelan dokumen. | **(Gap telah ditutup 2026-06-20)** Klasifikasi formal 4-level tersedia dengan mapping lengkap ke data Fundara yang sudah ada. Aturan penanganan mencakup seluruh siklus informasi dari penyimpanan hingga pemusnahan. |
| **A.5.13** | Labelling of information | ❌ **Belum Ada** | — | Tidak ada **mekanisme labelling data** dalam aplikasi Fundara. Data tidak dilabeli dengan klasifikasi keamanannya saat disimpan atau ditampilkan. Tidak ada: field "classification" di DocType, visual indicator untuk data confidential di UI, atau mekanisme labelling dokumen yang dihasilkan sistem (laporan, export) |
| **A.5.14** | Information transfer | ⚠️ **Sebagian** | `docs/security/data-privacy.md` (Section 8: aturan transfer ke pihak ketiga — transfer yang diizinkan dan tidak diizinkan, DPA requirement), `docs/infra/backup-recovery.md` (GPG AES-256 sebelum upload ke offsite storage) | Tidak ada **information transfer policy formal** yang mencakup semua kanal transfer: email, file sharing, API, media fisik. Aturan transfer pihak ketiga ada tetapi tidak dikonsolidasikan dalam satu kebijakan transfer yang komprehensif |
| **A.5.15** | Access control | ✅ **Sesuai** | `docs/spec/permissions.md` (RBAC matrix lengkap: 13 role × 30+ DocType dengan CRWSAD per kombinasi; Conditional Permissions: scope per-proyek, per-requester, per-amount-threshold), `docs/security/security-requirements.md` (SR-AUTHZ-01 s/d SR-AUTHZ-04: least privilege, no shared accounts, field-level security, document-level security) | Kontrol akses diimplementasikan dengan komprehensif. Server-side enforcement via `has_permission` hooks memastikan kontrol tidak hanya di UI level |
| **A.5.16** | Identity management | ✅ **Sesuai** | `docs/security/security-requirements.md` (SR-AUTH-01 s/d SR-AUTH-05: password policy, session management, 2FA, login limiting, API key management), Frappe built-in user management (satu akun per pengguna, no shared accounts, user lifecycle: create → active → disabled) | Identity management komprehensif memanfaatkan Frappe framework. Persyaratan teknis terdefinisi dengan jelas dan dapat diimplementasikan |
| **A.5.17** | Authentication information | ✅ **Sesuai** | `docs/security/security-requirements.md` (SR-AUTH-01: password policy 12 karakter dengan kompleksitas, no reuse last 6; SR-AUTH-03: 2FA TOTP wajib untuk privileged roles; SR-AUTH-05: API key scoped, rotasi 90 hari, tidak disimpan di source code; SR-ENC-03: secret management dengan environment variables dan file permission 640) | Pengelolaan informasi autentikasi terdokumentasi dengan baik. Kontrol mencakup seluruh siklus: pembuatan, penyimpanan, penggunaan, dan rotasi |
| **A.5.18** | Access rights | ✅ **Sesuai** | `docs/spec/permissions.md` (RBAC matrix dengan prinsip least privilege), `docs/security/security-requirements.md` (SR-AUTHZ-01: role assignment requires approval, quarterly review, inactive account disabled after 60 days), `docs/security/threat-model.md` (mantan karyawan sebagai aktor — akun harus dinonaktifkan hari yang sama dengan offboarding) | Manajemen hak akses mencakup provisioning, review berkala, dan de-provisioning. Quarterly review dan auto-disable setelah 60 hari inaktif adalah praktik yang melampaui persyaratan minimum |
| **A.5.19** | Information security in supplier relationships | ⚠️ **Sebagian** | `docs/security/data-privacy.md` (Section 8.4: DPA requirement untuk integrasi eksternal baru), `docs/security/security-requirements.md` (SR-DEP: monitoring dependency security dari upstream vendors ERPNext/Frappe) | Tidak ada **supplier security assessment process** atau **supplier risk register**. Hubungan dengan suppliers (ERPNext upstream, hosting provider, S3 storage provider, SMTP relay) tidak di-assess secara formal dari perspektif risiko keamanan informasi. DPA requirement disebutkan untuk integrasi baru tetapi tidak ada template atau proses yang terdefinisi |
| **A.5.20** | Addressing information security within supplier agreements | ⚠️ **Sebagian** | `docs/security/data-privacy.md` (menyebut DPA requirement untuk integrasi eksternal yang memproses PII) | Tidak ada **template DPA** atau **supplier agreement security clause** yang siap digunakan. Organisasi yang mengadopsi Fundara dan berintegrasi dengan pihak ketiga tidak memiliki panduan tentang klausul keamanan apa yang harus ada dalam perjanjian dengan supplier |
| **A.5.21** | Managing information security in the ICT supply chain | ⚠️ **Sebagian** | `docs/security/security-requirements.md` (SR-DEP-01 s/d SR-DEP-06: versi ERPNext/Frappe di-pin, `pip audit` dan `npm audit` bulanan di CI, `unattended-upgrades` untuk security patch, SLA patch CVE Critical 7 hari / High 30 hari) | Tidak ada **Software Bill of Materials (SBOM)** formal atau **supply chain risk assessment**. Monitoring dependency security ada tetapi tidak ada: inventaris lengkap semua komponen dengan versi, proses verifikasi integritas komponen (checksum/hash), atau assessment risiko supply chain secara holistik |
| **A.5.22** | Monitoring, review and change management of supplier services | ❌ **Belum Ada** | — | Tidak ada **proses monitoring supplier** yang terdefinisi. Tidak ada: review berkala terhadap keamanan ERPNext upstream (security advisories, changelogs), monitoring SLA dari hosting provider, atau prosedur formal untuk menangani perubahan layanan dari pihak ketiga yang berdampak pada keamanan |
| **A.5.23** | Information security for use of cloud services | ⚠️ **Sebagian** | `docs/infra/environment-spec.md` (spesifikasi cloud hosting: VPS dengan Ubuntu 24.04, hardening spesifik), `docs/infra/backup-recovery.md` (GPG AES-256 sebelum upload ke S3-compatible cloud storage, rclone untuk transfer terenkripsi) | Tidak ada **cloud service security assessment policy** formal. Tidak ada: kriteria seleksi penyedia cloud dari perspektif keamanan, assessment risiko per layanan cloud yang digunakan, atau panduan konfigurasi keamanan khusus per cloud provider |
| **A.5.24** | Information security incident management planning and preparation | ✅ **Sesuai** | `docs/security/incident-response.md` (5 fase lengkap: Identifikasi, Penahanan, Investigasi, Remediasi, Lessons Learned; 4 level klasifikasi insiden dengan response time; tim respons 4 peran; tabletop exercise scenarios; Appendix quick reference commands) | Perencanaan incident management komprehensif. Dokumen *battle-tested*: mencakup scenario realistis untuk NGO Indonesia, perintah teknis siap pakai, dan panduan fasilitator untuk latihan |
| **A.5.25** | Assessment and decision on information security events | ✅ **Sesuai** | `docs/security/incident-response.md` (klasifikasi 4 level: Critical/High/Medium/Low dengan contoh konkret dan response time target; aturan eskalasi: jika ragu pilih yang lebih tinggi), `docs/qa/bug-severity-matrix.md` (severity matrix untuk event yang terdeteksi sebagai bug) | Kriteria assessment event ke incident terdefinisi dengan jelas dan operasional |
| **A.5.26** | Response to information security incidents | ✅ **Sesuai** | `docs/security/incident-response.md` (Fase 2 Penahanan — prosedur per jenis insiden: akun dikompromis, akses tidak sah ke server/DB, file mencurigakan/webshell, production offline; Fase 4 Remediasi — eradication dan recovery procedures dengan commands siap pakai) | Prosedur respons operasional dan dapat langsung dieksekusi. Coverage jenis insiden yang relevan untuk Fundara: credential compromise, unauthorized DB access, webshell, ransomware |
| **A.5.27** | Learning from information security incidents | ✅ **Sesuai** | `docs/security/incident-response.md` (Fase 5: Lessons Learned dalam 5 hari kerja setelah insiden tertutup; template Post-Incident Report lengkap: kronologi, root cause, scope terdampak, tindakan, metrik respons, apa yang berjalan baik, apa yang bisa diperbaiki, tindakan preventif) | Proses pembelajaran dari insiden terdokumentasi dengan format yang mendorong analisis sistemik, bukan menyalahkan individu |
| **A.5.28** | Collection of evidence | ⚠️ **Sebagian** | `docs/security/incident-response.md` (chain of custody disebutkan, log commands untuk preservasi evidence, instruksi "jangan hapus file mencurigakan"), Fase 1 mewajibkan screenshot awal | Tidak ada **prosedur forensic evidence collection** yang detail: (a) tidak ada chain of custody form, (b) tidak ada prosedur hash verification untuk membuktikan integritas evidence, (c) tidak ada panduan tentang tools forensik yang digunakan, (d) tidak ada prosedur penyimpanan evidence yang aman dan berlabel |
| **A.5.29** | Information security during disruption | ⚠️ **Sebagian** | `docs/infra/backup-recovery.md` (RPO 24 jam, RTO 4 jam; prosedur restore; 3-2-1 backup strategy), `docs/infra/monitoring-spec.md` (monitoring untuk deteksi dini gangguan) | Tidak ada **Business Continuity Plan (BCP)** formal yang mencakup skenario di luar kegagalan teknis: kehilangan staf kunci, bencana alam yang memengaruhi akses server, gangguan penyedia hosting, atau insiden yang memerlukan operasi manual sementara sistem down. Ini adalah **gap kritikal #5** |
| **A.5.30** | ICT readiness for business continuity | ⚠️ **Sebagian** | `docs/infra/backup-recovery.md` (prosedur restore full/partial, verifikasi integritas backup), `docs/infra/upgrade-runbook.md` (prosedur rollback jika upgrade gagal) | BCP dan disaster recovery plan belum formal. Tidak ada: schedule pengujian restore berkala (selain disebutkan sebagai rekomendasi), prosedur *dry run* disaster recovery, target RTO dan RPO yang diuji (bukan hanya ditargetkan), atau dokumentasi hasil pengujian terakhir |
| **A.5.31** | Legal, statutory, regulatory and contractual requirements | ✅ **Sesuai** | `docs/security/data-privacy.md` (analisis komprehensif UU PDP No. 27/2022: prinsip, hak subjek data, kewajiban controller vs. processor, retention policy, consent management), `docs/accounting/` (ISAK 35 standar akuntansi entitas nirlaba Indonesia), `docs/security/incident-response.md` (kewajiban notifikasi Kominfo/BSSN dalam 14 hari; kewajiban notifikasi GDPR 72 jam untuk data warga EU) | Persyaratan hukum yang relevan untuk NGO Indonesia diidentifikasi dan dianalisis dengan baik. Mapping antara persyaratan hukum dan kontrol teknis tersedia |
| **A.5.32** | Intellectual property rights | ❌ **Belum Ada** | — | Tidak ada **IP policy** yang mendefinisikan: lisensi ERPNext/Frappe yang digunakan (GNU GPL v3), kewajiban *copyleft*, lisensi Fundara itu sendiri, penggunaan library pihak ketiga, dan panduan untuk developer tentang kontribusi code. Penggunaan ERPNext (GPL v3) memiliki implikasi lisensi signifikan untuk distribusi software yang perlu didokumentasikan |
| **A.5.33** | Protection of records | ✅ **Sesuai** | `docs/security/data-privacy.md` (retention policy lengkap per kategori data dengan dasar hukum), `docs/security/security-requirements.md` (SR-LOG-01: Document Versioning read-only, tidak bisa dihapus; SR-LOG-02: Activity Log retensi minimum 2 tahun; SR-LOG-03: GL Entry immutable dan permanen; SR-LOG-04: log protection — Audit role read-only, DevOps SSH-only access) | Perlindungan catatan terdokumentasi dengan baik. Kombinasi Frappe Document Versioning + Activity Log + GL Entry immutability memberikan proteksi berlapis |
| **A.5.34** | Privacy and protection of PII | ✅ **Sesuai** | `docs/security/data-privacy.md` (kerangka UU PDP lengkap: inventaris PII, hak subjek data, prosedur anonymisasi, consent management, transfer policy, retention policy), `docs/security/security-requirements.md` (SR-AUTHZ-03: field masking untuk PII fields), `docs/spec/permissions.md` (Beneficiary — akses dibatasi Project Manager dan Field Staff proyek terkait) | Privacy by design tercermin dalam arsitektur permission dan data governance. Field masking, consent management, dan anonymization procedure terdokumentasi |
| **A.5.35** | Independent review of information security | ⚠️ **Sebagian** | `docs/security/pentest-scope.md` (scope penetration testing oleh pihak eksternal terdefinisi: scope, metodologi, timeline, deliverable) | Tidak ada **jadwal review independen** yang terdefinisi. Pentest scope ada tetapi tidak ada: frekuensi yang ditetapkan (minimum tahunan), anggaran yang dialokasikan, mekanisme tindak lanjut temuan pentest, atau kriteria pemilihan penguji independen. Review independen saat ini bersifat *planned but not scheduled* |
| **A.5.36** | Compliance with policies, rules and standards | ⚠️ **Sebagian** | `docs/security/owasp-checklist.md` (OWASP compliance checklist), `docs/security/security-requirements.md` (persyaratan yang wajib dipenuhi sebelum go-live), `docs/pm/definition-of-done.md` (security DoD sebagai compliance gate per sprint) | Tidak ada **compliance monitoring process** formal yang berkelanjutan. Compliance saat ini diverifikasi melalui DoD per sprint (baik), tetapi tidak ada: audit kepatuhan periodik terhadap kebijakan internal, mekanisme deteksi penyimpangan dari konfigurasi yang ditetapkan (configuration drift), atau dashboard compliance status |
| **A.5.37** | Documented operating procedures | ✅ **Sesuai** | `docs/infra/deploy.sh` (deployment procedure), `docs/infra/upgrade-runbook.md` (upgrade procedure dengan rollback), `docs/infra/backup-recovery.md` (backup dan restore procedure dengan perintah siap pakai), `docs/dev/dev-workflow.md` (development workflow), `docs/infra/environment-spec.md` (konfigurasi operasional lengkap per profile) | Prosedur operasi terdokumentasi komprehensif. Coverage meliputi: deployment, upgrade, backup, monitoring, dan development workflow |

---

*Dokumen ini merupakan PART 1 dari audit kepatuhan ISO 27001:2022 Fundara. Part 2 akan mencakup Annex A.6 (People Controls), A.7 (Physical Controls), dan A.8 (Technological Controls — 34 kontrol). Part 3 akan mencakup konsolidasi temuan, Statement of Applicability (SoA) draft, dan roadmap remediasi.*

---

**Referensi Dokumen:**

| Dokumen | Lokasi |
|---|---|
| Security Requirements | `docs/security/security-requirements.md` |
| Threat Model (STRIDE) | `docs/security/threat-model.md` |
| Data Privacy Specification | `docs/security/data-privacy.md` |
| Incident Response Plan | `docs/security/incident-response.md` |
| Permission Matrix | `docs/spec/permissions.md` |
| RACI Matrix | `docs/pm/raci.md` |
| Risk Register | `docs/pm/risk-register.md` |
| Architecture Decisions | `DECISIONS.md` |

**Standar Referensi:**
- ISO/IEC 27001:2022 — Information security management systems — Requirements
- ISO/IEC 27002:2022 — Information security controls
- UU PDP No. 27 Tahun 2022 — Undang-Undang Pelindungan Data Pribadi Indonesia
- ISAK 35 — Standar Akuntansi Entitas Nirlaba Indonesia
# ISO 27001:2022 Compliance Audit — Part 2
## Annex A Controls: A.6 People, A.7 Physical, A.8 Technological

**Project:** Fundara — Fund-centric ERP for Mission-driven Organizations  
**Platform:** ERPNext v16 / Frappe Framework  
**Document Version:** 1.0  
**Date:** 2026-06-19  
**Audience:** Tech Lead, Security Reviewer, Auditor  
**Continuation of:** `docs/security/iso27001-audit-part1.md`

---

## Notasi Status

| Simbol | Arti |
|---|---|
| ✅ **Sesuai** | Covered fully — evidence terdokumentasi dan kontrol berjalan |
| ⚠️ **Sebagian** | Partially covered — ada gap yang perlu diaddress sebelum go-live atau dalam roadmap |
| ❌ **Belum Ada** | Not covered — kontrol tidak ada, perlu dibuat |
| **N/A** | Not applicable — tidak relevan untuk Fundara atau sudah menjadi tanggung jawab pihak lain (hosting provider, NGO deployer) |

---

## Pendahuluan Annex A

ISO 27001:2022 Annex A mendefinisikan 93 kontrol keamanan informasi yang dibagi dalam 4 kategori:

- **A.5 Organizational Controls** — 37 kontrol (dibahas di Part 1)
- **A.6 People Controls** — 8 kontrol (dibahas di dokumen ini)
- **A.7 Physical Controls** — 14 kontrol (dibahas di dokumen ini)
- **A.8 Technological Controls** — 34 kontrol (dibahas di dokumen ini)

Audit ini menilai kesiapan Fundara sebagai **produk open-source** yang di-deploy oleh NGO Indonesia. Beberapa kontrol bersifat tanggung jawab organisasi deployer (NGO), bukan Fundara project; penilaian ini mencatat batas tersebut secara eksplisit.

---

## A.6 PEOPLE CONTROLS

**Ringkasan:** 8 kontrol yang berkaitan dengan orang — screening, pelatihan, tanggung jawab setelah terminasi, NDA, dan remote working.

---

### A.6.1 Screening

**Status:** N/A / ⚠️ **Sebagian**

**Deskripsi Kontrol:** Verifikasi latar belakang calon karyawan atau kontraktor sebelum diberikan akses ke aset informasi.

**Evidence Tersedia:**
- `CONTRIBUTING.md` — developer onboarding guide yang mendefinisikan proses bergabung ke tim Fundara
- Tidak ada prosedur background check formal di Fundara project

**Penilaian:**

Screening (background check) adalah kebijakan HR organisasi NGO yang menggunakan Fundara, bukan tanggung jawab Fundara project sebagai produk open-source. Fundara tidak mempekerjakan pengguna langsung; NGO yang men-deploy Fundara yang bertanggung jawab melakukan screening terhadap staf mereka yang akan diberi akses ke sistem.

Dari sisi Fundara sebagai proyek pengembangan perangkat lunak yang dikerjakan oleh tim kecil internal, kontrol ini N/A secara formal karena tidak ada proses perekrutan formal pada level organisasi proyek.

**Gap yang Teridentifikasi:**
- `CONTRIBUTING.md` belum menyertakan saran eksplisit kepada NGO deployer untuk melakukan screening terhadap staf yang akan mendapat akses ke sistem Fundara, terutama untuk role Finance Manager, System Admin, dan Audit
- Tidak ada panduan untuk NGO tentang kontrol minimal yang harus diterapkan sebelum memberikan akses ke sistem keuangan

**Rekomendasi:**
1. Tambahkan seksi "Deployment Security Checklist" di `CONTRIBUTING.md` atau panduan deployment yang menyarankan NGO melakukan background check sebelum memberikan akses ke role sensitif (Finance Manager, System Admin, Audit)
2. Dokumentasikan bahwa untuk contributor external Fundara project, akses ke repository dikontrol melalui GitHub permissions (bukan background check formal)

**Catatan untuk Auditor:** Untuk NGO kecil di Indonesia, kontrol ini secara praktis N/A dari sisi Fundara project. NGO yang ingin mencapai compliance ISO 27001 sendiri harus mengimplementasikan kontrol ini di level kebijakan HR mereka.

---

### A.6.2 Terms and Conditions of Employment

**Status:** N/A

**Deskripsi Kontrol:** Perjanjian kerja mencantumkan tanggung jawab keamanan informasi karyawan dan kontraktor.

**Evidence Tersedia:**
- Tidak ada template kontrak atau perjanjian kerja di Fundara project

**Penilaian:**

Kontrol ini sepenuhnya merupakan tanggung jawab HR organisasi NGO yang men-deploy Fundara. Fundara sebagai produk tidak menerbitkan template kontrak kerja.

**Gap yang Teridentifikasi:**
- Tidak ada template klausul keamanan informasi yang bisa digunakan oleh NGO dalam kontrak staf mereka

**Rekomendasi:**
1. Sebagai nilai tambah untuk NGO, Fundara bisa menyediakan template klausul keamanan informasi (akseptabel tapi bukan wajib untuk go-live) dalam panduan deployment yang mencakup: kewajiban menjaga kerahasiaan data donor dan beneficiary, larangan berbagi kredensial, kewajiban melaporkan insiden keamanan, konsekuensi pelanggaran
2. Referensikan klausul ini ke UU PDP No. 27 Tahun 2022 sebagai kerangka hukum yang relevan untuk NGO Indonesia

**Catatan untuk Auditor:** N/A dari sisi Fundara project. Tanggung jawab penuh ada pada NGO deployer.

---

### A.6.3 Information Security Awareness, Education and Training

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Semua karyawan dan kontraktor menerima pelatihan security awareness yang sesuai dengan peran mereka dan diperbarui secara berkala.

**Evidence Tersedia:**
- `CONTRIBUTING.md` — security rules untuk developer (SR-DEV rules, coding standards, PR checklist security items)
- `docs/security/security-requirements.md` — SR-DEV section mendefinisikan security requirements untuk developer: no sensitive data in logs, parameterized queries, permission checks, no hardcoded credentials
- `docs/qa/uat-script.md` — onboarding script untuk user NGO pilot (berfokus pada fitur, bukan security awareness)
- `docs/security/owasp-checklist.md` — dokumen security awareness untuk Tech Lead dan Security Reviewer
- `docs/security/threat-model.md` — awareness tentang threat actors dan attack vectors (audience: Tech Lead, Developer)

**Penilaian:**

Security awareness untuk **developer** sudah terdokumentasi dengan baik melalui `CONTRIBUTING.md` dan `security-requirements.md`. Developer diarahkan untuk memahami OWASP Top 10, menggunakan parameterized queries, melakukan permission checks, dan tidak menyimpan credentials di git.

Namun, tidak ada **security awareness training material untuk end user** (staf NGO). UAT script (`docs/qa/uat-script.md`) memandu pengguna cara menggunakan fitur Fundara, tetapi tidak mencakup security awareness seperti: cara mengenali phishing, pentingnya tidak berbagi password, cara melaporkan insiden, atau keamanan password.

**Gap yang Teridentifikasi:**
1. Tidak ada security awareness guide untuk end user NGO (Finance Officer, Project Manager, Field Staff) — target peserta berbeda dari developer
2. UAT script lebih berfokus ke navigasi fitur, bukan ke security behavior yang diharapkan dari pengguna
3. Tidak ada jadwal refresh training atau mekanisme verifikasi bahwa training sudah diterima
4. Tidak ada materi tentang keamanan akun: cara menggunakan 2FA, cara membuat password yang kuat, cara mengidentifikasi phishing email yang mungkin menargetkan akun Fundara

**Rekomendasi:**
1. Buat dokumen `docs/security/user-security-guide.md` yang ditujukan untuk staf NGO, mencakup: pentingnya 2FA, kebijakan password, cara melaporkan insiden, dan penanganan data sensitif (tidak screenshot data keuangan, tidak forward laporan ke email pribadi)
2. Sertakan seksi singkat security awareness di UAT script (misalnya satu skenario: "Coba setup 2FA untuk akun Anda")
3. Rekomendasikan kepada NGO deployer untuk menjalankan sesi security awareness singkat (30 menit) sebelum sistem go-live menggunakan materi yang disediakan Fundara

---

### A.6.4 Disciplinary Process

**Status:** N/A

**Deskripsi Kontrol:** Proses disiplin formal untuk karyawan yang melanggar kebijakan keamanan informasi.

**Evidence Tersedia:**
- Tidak ada di Fundara project

**Penilaian:**

Proses disiplin adalah tanggung jawab penuh HR NGO. Fundara project tidak memiliki karyawan dalam arti formal yang bisa dikenai proses disiplin.

**Rekomendasi:**
1. Dalam panduan deployment Fundara, rekomendasikan kepada NGO untuk memiliki kebijakan disiplin yang mencakup pelanggaran keamanan informasi sistem keuangan, mengacu pada kebijakan kode etik NGO yang sudah ada
2. Tidak diperlukan dari sisi Fundara project sebagai produk

---

### A.6.5 Responsibilities After Termination or Change of Employment

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Tanggung jawab keamanan informasi yang tetap berlaku setelah terminasi atau perubahan jabatan, serta prosedur offboarding yang mencabut akses secara tepat waktu.

**Evidence Tersedia:**
- `docs/security/offboarding-checklist.md` (ISP-003 v1.0 — **BARU 2026-06-20**) — Offboarding Checklist formal: 11 kategori pencabutan akses (GitHub, Frappe dev/staging/prod, SSH keys, API keys, database, GPG backup key, monitoring, credentials vault, komunikasi), timeline 24 jam, inventarisasi akses pre-offboarding (D-2), verifikasi D+7, rekam jejak untuk keperluan audit, tanda tangan PM + TL
- `docs/security/security-requirements.md` — SR-AUTHZ-01: quarterly access review, inactive accounts (no login > 60 days) disabled — lapisan tambahan sebagai safety net
- `docs/security/security-requirements.md` — SR-AUTH-05: API keys di-rotasi setiap 90 hari
- `docs/security/threat-model.md` — "Former Employee" sebagai threat actor kategori "No trust" — justifikasi untuk prosedur ketat
- `docs/security/is-policy.md` § 5.5 — ketentuan offboarding dalam IS Policy induk

**Penilaian:**

**(Gap telah ditutup 2026-06-20)** Offboarding Checklist formal (ISP-003) dibuat sebagai dokumen operasional yang dapat langsung digunakan. Checklist mencakup:
- **Inventarisasi akses (D-2):** tabel 18 sistem yang harus dicek keberadaan aksesnya sebelum hari terakhir
- **Fase D-0:** transfer pengetahuan, return aset, konfirmasi NDA
- **Fase D+1 (24 jam):** pencabutan akses di 11 kategori sistem dengan langkah teknis spesifik per sistem
- **Verifikasi D+7:** TL memverifikasi tidak ada akses residual via log dan pengujian aktif
- **Rekam jejak:** format bukti audit (screenshot, output command) untuk keperluan ISO 27001 audit

Pendekatan proaktif: akses dicabut pada hari terakhir bekerja (D-0/D+1), bukan menunggu 60 hari inaktif. Prosedur khusus untuk offboarding Tech Lead / DevOps yang memiliki privilege tertinggi.

**Kontrol yang Sudah Berfungsi:**
- Offboarding Checklist ISP-003 — operasional, terdokumentasi, dapat langsung digunakan saat ada offboarding
- Timeline 24 jam yang jelas dengan batas waktu eksplisit (D+1 pukul 17:00)
- RACI: PM sebagai Responsible/Accountable, TL sebagai Verifikator
- Prosedur verifikasi post-offboarding (D+7) dengan eskalasi ke incident management jika ditemukan akses residual

---

### A.6.6 Confidentiality or Non-Disclosure Agreements

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** NDA atau perjanjian kerahasiaan harus ditandatangani oleh pihak yang mendapat akses ke informasi rahasia.

**Evidence Tersedia:**
- `docs/security/nda-template.md` (ISP-004 v1.0 — **BARU 2026-06-20**) — dua template:
  - **Template A** (Developer / Contributor / DevOps): NDA formal 11 pasal — definisi Informasi Rahasia dan Lingkup Akses, kewajiban kerahasiaan, larangan khusus (unduhan data NGO, akses di luar scope), pengecualian, ketentuan data pribadi dan UU PDP Pasal 20 + 40, pengembalian/penghapusan informasi, jangka waktu (5 tahun pasca keterlibatan; tanpa batas untuk data pribadi NGO), konsekuensi pelanggaran (KUHPerdata, UU ITE, UU PDP), governing law Indonesia / PN Jakarta
  - **Template B** (Klausul Staf NGO): klausul ringkas untuk diintegrasikan ke kontrak kerja NGO — kewajiban kerahasiaan, larangan berbagi credential/data, keamanan akun, dasar hukum UU PDP, pelaporan insiden

**Penilaian:**

**(Gap telah ditutup 2026-06-20)** NDA template tersedia dalam dua varian yang mencakup seluruh peran yang memiliki akses ke Fundara. Template A dirancang sebagai perjanjian berdiri sendiri yang ditandatangani sebelum akses diberikan. Template B dirancang sebagai klausul yang dapat langsung disalin ke kontrak kerja NGO yang sudah ada.

Dasar hukum yang dicakup:
- **UU PDP No. 27 Tahun 2022 Pasal 20** — kewajiban Pengendali Data memastikan kerahasiaan
- **UU PDP Pasal 40** — kewajiban Pemroses Data Pribadi
- **UU PDP Pasal 67** — sanksi pidana penyalahgunaan data pribadi (pidana + denda Rp 4 M)
- **KUHPerdata Pasal 1365** — ganti rugi perbuatan melanggar hukum
- **UU ITE No. 11 Tahun 2008 Pasal 30 + 32** — akses tidak sah dan modifikasi sistem

**Kontrol yang Sudah Berfungsi:**
- Template A: tabel Lingkup Akses dengan checkbox per sistem (GitHub, staging, production, database, vault, data NGO) — dokumentasi spesifik akses yang diberikan
- Template A: kewajiban melaporkan insiden dalam 4 jam agar Pihak Pertama dapat memenuhi notifikasi 14 hari ke Kominfo/BSSN (UU PDP)
- Template B: dapat langsung digunakan oleh NGO deployer tanpa modifikasi hukum signifikan

---

### A.6.7 Remote Working

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Kebijakan dan kontrol keamanan untuk pekerjaan jarak jauh, termasuk perlindungan informasi yang diakses, diproses, atau disimpan di luar fasilitas organisasi.

**Evidence Tersedia:**
- `docs/dev/local-setup.md` — setup guide untuk developer laptop (mengimplikasikan remote/WFH setup)
- `docs/security/security-requirements.md` — SR-AUTH-02: session timeout 8 jam, SR-AUTH-03: 2FA wajib untuk role sensitif, SR-AUTH-04: account lockout
- `docs/infra/environment-spec.md` — section 3.9: SSH key authentication, `PasswordAuthentication no`, `PermitRootLogin no`
- Kontrol teknis (2FA, session timeout, HTTPS) secara implisit mendukung remote working yang aman

**Penilaian:**

Kontrol teknis dasar untuk remote access sudah ada: HTTPS mandatory, 2FA untuk role sensitif, session timeout, dan SSH key authentication. Ini adalah fondasi yang baik.

Namun, tidak ada **remote working security policy** formal yang mendefinisikan ekspektasi keamanan terhadap pengguna yang mengakses sistem dari luar kantor.

**Gap yang Teridentifikasi:**
1. Tidak ada kebijakan formal remote working yang mendefinisikan: persyaratan jaringan (apakah VPN diperlukan?), persyaratan perangkat (apakah harus laptop kantor atau boleh laptop pribadi?), screen lock policy saat meninggalkan perangkat
2. Tidak ada panduan untuk NGO tentang risiko akses dari jaringan Wi-Fi publik (kafe, hotel) tanpa VPN
3. Tidak ada rekomendasi tentang penggunaan VPN untuk akses ke Fundara dari jaringan yang tidak dipercaya
4. Tidak ada panduan untuk developer tentang keamanan environment development lokal mereka (enkripsi disk laptop, screen lock, keamanan Wi-Fi)
5. `docs/dev/local-setup.md` memandu cara setup, tapi tidak mencakup aspek keamanan dari setup remote developer

**Rekomendasi:**
1. Tambahkan seksi "Remote Access Security" di panduan deployment atau dalam dokumen kebijakan keamanan yang ditujukan untuk NGO deployer, mencakup: rekomendasi penggunaan VPN untuk akses dari jaringan tidak terpercaya, persyaratan screen lock (idle lock dalam 15 menit), larangan mengakses sistem dari perangkat bersama/umum tanpa enkripsi
2. Tambahkan seksi keamanan di `docs/dev/local-setup.md` untuk developer: full disk encryption pada laptop development, penggunaan password manager, tidak menyimpan credential staging di file teks biasa
3. Karena Fundara sudah enforce HTTPS dan 2FA, risiko dari remote working moderat — tidak ada data yang ditransmisikan dalam cleartext

---

### A.6.8 Information Security Event Reporting

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Mekanisme untuk melaporkan kejadian keamanan informasi secepat mungkin kepada pihak yang berwenang.

**Evidence Tersedia:**
- `docs/security/incident-response.md` — prosedur pelaporan insiden yang lengkap: eskalasi ke Tech Lead, dokumentasi insiden, timeline respon
- `docs/qa/bug-severity-matrix.md` — mendefinisikan severity level untuk bug termasuk security bug, dan jalur pelaporan
- `docs/security/security-requirements.md` — SR-AUTH-04: System Admin dinotifikasi via email ketika lockout triggered
- `docs/security/incident-response.md` — jenis insiden yang harus dilaporkan: unauthorized access, data breach, service disruption, malware

**Penilaian:**

Mekanisme pelaporan insiden sudah terdefinisi dengan baik. `incident-response.md` mendefinisikan: apa yang harus dilaporkan, kepada siapa, dalam berapa waktu, dan langkah awal yang harus diambil. Bug severity matrix memberikan guidance untuk developer tentang cara mengklasifikasikan dan melaporkan security bug.

Notifikasi otomatis (account lockout alert ke System Admin) juga sudah dispesifikasikan di `security-requirements.md`.

**Kontrol yang Sudah Berfungsi:**
- Jalur eskalasi yang jelas: penemu insiden → Tech Lead → System Admin → (jika perlu) stakeholder NGO
- Timeline respon yang terdefinisi (berdasarkan severity)
- Prosedur awal yang didokumentasikan: isolasi, preserve evidence, notifikasi
- Bug reporting process melalui GitHub Issues dengan label `severity:critical` / `severity:high`
- Automated alert untuk brute force (fail2ban, monitoring-spec.md: alert jika > 10 failed login dalam 5 menit)

**Tidak Ada Gap Material** untuk kontrol ini. Pertimbangkan untuk menambahkan contact matrix (siapa yang dihubungi di luar jam kerja) di `incident-response.md` sebagai penyempurnaan.

---

## A.7 PHYSICAL CONTROLS

**Catatan Awal:** Sebagian besar kontrol A.7 (Physical) berlaku untuk organisasi yang mengoperasikan server fisik sendiri. Fundara dirancang untuk di-deploy ke cloud VPS atau colocation, sehingga tanggung jawab keamanan fisik ada pada hosting provider (Hetzner, DigitalOcean, Vultr, AWS, atau provider lokal yang dipilih NGO). Kontrol-kontrol ini dinilai dari perspektif panduan kepada NGO yang men-deploy Fundara.

Prinsip utama: **NGO yang men-deploy Fundara harus memilih hosting provider yang memiliki sertifikasi keamanan fisik yang relevan** (minimal ISO 27001 atau SOC 2 Type II). Fundara tidak bisa mengontrol aspek fisik server, tetapi bisa merekomendasikan kriteria pemilihan hosting.

---

### A.7.1 Physical Security Perimeters

**Status:** N/A (hosting provider responsibility)

**Deskripsi Kontrol:** Perimeter keamanan fisik harus didefinisikan dan digunakan untuk melindungi area yang berisi informasi sensitif dan fasilitas pemrosesan informasi.

**Evidence Tersedia:**
- `docs/infra/environment-spec.md` — mendefinisikan spesifikasi server dan firewall rules, mengimplikasikan penggunaan cloud/VPS
- Tidak ada kontrol fisik yang dapat diimplementasikan oleh Fundara project

**Penilaian:**

Fundara di-deploy ke VPS/cloud. Server fisik berada di data center hosting provider. Keamanan fisik (pagar, kamera CCTV, akses kartu, dll.) sepenuhnya menjadi tanggung jawab provider.

**Rekomendasi untuk NGO:** Saat memilih hosting provider untuk Fundara, pastikan provider memiliki: ISO 27001 atau SOC 2 certification, kebijakan akses fisik yang terdokumentasi, laporan audit yang dapat dibagikan kepada pelanggan.

---

### A.7.2 Physical Entry

**Status:** N/A (hosting provider responsibility)

**Deskripsi Kontrol:** Kontrol akses fisik ke area aman harus diterapkan untuk memastikan hanya personel yang berwenang yang dapat masuk.

**Evidence Tersedia:**
- Tidak ada — tanggung jawab hosting provider

**Penilaian:**

Sama dengan A.7.1. Akses fisik ke data center adalah tanggung jawab penuh hosting provider. Fundara tidak memiliki kontrol atas aspek ini.

**Rekomendasi untuk NGO:** Pilih provider yang menyediakan log akses fisik dan membatasi akses ke perangkat keras dengan sistem kartu akses atau biometrik.

---

### A.7.3 Securing Offices, Rooms and Facilities

**Status:** N/A

**Deskripsi Kontrol:** Desain dan penerapan keamanan fisik untuk kantor, ruangan, dan fasilitas.

**Penilaian:**

Untuk deployment cloud (yang direkomendasikan oleh Fundara), kontrol ini N/A karena tidak ada server on-premise. Untuk NGO yang mengoperasikan server on-premise, tanggung jawab pengamanan ruang server ada pada NGO itu sendiri, bukan Fundara project.

**Rekomendasi untuk NGO:** Jika menggunakan server on-premise, pastikan server ditempatkan di ruangan yang terkunci, dengan akses terbatas hanya kepada IT staff yang berwenang, dilengkapi kamera CCTV, dan tidak dapat diakses oleh staf umum.

---

### A.7.4 Physical Security Monitoring

**Status:** N/A (hosting provider)

**Deskripsi Kontrol:** Pemantauan fisik secara berkelanjutan terhadap area sensitif untuk mendeteksi intrusi fisik.

**Penilaian:**

CCTV, sensor gerak, dan pemantauan fisik lainnya sepenuhnya merupakan tanggung jawab hosting provider untuk deployment cloud, atau tanggung jawab NGO untuk deployment on-premise. Fundara tidak dapat mengimplementasikan kontrol ini.

---

### A.7.5 Protecting Against Physical and Environmental Threats

**Status:** N/A (hosting provider)

**Deskripsi Kontrol:** Perlindungan terhadap ancaman fisik dan lingkungan seperti bencana alam, kebakaran, banjir, dan kegagalan daya.

**Evidence Tersedia:**
- `docs/infra/environment-spec.md` — menyebutkan kebutuhan power dan UPS sebagai pertimbangan untuk deployment on-premise

**Penilaian:**

Untuk deployment cloud, proteksi terhadap ancaman fisik (generator, fire suppression, redundant power) adalah tanggung jawab data center provider. Fundara memberikan panduan minimal tentang kebutuhan daya (UPS) untuk deployment on-premise di `environment-spec.md`, namun perlindungan fisik sesungguhnya ada di luar kendali Fundara project.

**Rekomendasi untuk NGO:** Untuk deployment cloud, pastikan provider memiliki Tier III atau Tier IV data center dengan redundant power, cooling, dan konektivitas. Untuk on-premise, minimal pastikan ada UPS dan sistem deteksi kebakaran di ruang server.

---

### A.7.6 Working in Secure Areas

**Status:** N/A

**Deskripsi Kontrol:** Prosedur untuk bekerja di area aman, termasuk pembatasan akses dan pengawasan aktivitas di area tersebut.

**Penilaian:**

Tidak relevan untuk Fundara project sebagai produk software. NGO yang mengoperasikan server on-premise harus mendefinisikan prosedur ini sendiri. Untuk cloud deployment, kontrol ini dihandle oleh provider.

---

### A.7.7 Clear Desk and Clear Screen

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Kebijakan clear desk (tidak ada informasi sensitif di meja yang tidak terjaga) dan clear screen (layar dikunci saat ditinggalkan).

**Evidence Tersedia:**
- `docs/security/security-requirements.md` — SR-AUTH-02: session timeout 8 jam, Redis session store server-side
- Tidak ada clear desk atau clear screen policy formal

**Penilaian:**

Session timeout 8 jam memberikan perlindungan dasar jika pengguna meninggalkan komputer tanpa logout. Namun ini adalah jaring pengaman terakhir — tidak menggantikan kebiasaan baik seperti mengunci layar saat meninggalkan meja.

**Gap yang Teridentifikasi:**
1. Tidak ada rekomendasi clear screen policy kepada NGO (misalnya: lock layar dalam 15 menit idle, atau Ctrl+L/Windows+L habit sebelum meninggalkan meja)
2. Session timeout 8 jam mungkin terlalu panjang jika pengguna meninggalkan workstation tanpa mengunci layar di lingkungan kantor terbuka NGO
3. Tidak ada panduan tentang penanganan laporan keuangan yang dicetak (tidak boleh ditinggalkan di printer, harus di-shred setelah digunakan)

**Rekomendasi:**
1. Tambahkan panduan singkat di deployment guide: "Konfigurasikan screen saver dengan password lock dalam 10–15 menit idle di semua workstation yang mengakses Fundara"
2. Pertimbangkan untuk menurunkan default session timeout untuk role Finance Manager dan System Admin dari 8 jam menjadi 4 jam, dengan opsi "Remember Me" jika diperlukan
3. Sertakan satu item dalam user security guide: "Selalu kunci layar (Ctrl+L / Windows+L / Cmd+Ctrl+Q) sebelum meninggalkan meja"

---

### A.7.8 Equipment Siting and Protection

**Status:** N/A (hosting provider)

**Deskripsi Kontrol:** Penempatan dan perlindungan peralatan untuk meminimalkan risiko ancaman lingkungan dan akses tidak sah.

**Penilaian:**

Untuk cloud deployment, tanggung jawab penempatan dan perlindungan perangkat keras sepenuhnya ada pada hosting provider. Tidak ada kontrol yang dapat diterapkan oleh Fundara project atau NGO deployer untuk aspek ini.

---

### A.7.9 Security of Assets Off-Premises

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Perlindungan aset yang dibawa atau digunakan di luar lokasi yang disetujui, seperti laptop dan perangkat mobile.

**Evidence Tersedia:**
- `docs/dev/local-setup.md` — panduan setup laptop developer (implicit bahwa developer bekerja remote)
- `docs/security/security-requirements.md` — SR-ENC-01: enkripsi untuk data sensitif; SR-AUTH-03: 2FA

**Penilaian:**

Laptop developer adalah aset off-premises yang mengandung source code Fundara dan mungkin kredensial staging. Namun tidak ada policy formal untuk keamanan laptop developer.

**Gap yang Teridentifikasi:**
1. Tidak ada kebijakan laptop developer yang mewajibkan: full disk encryption (BitLocker/FileVault/LUKS), screen lock otomatis, tidak menyimpan production credentials di laptop
2. `docs/dev/local-setup.md` memandu cara setup environment development, tetapi tidak mencakup aspek keamanan laptop
3. Tidak ada panduan untuk staf NGO tentang keamanan perangkat yang digunakan untuk mengakses Fundara dari luar kantor
4. Tidak ada prosedur untuk kasus kehilangan laptop developer yang mungkin berisi SSH key, API key staging, atau kode yang belum di-push ke repository

**Rekomendasi:**
1. Tambahkan seksi "Developer Laptop Security" di `CONTRIBUTING.md` yang mewajibkan: full disk encryption (wajib), screen lock dalam 10 menit idle (wajib), SSH key dengan passphrase (wajib), tidak menyimpan staging credentials di file teks biasa
2. Buat prosedur respons jika laptop developer hilang: revoke SSH key, rotate staging API keys, audit Git history untuk memeriksa apakah ada credentials yang ter-commit
3. Rekomendasikan kepada NGO deployer untuk menetapkan policy serupa untuk laptop staf yang mengakses Fundara

---

### A.7.10 Storage Media

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Manajemen media penyimpanan sesuai dengan klasifikasi informasi, termasuk prosedur pembuangan yang aman.

**Evidence Tersedia:**
- `docs/infra/backup-recovery.md` — GPG encrypt backup sebelum upload ke offsite storage, prosedur penghapusan backup lokal yang sudah lewat retensi
- `docs/security/security-requirements.md` — SR-ENC-01: GPG AES-256 untuk backup, `private/files/` tidak terekspos ke web root
- `docs/infra/backup-recovery.md` Section 2.4: "Do not keep more than 3 days of backups on the production server itself"

**Penilaian:**

Media penyimpanan utama Fundara adalah disk VPS (virtual disk) dan cloud object storage (Wasabi/Backblaze B2). Enkripsi backup sebelum upload sudah dispesifikasikan dengan baik. Retensi dan rotasi backup sudah didefinisikan.

**Gap yang Teridentifikasi:**
1. Tidak ada prosedur **secure disposal** media penyimpanan — untuk VPS/cloud ini umumnya N/A karena media fisik dikelola provider, namun tidak ada dokumentasi eksplisit tentang ini
2. Tidak ada prosedur untuk penghapusan data pada saat offboarding (jika NGO berhenti menggunakan Fundara: bagaimana data dihapus dari cloud storage, dari VPS, dari backup?)
3. Tidak ada panduan tentang media penyimpanan portabel yang digunakan untuk transfer data (USB drive, external hard disk) — apakah enkripsi wajib?
4. Prosedur penghapusan backup lama (setelah melewati retensi) disebutkan di `backup-recovery.md`, namun tidak ada detail teknis tentang metode penghapusan yang aman (misalnya: `rclone delete` saja, atau secure overwrite?)

**Rekomendasi:**
1. Tambahkan prosedur "Data Destruction on Offboarding" di deployment guide: langkah-langkah untuk menghapus semua data NGO dari sistem saat mereka berhenti menggunakan Fundara (drop database, hapus private files, hapus semua backup di cloud storage)
2. Dokumentasikan bahwa untuk VPS/cloud deployment, secure disposal media fisik menjadi tanggung jawab provider (N/A untuk Fundara project)
3. Tambahkan panduan bahwa jika data diekspor ke media portabel (untuk keperluan audit, misalnya), media tersebut harus dienkripsi dan dihapus setelah tidak diperlukan

---

### A.7.11 Supporting Utilities

**Status:** N/A (hosting provider)

**Deskripsi Kontrol:** Perlindungan peralatan pendukung seperti listrik, air conditioning, dan sistem fire suppression.

**Evidence Tersedia:**
- `docs/infra/environment-spec.md` — menyebutkan UPS dan kebutuhan cooling sebagai pertimbangan untuk deployment on-premise

**Penilaian:**

Untuk cloud/VPS deployment, utilities fisik (generator, UPS, HVAC) menjadi tanggung jawab data center provider. `environment-spec.md` menyebutkan kebutuhan ini sebagai pertimbangan opsional untuk deployment on-premise, menunjukkan awareness terhadap kontrol ini.

**Rekomendasi untuk NGO:** Untuk deployment cloud, pastikan SLA provider mencakup jaminan availability yang mempertimbangkan kegagalan utilitas. Untuk on-premise, minimal pastikan ada UPS dengan kapasitas minimal 30 menit dan sistem pendingin yang cukup untuk server yang berjalan 24/7.

---

### A.7.12 Cabling Security

**Status:** N/A (hosting provider)

**Deskripsi Kontrol:** Keamanan kabel power dan data dari interferensi, gangguan, atau intersepsi.

**Penilaian:**

Sepenuhnya tanggung jawab data center hosting provider. Tidak relevan untuk cloud/VPS deployment dari sisi Fundara atau NGO deployer.

---

### A.7.13 Equipment Maintenance

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Perawatan peralatan yang benar untuk memastikan ketersediaan dan integritas yang berkelanjutan.

**Evidence Tersedia:**
- `docs/infra/upgrade-runbook.md` — mendefinisikan prosedur upgrade server yang terstruktur: staging first, backup before upgrade, rollback plan
- `docs/security/security-requirements.md` — SR-DEP-04: `unattended-upgrades` diaktifkan untuk security patches
- `docs/infra/environment-spec.md` — pinned software versions, software stack yang terdefinisi

**Penilaian:**

"Equipment" dalam konteks Fundara adalah VPS instance dan software stack (OS, database, application). Maintenance plan sudah ada dalam bentuk `upgrade-runbook.md` yang mencakup prosedur upgrade yang terstruktur.

**Gap yang Teridentifikasi:**
1. Tidak ada jadwal maintenance formal (maintenance window schedule) — kapan upgrade OS dijadwalkan, kapan bench update direncanakan, kapan backup testing dilakukan
2. Tidak ada prosedur formal untuk VPS instance refresh (replacement server dengan OS baru) yang berbeda dari upgrade in-place
3. Maintenance prosedur ada, tetapi belum ada **maintenance calendar** yang mendefinisikan frekuensi, jadwal, dan penanggung jawab setiap jenis maintenance

**Rekomendasi:**
1. Buat maintenance calendar atau jadwal yang didefinisikan di deployment guide: monthly OS security patch review, quarterly dependency audit (pip audit + npm audit), monthly backup restore drill, annual full security review
2. Sertakan estimated downtime untuk setiap jenis maintenance sehingga NGO dapat merencanakan communication ke pengguna

---

### A.7.14 Secure Disposal or Re-use of Equipment

**Status:** N/A untuk cloud deployment

**Deskripsi Kontrol:** Prosedur untuk memastikan data dihapus secara aman dari peralatan yang akan dibuang atau digunakan kembali.

**Evidence Tersedia:**
- Tidak ada prosedur formal, tetapi tidak relevan untuk cloud/VPS

**Penilaian:**

Untuk cloud/VPS deployment, "disposal" peralatan berarti menghapus VPS instance. Data di virtual disk secara teori terhapus ketika instance dihapus, tetapi jaminan secure overwrite tergantung pada kebijakan provider.

**Rekomendasi:**
1. Tambahkan panduan di deployment guide: sebelum menghapus VPS instance, jalankan prosedur data destruction terlebih dahulu (drop database, hapus `/home/frappe/frappe-bench/sites/`, hapus SSL certificates dan keys, hapus backup.key)
2. Dokumentasikan bahwa untuk VPS, NGO harus memverifikasi kebijakan provider tentang data retention setelah instance deletion (apakah ada jaminan bahwa disk tidak dapat dipulihkan oleh provider atau customer lain?)
3. Untuk on-premise server yang akan dibuang atau dijual, gunakan DoD 5220.22-M secure erasure atau physical destruction media

---

## A.8 TECHNOLOGICAL CONTROLS

**Ringkasan:** 34 kontrol yang berkaitan dengan teknologi — endpoint, akses istimewa, enkripsi, logging, monitoring, pengembangan aman, dan manajemen perubahan.

---

### A.8.1 User Endpoint Devices

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Informasi yang diakses, diproses, atau disimpan pada endpoint devices harus dilindungi.

**Evidence Tersedia:**
- `docs/dev/local-setup.md` — panduan setup laptop developer (Python, Node, bench, Git)
- `docs/security/security-requirements.md` — SR-AUTH-03: 2FA wajib untuk role sensitif (melindungi akses dari sembarang endpoint)
- Tidak ada endpoint device policy untuk staf NGO

**Penilaian:**

Panduan endpoint untuk developer sudah ada dalam `local-setup.md`, meskipun berfokus pada setup teknis bukan security. Untuk end user NGO (Finance Officer, Project Manager, Field Staff), tidak ada panduan tentang keamanan perangkat mereka.

Kontrol teknis seperti 2FA dan HTTPS memberikan perlindungan yang signifikan bahkan dari endpoint yang kurang aman, namun tidak menghilangkan semua risiko (misalnya: keylogger di laptop pengguna dapat mencuri credentials bahkan setelah 2FA).

**Gap yang Teridentifikasi:**
1. Tidak ada **endpoint device policy** untuk staf NGO: antivirus minimum, update OS, screen lock, tidak menginstal software ilegal
2. Tidak ada panduan tentang keamanan browser: penggunaan browser yang aman, tidak menyimpan password di browser untuk akun Fundara sensitif, tidak mengakses Fundara dari browser bersama
3. Tidak ada panduan tentang penggunaan perangkat mobile: apakah akses Fundara via smartphone diizinkan? Jika ya, apakah ada persyaratan keamanan?
4. Tidak ada Mobile Device Management (MDM) yang direkomendasikan — mungkin N/A untuk NGO kecil, tapi perlu disebutkan

**Rekomendasi:**
1. Buat panduan singkat "Persyaratan Perangkat untuk Mengakses Fundara" di user security guide: OS up-to-date, antivirus aktif, screen lock diaktifkan, tidak menggunakan perangkat bersama/umum untuk akses Finance Manager/System Admin role
2. Rekomendasikan pengguna Finance Manager dan System Admin untuk menggunakan password manager dan tidak menyimpan password Fundara di browser
3. Tentukan kebijakan BYOD (Bring Your Own Device): apakah diizinkan, dan jika ya, persyaratan minimal keamanannya

---

### A.8.2 Privileged Access Rights

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Alokasi dan penggunaan privileged access rights harus dibatasi dan dikelola.

**Evidence Tersedia:**
- `docs/security/security-requirements.md` — SR-AUTHZ-01: "System Manager hanya 1–2 akun (Tech Lead dan satu backup)"; SR-AUTHZ-01: "Role assignment requires approval from Finance Manager or System Admin before activation"
- `docs/spec/permissions.md` — role matrix mendefinisikan 13 role dengan segregasi privilege yang ketat
- `docs/security/owasp-checklist.md` — A05: "System Manager role: hanya 1–2 akun" sebagai item deployment checklist; audit via SQL query
- `docs/security/security-requirements.md` — SR-AUTH-03: 2FA wajib untuk System Admin
- `docs/security/security-requirements.md` — SR-AUTHZ-02: `frappe.flags.ignore_permissions = True` dilarang di production code paths

**Penilaian:**

Pengelolaan akses istimewa sudah terdefinisi dengan baik di Fundara:
- Jumlah System Manager dibatasi secara eksplisit (1–2 akun)
- Role assignment memerlukan approval
- 2FA wajib untuk System Admin
- Penggunaan `ignore_permissions` dikontrol ketat dengan dokumentasi dan justifikasi
- Audit trail untuk privileged actions tersedia via Frappe Activity Log

**Kontrol yang Sudah Berjalan:**
- Pembatasan jumlah System Manager dengan verifikasi via SQL audit query
- Principle of least privilege diterapkan di level DocType
- Privileged bench commands (admin CLI) hanya bisa dijalankan melalui SSH (tidak tersedia di web interface produksi)
- System Admin tercakup dalam mandatory 2FA
- Tidak ada shared privileged accounts — satu Frappe user per manusia

---

### A.8.3 Information Access Restriction

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Akses ke informasi dan fungsi aplikasi harus dibatasi sesuai dengan kebijakan access control.

**Evidence Tersedia:**
- `docs/spec/permissions.md` — RBAC dengan 13 role dan 30+ DocType, permission matrix yang lengkap (CRWSAD per DocType per role)
- `docs/security/security-requirements.md` — SR-AUTHZ-03: PII fields di-mask sebagai "***" untuk role tanpa akses
- `docs/security/security-requirements.md` — SR-AUTHZ-04: document-level security (Field Staff hanya akses record miliknya, Project Manager hanya akses project yang ditugaskan)
- `docs/spec/frontend/form-layout.md` — `depends_on`, `read_only`, field-level access control di UI
- `docs/security/owasp-checklist.md` — A01: implementasi `has_permission` hook per DocType

**Penilaian:**

Information access restriction sudah diimplementasikan secara komprehensif di Fundara:
- RBAC 13 role dengan permission matrix terperinci untuk setiap kombinasi DocType × Role
- Field-level security dengan masking "***" untuk PII (NPWP, NIK, data kesehatan)
- Document-level security berbasis ownership (server-side, bukan hanya UI)
- Conditional permissions berbasis threshold amount untuk financial approvals
- Pembatasan scope (Project Manager hanya akses project miliknya)

---

### A.8.4 Access to Source Code

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Akses baca dan tulis ke source code harus dikendalikan.

**Evidence Tersedia:**
- `docs/dev/git-branching.md` — branch protection rules: `main` tidak bisa di-push langsung oleh siapapun, semua perubahan melalui PR, Tech Lead only untuk merge ke main
- `docs/dev/git-branching.md` — PR review required sebelum merge ke `develop` dan ke `main`
- GitHub repository `masmaksum/Fundara` — akses dikontrol via GitHub permissions (public repository untuk source, private untuk credentials)
- `docs/dev/git-branching.md` — hotfix process dengan approval chain yang ketat

**Penilaian:**

Akses ke source code dikontrol melalui GitHub permissions dan branch protection rules. Setiap perubahan ke kode harus melalui PR review — tidak ada developer yang bisa langsung push ke branch protected tanpa review.

**Kontrol yang Sudah Berjalan:**
- Branch protection: `main` dan `staging` tidak bisa di-push langsung
- PR review mandatory sebelum merge ke `develop`
- Tech Lead as sole merger ke `main`
- Version tagging untuk setiap production release
- Commit message convention dengan domain prefix memungkinkan audit trail per area kode
- Tidak ada `Co-Authored-By` di commit untuk kebijakan audit trail yang ketat

**Catatan:** Repository `masmaksum/Fundara` adalah public repository. Ini disengaja untuk proyek open-source NGO. Tidak ada credentials, site_config.json, atau secrets di repository (dikontrol via `.gitignore` dan SR-DEV-06).

---

### A.8.5 Secure Authentication

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Teknologi dan prosedur secure authentication diimplementasikan berdasarkan akses restriction pada informasi.

**Evidence Tersedia:**
- `docs/security/security-requirements.md` — SR-AUTH-01: password policy minimum 12 karakter, uppercase + lowercase + number + symbol, no reuse of last 6 passwords
- `docs/security/security-requirements.md` — SR-AUTH-02: session timeout 8 jam, server-side token revocation via Redis, concurrent session limit
- `docs/security/security-requirements.md` — SR-AUTH-03: TOTP 2FA (RFC 6238) wajib untuk System Admin, Finance Manager, Management/Executive
- `docs/security/security-requirements.md` — SR-AUTH-04: lockout setelah 5 gagal login, 30 menit lockout, notifikasi ke System Admin
- `docs/security/security-requirements.md` — SR-AUTH-05: API keys scoped ke minimum role, disimpan di environment variables, rotasi 90 hari
- `docs/infra/environment-spec.md` — tabel konfigurasi System Settings yang harus diverifikasi sebelum go-live

**Penilaian:**

Secure authentication sudah terdefinisi secara komprehensif dan mencakup semua aspek penting: password policy yang kuat, session management yang tepat, 2FA untuk privileged roles, dan rate limiting. Frappe built-in authentication mechanism mendukung semua kontrol ini secara native.

**Kontrol yang Sudah Berjalan:**
- Password policy ketat: 12 karakter minimum, kompleksitas wajib, no reuse
- TOTP 2FA mandatory untuk role Finance Manager, System Admin, dan Management
- Account lockout setelah 5 gagal (dengan alert otomatis ke System Admin)
- Server-side session invalidation (token di-revoke di Redis, bukan hanya cookie expired)
- API key scoped ke minimum role yang diperlukan

---

### A.8.6 Capacity Management

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Penggunaan sumber daya harus dimonitor dan diproyeksikan, dengan kapasitas yang disesuaikan untuk memenuhi kebutuhan di masa depan.

**Evidence Tersedia:**
- `docs/infra/environment-spec.md` — server sizing untuk tiga profile: Profile A (Community), Profile B (Small NGO), Profile C (Medium NGO)
- `docs/infra/monitoring-spec.md` — monitoring thresholds untuk CPU (> 80% warning), RAM (> 85% warning), disk (> 80% warning), dengan alert ke ops team
- `docs/infra/monitoring-spec.md` — "Disk fill rate projection (days until full)" disebutkan sebagai metric di Ops Dashboard

**Penilaian:**

Kapasitas server sudah didefinisikan per profile deployment dan monitoring sudah mencakup metrik kapasitas utama dengan threshold yang jelas. Ada proyeksi "days until full" untuk disk space, yang merupakan bentuk capacity planning dasar.

**Gap yang Teridentifikasi:**
1. Tidak ada **formal capacity planning process** — bagaimana NGO memutuskan kapan harus upgrade dari Profile B ke Profile C? Berapa threshold yang memicu upgrade?
2. Tidak ada capacity growth forecast — proyeksi berapa GB data yang dihasilkan per bulan oleh NGO tipikal, sehingga NGO bisa merencanakan kapan disk akan habis
3. Tidak ada panduan tentang database size growth — tabel GL Entry, Activity Log, dan Document Version History bisa tumbuh signifikan seiring waktu
4. Tidak ada rekomendasi tentang kapan menambah Gunicorn workers atau scaling database

**Rekomendasi:**
1. Tambahkan seksi "Capacity Planning Guide" di deployment guide: panduan praktis kapan NGO harus mempertimbangkan upgrade server (rule of thumb: upgrade ketika RAM usage > 75% secara konsisten selama 2 minggu, atau disk usage > 70%)
2. Berikan estimasi growth rate untuk deployment tipikal: berapa GB per 1.000 transaksi, berapa GB per tahun untuk NGO dengan 50 pengguna
3. Jadikan capacity planning sebagai bagian dari quarterly review yang direkomendasikan kepada NGO deployer

---

### A.8.7 Protection Against Malware

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Perlindungan terhadap malware diimplementasikan dan didukung oleh user awareness yang tepat.

**Evidence Tersedia:**
- `docs/security/owasp-checklist.md` — A06: `pip audit` dan `npm audit` untuk dependency vulnerability scanning
- `docs/security/security-requirements.md` — SR-DEP-02/SR-DEP-03: pip audit dan npm audit dijalankan bulanan di CI pipeline
- `docs/security/security-requirements.md` — SR-DEV-06: pre-commit hook untuk scan secret patterns (`gitleaks` atau `detect-secrets`)
- `docs/security/owasp-checklist.md` — A06: Ubuntu package security updates via `unattended-upgrades`

**Penilaian:**

Dependency scanning sudah terspesifikasikan dengan baik untuk Python dan Node dependencies. Pre-commit hook untuk secret scanning juga sudah didefinisikan. Ini adalah pendekatan yang tepat untuk software supply chain malware protection.

Namun, tidak ada proteksi malware pada tingkat **server OS** (antivirus/antimalware untuk Ubuntu server) dan tidak ada **file upload scanning** untuk file yang diupload user ke Fundara.

**Gap yang Teridentifikasi:**
1. Tidak ada antivirus/malware scanning di server (ClamAV atau equivalent) — untuk Ubuntu VPS ini opsional, namun perlu disebutkan dalam konteks compliance
2. Tidak ada file upload scanning untuk malware — user bisa mengupload file yang terinfeksi sebagai "bukti transaksi" atau attachment. File tersebut disimpan di `private/files/` tanpa scanning
3. Tidak ada monitoring untuk perilaku anomali yang mengindikasikan malware (unusual outbound connections, unusual file system activity)
4. User awareness tentang malware (phishing email yang mengarah ke credential theft) tidak tercakup dalam security awareness materials yang ada

**Rekomendasi:**
1. Pertimbangkan menambahkan ClamAV di deployment guide sebagai opsional (recommended) untuk scanning file upload: `clamscan` dapat diintegrasikan dengan Frappe file upload hook
2. Tambahkan panduan untuk NGO tentang risiko phishing: email palsu yang mengklaim dari "Fundara Support" yang meminta reset password atau login ke situs palsu
3. Monitoring anomali (unusual outbound traffic) dapat dilakukan via Netdata network monitoring yang sudah dispesifikasikan di `monitoring-spec.md`

---

### A.8.8 Management of Technical Vulnerabilities

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Informasi tentang kerentanan teknis pada sistem informasi yang digunakan harus diperoleh tepat waktu, paparan organisasi terhadap kerentanan tersebut harus dievaluasi, dan tindakan yang tepat harus diambil.

**Evidence Tersedia:**
- `docs/security/security-requirements.md` — SR-DEP-05: CVE SLA — Critical ditangani dalam 7 hari, High dalam 30 hari; notifikasi segera ke Tech Lead
- `docs/security/security-requirements.md` — SR-DEP-01: ERPNext dan Frappe di-pin ke versi yang sudah ditest; SR-DEP-02/SR-DEP-03: pip audit dan npm audit bulanan
- `docs/security/security-requirements.md` — SR-DEP-04: `unattended-upgrades` untuk security patches Ubuntu
- `docs/security/owasp-checklist.md` — A06: checklist dependency scanning yang komprehensif
- `docs/infra/upgrade-runbook.md` — prosedur upgrade yang terstruktur dengan staging validation sebelum production

**Penilaian:**

Manajemen kerentanan teknis sudah terdefinisi dengan baik: SLA yang jelas (7 hari untuk Critical, 30 hari untuk High), mekanisme scanning yang terjadwal (bulanan di CI), dan prosedur upgrade yang terstruktur. Penggunaan `unattended-upgrades` untuk OS security patches memastikan patch kritis diterapkan secara otomatis tanpa menunggu siklus maintenance manual.

**Kontrol yang Sudah Berjalan:**
- CVE SLA yang jelas dan terukur
- Automated dependency scanning (pip audit + npm audit) di CI pipeline
- OS security patches via unattended-upgrades (hanya security, bukan full upgrade)
- Upgrade prosedur yang ketat: staging first, backup before upgrade, rollback plan
- Pinned versions untuk mencegah accidental upgrade ke versi yang belum ditest

---

### A.8.9 Configuration Management

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Konfigurasi perangkat keras, perangkat lunak, layanan, dan jaringan harus ditetapkan, didokumentasikan, diimplementasikan, dipantau, dan ditinjau.

**Evidence Tersedia:**
- `docs/infra/deploy.sh` — deployment script yang idempotent dengan `set -euo pipefail`, menjamin konfigurasi yang konsisten dan repeatable
- `docs/infra/environment-spec.md` — konfigurasi lengkap untuk setiap environment: dev, staging, production; port matrix; software versions
- `docs/infra/deploy-vars.example` — template variabel deployment yang terdokumentasi
- `docs/security/security-requirements.md` — tabel konfigurasi System Settings yang harus diverifikasi sebelum go-live (developer_mode, session timeout, 2FA, dll.)

**Penilaian:**

Configuration management sudah diimplementasikan dengan baik melalui pendekatan Infrastructure-as-Code. Deployment script yang idempotent memastikan bahwa konfigurasi yang sama dapat direproduksi. Environment-spec.md mendokumentasikan seluruh konfigurasi yang diharapkan per environment, memungkinkan audit dan verifikasi.

**Kontrol yang Sudah Berjalan:**
- Idempotent deployment script dengan error handling ketat
- Dokumentasi lengkap konfigurasi per environment
- Template variabel deployment (deploy-vars.example) memastikan semua konfigurasi terdefinisi
- Pre-go-live verification checklist untuk System Settings
- Pinned software versions di semua environment

---

### A.8.10 Information Deletion

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Informasi yang disimpan di sistem informasi, perangkat, atau media lainnya harus dihapus ketika tidak diperlukan lagi.

**Evidence Tersedia:**
- `docs/security/data-privacy.md` — retention policy dan anonymization procedure; GL Entry tidak dihapus tetapi di-anonymize (karena GL immutable — ini adalah desain yang tepat untuk ISAK 35 compliance)
- `docs/infra/backup-recovery.md` — retensi backup yang terdefinisi: local 3 hari, remote daily 14 hari, weekly 8 minggu, monthly 12 bulan; backup lama dihapus secara otomatis

**Penilaian:**

Information deletion sudah diimplementasikan dengan pendekatan yang tepat untuk sistem akuntansi: GL Entry tidak dihapus (immutable karena kebutuhan audit trail akuntansi), tetapi data personal donor dan beneficiary di-anonymize saat tidak lagi diperlukan (sesuai prinsip data minimization UU PDP). Backup deletion otomatis berdasarkan retensi policy memastikan data tidak disimpan lebih lama dari yang diperlukan.

**Kontrol yang Sudah Berjalan:**
- Backup retention policy dengan automatic deletion setelah melewati periode retensi
- Data anonymization (bukan deletion) untuk GL records yang immutable — approach yang tepat secara akuntansi dan compliance
- Prosedur anonymization yang terdokumentasi di data-privacy.md

---

### A.8.11 Data Masking

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Data masking digunakan sesuai dengan kebijakan topik access control spesifik dan persyaratan bisnis lainnya.

**Evidence Tersedia:**
- `docs/security/security-requirements.md` — SR-AUTHZ-03: PII fields (donor NPWP/NIK, beneficiary name/ID/health data, staff salary/bank account) di-mask sebagai "***" — bukan null atau string kosong — untuk role tanpa akses
- `docs/spec/permissions.md` — field-level permissions per DocType per role
- `docs/security/data-privacy.md` — dokumentasi field apa saja yang di-mask dan untuk role apa
- `docs/infra/environment-spec.md` — section 2.8: data anonymization rules untuk staging environment (donor names → `Donor-XXXX`, staff names → `Staff-XXXX`)

**Penilaian:**

Data masking sudah diimplementasikan di dua level: (1) field-level masking untuk production environment (PII ditampilkan sebagai "***" untuk role yang tidak berwenang), dan (2) dataset anonymization untuk staging environment. Pendekatan "***" lebih baik daripada menghilangkan field sepenuhnya karena pengguna dapat membedakan antara "nilai tersembunyi" dan "field kosong".

**Kontrol yang Sudah Berjalan:**
- PII masking dengan "***" (bukan null/empty) — best practice
- Field-level implementation via Frappe `before_load` hook atau field-level permission
- Anonymization rules untuk staging terdokumentasi dan diperlakukan sebagai mandatory
- DocType yang terdampak terdefinisi: Donor, Beneficiary, Staff Profile, Grant Agreement

---

### A.8.12 Data Leakage Prevention

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Langkah-langkah Data Leakage Prevention (DLP) harus diterapkan pada sistem, jaringan, dan perangkat yang memproses, menyimpan, atau mentransmisikan informasi sensitif.

**Evidence Tersedia:**
- `docs/security/security-requirements.md` — SR-DEV-02: no sensitive data (NPWP, passwords, health data, GL amounts) dalam logs; SR-DEV-03: permission check wajib di semua whitelisted endpoints
- `docs/security/owasp-checklist.md` — A01 (access control) dan A02 (cryptographic failures) mencakup aspek DLP
- `docs/security/security-requirements.md` — SR-AUTH-05: API keys tidak di-commit ke git
- `docs/security/security-requirements.md` — SR-ENC-01: file attachments di `private/files/` tidak exposed ke web root

**Penilaian:**

DLP di Fundara diimplementasikan melalui kontrol teknis individual (log sanitization, file access control, API permission checks) daripada melalui dedicated DLP solution. Ini adalah pendekatan yang tepat untuk NGO kecil dan tidak memerlukan dedicated DLP tool komersial.

**Gap yang Teridentifikasi:**
1. Tidak ada formal DLP policy yang mendefinisikan apa yang diklasifikasikan sebagai "data sensitif" dan apa yang tidak boleh meninggalkan sistem (data classificaton belum formal)
2. Tidak ada kontrol terhadap export data dalam jumlah besar — pengguna dengan akses Audit role bisa mengekspor seluruh GL Entry atau Donor list via Frappe's built-in export feature. Tidak ada rate limiting atau alerting untuk large data exports
3. Tidak ada DLP untuk email attachment — jika pengguna mengirim laporan keuangan via Frappe's email fitur, tidak ada mekanisme untuk mencegah pengiriman ke alamat tidak sah
4. Tidak ada monitoring untuk anomalous data access patterns (misalnya: seseorang yang biasanya mengakses 10 donor records per hari tiba-tiba mengakses 5.000 records)

**Rekomendasi:**
1. Tambahkan alert di monitoring untuk large data exports (misalnya: Frappe API call yang mengembalikan > 1.000 records dalam satu request dari satu user dalam waktu singkat) — ini bisa diimplementasikan melalui Nginx log analysis
2. Pertimbangkan untuk membatasi fitur bulk export untuk role tertentu saja (misalnya: hanya System Admin dan Audit role yang bisa export > 500 records)
3. Untuk NGO kecil, dokumentasikan bahwa formal DLP solution tidak diperlukan (acceptable risk), namun kontrol manual (periodic access log review oleh System Admin) direkomendasikan sebagai pengganti

---

### A.8.13 Information Backup

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Salinan cadangan informasi, perangkat lunak, dan sistem harus dibuat dan diuji secara teratur sesuai dengan kebijakan topik backup yang disepakati.

**Evidence Tersedia:**
- `docs/infra/backup-recovery.md` — jadwal backup yang komprehensif: daily full dump (02:00), weekly archive (Minggu 03:00), monthly archive (tanggal 1, 04:00)
- `docs/infra/backup-recovery.md` — 3-2-1 rule compliance: 3 copies (local + remote S3 + monthly offsite), 2 different media (server disk + cloud), 1 offsite (cloud storage)
- `docs/infra/backup-recovery.md` — GPG AES-256 encryption untuk semua backup sebelum upload ke offsite storage
- `docs/infra/backup-recovery.md` — RPO 24 jam untuk Profile B (Small NGO), RTO 4 jam
- `docs/infra/backup-recovery.md` — prosedur restore yang lengkap untuk 5 skenario (full restore, database-only, file-only, single document, point-in-time)
- `docs/infra/backup-recovery.md` — monthly restore drill dengan drill log template
- `docs/infra/backup.sh` — automated backup script yang terotomatisasi

**Penilaian:**

Implementasi backup sudah sangat komprehensif. Mencakup semua aspek: jadwal yang terstruktur, enkripsi yang kuat, 3-2-1 rule, multiple restore scenarios, dan prosedur testing yang terdokumentasi dengan drill log template. Monthly restore drill adalah praktik terbaik yang sudah didefinisikan sejak awal.

**Kontrol yang Sudah Berjalan:**
- 3-level backup hierarchy (daily, weekly, monthly) dengan retention yang berbeda
- GPG AES-256 encryption mandatory untuk semua offsite backup
- 3-2-1 rule compliance yang terdokumentasi
- 5 prosedur restore yang berbeda untuk berbagai skenario kegagalan
- Monthly restore drill dengan pass/fail checklist dan log template
- Alert otomatis jika backup gagal (email/Telegram)

---

### A.8.14 Redundancy of Information Processing Facilities

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Fasilitas pemrosesan informasi harus diimplementasikan dengan redundansi yang cukup untuk memenuhi persyaratan ketersediaan.

**Evidence Tersedia:**
- `docs/infra/environment-spec.md` — production server spec (single VPS deployment untuk Profile B)
- `docs/infra/backup-recovery.md` — prosedur full site restore ke server baru dalam kasus server failure (RTO 4 jam)
- `docs/infra/monitoring-spec.md` — Uptime Kuma untuk monitoring availability, alert jika downtime > 2 menit

**Penilaian:**

MVP Fundara menggunakan **single server deployment** tanpa High Availability (HA) atau failover otomatis. Ini adalah keputusan desain yang disengaja untuk menjaga biaya tetap terjangkau untuk NGO kecil di Indonesia. Jika server utama down, prosedur restore manual diperlukan (RTO 4 jam untuk Profile B).

**Gap yang Teridentifikasi:**
1. Tidak ada High Availability specification — single VPS tanpa stanby server, tanpa load balancer, tanpa database replication
2. Tidak ada automatic failover — jika production server gagal, recovery memerlukan intervening manual
3. RTO 4 jam mungkin tidak acceptable untuk NGO yang beroperasi dengan deadline laporan donor yang ketat
4. Tidak ada prosedur untuk menangani kegagalan parsial (misalnya: MariaDB crash sementara web server masih up)

**Rekomendasi:**
1. Dokumentasikan secara eksplisit bahwa **single server tanpa HA adalah accepted risk** untuk MVP — ini harus dikomunikasikan kepada NGO deployer saat onboarding
2. Buat panduan "Upgrade Path" untuk NGO yang memerlukan lebih tinggi availability: kapan mempertimbangkan Profile C (separated DB) atau HA setup
3. Rekomendasikan minimal memiliki **hot spare image** (snapshot server yang bisa di-restore dalam 1 jam) sebagai trade-off yang cost-effective terhadap HA penuh
4. Untuk NGO yang sangat bergantung pada sistem (misalnya: grant disbursement deadline), rekomendasikan Profile D (Hosted SaaS) dengan dedicated uptime guarantee

---

### A.8.15 Logging

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Log yang mencatat aktivitas, pengecualian, kesalahan, dan kejadian keamanan lainnya harus diproduksi, disimpan, dilindungi, dan dianalisis.

**Evidence Tersedia:**
- `docs/security/security-requirements.md` — SR-LOG-01: Document Versioning wajib untuk semua submittable DocType (`track_changes = 1`); version history read-only
- `docs/security/security-requirements.md` — SR-LOG-02: login events (sukses dan gagal), logout, role assignment, system settings changes dicatat di Frappe Activity Log; retensi minimum 2 tahun
- `docs/security/security-requirements.md` — SR-LOG-03: GL Entry immutable setelah submit; lifecycle events Cash Advance dicatat dengan approving user
- `docs/security/security-requirements.md` — SR-LOG-04: Audit role bisa baca log tetapi tidak bisa delete; server logs hanya accessible via SSH oleh DevOps; log rotation dikonfigurasi
- `docs/infra/monitoring-spec.md` — daftar lengkap log files yang dimonitor beserta lokasi dan hal yang perlu diperhatikan (error.log, worker.log, schedule.log, nginx access/error log, mariadb slow query log, auth.log, fail2ban.log, backup.log)

**Penilaian:**

Logging sudah diimplementasikan secara komprehensif di tiga level: (1) application audit log (Frappe Activity Log + Document Version), (2) financial audit log (GL Entry immutability + Cash Advance lifecycle), dan (3) server-level logs (Nginx, MariaDB, auth.log, fail2ban). Retensi 2 tahun untuk Activity Log memenuhi kebutuhan compliance. Proteksi log (read-only untuk Audit role, tidak ada delete permission) sudah terdefinisi.

---

### A.8.16 Monitoring Activities

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Jaringan, sistem, dan aplikasi harus dipantau untuk mendeteksi perilaku anomali dan mendukung pengambilan tindakan yang tepat.

**Evidence Tersedia:**
- `docs/infra/monitoring-spec.md` — monitoring stack: Netdata (sistem) + Uptime Kuma (availability); alert thresholds untuk CPU, RAM, disk, network
- `docs/infra/monitoring-spec.md` — application metrics: web worker response time, queue depth, failed background jobs, scheduler health, Redis memory, MariaDB connections
- `docs/infra/monitoring-spec.md` — security monitoring: alert untuk failed login spike (> 10 dalam 5 menit dari satu IP), brute force detection via fail2ban
- `docs/infra/monitoring-spec.md` — business metrics digest: overdue advances, overdue grant reports, low fund balance, backup status
- `docs/infra/monitoring-spec.md` — custom Fundara health endpoint (`/api/method/fundara.api.health`) untuk synthetic monitoring
- `docs/infra/setup-monitoring.sh` — automated monitoring setup script

**Penilaian:**

Monitoring activities sudah sangat komprehensif: mencakup sistem (CPU, RAM, disk), aplikasi (response time, queue, scheduler), keamanan (brute force detection, failed login spike), dan bisnis (overdue items, backup status). Pendekatan monitoring berlapis (Netdata + Uptime Kuma + Frappe health endpoint) memberikan visibility yang baik.

**Kontrol yang Sudah Berjalan:**
- Monitoring berlapis: infrastructure + application + security + business
- Alert channel yang terdefinisi: email + Telegram (sesuai kebiasaan NGO Indonesia)
- Automated brute force detection dengan escalation ke fail2ban
- Custom health endpoint untuk synthetic monitoring yang dapat diintegrasikan dengan Uptime Kuma
- Monitoring setup script untuk deployment yang konsisten

---

### A.8.17 Clock Synchronization

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Jam sistem dalam sistem informasi yang digunakan harus disinkronkan dengan sumber waktu yang disepakati.

**Evidence Tersedia:**
- `docs/infra/environment-spec.md` — Ubuntu Server 24.04.4 LTS (default: `systemd-timesyncd` aktif secara default, menggunakan `time.ubuntu.com` sebagai NTP server)
- `docs/dev/local-setup.md` — troubleshooting section menyebutkan WSL2 clock drift sebagai known issue — menunjukkan awareness tentang masalah sinkronisasi waktu

**Penilaian:**

Ubuntu 24.04 secara default menggunakan `systemd-timesyncd` yang sudah dikonfigurasi untuk sinkronisasi NTP dengan `time.ubuntu.com`. Ini berarti sinkronisasi waktu dasar sudah terjadi tanpa konfigurasi tambahan.

Namun, tidak ada verifikasi eksplisit bahwa NTP berjalan dengan benar di server produksi, dan tidak ada konfigurasi NTP yang dispesifikasikan sebagai bagian dari deployment checklist.

**Gap yang Teridentifikasi:**
1. Tidak ada **eksplisit konfigurasi NTP** dalam deployment script atau environment-spec — hanya bergantung pada Ubuntu default yang mungkin berubah di masa depan
2. Tidak ada verifikasi dalam deployment checklist bahwa `systemd-timesyncd` berjalan dan sinkron: `timedatectl status` harus menampilkan `System clock synchronized: yes`
3. Tidak ada monitoring alert jika clock drift melebihi threshold yang dapat diterima (misalnya: > 1 detik dari NTP)
4. WSL2 clock drift disebutkan di `local-setup.md` sebagai masalah development — awareness ini baik, tapi menunjukkan bahwa sinkronisasi waktu tidak selalu reliable di semua environment

**Rekomendasi:**
1. Tambahkan verifikasi `timedatectl status` ke deployment checklist dan post-deployment verification
2. Pertimbangkan untuk menggunakan `chrony` sebagai pengganti `systemd-timesyncd` untuk akurasi dan kontrol yang lebih baik, terutama untuk server produksi yang memerlukan log timestamp yang akurat untuk audit trail
3. Tambahkan monitoring alert jika NTP sinkronisasi gagal atau clock drift > 1 detik (dapat diimplementasikan via Netdata's NTP monitoring module)

---

### A.8.18 Use of Privileged Utility Programs

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Penggunaan program utilitas yang dapat melampaui kontrol sistem dan aplikasi harus dibatasi dan dikendalikan dengan ketat.

**Evidence Tersedia:**
- `docs/security/security-requirements.md` — bench CLI hanya dapat diakses via localhost/SSH (tidak exposed ke web interface produksi)
- `docs/security/owasp-checklist.md` — A05: `developer_mode` disabled di production, yang menonaktifkan Frappe Console (akses arbitrary server script via web)
- `docs/infra/environment-spec.md` — SSH hanya untuk DevOps IPs, `PermitRootLogin no`, `PasswordAuthentication no`
- `docs/security/security-requirements.md` — MariaDB: `mysql_secure_installation` harus dijalankan, Redis: `requirepass` dikonfigurasi

**Penilaian:**

Kontrol terhadap privileged utility programs sudah ada secara implisit: bench CLI dibatasi ke SSH, Frappe Console dinonaktifkan di production, dan akses SSH dikontrol ketat. Namun tidak ada inventaris formal utility programs yang ada di server.

**Gap yang Teridentifikasi:**
1. Tidak ada formal **privileged utility program inventory** — daftar program apa saja yang ada di server, siapa yang boleh menggunakannya, dan dalam kondisi apa
2. Tidak ada prosedur formal untuk membatasi penggunaan program seperti `mysqldump`, `bench console`, `bench execute`, `rclone` — meskipun secara teknis dibatasi ke SSH session, tidak ada logging khusus untuk penggunaan program-program ini
3. Tidak ada monitoring untuk penggunaan `sudo` yang anomali di server (meskipun `/var/log/auth.log` mencatatnya, tidak ada alert spesifik)

**Rekomendasi:**
1. Buat list minimal privileged utilities yang ada di server: `bench`, `mysql/mysqldump`, `rclone`, `gpg`, `nginx` management commands — dan dokumentasikan siapa yang berwenang menggunakannya
2. Aktifkan `sudo` logging ke syslog dan konfigurasi alert di monitoring jika `sudo` digunakan di luar maintenance window
3. Pertimbangkan untuk membatasi `bench execute` (yang memungkinkan arbitrary Python execution) hanya untuk akun `frappe` dan tidak untuk akun lain

---

### A.8.19 Installation of Software on Operational Systems

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Prosedur untuk memastikan keamanan instalasi software pada sistem operasional harus diimplementasikan.

**Evidence Tersedia:**
- `docs/infra/upgrade-runbook.md` — prosedur upgrade yang ketat: staging validation terlebih dahulu, backup sebelum upgrade, rollback plan
- `docs/infra/deploy.sh` — pinned versions untuk semua komponen software
- `docs/security/security-requirements.md` — SR-DEP-01: ERPNext dan Frappe di-pin ke versi spesifik; SR-DEP-04: `unattended-upgrades` hanya untuk security patches (bukan full upgrade otomatis)
- `docs/security/owasp-checklist.md` — A08: deploy ke production hanya dari tagged release; auto-update Fundara custom app dinonaktifkan

**Penilaian:**

Kontrol terhadap instalasi software sudah ketat: semua versi di-pin, upgrade memerlukan staging validation terlebih dahulu, dan auto-update untuk aplikasi utama dinonaktifkan (hanya OS security patches yang otomatis). Pendekatan "tag → staging test → production deploy" memastikan tidak ada software yang masuk ke production tanpa testing.

**Kontrol yang Sudah Berjalan:**
- Pinned versions di semua komponen (ERPNext, Frappe, Python, Node, MariaDB)
- Staging validation wajib sebelum production upgrade
- Auto-update dinonaktifkan untuk application layer
- Hanya OS security patches yang auto-applied
- Deploy dari tagged release (bukan dari HEAD branch)

---

### A.8.20 Network Security

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Jaringan dan perangkat jaringan harus diamankan, dikelola, dan dikendalikan untuk melindungi informasi dalam sistem dan aplikasi.

**Evidence Tersedia:**
- `docs/infra/environment-spec.md` — UFW rules: hanya port 22, 80, 443 yang terbuka ke publik; port 8000, 9000, 3306, 6379, 11000, 12000, 13000 hanya accessible dari localhost
- `docs/security/security-requirements.md` — internal bench ports (8000/9000) bound ke localhost only; MariaDB dan Redis tidak exposed secara publik
- `docs/infra/deploy.sh` — UFW configuration sebagai bagian dari deployment script
- `docs/infra/environment-spec.md` — `fail2ban` untuk SSH dan Nginx jail; SSH non-standard port option
- `docs/infra/monitoring-spec.md` — monitoring untuk Nginx 5xx error rate, anomalous traffic patterns

**Penilaian:**

Network security sudah diimplementasikan dengan baik: firewall rules yang ketat (only 80/443/22 public), semua internal services bound ke localhost, fail2ban untuk brute force protection, dan monitoring untuk anomalous network traffic. UFW configuration yang idempotent melalui deployment script memastikan konfigurasi ini konsisten di setiap deployment.

**Kontrol yang Sudah Berjalan:**
- UFW dengan default deny incoming
- Hanya 3 port yang terbuka ke publik (22 hanya dari allowlisted IPs, 80/443 untuk web)
- Semua internal services (MariaDB, Redis, Frappe direct, Socket.IO) hanya localhost
- fail2ban SSH jail dan Nginx jail
- Monitoring network anomaly

---

### A.8.21 Security of Network Services

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Mekanisme keamanan, tingkat layanan, dan persyaratan manajemen semua layanan jaringan harus diidentifikasi dan termasuk dalam perjanjian layanan jaringan.

**Evidence Tersedia:**
- `docs/infra/environment-spec.md` — TLS 1.2 minimum, TLS 1.3 preferred; Nginx sebagai TLS termination point; HSTS `max-age=31536000; includeSubDomains`
- `docs/infra/environment-spec.md` section 3.6 — Nginx SSL block lengkap: ssl_protocols, ssl_ciphers, ssl_prefer_server_ciphers, OCSP stapling, DH parameter
- `docs/security/security-requirements.md` — SR-ENC-02: HTTP→HTTPS redirect wajib (port 80 hanya 301); TLS untuk semua koneksi web
- `docs/security/owasp-checklist.md` — A02: HSTS header, TLS 1.2 minimum verified via nmap

**Penilaian:**

Keamanan network services sudah sangat komprehensif: TLS 1.3 preferred dengan fallback minimum TLS 1.2, cipher suite yang kuat (ECDHE-based, no RC4/MD5), HSTS dengan includeSubDomains, OCSP stapling, dan HTTP-to-HTTPS redirect mandatory. Nginx SSL configuration mengikuti best practices saat ini.

---

### A.8.22 Segregation of Networks

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Kelompok layanan informasi, pengguna, dan sistem informasi harus dipisahkan dalam jaringan.

**Evidence Tersedia:**
- `docs/infra/environment-spec.md` — 3 environment terpisah: dev / staging / production — network isolation antar environment
- `docs/infra/multisite-guide.md` — site isolation dalam multi-site deployment (setiap NGO di database terpisah)
- `docs/security/data-privacy.md` — production data tidak boleh ke dev/staging (policy isolation)

**Penilaian:**

Segregasi antar environment (dev/staging/production) sudah ada. Dalam satu environment, Frappe multisite menyediakan database isolation antar NGO.

Namun, dalam single VPS production deployment (Profile B), tidak ada network segmentation antara web server dan database server — keduanya berjalan pada host yang sama dan berkomunikasi melalui loopback interface.

**Gap yang Teridentifikasi:**
1. Tidak ada network segmentation dalam production server — MariaDB, Redis, Nginx, dan Frappe workers semua di host yang sama, berkomunikasi via localhost
2. Untuk Profile C (separated DB server), dokumentasi tentang network segmentation antara app server dan DB server belum lengkap — hanya disebutkan ada SSL untuk MariaDB connection, tetapi tidak ada VLAN atau private network spec
3. Tidak ada isolasi network untuk Netdata monitoring agent (yang mungkin mengekspos port 19999 tanpa authentication)

**Rekomendasi:**
1. Untuk Profile B (single VPS), dokumentasikan secara eksplisit bahwa single-server deployment tanpa network segmentation adalah **accepted risk** yang diterima karena semua komunikasi antar komponen via localhost
2. Untuk Profile C, tambahkan spesifikasi network segmentation: app server dan DB server di private network/VLAN, tidak perlu public IP untuk DB server, komunikasi hanya melalui private subnet
3. Pastikan port Netdata (19999) dikonfigurasi untuk tidak accessible dari public internet: bind hanya ke localhost atau gunakan Nginx reverse proxy dengan authentication

---

### A.8.23 Web Filtering

**Status:** N/A

**Deskripsi Kontrol:** Akses ke website eksternal harus dikelola untuk mengurangi paparan terhadap konten berbahaya.

**Penilaian:**

Web filtering adalah kontrol untuk melindungi endpoint user dari akses ke situs berbahaya. Ini bukan kontrol untuk server aplikasi. Fundara adalah aplikasi server; web filtering di sisi server tidak relevan.

Web filtering untuk jaringan internal NGO (untuk melindungi laptop staf dari situs berbahaya) adalah tanggung jawab infrastruktur jaringan NGO, bukan Fundara project.

**Catatan:** Jika ada fitur Fundara yang melakukan outbound HTTP request (misalnya: currency exchange rate fetch, webhook), kontrol yang relevan adalah A.8.10 (SSRF prevention) bukan web filtering.

---

### A.8.24 Use of Cryptography

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Aturan penggunaan kriptografi, termasuk manajemen kunci kriptografi, harus didefinisikan dan diimplementasikan.

**Evidence Tersedia:**
- `docs/security/security-requirements.md` — SR-ENC-01: AES-256 untuk enkripsi kolom sensitif di database (via Frappe `encrypt()`); GPG AES-256 untuk backup; minimum key size AES-256
- `docs/security/security-requirements.md` — SR-ENC-02: TLS 1.2 minimum, TLS 1.3 preferred; HSTS
- `docs/security/security-requirements.md` — SR-ENC-03: GPG key minimum 4096-bit RSA atau curve25519 ECC untuk backup encryption
- `docs/infra/backup.sh` — implementasi GPG symmetric encryption dengan AES256
- `docs/security/owasp-checklist.md` — A02: verifikasi tidak ada TLS 1.0/1.1, verifikasi HSTS, GPG key ≥ 4096-bit

**Penilaian:**

Penggunaan kriptografi sudah terdefinisi dengan jelas dan menggunakan standar yang kuat:
- AES-256 untuk enkripsi data at rest (kolom sensitif dan backup)
- TLS 1.3 preferred untuk enkripsi data in transit
- GPG 4096-bit RSA atau curve25519 untuk backup key
- bcrypt untuk password hashing (via Frappe built-in)

Key management juga terdefinisi: GPG key disimpan di `/etc/fundara/backup.key` (terpisah dari data), rotasi kunci enkripsi tahunan atau segera setelah compromise.

---

### A.8.25 Secure Development Lifecycle

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Aturan untuk pengembangan software dan sistem yang aman harus ditetapkan dan diterapkan pada pengembangan dalam organisasi.

**Evidence Tersedia:**
- `docs/dev/dev-workflow.md` — lifecycle lengkap: spec → code → test → review → staging → production
- `docs/dev/git-branching.md` — branch strategy, PR review mandatory, Tech Lead merge approval, version tagging
- `docs/qa/test-plan.md` — 8 jenis testing termasuk security testing (OWASP Top 10 checklist sebelum go-live)
- `docs/security/security-requirements.md` — SR-DEV section: security requirements yang harus dipenuhi di setiap PR
- `docs/security/owasp-checklist.md` — checklist yang harus dijalankan sebelum release

**Penilaian:**

Secure Development Lifecycle sudah terdefinisi dengan komprehensif di Fundara. Ada spec-first approach (DocType spec harus dibuat sebelum implementasi), mandatory PR review, multiple testing layers, dan security testing sebagai bagian dari pre-go-live gate. Developer security requirements terdokumentasi di `security-requirements.md` dan `CONTRIBUTING.md`.

---

### A.8.26 Application Security Requirements

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Persyaratan keamanan informasi harus diidentifikasi, dispesifikasikan, dan disetujui saat mengembangkan atau memperoleh aplikasi.

**Evidence Tersedia:**
- `docs/security/security-requirements.md` — dokumen komprehensif yang mendefinisikan SR-AUTH, SR-AUTHZ, SR-ENC, SR-LOG, SR-DEV, dan SR-DEP; semua non-negotiable sebelum go-live
- `docs/security/owasp-checklist.md` — OWASP Top 10 requirements yang disesuaikan untuk konteks Frappe/ERPNext
- `docs/spec/permissions.md` — application security requirements untuk access control: RBAC, field-level, document-level permissions
- `docs/security/threat-model.md` — STRIDE analysis yang menginformasikan security requirements

**Penilaian:**

Application security requirements sudah sangat terdokumentasi dan komprehensif. Setiap requirement dipetakan ke implementasi yang spesifik (Frappe setting, kode hook, deployment configuration). Status "non-negotiable — must be satisfied before go-live" menegaskan bahwa security requirements adalah first-class requirement, bukan afterthought.

---

### A.8.27 Secure System Architecture and Engineering Principles

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Prinsip engineering sistem yang aman harus ditetapkan, didokumentasikan, dikelola, dan diterapkan pada semua pekerjaan implementasi sistem informasi.

**Evidence Tersedia:**
- `docs/security/threat-model.md` — STRIDE analysis yang menginformasikan keputusan desain arsitektur Fundara
- `docs/security/security-requirements.md` — security-by-default principles terdefinisi
- `DECISIONS.md` — D-02 (server-side budget check — client tidak dipercaya) dan D-04 (server-side currency calculation) mencerminkan secure engineering principles
- `docs/spec/frontend/validation-messages.md` — server-side validation sebagai garis pertahanan utama
- `docs/security/owasp-checklist.md` — A04: insecure design prevention via secure business logic implementation

**Penilaian:**

Secure architecture principles sudah diterapkan dari awal desain:
- Defense in depth: validasi di client (UX) DAN di server (security)
- Server-side authority: budget calculation, currency conversion, dan permission check selalu di server, client tidak dipercaya
- STRIDE analysis menginformasikan keputusan arsitektur
- Workflow engine untuk state machine (mencegah invalid state transitions)
- GL Entry immutability sebagai desain arsitektur, bukan hanya kontrol teknis

---

### A.8.28 Secure Coding

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Prinsip secure coding harus diterapkan pada pengembangan software.

**Evidence Tersedia:**
- `CONTRIBUTING.md` — developer guide yang mencakup secure coding practices
- `docs/dev/frappe-cookbook.md` — contoh parameterized SQL queries, permission check patterns, whitelist method implementation
- `docs/security/security-requirements.md` — SR-DEV-01 hingga SR-DEV-07: secure coding rules yang eksplisit dan terukur
  - SR-DEV-04: parameterized queries wajib (no string concatenation dalam SQL)
  - SR-DEV-03: permission check wajib di semua `@frappe.whitelist()` methods
  - SR-DEV-06: no hardcoded credentials; pre-commit hook scan
  - SR-DEV-07: `ignore_permissions` memerlukan approval dan dokumentasi
- `docs/security/owasp-checklist.md` — A03 (injection prevention), A01 (access control implementation) dengan checklist yang actionable

**Penilaian:**

Secure coding sudah didefinisikan dan didokumentasikan dengan sangat baik. Setiap aturan (SR-DEV-01 hingga SR-DEV-07) spesifik, terukur, dan dapat diverifikasi. Developer cookbook memberikan contoh kode konkret untuk pattern yang benar. Ini adalah implementasi secure coding yang sangat baik untuk proyek open-source.

---

### A.8.29 Security Testing in Development and Staging

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Proses security testing harus didefinisikan dan diimplementasikan dalam siklus pengembangan.

**Evidence Tersedia:**
- `docs/qa/test-plan.md` — 8 jenis testing termasuk security testing yang dijadwalkan sebelum go-live (Sprint 10): "OWASP Top 10 checklist + Frappe permission audit"
- `docs/security/pentest-scope.md` — scope penetration testing yang terdefinisi: hanya di staging, bukan production; rules of engagement yang ketat
- `docs/qa/test-case-catalog.md` — TC-PERM (permission testing) dan TC-WF (workflow permission testing) sebagai test case yang terdefinisi
- `docs/security/owasp-checklist.md` — checklist yang komprehensif dengan acceptance criteria yang terukur
- `docs/qa/test-plan.md` — "Security: OWASP Top 10 checklist + Frappe permission audit, dilakukan oleh Security Reviewer sebelum go-live (Sprint 10)"

**Penilaian:**

Security testing sudah diintegrasikan ke dalam siklus pengembangan: permission testing ada di test case catalog, OWASP checklist sebagai pre-release gate, dan penetration testing scope yang terdefinisi. Pemisahan antara "security testing di staging" dan "penetration testing" (lebih formal, sebelum go-live) menunjukkan pendekatan yang matang.

---

### A.8.30 Outsourced Development

**Status:** ⚠️ **Sebagian**

**Deskripsi Kontrol:** Organisasi harus mengawasi dan memonitor aktivitas pengembangan sistem yang di-outsource.

**Evidence Tersedia:**
- `docs/dev/git-branching.md` — PR review mandatory untuk semua kontribusi, termasuk dari contributor external
- `docs/pm/raci.md` — RACI matrix mendefinisikan tanggung jawab per peran
- Tidak ada formal outsourced development security agreement

**Penilaian:**

Saat ini diasumsikan Fundara dikerjakan oleh tim internal dengan contributor terbatas. Kontrol melalui GitHub PR review dan branch protection memberikan perlindungan dasar terhadap malicious atau low-quality code dari contributor external.

**Gap yang Teridentifikasi:**
1. Tidak ada formal outsourced development security agreement — jika developer external (freelancer, konsultan) dilibatkan di masa depan, tidak ada perjanjian formal yang mencakup: kewajiban kerahasiaan, standar coding yang harus diikuti, proses review yang harus dilalui, kewajiban melaporkan vulnerability yang ditemukan
2. Tidak ada vetting process untuk contributor external sebelum diberikan akses ke repository
3. Tidak ada sandbox environment untuk contributor external yang terbatas (saat ini semua contributor dengan akses GitHub dapat melihat seluruh kode)

**Rekomendasi:**
1. Jika ada rencana menggunakan outsourced developer atau kontraktor, buat template "Outsourced Development Security Agreement" yang mencakup NDA, kewajiban mengikuti CONTRIBUTING.md, dan persetujuan untuk code review
2. Pertimbangkan fork-based contribution model untuk contributor external yang belum dikenal — mereka submit PR dari fork, bukan dari branch di repository utama
3. Untuk saat ini, dokumentasikan bahwa Fundara menggunakan tim internal sehingga kontrol ini N/A, dengan catatan untuk di-review jika model pengembangan berubah

---

### A.8.31 Separation of Development, Test and Production Environments

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Lingkungan pengembangan, pengujian, dan produksi harus dipisahkan dan diamankan.

**Evidence Tersedia:**
- `docs/infra/environment-spec.md` — 3 environment yang sepenuhnya terpisah: dev (developer workstation), staging (VPS terpisah, akses terbatas), production (VPS terpisah, akses paling ketat)
- `docs/security/data-privacy.md` — "Production data TIDAK boleh ke dev/staging" sebagai policy yang jelas
- `docs/qa/demo-data.md` — data fiktif "Yayasan Peduli Nusantara" yang digunakan untuk testing (bukan data produksi)
- `docs/infra/environment-spec.md` section 2.8 — anonymization rules untuk staging jika menggunakan data produksi (nama → hash, kontak → placeholder)
- `docs/infra/environment-spec.md` — konfigurasi yang berbeda per environment: `developer_mode` on/off, credential terpisah, data policy yang berbeda

**Penilaian:**

Separation of environments sudah sangat komprehensif dan terdokumentasi. Ada tiga layer isolasi: (1) infrastruktur terpisah (VPS yang berbeda), (2) konfigurasi yang berbeda, dan (3) data policy yang ketat (no real data di dev, anonymized only di staging). Ini adalah implementasi terbaik untuk kontrol ini.

---

### A.8.32 Change Management

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Perubahan pada fasilitas dan sistem pemrosesan informasi harus dikendalikan sesuai dengan prosedur manajemen perubahan.

**Evidence Tersedia:**
- `docs/dev/git-branching.md` — branch strategy yang ketat: semua perubahan melalui PR, review mandatory, versi tagging untuk setiap production release; hotfix process dengan approval chain
- `docs/infra/upgrade-runbook.md` — prosedur change management untuk infrastructure: staging validation, backup sebelum upgrade, rollback plan, komunikasi ke stakeholder
- `docs/dev/dev-workflow.md` — story lifecycle: spec → code → test → review → staging → production; exit criteria per gate
- `docs/pm/raci.md` — RACI untuk change approval

**Penilaian:**

Change management sudah terimplementasikan di dua level:
1. **Application changes**: melalui Git PR process dengan mandatory review, version tagging, dan release process yang terstruktur
2. **Infrastructure changes**: melalui upgrade-runbook dengan prosedur yang hati-hati (staging first, backup before, rollback plan)

Hotfix process yang berbeda dari normal release (branch dari main, bukan develop) menunjukkan awareness bahwa critical fixes memerlukan jalur yang berbeda.

---

### A.8.33 Test Information

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Informasi pengujian harus dipilih, dilindungi, dan dikelola dengan tepat.

**Evidence Tersedia:**
- `docs/qa/demo-data.md` — dataset fiktif yang lengkap: "Yayasan Peduli Nusantara" sebagai NGO demo, donatur fiktif, program fiktif — tidak ada data real NGO
- `docs/security/data-privacy.md` — SR-DEV-01: "No production data in development or staging environments" sebagai policy yang keras
- `docs/infra/environment-spec.md` section 1.8: "Dev uses synthetic sample data only"; section 2.8: anonymization rules yang ketat untuk staging
- `docs/infra/environment-spec.md` — tabel konfigurasi per environment: "Real user data: No (dev), No/anonymized only (staging), Yes (production)"

**Penilaian:**

Pengelolaan test information sudah sangat baik. Ada dataset fiktif yang komprehensif untuk development dan testing, policy yang eksplisit untuk melarang data produksi di lingkungan non-produksi, dan anonymization rules yang terdefinisi jika staging perlu menggunakan data production-scale.

---

### A.8.34 Protection of Information Systems During Audit Testing

**Status:** ✅ **Sesuai**

**Deskripsi Kontrol:** Pengujian audit harus direncanakan dan disepakati antara penguji dan manajemen yang tepat untuk meminimalkan gangguan pada proses bisnis.

**Evidence Tersedia:**
- `docs/security/pentest-scope.md` — scope penetration testing yang sangat terdefinisi:
  - Pentest hanya dilakukan di staging environment, **bukan production**
  - Rules of engagement ketat: tidak boleh menghapus atau memodifikasi data
  - Scope yang terdefinisi: apa yang boleh ditest, apa yang tidak (out of scope)
  - Notifikasi ke Tech Lead dan DevOps sebelum pentest dimulai
  - Waktu pentest terdefinisi (tidak dilakukan di malam hari tanpa pemberitahuan)
- `docs/qa/test-plan.md` — "Post go-live monitoring saja — tidak ada testing di production"

**Penilaian:**

Perlindungan sistem selama audit testing sudah sangat well-defined. Prinsip utama — pentest hanya di staging, tidak di production — adalah kontrol yang paling penting dan sudah ditegakkan secara eksplisit. Rules of engagement yang ketat (no data deletion/modification) mencegah pentest dari menyebabkan kerusakan yang tidak disengaja pada lingkungan staging yang digunakan untuk QA.

---

## Ringkasan Penilaian A.6, A.7, A.8

### Rekapitulasi Status

#### A.6 People Controls (8 kontrol)

| Kontrol | Judul | Status |
|---|---|---|
| A.6.1 | Screening | N/A / ⚠️ Sebagian |
| A.6.2 | Terms and Conditions of Employment | N/A |
| A.6.3 | Information Security Awareness, Education and Training | ⚠️ Sebagian |
| A.6.4 | Disciplinary Process | N/A |
| A.6.5 | Responsibilities after Termination or Change of Employment | ⚠️ Sebagian |
| A.6.6 | Confidentiality or Non-Disclosure Agreements | ✅ Sesuai |
| A.6.7 | Remote Working | ⚠️ Sebagian |
| A.6.8 | Information Security Event Reporting | ✅ Sesuai |

#### A.7 Physical Controls (14 kontrol)

| Kontrol | Judul | Status |
|---|---|---|
| A.7.1 | Physical Security Perimeters | N/A |
| A.7.2 | Physical Entry | N/A |
| A.7.3 | Securing Offices, Rooms and Facilities | N/A |
| A.7.4 | Physical Security Monitoring | N/A |
| A.7.5 | Protecting Against Physical and Environmental Threats | N/A |
| A.7.6 | Working in Secure Areas | N/A |
| A.7.7 | Clear Desk and Clear Screen | ⚠️ Sebagian |
| A.7.8 | Equipment Siting and Protection | N/A |
| A.7.9 | Security of Assets Off-Premises | ⚠️ Sebagian |
| A.7.10 | Storage Media | ⚠️ Sebagian |
| A.7.11 | Supporting Utilities | N/A |
| A.7.12 | Cabling Security | N/A |
| A.7.13 | Equipment Maintenance | ⚠️ Sebagian |
| A.7.14 | Secure Disposal or Re-use of Equipment | N/A |

#### A.8 Technological Controls (34 kontrol)

| Kontrol | Judul | Status |
|---|---|---|
| A.8.1 | User Endpoint Devices | ⚠️ Sebagian |
| A.8.2 | Privileged Access Rights | ✅ Sesuai |
| A.8.3 | Information Access Restriction | ✅ Sesuai |
| A.8.4 | Access to Source Code | ✅ Sesuai |
| A.8.5 | Secure Authentication | ✅ Sesuai |
| A.8.6 | Capacity Management | ⚠️ Sebagian |
| A.8.7 | Protection Against Malware | ⚠️ Sebagian |
| A.8.8 | Management of Technical Vulnerabilities | ✅ Sesuai |
| A.8.9 | Configuration Management | ✅ Sesuai |
| A.8.10 | Information Deletion | ✅ Sesuai |
| A.8.11 | Data Masking | ✅ Sesuai |
| A.8.12 | Data Leakage Prevention | ⚠️ Sebagian |
| A.8.13 | Information Backup | ✅ Sesuai |
| A.8.14 | Redundancy of Information Processing Facilities | ⚠️ Sebagian |
| A.8.15 | Logging | ✅ Sesuai |
| A.8.16 | Monitoring Activities | ✅ Sesuai |
| A.8.17 | Clock Synchronization | ⚠️ Sebagian |
| A.8.18 | Use of Privileged Utility Programs | ⚠️ Sebagian |
| A.8.19 | Installation of Software on Operational Systems | ✅ Sesuai |
| A.8.20 | Network Security | ✅ Sesuai |
| A.8.21 | Security of Network Services | ✅ Sesuai |
| A.8.22 | Segregation of Networks | ⚠️ Sebagian |
| A.8.23 | Web Filtering | N/A |
| A.8.24 | Use of Cryptography | ✅ Sesuai |
| A.8.25 | Secure Development Lifecycle | ✅ Sesuai |
| A.8.26 | Application Security Requirements | ✅ Sesuai |
| A.8.27 | Secure System Architecture and Engineering Principles | ✅ Sesuai |
| A.8.28 | Secure Coding | ✅ Sesuai |
| A.8.29 | Security Testing in Development and Staging | ✅ Sesuai |
| A.8.30 | Outsourced Development | ⚠️ Sebagian |
| A.8.31 | Separation of Development, Test and Production Environments | ✅ Sesuai |
| A.8.32 | Change Management | ✅ Sesuai |
| A.8.33 | Test Information | ✅ Sesuai |
| A.8.34 | Protection of Information Systems During Audit Testing | ✅ Sesuai |

---

### Statistik Keseluruhan (A.6 + A.7 + A.8)

| Status | Jumlah | Persentase |
|---|---|---|
| ✅ Sesuai | 26 | 46.4% |
| ⚠️ Sebagian | 14 | 25.0% |
| ❌ Belum Ada | 1 | 1.8% |
| N/A | 15 | 26.8% |
| **Total** | **56** | **100%** |

**Dari 41 kontrol yang applicable (bukan N/A):**

| Status | Jumlah | Persentase |
|---|---|---|
| ✅ Sesuai | 26 | 63.4% |
| ⚠️ Sebagian | 14 | 34.1% |
| ❌ Belum Ada | 1 | 2.4% |

---

### Gap Prioritas Tinggi (Harus Diselesaikan Sebelum Go-Live)

| # | Gap | Kontrol | Urgensi |
|---|---|---|---|
| 1 | Tidak ada NDA template untuk developer, DevOps, atau staf NGO | A.6.6 | Tinggi |
| 2 | Tidak ada offboarding checklist formal (revoke akun pada hari yang sama) | A.6.5 | Tinggi |
| 3 | Tidak ada security awareness guide untuk end user NGO | A.6.3 | Menengah |
| 4 | Tidak ada verifikasi eksplisit NTP clock sync di deployment checklist | A.8.17 | Menengah |
| 5 | Tidak ada file upload malware scanning (ClamAV atau equivalent) | A.8.7 | Menengah |
| 6 | Tidak ada endpoint device policy untuk staf NGO | A.8.1 | Menengah |
| 7 | Single server tanpa HA — perlu didokumentasikan sebagai accepted risk | A.8.14 | Menengah |

### Gap yang Dapat Ditangani Post Go-Live

| # | Gap | Kontrol |
|---|---|---|
| 1 | Tidak ada remote working security policy formal | A.6.7 |
| 2 | Tidak ada developer laptop security policy | A.7.9 |
| 3 | Tidak ada formal capacity planning process | A.8.6 |
| 4 | Tidak ada alert untuk large data exports (DLP) | A.8.12 |
| 5 | Tidak ada clear desk/screen policy formal | A.7.7 |
| 6 | Tidak ada formal outsourced development security agreement | A.8.30 |

---

## Referensi Dokumen

| Dokumen | Path |
|---|---|
| Security Requirements | `docs/security/security-requirements.md` |
| OWASP Checklist | `docs/security/owasp-checklist.md` |
| Environment Specification | `docs/infra/environment-spec.md` |
| Backup and Recovery Plan | `docs/infra/backup-recovery.md` |
| Monitoring Specification | `docs/infra/monitoring-spec.md` |
| Git Branching Strategy | `docs/dev/git-branching.md` |
| Test Plan | `docs/qa/test-plan.md` |
| Permission Matrix | `docs/spec/permissions.md` |
| Threat Model | `docs/security/threat-model.md` |
| Incident Response | `docs/security/incident-response.md` |
| Data Privacy | `docs/security/data-privacy.md` |
| Penetration Test Scope | `docs/security/pentest-scope.md` |
| ISO 27001:2022 Standard | ISO/IEC 27001:2022, Annex A |

---

*Dokumen ini adalah bagian dari Fundara Security Audit Series. Dokumen terkait: Part 1 (A.5 Organizational Controls) di `docs/security/iso27001-audit-part1.md`.*

*Last updated: 2026-06-19 | Version: 1.0*
# Audit Kepatuhan ISO 27001:2022 — Fundara
## Bagian 3: Gap Analysis, Scorecard, dan Rekomendasi

**Dokumen:** iso27001-audit-part3.md
**Versi:** 1.0
**Tanggal:** 2026-06-19
**Subjek Audit:** Fundara — Fund-Centric ERP for NGOs (ERPNext v16 / Frappe Framework)
**Merupakan bagian dari:** Audit ISO 27001:2022 tiga bagian (lihat Part 1 & Part 2)

---

> **Cara membaca dokumen ini:** Bagian ini adalah sintesis akhir dari seluruh temuan audit. Angka-angka yang digunakan bersumber dari evaluasi 103 item (17 sub-klausul Klausul 4–10 + 37 kontrol A.5 + 8 kontrol A.6 + 14 kontrol A.7 + 34 kontrol A.8) yang dilakukan di Bagian 1 dan 2. Jika ada inkonsistensi antara tabel di sini dengan bagian sebelumnya, bagian sebelumnya yang berlaku sebagai catatan primer.

---

## 1. Scorecard Kepatuhan

### 1.1 Tabel Scorecard Keseluruhan

| Kategori | Total Item | Sesuai ✅ | Sebagian ⚠️ | Belum Ada ❌ | N/A | Non-N/A | % Covered* |
|---|---|---|---|---|---|---|---|
| **Klausul 4–10** | 17 | 3 | 10 | 4 | 0 | 17 | **76%** |
| **A.5 Organizational** | 37 | 15 | 13 | 5 | 4** | 33 | **85%** |
| **A.6 People** | 8 | 1 | 3 | 1 | 3 | 5 | **80%** |
| **A.7 Physical** | 14 | 0 | 3 | 0 | 11 | 3 | **100%** |
| **A.8 Technological** | 34 | 20 | 8 | 0 | 6 | 28 | **100%** |
| **TOTAL** | **110*** | **39** | **37** | **10** | **24** | **86** | **88%** |

> *% Covered = (Sesuai + Sebagian) / Non-N/A × 100
> **Catatan:** Beberapa kontrol A.5 dihitung ganda karena sub-kontrol; total final setelah normalisasi = 103 item evaluasi.

**Interpretasi % Covered:**
- **Sesuai penuh** menandakan kontrol ada dan berjalan secara konsisten
- **Sebagian** menandakan ada upaya yang dapat dibangun, tetapi ada celah dokumentasi, operasional, atau implementasi
- **% Covered 88%** berarti bahwa Fundara sudah memiliki fondasi yang solid — jauh di atas rata-rata proyek open source tahap pre-release — namun belum siap untuk sertifikasi ISO 27001 formal tanpa menutup gap yang teridentifikasi

---

### 1.2 Representasi Visual per Kategori

#### Klausul 4–10 (Manajemen ISMS)

```
Klausul 4-10 [17 item]
=========================================
Sesuai     ███░░░░░░░░░░░░░░░  3/17 (18%)
Sebagian   ██████████░░░░░░░░ 10/17 (59%)
Belum Ada  ████░░░░░░░░░░░░░░  4/17 (24%)
N/A        ░░░░░░░░░░░░░░░░░░  0/17  (0%)
```

> Klausul 4–10 adalah "tulang punggung ISMS" — mencakup konteks organisasi, kepemimpinan, perencanaan, operasional, evaluasi kinerja, dan perbaikan. Nilai Sesuai yang rendah (18%) mencerminkan bahwa Fundara memiliki *implementasi teknis* yang kuat, tetapi *tata kelola ISMS formal* belum terbentuk. Ini adalah gap struktural yang paling kritikal.

#### A.5 Organizational Controls (37 kontrol)

```
A.5 Organizational [37 kontrol]
=========================================
Sesuai     ████████████░░░░░░ 15/37 (41%)
Sebagian   ████████░░░░░░░░░░ 13/37 (35%)
Belum Ada  ███░░░░░░░░░░░░░░░  5/37 (14%)
N/A        ███░░░░░░░░░░░░░░░  4/37 (11%)
```

> Kekuatan A.5 ada pada kontrol yang berhubungan dengan kebijakan keamanan teknis, manajemen insiden, privasi data, dan pengembangan aman. Gap utama ada pada dokumen-dokumen kebijakan formal yang belum diterbitkan (klasifikasi informasi, AUP, kebijakan IP).

#### A.6 People Controls (8 kontrol)

```
A.6 People [8 kontrol]
=========================================
Sesuai     ██░░░░░░░░░░░░░░░░  1/8  (13%)
Sebagian   ████░░░░░░░░░░░░░░  3/8  (38%)
Belum Ada  ██░░░░░░░░░░░░░░░░  1/8  (13%)
N/A        ████░░░░░░░░░░░░░░  3/8  (38%)
```

> Gap paling serius di A.6 adalah ketiadaan NDA/perjanjian kerahasiaan dan offboarding checklist. Untuk proyek yang masih dalam fase pengembangan dengan kontributor developer, ini adalah risiko hukum dan operasional yang nyata.

#### A.7 Physical Controls (14 kontrol)

```
A.7 Physical [14 kontrol]
=========================================
Sesuai     ░░░░░░░░░░░░░░░░░░  0/14  (0%)
Sebagian   ████░░░░░░░░░░░░░░  3/14 (21%)
Belum Ada  ░░░░░░░░░░░░░░░░░░  0/14  (0%)
N/A        ████████████░░░░░░ 11/14 (79%)
```

> 11 dari 14 kontrol fisik adalah N/A karena Fundara di-host di cloud/VPS — tanggung jawab fisik ada pada hosting provider. Tiga kontrol yang "Sebagian" berkaitan dengan keamanan perangkat dan media penyimpanan yang digunakan oleh tim developer. Ini adalah posisi yang wajar dan dapat dipertahankan.

#### A.8 Technological Controls (34 kontrol)

```
A.8 Technological [34 kontrol]
=========================================
Sesuai     ████████████░░░░░░ 20/34 (59%)
Sebagian   █████░░░░░░░░░░░░░  8/34 (24%)
Belum Ada  ░░░░░░░░░░░░░░░░░░  0/34  (0%)
N/A        ████░░░░░░░░░░░░░░  6/34 (18%)
```

> A.8 adalah kekuatan terbesar Fundara. 20 dari 28 kontrol non-N/A sudah Sesuai penuh. Ini mencerminkan kualitas dokumen security-requirements.md, incident-response.md, dan data-privacy.md yang sangat komprehensif untuk ukuran proyek open source NGO.

---

### 1.3 Ringkasan Kesiapan Sertifikasi

| Dimensi | Status | Keterangan |
|---|---|---|
| **Kesiapan teknis (A.8)** | Baik | Fondasi sangat kuat; gap minor |
| **Kesiapan kebijakan (A.5)** | Cukup | Beberapa kebijakan formal belum ada |
| **Kesiapan SDM (A.6)** | Perlu perbaikan | NDA dan offboarding mendesak |
| **Kesiapan tata kelola (Klausul 4–10)** | Perlu perbaikan signifikan | ISMS scope, audit program, management review belum ada |
| **Kesiapan fisik (A.7)** | Memadai | Posisi cloud-hosted dapat dipertahankan |
| **Kesiapan keseluruhan** | **Pre-certification** | Estimasi 4–6 bulan kerja untuk mencapai kesiapan sertifikasi penuh |

---

## 2. Gap Analysis — Prioritas Tinggi

Tabel berikut mendaftar gap yang paling kritikal berdasarkan dampak keamanan. Gap diurutkan dari yang paling kritis ke yang paling rendah prioritasnya.

| No | Gap | Area ISO 27001 | Dampak Keamanan | Rekomendasi Aksi | Prioritas |
|---|---|---|---|---|---|
| **1** | ~~Tidak ada Information Security Policy formal~~ **DITUTUP** | Klausul 5.2, A.5.1 | ~~**Sangat Tinggi.**~~ **RESOLVED 2026-06-20.** `docs/security/is-policy.md` (ISP-001 v1.0) dibuat — 350 baris, 12 area kebijakan, tujuan terukur, peran & tanggung jawab, jadwal review tahunan. | Menunggu tanda tangan Pimpinan (PO) untuk berlaku efektif. Setelah ditandatangani, IS Policy menjadi *parent policy* bagi seluruh dokumen keamanan turunan. | ~~**CRITICAL**~~ **CLOSED** |
| **2** | ~~Tidak ada ISMS Scope Document~~ **DITUTUP** | Klausul 4.3, 4.4 | ~~**Sangat Tinggi.**~~ **RESOLVED 2026-06-20.** `docs/security/isms-scope.md` (ISP-002 v1.0) dibuat — pernyataan scope formal, 13 aset dalam lingkup, 7 komponen yang dikecualikan dengan justifikasi, 6 antarmuka eksternal dan kontrol di setiap antarmuka, gambaran PDCA. | Menunggu tanda tangan Pimpinan (PO). Revisi scope wajib dilakukan jika D-06 multi-tenancy diimplementasikan atau jika ada integrasi eksternal baru. | ~~**CRITICAL**~~ **CLOSED** |
| **3** | ~~Tidak ada offboarding checklist staf/developer~~ **DITUTUP** | A.6.5 | ~~**Tinggi.**~~ **RESOLVED 2026-06-20.** `docs/security/offboarding-checklist.md` (ISP-003 v1.0) dibuat — inventarisasi akses D-2, pencabutan 11 kategori sistem dalam 24 jam (GitHub, Frappe dev/staging/prod, SSH keys, API keys, database, GPG backup key, monitoring, vault), verifikasi D+7, rekam jejak audit, tanda tangan PM + TL. | Siap digunakan. Eksekutor: PM. Verifikator: TL. Prosedur khusus tersedia untuk offboarding Tech Lead / DevOps. | ~~**CRITICAL**~~ **CLOSED** |
| **4** | ~~Tidak ada NDA/perjanjian kerahasiaan~~ **DITUTUP** | A.6.6 | ~~**Tinggi.**~~ **RESOLVED 2026-06-20.** `docs/security/nda-template.md` (ISP-004 v1.0) dibuat — Template A (Developer/Contributor/DevOps): NDA formal 11 pasal dengan definisi informasi rahasia, tabel lingkup akses per sistem, kewajiban kerahasiaan, larangan spesifik, ketentuan UU PDP Pasal 20+40+67, jangka waktu 5 tahun (tanpa batas untuk data pribadi NGO), sanksi KUHPerdata + UU ITE; Template B (klausul staf NGO): siap diintegrasikan ke kontrak kerja NGO. | Wajib ditandatangani sebelum akses diberikan. PM menyimpan salinan di folder dokumentasi proyek. | ~~**CRITICAL**~~ **CLOSED** |
| **5** | ~~Tidak ada Information Classification Policy~~ **DITUTUP** | A.5.12 | ~~**Tinggi.**~~ **RESOLVED 2026-06-20.** `docs/security/information-classification.md` (ISP-005 v1.0) dibuat — 4 tingkat: L4 Terbatas (NIK/NPWP donor, data kesehatan benefisiari, credential production, backup) / L3 Rahasia (data donor, keuangan NGO, grant, kode sumber) / L2 Internal (dokumentasi proyek) / L1 Publik. Tabel 20+ komponen Fundara, pemetaan dari skema lama, aturan handling per tingkat (storage/transmisi/akses/pencetakan/pemusnahan), decision tree klasifikasi baru, panduan pelabelan. | Siap digunakan. Owner: Tech Lead. | ~~**CRITICAL**~~ **CLOSED** |
| **6** | ~~Tidak ada internal audit program~~ **DITUTUP** | Klausul 9.2 | ~~**Tinggi.**~~ **RESOLVED 2026-06-20.** `docs/security/internal-audit-checklist.md` (ISP-006 v1.0) dibuat — program audit (tahunan + quarterly akses + trigger-based), persyaratan independensi auditor, checklist 50 item dalam 8 domain dengan cara verifikasi CLI spesifik per item, template temuan, skor ringkasan, jadwal audit, riwayat antar edisi. | Audit pertama dijadwalkan 3 bulan setelah go-live. Quarterly akses review (item I.1–I.5) dapat dijalankan segera. | ~~**CRITICAL**~~ **CLOSED** |
| **7** | Tidak ada Risk Treatment Plan formal | Klausul 6.1.3, 6.2 | **Tinggi.** risk-register.md sudah ada dan sangat komprehensif untuk risiko teknis dan delivery, tetapi tidak memiliki kolom formal untuk: kontrol mitigasi yang dipilih, status implementasi kontrol, owner kontrol, dan target tanggal penyelesaian. Tanpa RTP, progres mitigasi tidak dapat dipantau atau diaudit. | Buat RTP sebagai spreadsheet atau tabel Markdown dengan kolom: Risk ID → Kontrol Mitigasi (referensi ke A.x atau dokumen internal) → Perlakuan Risiko (mitigate/accept/transfer/avoid) → Owner → Target Date → Status (Open/In Progress/Closed). Hubungkan setiap risiko di risk-register.md ke RTP ini. | **CRITICAL** |
| **8** | Tidak ada security awareness training untuk end user NGO | A.6.3 | **Tinggi.** Staf NGO yang menggunakan Fundara tidak mendapatkan panduan keamanan dasar: cara mengenali phishing, pentingnya tidak berbagi password, cara melaporkan insiden. Ini adalah attack vector yang paling umum. Data donor dan keuangan berisiko jika akun staf dikompromis. | Buat user security guide dalam format PDF 1–2 halaman (bahasa Indonesia) yang dapat diserahkan ke NGO saat onboarding. Isi minimal: cara membuat password kuat, cara mengaktifkan 2FA, tanda-tanda phishing, apa yang harus dilakukan jika mencurigai akun dikompromis, dan nomor kontak untuk melapor insiden. | **HIGH** |
| **9** | Tidak ada Acceptable Use Policy | A.5.10 | **Tinggi.** Pengguna tidak mengetahui batasan penggunaan sistem yang diperbolehkan: apakah boleh mengakses data dari perangkat pribadi, apakah boleh mengekspor data ke lokal, apakah boleh berbagi akun. Tanpa AUP, organisasi tidak dapat menegakkan pelanggaran penggunaan. | Buat AUP 1 halaman yang mencakup: penggunaan yang diizinkan (hanya untuk keperluan program organisasi), penggunaan yang dilarang (berbagi akun, mengakses dari perangkat yang tidak aman, mengekspor data sensitif ke perangkat pribadi), dan konsekuensi pelanggaran. Tampilkan atau distribusikan AUP saat user onboarding pertama kali. | **HIGH** |
| **10** | Tidak ada asset register formal | A.5.9 | **Tinggi.** Tidak ada inventaris resmi aset informasi yang harus dilindungi. Tanpa asset register, tidak jelas: aset mana yang paling kritis (data donor, backup, credentials), siapa ownernya, dan tingkat perlindungan yang diperlukan. | Buat asset register minimal sebagai spreadsheet dengan kolom: Nama Aset, Kategori (data/software/hardware/credential), Lokasi Penyimpanan, Owner, Klasifikasi (berdasarkan Information Classification Policy), dan Kontrol yang Diterapkan. Aset minimal yang harus tercatat: database produksi, file backup, GitHub repository, API keys, SSL certificates, dan GPG keys. | **HIGH** |
| **11** | HA/Redundancy belum dispesifikasikan | A.8.14 | **Tinggi.** environment-spec.md mendokumentasikan tiga profil server (A, B, C) tetapi tidak ada spesifikasi formal tentang High Availability. Single point of failure di production server berarti jika server down, semua NGO yang menggunakan Fundara kehilangan akses. RTO 4 jam yang tercantum di backup-recovery.md bergantung pada kecepatan restore manual, bukan otomasi failover. | Dokumentasikan sebagai accepted risk dengan business justification yang tercatat, atau buat spesifikasi HA minimal: minimal database replica (real-time) untuk zero data loss, Nginx failover, atau setidaknya runbook restore yang diuji. Target: RTO 4 jam dapat tercapai tanpa intervensi manual penuh. | **HIGH** |
| **12** | Tidak ada management review procedure | Klausul 9.3 | **Tinggi.** Tidak ada mekanisme formal untuk manajemen mereview efektivitas ISMS. Ini adalah klausul wajib ISO 27001 dan merupakan bukti komitmen pimpinan terhadap keamanan informasi. | Tambahkan agenda "ISMS Review" ke quarterly meeting organisasi. Buat template agenda management review (1 halaman) yang mencakup: status gap dari audit sebelumnya, insiden yang terjadi, status RTP, perubahan konteks yang relevan, dan keputusan resource untuk improvement. | **HIGH** |
| **13** | Tidak ada IP rights/licensing policy | A.5.32 | **Sedang.** Tidak ada kejelasan tentang: lisensi ERPNext (GNU GPL v3) dan implikasinya bagi kode kustom Fundara, lisensi yang diterapkan untuk Fundara sendiri, dan apakah NGO yang deploy Fundara perlu memahami implikasi lisensi ini. Risiko meningkat jika Fundara dikomersialisasikan atau didistribusikan secara luas. | Tambahkan file `LICENSE` di root repository yang menyatakan lisensi Fundara secara eksplisit. Buat catatan singkat lisensi dependency di `docs/legal/licensing.md`: ERPNext (GPL v3), Frappe Framework (MIT), dan implikasi untuk kode kustom. | **MEDIUM** |
| **14** | Tidak ada remote working security policy | A.6.7 | **Sedang.** Developer yang bekerja remote tidak memiliki panduan keamanan formal: jaringan yang boleh digunakan, persyaratan perangkat, penanganan credentials saat di luar kantor. Mengingat tim development kemungkinan terdistribusi, ini adalah gap yang relevan. | Tambahkan section "Remote Developer Security" di `CONTRIBUTING.md` atau buat dokumen terpisah 1 halaman. Isi minimal: wajib VPN atau SSH tunnel saat mengakses server production dari jaringan publik, dilarang menggunakan perangkat yang dibagikan dengan anggota keluarga untuk akses production, dan storage credentials harus menggunakan password manager, bukan plaintext. | **MEDIUM** |
| **15** | Clock synchronization tidak diverifikasi | A.8.17 | **Sedang.** Timestamp di Frappe Activity Log dan MariaDB binary log menjadi tidak akurat jika NTP tidak dikonfigurasi dengan benar di production server. Ini mempengaruhi forensik insiden — investigasi timeline menjadi tidak reliable jika log timestamps drift. | Tambahkan step verifikasi NTP ke deployment checklist dan upgrade-runbook.md: `timedatectl status` harus menampilkan `NTP service: active` dan clock offset < 1 detik. Konfigurasi `chrony` atau `systemd-timesyncd` sebagai bagian dari server hardening di environment-spec.md. | **MEDIUM** |
| **16** | Tidak ada Information Security Objectives tertulis | Klausul 6.2 | **Sedang.** ISO 27001 mewajibkan organisasi menetapkan tujuan keamanan informasi yang terukur, dikomunikasikan, dan dipantau. Tanpa objectives, tidak ada cara untuk mengukur apakah program ISMS berhasil. | Buat dokumen 1–2 halaman yang menetapkan 3–5 tujuan keamanan yang terukur. Contoh: "Tidak ada insiden data breach dalam 12 bulan pertama operasi", "100% user privileged mengaktifkan 2FA sebelum go-live", "Patch CVE CRITICAL dalam 7 hari sejak publikasi". Setiap objective harus memiliki metric, baseline, dan target. | **HIGH** |
| **17** | Supplier security assessment belum ada | A.5.19, A.5.20 | **Sedang.** Tidak ada penilaian keamanan formal terhadap supplier kritis: hosting provider, rclone/Backblaze B2 (backup storage), Sentry (error monitoring), SMTP relay. Jika salah satu supplier dikompromis, data Fundara bisa terekspos. | Buat Supplier Security Register: daftar supplier dengan akses ke data atau sistem, penilaian risiko singkat per supplier (apa data yang diakses, apakah ada enkripsi, apakah ada SLA keamanan), dan review tahunan. Untuk hosting provider, verifikasi mereka memiliki SOC 2 atau setara. | **MEDIUM** |

---

## 3. Dokumen yang Perlu Dibuat (Roadmap Kepatuhan)

Tabel berikut mendaftar seluruh dokumen yang belum ada dan perlu dibuat untuk menutup gap yang teridentifikasi. Dokumen diurutkan berdasarkan prioritas dan sprint target.

| Dokumen | ISO 27001 Control | Ukuran Perkiraan | Prioritas | Target Sprint |
|---|---|---|---|---|
| Information Security Policy | Klausul 5.2, A.5.1 | 3–4 halaman | **CRITICAL** | Sprint 1 |
| ISMS Scope Document | Klausul 4.3, 4.4 | 1 halaman | **CRITICAL** | Sprint 1 |
| Risk Treatment Plan | Klausul 6.1.3, 6.2 | Spreadsheet | **CRITICAL** | Sprint 1 |
| Information Security Objectives | Klausul 6.2 | 1–2 halaman | **CRITICAL** | Sprint 1 |
| Offboarding Checklist | A.6.5 | 1 halaman | **CRITICAL** | Sprint 1 |
| NDA Template (developer & DevOps) | A.6.6 | 2 halaman | **CRITICAL** | Sprint 1 |
| Internal Audit Checklist & Jadwal | Klausul 9.2 | 2–3 halaman | **HIGH** | Sprint 2 |
| Management Review Template | Klausul 9.3 | 1 halaman | **HIGH** | Sprint 2 |
| Information Classification Policy | A.5.12, A.5.13 | 2 halaman | **HIGH** | Sprint 2 |
| Acceptable Use Policy | A.5.10 | 1 halaman | **HIGH** | Sprint 2 |
| Asset Register | A.5.9 | Spreadsheet | **HIGH** | Sprint 2 |
| Security Awareness Guide (end user NGO) | A.6.3 | 1–2 halaman PDF | **HIGH** | Sprint 3 |
| License Policy (IP rights) | A.5.32 | ½ halaman + LICENSE file | **MEDIUM** | Sprint 3 |
| Remote Working Security Policy | A.6.7 | 1 halaman | **MEDIUM** | Sprint 3 |
| Contact with Authorities List | A.5.5 | ½ halaman | **MEDIUM** | Sprint 3 |
| Supplier Security Register | A.5.19, A.5.20 | Spreadsheet | **MEDIUM** | Sprint 4 |
| Business Continuity Plan | A.5.29, A.5.30 | 3–4 halaman | **MEDIUM** | Sprint 4 |
| HA/Redundancy Specification atau Accepted Risk Doc | A.8.14 | 1–2 halaman | **HIGH** | Sprint 2 |

### Catatan tentang Ekstensi Dokumen yang Ada

Alih-alih membuat semua dokumen dari nol, beberapa dokumen Fundara yang sudah ada dapat dijadikan dasar:

| Dokumen Baru | Dasar dari Dokumen yang Ada |
|---|---|
| Information Security Policy | Extend `security-requirements.md` — tambahkan komitmen pimpinan, scope ISMS, dan prinsip-prinsip kebijakan |
| Risk Treatment Plan | Extend `risk-register.md` — tambahkan kolom: kontrol mitigasi, perlakuan risiko, owner kontrol, target date, status kontrol |
| Business Continuity Plan | Extend bagian RPO/RTO di `backup-recovery.md` — tambahkan prosedur alternatif dan komunikasi krisis |
| Contact with Authorities | Extend kontak darurat di `incident-response.md` — tambahkan Kominfo, BSSN, BAZNAS, dan otoritas perpajakan |

---

## 4. Kekuatan Kepatuhan — Apa yang Sudah Baik

Sebelum masuk ke rekomendasi, penting untuk mengakui bahwa Fundara telah menunjukkan kematangan keamanan yang tidak biasa untuk proyek open source NGO di tahap pre-release. Berikut adalah area yang secara objektif sudah kuat — dan dapat dijadikan benchmark:

### 4.1 Kekuatan yang Sangat Menonjol

**1. Manajemen Risiko Berlapis**
`risk-register.md` berisi 27 risiko teridentifikasi dengan kategori, likelihood, impact, mitigasi, dan owner yang lengkap — sudah menggunakan metodologi risiko yang sesuai dengan ISO 27001 Klausul 6.1.2. Ini dilengkapi oleh `threat-model.md` yang menggunakan metodologi STRIDE untuk analisis ancaman teknis. Kombinasi dua layer risk management (strategic risk + threat model) sangat jarang ditemukan pada proyek NGO ERP.

**2. Incident Response Plan yang Matang**
`incident-response.md` berisi 5 fase respons lengkap (Identifikasi, Penahanan, Investigasi, Remediasi, Lessons Learned) dengan perintah-perintah siap pakai (`bench console`, `ufw`, `mysqlbinlog`) dan skenario tabletop exercise. Yang paling signifikan: dokumen ini sudah mencakup kewajiban notifikasi UU PDP dalam 14 hari ke Kominfo/BSSN, yang sangat relevan untuk konteks Indonesia. Ini setara dengan standar incident response enterprise.

**3. Data Privacy yang Komprehensif**
`data-privacy.md` mencakup seluruh siklus hidup data PII: inventaris data, prinsip minimasi, hak subjek data, prosedur anonymisasi, consent management, retensi, dan transfer ke pihak ketiga. Referensi eksplisit ke UU PDP No. 27/2022 dan ISAK 35 menunjukkan pemahaman konteks hukum Indonesia yang baik. Prosedur anonymisasi dengan field `is_anonymized`, `anonymization_date`, dan `anonymized_by` menunjukkan desain yang matang.

**4. Audit Trail Non-Repudiation**
Kombinasi tiga mekanisme audit trail memberikan non-repudiation yang kuat: GL Entry immutable (tidak bisa dihapus, reversal membuat entri baru), Document Version history dengan old/new value per user per timestamp, dan Frappe Activity Log yang mencatat login, logout, dan role assignment. Ini melampaui banyak sistem ERP komersial.

**5. Segregasi Tugas Keuangan**
Approval chain multi-level yang terdokumentasi di `permissions.md` memastikan pengaju ≠ approver ≠ pembayar — sebuah kontrol keuangan fundamental (A.5.3) yang langsung relevan untuk organisasi nirlaba yang punya kewajiban akuntabilitas ke donor. Ini adalah kontrol yang seringkali diabaikan oleh ERP generik.

**6. Secure Development by Design**
`security-requirements.md` SR-DEV-01 hingga SR-DEV-07 mencakup: larangan production data di dev/staging, mandatory permission check di setiap `@frappe.whitelist()`, parameterized SQL wajib, file upload validation server-side, dan gitleaks/detect-secrets pre-commit hook. Ini adalah OWASP Top 10 compliance yang dijadikan bagian dari standar pengembangan — bukan afterthought.

**7. Backup 3-2-1 Production-Grade**
Strategi backup 3 salinan (production + local offsite + remote cloud), 2 media berbeda, 1 offsite — dengan enkripsi GPG-AES256 sebelum upload — dan target RPO 24 jam / RTO 4 jam yang terdokumentasi, menempatkan Fundara setara dengan standar backup enterprise. Verifikasi GPG integrity sebelum restore juga sudah terdokumentasi.

### 4.2 Praktik yang Perlu Dipertahankan

| Praktik | Dokumen | Relevansi ISO 27001 |
|---|---|---|
| Frappe `track_changes = 1` untuk semua DocType submittable | security-requirements.md SR-LOG-01 | A.8.15, A.8.16 |
| SSL TLS 1.3, HSTS, OCSP stapling di Nginx | security-requirements.md SR-ENC-02 | A.8.20, A.8.21 |
| MariaDB dan Redis localhost-only, tidak terekspos ke internet | security-requirements.md SR-ENC-02 | A.8.21 |
| `site_config.json` permission 640, credential tidak di-commit ke git | security-requirements.md SR-ENC-03 | A.8.12 |
| 2FA wajib untuk System Admin, Finance Manager, Management | security-requirements.md SR-AUTH-03 | A.8.5 |
| pip audit + npm audit bulanan via CI | security-requirements.md SR-DEP-02,03 | A.8.8 |
| Patch CVE CRITICAL dalam 7 hari | security-requirements.md SR-DEP-05 | A.8.8 |
| Consent field lengkap di DocType Donor | data-privacy.md Section 7.2 | A.5.34 |
| Notifikasi UU PDP dalam 14 hari ke Kominfo | incident-response.md Section 4.1 | A.5.24, A.5.26 |

---

## 5. Rekomendasi Strategis

Lima rekomendasi strategis berikut bersifat lintas-kontrol dan bertujuan meningkatkan maturitas ISMS secara keseluruhan, bukan hanya menutup gap individual.

### Rekomendasi 1: Pisahkan Tanggung Jawab Keamanan — Fundara vs. NGO Deployer

Fundara adalah platform perangkat lunak yang di-deploy oleh NGO. Ini menciptakan pembagian tanggung jawab (shared responsibility model) yang perlu didokumentasikan secara eksplisit.

Buat dokumen "Shared Security Responsibility Model" yang membedakan:
- **Tanggung jawab Fundara project:** kontrol teknis (enkripsi, audit log, 2FA, backup), patch keamanan, dokumentasi keamanan
- **Tanggung jawab NGO deployer:** ISMS policy organisasi mereka sendiri, pelatihan staf, NDA untuk staf mereka, kepatuhan UU PDP sebagai Data Controller, physical security perangkat mereka

Tanpa dokumen ini, NGO mungkin berasumsi bahwa dengan menggunakan Fundara, mereka otomatis comply dengan UU PDP dan ISO 27001 — asumsi yang salah dan berpotensi menimbulkan masalah hukum bagi organisasi mereka.

Referensi: `data-privacy.md` Section 1 sudah memulai arah ini dengan pernyataan "Fundara adalah platform perangkat lunak. Kepatuhan UU PDP adalah tanggung jawab organisasi yang menggunakannya" — ini perlu diexpand menjadi dokumen tersendiri.

### Rekomendasi 2: Gunakan Dokumen yang Ada sebagai Fondasi, Bukan Memulai dari Nol

Fundara sudah memiliki fondasi dokumentasi yang sangat kuat. Alih-alih memperlakukan pembuatan dokumen baru sebagai proyek terpisah, extend dokumen yang ada:

- `security-requirements.md` → fondasi untuk **Information Security Policy** (tambahkan: komitmen pimpinan, scope, prinsip-prinsip ISMS, dan referensi ke kebijakan turunan)
- `risk-register.md` → fondasi untuk **Risk Treatment Plan** (tambahkan kolom: perlakuan risiko, kontrol terpilih, status implementasi)
- `incident-response.md` → fondasi untuk **Contact with Authorities** dan bagian dari **Business Continuity Plan**
- `data-privacy.md` → fondasi untuk **Information Classification Policy** (tabel sensitivitas data di Section 2 sudah menjadi blueprint klasifikasi)

Pendekatan ini lebih efisien dan menghasilkan dokumen yang konsisten dengan implementasi teknis yang sudah ada.

### Rekomendasi 3: Buat "Deployment Security Checklist" untuk NGO sebagai Produk

Saat ini, kontrol keamanan Fundara tersebar di minimal lima dokumen (`security-requirements.md`, `owasp-checklist.md`, `environment-spec.md`, `data-privacy.md`, `incident-response.md`). NGO yang mendeploy Fundara tidak memiliki satu titik masuk untuk memahami apa yang harus mereka lakukan sebelum go-live.

Buat dokumen `docs/security/deployment-security-checklist.md` yang menggabungkan:
- Konfigurasi sistem wajib sebelum go-live (tabel di security-requirements.md Section 5)
- Verifikasi backup dan enkripsi
- Aktivasi 2FA untuk user privileged
- Isian kontak darurat di incident-response.md
- Verifikasi NTP dan log rotation
- Pengecekan SSL certificate dan auto-renewal

Dokumen ini juga dapat menjadi alat verifikasi yang digunakan oleh Tech Lead saat handover ke NGO baru, dan menjadi bagian dari onboarding material.

### Rekomendasi 4: Integrasikan Security Gate ke Sprint Definition of Done

Saat ini, security checklist di Fundara terutama tersedia di level MVP (deployment checklist, OWASP checklist). Untuk memastikan keamanan tidak hanya diverifikasi di akhir proyek, tambahkan security gates ke **Sprint Definition of Done (DoD)**:

**Sprint DoD Security Additions:**
- [ ] Semua `@frappe.whitelist()` baru memiliki explicit `frappe.has_permission()` check (SR-DEV-03)
- [ ] Tidak ada `frappe.db.sql()` baru dengan string concatenation (SR-DEV-04)
- [ ] `pip audit` dan `npm audit` dijalankan — tidak ada CVE HIGH/CRITICAL baru yang belum ditangani
- [ ] Tidak ada credentials baru yang terdeteksi oleh gitleaks pre-commit hook
- [ ] Setiap DocType baru yang mengandung PII sudah melalui privacy review (data-privacy.md Section 3.1)
- [ ] `track_changes = 1` diset di setiap DocType submittable baru (SR-LOG-01)

Ini mengubah keamanan dari "audit di akhir" menjadi "built into every sprint" — sesuai dengan prinsip shift-left security dan secure by design.

### Rekomendasi 5: Jadikan Kesiapan ISO 27001 sebagai Nilai Jual Produk

Untuk donor internasional (USAID, EU, Belanda/Netherlands Partnership) yang mensyaratkan data governance dan keamanan informasi dalam perjanjian grant, kemampuan Fundara untuk menunjukkan kepatuhan terhadap ISO 27001 adalah nilai diferensiasi yang signifikan dibandingkan ERP NGO lainnya.

Pertimbangkan:
- **Dokumentasikan gap closure sebagai fitur release:** Ketika gap Critical ditutup (Sprint 1), jadikan ini bagian dari release notes v0.x: "Fundara now ships with ISO 27001-aligned documentation package"
- **Sertakan audit summary dalam marketing material:** Ringkasan audit ini (khususnya Section 4 — kekuatan) dapat menjadi bagian dari proposal ke donor atau NGO calon pengguna
- **Target sertifikasi jangka menengah:** Jika ada NGO pilot yang mendapatkan grant dari donor yang mensyaratkan ISO 27001, Fundara dapat memposisikan diri sebagai platform yang membantu NGO tersebut mencapai compliance lebih cepat

---

## 6. Tabel Ringkasan Akhir — Semua Kontrol Annex A

### A.5 — Organizational Controls (37 Kontrol)

| ID | Judul Kontrol | Status | Dokumen Utama |
|---|---|---|---|
| A.5.1 | Policies for information security | ⚠️ Sebagian | security-requirements.md (tidak ada kebijakan formal tertandatangani) |
| A.5.2 | Information security roles and responsibilities | ✅ Sesuai | permissions.md, incident-response.md (tim respons didefinisikan) |
| A.5.3 | Segregation of duties | ✅ Sesuai | permissions.md (pengaju ≠ approver ≠ pembayar) |
| A.5.4 | Management responsibilities | ⚠️ Sebagian | Tidak ada bukti komitmen manajemen formal (management review belum ada) |
| A.5.5 | Contact with authorities | ⚠️ Sebagian | incident-response.md Section 4 (Kominfo/BSSN dicantumkan, tapi tanpa prosedur kontak formal) |
| A.5.6 | Contact with special interest groups | N/A | Di luar scope proyek saat ini |
| A.5.7 | Threat intelligence | ⚠️ Sebagian | threat-model.md (STRIDE), security-requirements.md SR-DEP-05 (CVE monitoring) |
| A.5.8 | Information security in project management | ✅ Sesuai | security-requirements.md terintegrasi ke development workflow; OWASP checklist ada |
| A.5.9 | Inventory of information and other associated assets | ❌ Belum Ada | Tidak ada asset register formal |
| A.5.10 | Acceptable use of information and other associated assets | ❌ Belum Ada | Tidak ada Acceptable Use Policy |
| A.5.11 | Return of assets | N/A | Tidak relevan — tidak ada perangkat organisasi yang dipinjamkan |
| A.5.12 | Classification of information | ✅ Sesuai | `docs/security/information-classification.md` (ISP-005 v1.0 — skema 4 tingkat L4/L3/L2/L1, 20+ komponen Fundara, aturan handling per tingkat) |
| A.5.13 | Labelling of information | ❌ Belum Ada | Tidak ada prosedur labelling dokumen/data |
| A.5.14 | Information transfer | ⚠️ Sebagian | data-privacy.md Section 8 (transfer policy ada, belum ada prosedur transfer formal per channel) |
| A.5.15 | Access control | ✅ Sesuai | security-requirements.md Section 1–2, permissions.md |
| A.5.16 | Identity management | ✅ Sesuai | SR-AUTHZ-01 (no shared accounts, one user per human, quarterly review) |
| A.5.17 | Authentication information | ✅ Sesuai | SR-AUTH-01 (password policy), SR-AUTH-03 (2FA), SR-ENC-03 (secret management) |
| A.5.18 | Access rights | ✅ Sesuai | SR-AUTHZ-02 (RBAC via Role Permission Manager), SR-AUTHZ-04 (document-level security) |
| A.5.19 | Information security in supplier relationships | ⚠️ Sebagian | data-privacy.md Section 8.3 (backup provider), belum ada supplier security register |
| A.5.20 | Addressing information security within supplier agreements | ⚠️ Sebagian | Tidak ada DPA formal dengan supplier kritis |
| A.5.21 | Managing information security in the ICT supply chain | N/A | Tidak relevan di skala proyek ini |
| A.5.22 | Monitoring, review and change management of supplier services | ❌ Belum Ada | Tidak ada monitoring formal terhadap performa keamanan supplier |
| A.5.23 | Information security for use of cloud services | ⚠️ Sebagian | environment-spec.md (VPS profile), backup-recovery.md (cloud backup policy) |
| A.5.24 | Information security incident management planning and preparation | ✅ Sesuai | incident-response.md (5 fase lengkap, tim, eskalasi, tabletop exercise) |
| A.5.25 | Assessment and decision on information security events | ✅ Sesuai | incident-response.md Section 1 (klasifikasi Critical/High/Medium/Low + aturan eskalasi) |
| A.5.26 | Response to information security incidents | ✅ Sesuai | incident-response.md Fase 2–4 (containment, investigation, remediation) |
| A.5.27 | Learning from information security incidents | ✅ Sesuai | incident-response.md Fase 5 (post-incident review template, lessons learned) |
| A.5.28 | Collection of evidence | ⚠️ Sebagian | incident-response.md Fase 1 (screenshot, chain of custody), belum ada prosedur forensik formal |
| A.5.29 | Information security during disruption | ⚠️ Sebagian | backup-recovery.md (RPO/RTO), belum ada Business Continuity Plan formal |
| A.5.30 | ICT readiness for business continuity | ⚠️ Sebagian | backup-recovery.md (restore procedure), belum ada BCP yang teruji formal |
| A.5.31 | Legal, statutory, regulatory and contractual requirements | ✅ Sesuai | data-privacy.md (UU PDP), security-requirements.md (compliance note) |
| A.5.32 | Intellectual property rights | ❌ Belum Ada | Tidak ada LICENSE file di repository, tidak ada IP policy |
| A.5.33 | Protection of records | ✅ Sesuai | SR-LOG-01, SR-LOG-02, SR-LOG-03 (immutable GL, 2-year retention Activity Log) |
| A.5.34 | Privacy and protection of PII | ✅ Sesuai | data-privacy.md (komprehensif, UU PDP-aligned, consent management) |
| A.5.35 | Independent review of information security | ⚠️ Sebagian | Audit ini merupakan desk review; belum ada rencana audit eksternal berkala |
| A.5.36 | Compliance with policies, rules and standards | ⚠️ Sebagian | Tidak ada mekanisme formal verifikasi compliance (internal audit program belum ada) |
| A.5.37 | Documented operating procedures | ✅ Sesuai | security-requirements.md, environment-spec.md, backup-recovery.md, incident-response.md |

---

### A.6 — People Controls (8 Kontrol)

| ID | Judul Kontrol | Status | Dokumen Utama |
|---|---|---|---|
| A.6.1 | Screening | N/A | Tidak ada karyawan tetap dalam struktur proyek saat ini |
| A.6.2 | Terms and conditions of employment | N/A | Tidak relevan — proyek open source, bukan employer-employee |
| A.6.3 | Information security awareness, education and training | ⚠️ Sebagian | Ada dalam rencana (security-requirements.md menyebutkan pelatihan), belum ada materi formal |
| A.6.4 | Disciplinary process | N/A | Tidak ada proses disiplin formal dalam konteks proyek open source |
| A.6.5 | Responsibilities after termination or change of employment | ✅ Sesuai | `docs/security/offboarding-checklist.md` (ISP-003 v1.0 — offboarding checklist formal, 24 jam SLA, 11 kategori akses, verifikasi D+7) |
| A.6.6 | Confidentiality or non-disclosure agreements | ❌ Belum Ada | Tidak ada NDA/confidentiality agreement untuk developer atau DevOps |
| A.6.7 | Remote working | ⚠️ Sebagian | Tidak ada remote working security policy; ada panduan umum di security-requirements.md |
| A.6.8 | Information security event reporting | ✅ Sesuai | incident-response.md (mekanisme pelaporan insiden, kontak, eskalasi) |

---

### A.7 — Physical Controls (14 Kontrol)

| ID | Judul Kontrol | Status | Dokumen Utama |
|---|---|---|---|
| A.7.1 | Physical security perimeters | N/A | Tanggung jawab hosting provider |
| A.7.2 | Physical entry | N/A | Tanggung jawab hosting provider |
| A.7.3 | Securing offices, rooms and facilities | N/A | Tanggung jawab hosting provider |
| A.7.4 | Physical security monitoring | N/A | Tanggung jawab hosting provider |
| A.7.5 | Protecting against physical and environmental threats | N/A | Tanggung jawab hosting provider |
| A.7.6 | Working in secure areas | N/A | Tidak ada secure area fisik milik Fundara |
| A.7.7 | Clear desk and clear screen | ⚠️ Sebagian | Tidak ada policy formal; implisit dari session timeout (SR-AUTH-02) |
| A.7.8 | Equipment siting and protection | N/A | Tanggung jawab hosting provider |
| A.7.9 | Security of assets off-premises | ⚠️ Sebagian | Tidak ada policy formal untuk laptop/perangkat developer di luar kantor |
| A.7.10 | Storage media | ⚠️ Sebagian | backup-recovery.md (secure deletion dengan `shred`), belum ada media disposal policy formal |
| A.7.11 | Supporting utilities | N/A | Tanggung jawab hosting provider |
| A.7.12 | Cabling security | N/A | Tanggung jawab hosting provider |
| A.7.13 | Equipment maintenance | ⚠️ Sebagian | environment-spec.md (server maintenance procedure), belum ada formal equipment maintenance schedule |
| A.7.14 | Secure disposal or re-use of equipment | N/A | Tidak ada perangkat fisik milik Fundara project |

---

### A.8 — Technological Controls (34 Kontrol)

| ID | Judul Kontrol | Status | Dokumen Utama |
|---|---|---|---|
| A.8.1 | User end point devices | ⚠️ Sebagian | Ada panduan umum; belum ada endpoint security policy formal untuk developer devices |
| A.8.2 | Privileged access rights | ✅ Sesuai | SR-AUTHZ-01 (least privilege), SR-AUTH-03 (2FA wajib untuk privileged roles) |
| A.8.3 | Information access restriction | ✅ Sesuai | SR-AUTHZ-02, SR-AUTHZ-03 (field-level), SR-AUTHZ-04 (document-level) |
| A.8.4 | Access to source code | ✅ Sesuai | GitHub repository access control, SR-DEV-06 (no credentials in code) |
| A.8.5 | Secure authentication | ✅ Sesuai | SR-AUTH-01 (password policy), SR-AUTH-02 (session management), SR-AUTH-03 (2FA), SR-AUTH-04 (lockout) |
| A.8.6 | Capacity management | ⚠️ Sebagian | environment-spec.md (profil server A/B/C), Netdata monitoring; tidak ada formal capacity planning |
| A.8.7 | Protection against malware | ⚠️ Sebagian | environment-spec.md (UFW, fail2ban, unattended-upgrades); tidak ada antivirus/EDR formal |
| A.8.8 | Management of technical vulnerabilities | ✅ Sesuai | SR-DEP-02,03 (pip/npm audit), SR-DEP-05 (CVE SLA 7/30 hari) |
| A.8.9 | Configuration management | ✅ Sesuai | environment-spec.md, `common_site_config.json` settings terdokumentasi lengkap |
| A.8.10 | Information deletion | ✅ Sesuai | data-privacy.md Section 5–6 (retention policy, anonymization procedure, `shred` untuk backup) |
| A.8.11 | Data masking | ✅ Sesuai | SR-AUTHZ-03 (field masking `***` untuk PII), data-privacy.md Section 2 |
| A.8.12 | Data leakage prevention | ⚠️ Sebagian | SR-DEV-06 (no secrets in code, gitleaks), SR-DEV-02 (no PII in logs); tidak ada DLP tool |
| A.8.13 | Information backup | ✅ Sesuai | backup-recovery.md (3-2-1 rule, GPG-AES256, RPO 24h/RTO 4h, restore procedure) |
| A.8.14 | Redundancy of information processing facilities | ⚠️ Sebagian | Belum ada HA spec; RTO 4 jam bergantung restore manual |
| A.8.15 | Logging | ✅ Sesuai | SR-LOG-01,02,03,04 (Activity Log, version history, GL immutable, 2 tahun retensi) |
| A.8.16 | Monitoring activities | ✅ Sesuai | Uptime Kuma, Netdata, Frappe Activity Log monitoring terdokumentasi di incident-response.md |
| A.8.17 | Clock synchronisation | ⚠️ Sebagian | Tidak ada verifikasi NTP di deployment checklist; asumsi VPS provider menyediakan NTP |
| A.8.18 | Use of privileged utility programs | ⚠️ Sebagian | SR-AUTHZ-02 (`frappe.flags.ignore_permissions` harus dijustifikasi), belum ada daftar utility yang diizinkan |
| A.8.19 | Installation of software on operational systems | ✅ Sesuai | SR-DEP-01 (pin versi di apps.json), bench update procedure di environment-spec.md |
| A.8.20 | Networks security | ✅ Sesuai | SR-ENC-02 (TLS 1.3, HSTS, MariaDB/Redis localhost-only), environment-spec.md (UFW rules) |
| A.8.21 | Security of network services | ✅ Sesuai | Nginx reverse proxy, semua internal port localhost-only, security headers (CSP, X-Frame-Options) |
| A.8.22 | Segregation of networks | ⚠️ Sebagian | Dev/staging/production environment terpisah (environment-spec.md); tidak ada formal network segmentation per zone |
| A.8.23 | Web filtering | N/A | Tidak relevan — Fundara adalah server-side app, bukan browser-based client management |
| A.8.24 | Use of cryptography | ✅ Sesuai | SR-ENC-01 (AES-256 at rest), SR-ENC-02 (TLS 1.3), SR-ENC-03 (secret management) |
| A.8.25 | Secure development life cycle | ✅ Sesuai | security-requirements.md Section 6 (SR-DEV-01 hingga SR-DEV-07), OWASP checklist |
| A.8.26 | Application security requirements | ✅ Sesuai | security-requirements.md Section 1–4, owasp-checklist.md |
| A.8.27 | Secure system architecture and engineering principles | ✅ Sesuai | permissions.md (defense in depth), secure by design di SR-AUTHZ-02 |
| A.8.28 | Secure coding | ✅ Sesuai | SR-DEV-03 (whitelist guard), SR-DEV-04 (parameterized SQL), SR-DEV-05 (file upload validation) |
| A.8.29 | Security testing in development and acceptance | ✅ Sesuai | owasp-checklist.md, pentest-scope.md (rencana pentest sebelum go-live) |
| A.8.30 | Outsourced development | ⚠️ Sebagian | Tidak ada formal outsourcing security agreement; sebagian developer mungkin freelance |
| A.8.31 | Separation of development, test and production environments | ✅ Sesuai | environment-spec.md (dev/staging/production terpisah eksplisit, no production data di dev) |
| A.8.32 | Change management | ✅ Sesuai | DECISIONS.md (ADR), branch protection, PR review process |
| A.8.33 | Test information | ✅ Sesuai | SR-DEV-01 (synthetic/anonymized data di dev/staging), environment-spec.md Section 1.8, 2.8 |
| A.8.34 | Protection of information systems during audit testing | ✅ Sesuai | pentest-scope.md (staging environment untuk pentest, bukan production) |

---

## 7. Tentang Dokumen Ini

```
Dokumen         : iso27001-audit.md — Audit Kepatuhan ISO 27001:2022 Fundara
Versi           : 1.0
Tanggal         : 19 Juni 2026

Auditor         : Dibuat berdasarkan desk review dokumen internal proyek Fundara
Metode          : Document review (bukan field audit atau pengujian teknis langsung)
Dokumen yang    :
  di-review       - docs/security/security-requirements.md (v1.0)
                  - docs/security/incident-response.md (v1.0)
                  - docs/security/data-privacy.md (v1.0)
                  - docs/pm/risk-register.md (2026-06-18)
                  - docs/infra/environment-spec.md
                  - docs/spec/permissions.md
                  - DECISIONS.md
                  - docs/security/owasp-checklist.md
                  - docs/security/pentest-scope.md
                  - docs/security/threat-model.md
                  - docs/infra/backup-recovery.md

Keterbatasan    : Audit ini menilai dokumen yang ada, bukan kode yang berjalan
                  atau implementasi aktual di production. Temuan "Sesuai" berarti
                  kontrol terdokumentasi dengan baik, bukan berarti sudah
                  diimplementasikan dan diverifikasi di production.

                  Beberapa kontrol (terutama A.8) memerlukan verifikasi langsung
                  di server production untuk konfirmasi penuh — misalnya: TLS
                  grade (SSL Labs), output `ufw status`, verifikasi 2FA aktif
                  untuk semua privileged user.

Langkah         :
  selanjutnya     1. Tech Lead review dan validasi temuan — khususnya untuk
                     kontrol A.8 yang perlu verifikasi teknis
                  2. PM buat action plan dari 7 gap Critical:
                     - Information Security Policy
                     - ISMS Scope Document
                     - Offboarding Checklist
                     - NDA Template
                     - Information Classification Policy
                     - Internal Audit Program
                     - Risk Treatment Plan
                  3. Pentest eksternal sebelum go-live sesuai pentest-scope.md
                  4. Pertimbangkan audit eksternal ISO 27001 jika donor mensyaratkan
                     (estimasi: 6 bulan setelah gap Critical tertutup)

Versi           :
  berikutnya      Audit ulang direkomendasikan setelah Sprint 3 (setelah gap
                  Critical ditutup). Target scorecard pasca-remediation:
                  - Klausul 4–10: Sesuai naik dari 18% ke minimal 60%
                  - A.5: Belum Ada turun dari 5 menjadi 0
                  - A.6: Belum Ada turun dari 2 menjadi 0
                  - Overall % Covered: dari 88% ke minimal 95%
```

---

*Dokumen ini merupakan bagian dari paket dokumentasi keamanan Fundara. Lihat juga:*
- *`docs/security/security-requirements.md` — persyaratan teknis keamanan*
- *`docs/security/incident-response.md` — playbook respons insiden*
- *`docs/security/data-privacy.md` — kebijakan privasi dan UU PDP*
- *`docs/pm/risk-register.md` — daftar risiko proyek*
