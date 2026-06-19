# Fundara — Bug Severity Matrix

**Project:** Fundara — Fund-centric ERP for Mission-driven Organizations
**Platform:** ERPNext v16 / Frappe Framework
**Document owner:** QA Lead
**Last updated:** 2026-06-19
**Version:** 1.0

**Audience:** Semua tim — Developer, QA Engineer, Tech Lead, Project Manager

Dokumen ini mendefinisikan secara eksplisit apa yang dimaksud dengan setiap level severity bug. Tujuannya adalah menghilangkan ambiguitas saat bug pertama kali dilaporkan: tidak ada negosiasi soal label, tidak ada eskalasi yang tidak perlu.

---

## 1. Definisi Severity

### Critical

**Deskripsi:**
Bug yang menyebabkan salah satu kondisi berikut: (1) sistem tidak bisa digunakan sama sekali (down / crash / infinite loop); (2) data hilang atau korup; (3) keamanan data terbobol; (4) GL posting menghasilkan entri yang salah yang berdampak ke laporan keuangan; (5) alur utama (fund → budget → transaksi → laporan) tidak bisa dijalankan dari ujung ke ujung.

**Contoh konkret dari Fundara:**

| Contoh | Mengapa Critical |
|---|---|
| D-02 violation: Fund balance berkurang saat Cash Advance status = Approved, bukan saat Paid | Langsung melanggar keputusan arsitektur D-02; laporan donor akan salah |
| Cash Advance bisa di-submit dan dibayar tanpa melalui approval workflow | Kontrol keuangan utama bypass; uang bisa keluar tanpa approval |
| GL Entry double posting: payment satu transaksi menghasilkan dua Journal Entry | Neraca keuangan tidak balance; berdampak ke semua laporan ISAK 35 |
| Data Donor bisa dibaca oleh user dengan role Project Officer (tanpa hak akses) | Security breach; melanggar confidentiality donor |
| Fund Balance panel menampilkan angka USD yang berbeda dari sum GL entries aktual | Laporan kepada donor menggunakan angka salah |
| Scheduled job mark-overdue tidak berjalan: advance yang sudah lewat due date tidak pernah di-flag Overdue | Aging report tidak akurat; Finance tidak mendapat alert |
| `amount_in_base_currency` tidak dihitung ulang saat exchange rate berubah (D-04) | Semua multi-currency transaction salah secara akuntansi |

**SLA fix:** Dalam 4 jam kerja setelah bug dilaporkan. Jika ditemukan di luar jam kerja, fix diselesaikan paling lambat pukul 12.00 hari kerja berikutnya.

**Memblokir release:** YA — tidak boleh ada satu pun Critical bug yang open saat release approval.

**Notifikasi:** Tech Lead + PM langsung via Slack/WhatsApp (bukan hanya issue tracker).

**Siapa yang fix:** Tech Lead mengambil alih langsung atau mengassign ke developer paling senior yang tersedia. TL mereview fix sebelum merge, bahkan jika fix kecil.

---

### High

**Deskripsi:**
Fitur utama tidak berfungsi namun ada workaround yang bisa dilakukan pengguna, atau output fitur menghasilkan nilai yang salah tetapi tidak berdampak langsung ke laporan keuangan yang akan dikirim ke donor/auditor.

**Contoh konkret dari Fundara:**

| Contoh | Mengapa High (bukan Critical) |
|---|---|
| Workflow transition dari Approved ke Paid tidak bisa dilakukan oleh Finance Officer karena permission error | Advance tidak bisa dibayar via sistem — Finance bisa bypass sementara dengan workaround manual |
| Laporan Donor Fund Utilization menghasilkan angka USD yang sedikit berbeda karena rounding error (+/- USD 0.01) | Angka salah tapi bukan order of magnitude; laporan masih bisa dikirim dengan catatan |
| Filter tanggal di dashboard Budget vs Actual tidak berfungsi — selalu menampilkan semua periode | User masih bisa baca data, hanya tidak bisa filter |
| Notifikasi email advance overdue tidak terkirim ke requester | Alert tidak sampai tapi data di sistem benar; Finance masih bisa lihat aging report |
| Export PDF Laporan Aktivitas gagal, export XLSX masih berfungsi | Report masih bisa diakses dalam format lain |
| Budget Revision workflow tidak men-trigger notifikasi ke Finance Manager saat revision diajukan | Proses bisa lanjut jika FM aktif cek dashboard; tidak ada data corruption |

**SLA fix:** Dalam 1 sprint (2 minggu) dari tanggal bug dilaporkan.

**Memblokir release:** Carry over diizinkan maksimal 3 High bugs, dengan syarat: PM dan TL setuju secara eksplisit (tercatat di issue tracker), dan ada accept-and-monitor decision yang terdokumentasi.

**Notifikasi:** Tech Lead via issue tracker (tag `severity:high`). Dilaporkan di sprint QA standup mingguan.

**Siapa yang fix:** Developer yang mengerjakan feature terkait. TL mereview PR.

---

### Medium

**Deskripsi:**
Fitur berfungsi dengan benar secara fungsional, tetapi ada anomali yang mengurangi usability: pesan error tidak jelas, teks tidak sesuai spec, atau tampilan form tidak mengikuti desain yang disepakati.

**Contoh konkret dari Fundara:**

| Contoh | Mengapa Medium (bukan High) |
|---|---|
| Pesan validasi muncul dalam Bahasa Inggris ("End Date must be after Start Date") padahal spec mewajibkan Bahasa Indonesia | Sistem berfungsi benar, hanya teks yang salah |
| Field mandatory di form Cash Advance tidak ditandai dengan asterisk (*) | User tidak tahu field wajib diisi, tapi sistem tetap memvalidasi saat submit |
| Urutan field di form Fund tidak sesuai spec (`restriction_type` seharusnya di atas `currency`) | UX tidak optimal tapi tidak memblokir kerja |
| Export CSV Fund Utilization Report: kolom `exchange_rate` hilang dari file | Report masih bisa digunakan, hanya satu kolom informatif yang missing |
| Halaman Advance Aging tidak menampilkan pagination dengan benar saat ada >50 records | Tampilan kurang nyaman tapi semua data ada |
| Help text pada field `fund_type` kosong padahal spec mendefinisikan tooltip | User harus buka dokumentasi, tidak ada bahaya |

**SLA fix:** Dalam 2 sprint (4 minggu) dari tanggal bug dilaporkan.

**Memblokir release:** Tidak.

**Notifikasi:** Developer terkait via issue tracker. Tidak perlu ping langsung.

**Siapa yang fix:** Developer mana saja yang punya kapasitas; bisa di-batch dalam satu PR.

---

### Low

**Deskripsi:**
Masalah kosmetik, typo, atau improvement kecil yang tidak mempengaruhi fungsi sistem sama sekali.

**Contoh konkret dari Fundara:**

| Contoh | Mengapa Low |
|---|---|
| Warna badge status "Overdue" berwarna oranye, spec mendefinisikan merah (`#D44333`) | Tidak ada dampak fungsional; hanya visual |
| Label field `liquidation_date` tertulis "Liquidation Date" (tanpa spasi konteks), seharusnya "Tanggal Likuidasi" | Typo label; sistem berfungsi |
| Alignment form Grant Management sedikit off di resolusi 1280px | Estetika; tidak ada dampak ke data |
| Ikon di dashboard tombol "Generate Report" tidak sesuai design system | Visual only |
| Pesan sukses setelah submit Cash Advance tidak menyebut nama advance: "Document saved" vs. "Cash Advance CA-2025-001 berhasil disubmit" | UX improvement, bukan bug |

**SLA fix:** Fix kapan saja ada kapasitas; tidak ada deadline ketat. Boleh di-batch sebelum milestone release.

**Memblokir release:** Tidak.

**Notifikasi:** Developer terkait via issue tracker. Boleh di-label dan ditinggal sampai kapasitas tersedia.

**Siapa yang fix:** Developer mana saja; biasanya di-batch dalam sprint hardening (Sprint 10).

---

## 2. Tabel Ringkasan

| Severity | Deskripsi Singkat | Contoh Khas | SLA Fix | Blokir Release? | Notify Siapa | Fix Oleh |
|---|---|---|---|---|---|---|
| **Critical** | Data/GL salah, sistem down, security breach, alur utama gagal total | D-02 violation, double GL posting, data donor bocor ke role lain | 4 jam kerja | **Ya** — hard block | TL + PM (Slack/WA langsung) | TL atau Senior Dev; TL review wajib |
| **High** | Fitur utama tidak bisa digunakan, ada workaround; atau output salah tapi tidak ke laporan keuangan | Workflow permission error, export PDF gagal, notifikasi tidak terkirim | 1 sprint (2 minggu) | Carry over maks 3, PM+TL setuju | TL via issue tracker | Dev terkait; TL review PR |
| **Medium** | Fitur berfungsi, tapi UX buruk atau teks tidak sesuai spec | Pesan error dalam Bahasa Inggris, field mandatory tidak ditandai `*`, kolom CSV hilang | 2 sprint (4 minggu) | Tidak | Dev terkait via issue tracker | Dev mana saja yang tersedia |
| **Low** | Kosmetik, typo, visual yang tidak mempengaruhi fungsi | Warna badge salah, label typo, alignment form sedikit off | Kapan ada kapasitas | Tidak | Dev terkait via issue tracker | Dev mana saja; di-batch |

---

## 3. Proses Bug Reporting

Ikuti langkah-langkah berikut setiap kali menemukan bug:

**Langkah 1 — Cek duplikat**
Search issue tracker menggunakan keyword dari deskripsi bug. Jika sudah ada issue yang sama, tambahkan komentar di issue tersebut (jangan buat issue baru). Sertakan environment dan langkah reproduksi yang mungkin berbeda dari laporan asli.

**Langkah 2 — Format judul issue**
```
[SEVERITY][Domain] Deskripsi singkat maksimal 80 karakter
```
Contoh:
- `[CRITICAL][Cash Advance] D-02 violation: budget berkurang saat status Approved`
- `[HIGH][Reporting] Export PDF Laporan Aktivitas gagal — HTTP 500`
- `[MEDIUM][Fund] Pesan validasi Fund End Date dalam Bahasa Inggris`
- `[LOW][Dashboard] Badge status Overdue berwarna oranye bukan merah`

Domain yang valid: `Fund`, `Grant`, `Cash Advance`, `Procurement`, `Budget`, `Reporting`, `Evidence`, `Organization`, `Bank Reconciliation`, `General Journal`, `Dashboard`, `Permissions`, `Infrastructure`

**Langkah 3 — Isi template issue**

```markdown
## Bug Report

**Environment:** staging / local / production
**Tanggal ditemukan:** YYYY-MM-DD
**Ditemukan oleh:** [nama / role]
**Role yang digunakan saat bug terjadi:** Finance Manager / Finance Officer / dll.

## Langkah Reproduksi
1. [Langkah pertama — tuliskan state awal sistem]
2. [Langkah kedua — aksi yang dilakukan]
3. [Langkah ketiga — dst.]

## Expected
[Apa yang seharusnya terjadi, berdasarkan spec atau test scenario]

## Actual
[Apa yang sebenarnya terjadi]

## Screenshot / Video
[Lampirkan screenshot atau screen recording. Untuk Critical/High: wajib ada.]

## Severity
[Critical / High / Medium / Low] — beserta alasan singkat mengapa

## Dokumen Spec Terkait
[Link ke test scenario, misalnya: `docs/spec/test-scenarios.md#TC-CA-01`]
[Link ke keputusan arsitektur jika relevan, misalnya: D-02, D-04]

## Informasi Tambahan
[Error log dari Frappe console, traceback Python, browser console error — jika ada]
```

**Langkah 4 — Assign label dan assignee**

Setelah issue dibuat:
- Tambahkan label severity (`severity:critical`, `severity:high`, `severity:medium`, `severity:low`)
- Tambahkan label domain (`domain:cash-advance`, `domain:fund`, dll.)
- Tambahkan label `type:regression` jika bug ini adalah regresi dari fitur yang sebelumnya berfungsi
- Assign ke Tech Lead jika Critical; assign ke developer terkait jika High/Medium/Low
- Untuk Critical: kirim notifikasi manual ke TL dan PM — jangan hanya mengandalkan issue tracker

---

## 4. Bug Lifecycle

Setiap bug mengikuti state machine berikut:

```
Open → In Progress → In Review → Resolved → Closed
                                     ↓
                                  Reopened
```

| Transisi | Siapa yang melakukan | Kondisi |
|---|---|---|
| **Open → In Progress** | Developer (assign diri sendiri) | Developer mulai mengerjakan fix |
| **In Progress → In Review** | Developer | PR fix sudah dibuat dan siap direview; link PR ditambahkan ke issue |
| **In Review → Resolved** | Tech Lead (reviewer PR) | PR diapprove dan di-merge ke `develop`; fix ter-deploy ke staging |
| **Resolved → Closed** | QA Engineer | QA memverifikasi fix di staging; bug tidak muncul kembali |
| **Resolved → Reopened** | QA Engineer | Fix tidak efektif — bug masih muncul di staging setelah PR di-merge |
| **Open → Won't Fix** | Tech Lead + PM (joint decision) | Bug valid tapi tim memutuskan tidak diperbaiki (lihat kriteria di bawah) |

**Kapan bug di-reopen:**
- QA memverifikasi fix di staging dan bug masih terjadi dengan langkah reproduksi yang sama
- Bug dianggap fixed tapi muncul kembali di sprint berikutnya (otomatis menjadi `type:regression`)

**Kapan bug di-wontfix:**
Won't Fix hanya bisa ditetapkan oleh Tech Lead dan PM bersama. Kriteria yang membolehkan Won't Fix:
- Bug hanya terjadi pada browser/OS yang di luar support matrix Fundara (didokumentasikan di `docs/infra/`)
- Bug adalah konsekuensi langsung dari batasan ERPNext core yang tidak bisa di-override tanpa forking framework
- Biaya fix (estimated dev-days) tidak proporsional terhadap dampak (Low/Medium bug yang jarang terjadi)
- Fitur yang terdampak sudah dijadwalkan untuk di-refactor di sprint mendatang

Semua keputusan Won't Fix harus tercatat di issue dengan alasan eksplisit dan nama pembuat keputusan.

---

## 5. Metrik Bug

Tim menggunakan metrik berikut untuk membuat keputusan berdasarkan data, bukan intuisi:

### 5.1 Bug Velocity

**Definisi:** Perbandingan jumlah bug ditemukan vs. jumlah bug diselesaikan per sprint.

**Cara baca:**
- Velocity positif (diselesaikan > ditemukan): tim mengurangi technical debt — tanda sehat
- Velocity negatif (ditemukan > diselesaikan selama 2+ sprint berturut-turut): sinyal bahwa kapasitas QA perlu dinaikkan atau scope sprint perlu dikurangi

**Dilaporkan di:** Sprint QA Report (Lampiran A di `test-plan.md`).

### 5.2 Age of Open Bugs

**Definisi:** Berapa lama setiap bug sudah dalam status Open atau In Progress tanpa resolusi.

**Alert rule:**
- High bug yang sudah open > 2 sprint (>4 minggu) tanpa progress: PM harus diinformasikan di standup berikutnya
- Medium bug yang sudah open > 4 sprint (>8 minggu): triage ulang — pertimbangkan Won't Fix atau prioritas naik
- Critical bug yang belum resolved dalam 24 jam kerja: eskalasi ke PO

**Dipantau oleh:** QA Engineer setiap sprint standup.

### 5.3 Bug Density per Feature Group

**Definisi:** Jumlah bug (segala severity) yang ditemukan per feature group, dibagi estimasi dev-days feature group tersebut.

**Formula:**
```
Bug Density = Jumlah Bug / Estimasi Dev-Days (dari complexity.md)
```

**Cara baca:**
- Feature group dengan Bug Density tinggi (misalnya: >1 bug per 2 dev-days) adalah kandidat untuk:
  - Refactoring sebelum fitur-fitur dependen dibangun di atasnya
  - Test coverage review — apakah unit test benar-benar mengcover edge case?
  - Pair programming pada sprint berikutnya

**Dipantau oleh:** Tech Lead; dilaporkan di sprint review setiap 2 sprint.

### 5.4 Regression Rate

**Definisi:** Persentase bug yang ditemukan di sprint N yang merupakan regresi dari fitur yang sebelumnya berfungsi (pernah pass di sprint sebelumnya).

**Formula:**
```
Regression Rate = Jumlah bug type:regression / Total bug ditemukan sprint ini × 100%
```

**Alert rule:**
- Regression rate >20% dalam satu sprint: sinyal bahwa test coverage tidak cukup atau PR review kurang ketat
- Regression dua kali pada area yang sama: TL wajib melakukan root cause analysis dan menambah test case baru sebelum sprint berikutnya

**Dipantau oleh:** QA Engineer; dilaporkan di Sprint QA Report.

### 5.5 UAT Bug Rate

**Definisi:** Jumlah bug yang pertama kali ditemukan oleh end-user selama UAT (bukan oleh QA internal).

**Cara baca:**
- UAT Bug Rate tinggi = QA internal tidak berhasil menangkap bug sebelum UAT. Review coverage E2E test dan tambah negatif-test pada area yang terdampak.
- Target: <10% dari total bug ditemukan berasal dari UAT session pertama.

---

## Referensi

- Test scenarios: `docs/spec/test-scenarios.md`
- Test plan: `docs/qa/test-plan.md`
- Definition of Done: `docs/pm/definition-of-done.md`
- Feature complexity: `docs/pm/complexity.md`
- Architectural decisions D-02 (budget formula), D-04 (multi-currency): `docs/spec/DECISIONS.md`
