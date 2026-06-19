# Keputusan Desain Fundara

Dokumen ini mencatat keputusan arsitektur dan desain yang harus dibuat **sebelum coding dimulai**. Setiap keputusan yang belum diisi akan memblokir implementasi area terkait.

Format setiap entry:

- **Status:** `OPEN` (belum diputuskan) | `DECIDED` (sudah diputuskan)
- **Keputusan:** pilihan yang dipilih
- **Alasan:** mengapa pilihan ini dipilih
- **Implikasi:** apa yang berubah setelah keputusan ini

---

## D-01: Grant — Bounded Context Mandiri atau Sub-domain Fund?

**Status:** `DECIDED`

**Pertanyaan:**
Apakah Grant adalah bounded context tersendiri dengan DocType mandiri (Grant, Grant Agreement, Grant Budget Line), atau Grant diabsorb sebagai set atribut tambahan di dalam Fund master ketika Fund Type = Grant Fund?

**Opsi:**

| Opsi | Deskripsi | Pro | Kontra |
|---|---|---|---|
| A — Bounded Context | Grant punya DocType sendiri. Grant Fund di Fund Stewardship adalah proyeksinya. | Lebih fleksibel, bisa ada multi-grant per fund, lifecycle grant independent | Lebih banyak DocType, relasi lebih kompleks |
| B — Sub-domain Fund | Grant = atribut Fund. Tidak ada DocType Grant terpisah. | Lebih sederhana, satu titik entry | Sulit jika satu donor punya multiple grant, sulit handle grant pipeline sebelum Fund dibuat |

**Referensi:**
- `fundara-domain-contexts/04-grant-context.md` — kedua opsi sudah dielaborasi
- `workflow.md` seksi 7 — Grant lifecycle
- `domain-brainstorm.md` — ER diagram awal mengasumsikan Opsi A

**Keputusan:** Opsi A — Grant adalah Bounded Context Mandiri. Grant memiliki DocType sendiri: Grant, Grant Agreement, Grant Budget Line, Grant Reporting Schedule.

**Alasan:** Satu donor bisa punya multiple grant. Grant pipeline perlu dikelola sebelum Fund terbentuk. Lifecycle grant (Pipeline → Awarded → Active → Closed) harus bisa berjalan independent dari Fund lifecycle.

**Implikasi:**
- `04-grant-context.md` dikerjakan sesuai Opsi A
- Relasi: satu Grant menghasilkan satu Grant Fund (di Fund Stewardship). Fund punya FK ke Grant.
- Transaksi di-link ke: Fund → Grant Budget Line (via Grant)

---

## D-02: Formula Fund Balance — Definisi "Committed"

**Status:** `DECIDED`

> **Pertanyaan disederhanakan:** Ketika staf mengajukan Cash Advance atau Purchase Request dan sudah disetujui — apakah budget langsung berkurang (reserved), atau baru berkurang ketika uang benar-benar dibayar?

**Keputusan:** Budget berkurang setelah dibayar. Tidak ada commitment layer.

Formula yang berlaku:

```
Available Budget = Approved Budget − Actual
```

di mana Actual = transaksi yang sudah menghasilkan payment (Cash Advance Paid, Purchase Invoice dibayar).

**Implikasi implementasi:**

| DocType | Pengaruh ke Budget |
|---|---|
| Purchase Request | Tidak mengurangi budget |
| Purchase Order | Tidak mengurangi budget |
| Cash Advance (Approved, belum Paid) | Tidak mengurangi budget |
| Cash Advance (Paid) | Mengurangi budget |
| Purchase Invoice (posted) | Mengurangi budget |
| Payment Entry | Mengurangi budget (jika linked ke invoice) |

**Catatan risiko:** Tanpa commitment layer, ada kemungkinan overspending jika beberapa request disetujui bersamaan dari budget yang sama sebelum ada yang dibayar. Sistem perlu menampilkan "Pending Payment" (approved tapi belum paid) sebagai informasi di dashboard — bukan sebagai pengurang budget, tapi sebagai peringatan — agar Finance Officer sadar ada antrean pembayaran.

---

## D-03: Target Versi ERPNext

**Status:** `DECIDED`

**Pertanyaan:**
ERPNext versi berapa yang menjadi target minimum Fundara?

**Opsi:**

| Versi | Status | Catatan |
|---|---|---|
| ERPNext v14 | Mendekati end-of-community-support | Masih banyak deployment aktif di Indonesia |
| ERPNext v15 | Stable, community support aktif | Bank reconciliation lebih baik, accounting dimensions lebih mature |
| ERPNext v16 | Stable, terbaru | API terbaru, tapi ekosistem plugin belum semua update |

**Keputusan:** ERPNext v16 (versi terbaru stabil).

**Alasan:** Menggunakan versi terbaru menghindari technical debt sejak awal. Bank reconciliation dan accounting dimensions di v16 lebih mature.

**Implikasi:**
- Semua DocType design dan API mengacu dokumentasi v16
- Minimum Python 3.11+, Node 18+
- Pastikan library dependencies Fundara kompatibel dengan Frappe v16

---

## D-04: Multi-currency — Masuk MVP atau Tidak?

**Status:** `DECIDED`

**Pertanyaan:**
Apakah Fundara mendukung transaksi multi-currency (misalnya grant dalam USD, pengeluaran dalam IDR) di MVP, atau hanya single-currency?

**Konteks:**
Banyak NGO Indonesia menerima grant dalam USD atau EUR dan melaporkannya ke donor dalam mata uang grant, sementara operasional dalam IDR. Ini membutuhkan:
- exchange rate management per transaksi
- unrealized gain/loss calculation
- laporan donor dalam mata uang grant
- laporan internal dalam IDR

**Opsi:**

| Opsi | Deskripsi |
|---|---|
| A — Single currency di MVP | Semua transaksi dalam IDR. Multi-currency ditambahkan di v0.5 atau v1.0. |
| B — Multi-currency di MVP | Mendukung USD, EUR, IDR dari awal. Kompleksitas tinggi tapi menghindari refactor besar. |
| C — Partial multi-currency | Fund master bisa dalam berbagai currency, tapi konversi ke IDR dilakukan manual saat entry. Tidak ada auto exchange rate. |

**Keputusan:** Opsi B — Multi-currency masuk MVP.

**Alasan:** NGO Indonesia yang menerima grant dari donor internasional (UNICEF, EU, USAID) membutuhkan ini dari hari pertama. Menambahkan multi-currency setelah MVP akan membutuhkan refactor besar pada journal entry dan laporan donor.

**Implikasi:**
- Aktifkan ERPNext Multi-Currency feature dari awal
- Setiap transaksi harus menyimpan: currency, exchange rate, amount in transaction currency, amount in base currency (IDR)
- Fund master menyimpan currency fund
- Laporan donor dapat ditarik dalam currency fund, laporan internal dalam IDR
- Perlu spec tambahan: bagaimana exchange rate ditentukan (manual input per transaksi, atau ambil dari ERPNext Currency Exchange master?)
- Unrealized gain/loss dicatat sebagai journal entry periodik (bukan per transaksi)

---

## D-05: Source of Truth untuk Accounting Specification

**Status:** `DECIDED`

**Pertanyaan:**
Antara `docs/accounting/` (12 file terpisah per topik) dan `fundara-domain-contexts/06-financial-accountability-context.md` (satu file komprehensif), mana yang menjadi canonical source untuk spec accounting?

**Masalah saat ini:**
Kedua sumber menduplikasi konten yang sama (advance lifecycle, bank reconciliation, fixed asset, dll.) dan sudah diverge — terbukti dari perbedaan lifecycle status advance yang ditemukan dalam review.

**Opsi:**

| Opsi | Deskripsi | Implikasi |
|---|---|---|
| A — `docs/accounting/` adalah canonical | `06-financial-accountability-context.md` hanya ringkasan + link | File `docs/accounting/` harus lengkap dan up-to-date. Domain context jadi lebih ringkas. |
| B — `06-financial-accountability-context.md` adalah canonical | File `docs/accounting/` diarsip atau dihapus | Satu file besar, lebih mudah dijaga konsistensinya. |
| C — Pisahkan by concern | Domain context = konseptual/domain logic. `docs/accounting/` = implementasi detail dan edge case. | Keduanya dipertahankan tapi dengan scope berbeda dan tidak duplikasi. |

**Keputusan:** Opsi C — pisahkan by concern.

**Alasan:** Keduanya memiliki nilai yang berbeda. Domain context menjelaskan *mengapa* dan *apa* (konseptual). `docs/accounting/` menjelaskan *bagaimana* (implementasi detail, edge case, aturan akuntansi). Tidak perlu memilih salah satu — cukup bedakan scope-nya dengan jelas.

**Aturan yang berlaku mulai sekarang:**
- `fundara-domain-contexts/06-financial-accountability-context.md` = **domain logic** — entitas, relasi, lifecycle status, aturan bisnis
- `docs/accounting/*.md` = **implementation spec** — format field, edge case, formula, aturan akuntansi detail, contoh jurnal
- Jika ada konflik antara keduanya, **domain context adalah yang benar** untuk lifecycle dan aturan bisnis; `docs/accounting/` adalah yang benar untuk detail akuntansi
- Setiap `docs/accounting/` file harus memiliki referensi ke domain context terkait

**Implikasi:** Perlu audit `docs/accounting/` untuk memastikan tidak ada lifecycle status yang berbeda dari domain context. (Sudah dimulai: advance lifecycle sudah diselaraskan.)

---

## D-06: Multi-tenancy Strategy untuk v1.0

**Status:** `DEFERRED — Diputuskan sebelum v1.0 release`

**Pertanyaan:**
Bagaimana Fundara di-deploy untuk multiple organisasi?

**Opsi:**

| Opsi | Deskripsi | Pro | Kontra |
|---|---|---|---|
| A — One site per org | Setiap organisasi punya Frappe site sendiri (bench multi-site) | Isolasi data penuh, kustomisasi per org bebas, sesuai regulasi data | Overhead ops tinggi jika ratusan org, update per site |
| B — Shared site, single company | Satu Frappe site, multiple Company | Lebih mudah di-maintain | Company isolation di ERPNext tidak sempurna, risiko data leak |
| C — Shared site, multi-tenant custom | Satu Frappe site dengan tenant isolation custom | Efisien secara infrastruktur | Sangat kompleks, butuh custom permission logic menyeluruh |

**Rekomendasi:** Opsi A untuk v1.0 (one site per org). Lebih aman, lebih mudah diimplementasikan dengan Frappe bench, dan sesuai ekspektasi NGO yang sensitif terhadap kerahasiaan data.

**Keputusan:** _(belum diisi)_

**Alasan penundaan (konteks penting):**

Multi-tenancy ditunda bukan hanya karena kompleksitas teknis deployment, tetapi karena alasan domain yang lebih mendasar:

> Setiap organisasi memiliki SOP tersendiri yang bisa berbeda dari workflow default Fundara. Workflow yang sudah didefinisikan di `docs/spec/workflows.md` adalah **template default** — bukan aturan baku yang bisa diterapkan secara menyeluruh ke semua organisasi.

Implikasi desain yang harus dijaga sejak MVP:

1. **Workflow harus modular dan dapat dikonfigurasi per organisasi** — approval threshold, jumlah approval level, dan urutan state transition tidak boleh di-hardcode. Semua harus bisa diubah via Frappe Workflow configuration tanpa ubah kode.

2. **SOP organisasi ≠ workflow default Fundara** — ketika sebuah organisasi onboarding, mereka membawa SOP mereka sendiri. Fundara menyediakan template sebagai titik awal, bukan keharusan.

3. **One site per org (Opsi A) mendukung ini secara alami** — setiap site bisa punya konfigurasi workflow berbeda tanpa mempengaruhi organisasi lain.

4. **Workflow di `docs/spec/workflows.md` berlabel "Template Default"** — developer tidak boleh mengimplementasikannya sebagai fixed logic. Implementasikan sebagai Frappe Workflow fixture yang bisa di-override per site.

**Implikasi untuk developer:**
- Jangan hardcode approval logic di server script — gunakan Frappe Workflow engine
- Semua threshold (nilai approval, jumlah approver) harus ada di konfigurasi, bukan di kode
- Buat setiap workflow bisa diaktifkan/dinonaktifkan per site tanpa ubah kode aplikasi

**Implikasi untuk MVP:**
- Workflow fixture dibuat sebagai default yang bisa di-import saat onboarding organisasi baru
- Perlu ada "Fundara Setup Wizard" atau onboarding checklist yang memandu organisasi mengkonfigurasi workflow sesuai SOP mereka

---

## D-07: Scope Frontend — FE-04 Print Formats dan FE-05 Role Dashboards di MVP atau Post-MVP?

**Status:** `OPEN — Keputusan diperlukan dari PM + PO sebelum Sprint 4`

**Pertanyaan:**
Apakah 7 print format Jinja2 (FE-04, ~14 hari) dan 7 role-specific dashboard (FE-05, ~14 hari) masuk ke MVP, atau sebagian/seluruhnya dipindahkan ke v0.2?

**Konteks:**
Berdasarkan audit `docs/pm/complexity.md` — Frontend & UX Track dan `docs/spec/frontend/`:
- **FE-04** (7 print format Jinja2): ~14 hari. Ini adalah substantial Jinja2 development — conditional watermark, multi-currency block, terbilang, QR code, signature boxes — bukan UI polish.
- **FE-05** (7 role-specific dashboard): ~14 hari. FG-15 memperkirakan "1 Basic Dashboard = 6 hari", namun `docs/spec/frontend/dashboard-spec.md` mendefinisikan 7 dashboard terpisah per role (Executive Director, Finance Manager, Program Manager, dst.), masing-masing dengan 10+ number cards, 6+ charts, alert banners, dan custom multi-DocType server scripts.

Total FE-04 + FE-05: **~28 hari** yang tidak ada dalam estimasi 145 dev-days asli.

**Implikasi UAT:** UAT Milestone 1 (Sprint 5 exit) tidak membutuhkan print format atau role dashboard. UAT Milestone 2 (Sprint 10 exit) dapat berjalan tanpa print format lengkap — staf NGO dapat menyetujui fungsi bisnis inti terlebih dahulu, dan print format dirilis di v0.2.

**Opsi:**

| Opsi | Deskripsi | Tambahan Dev-Days ke Baseline | Dampak pada Timeline |
|---|---|---|---|
| **A — Semua masuk MVP** | FE-04 full (7 format) + FE-05 full (7 dashboard) masuk Sprint 5–10 | +28 hari | Perpanjang ~2 sprint atau butuh Frontend Developer tambahan mulai Sprint 5 |
| **B — Sebagian MVP** | 2 print format paling kritis (Bukti Pembayaran Uang Muka + Ringkasan Pertanggungjawaban) + FG-15 basic dashboard masuk MVP; sisanya post-MVP | +8 hari | Masih dalam 10 sprint dengan prioritas ulang Sprint 6–7 |
| **C — FE-04 post-MVP, FE-05 dikurangi** | FE-04 semua print format → v0.2. FE-05: FG-15 Basic Dashboard (6 hari, sudah ada di Sprint 9) masuk MVP; 7 role-specific dashboard → v0.2 | +0 hari tambahan | Timeline 10 sprint tidak berubah |

**Rekomendasi: Opsi C.**

**Alasan rekomendasi:**
1. Print format tidak memblokir UAT atau penggunaan harian — staf bisa menggunakan print browser standard Frappe sementara format NGO-branded dibuat di v0.2.
2. Dashboard multi-DocType dengan 10+ number cards membutuhkan data historis (minimum 2–3 sprint operasional) agar bermakna — lebih baik dibangun setelah sistem dipakai, sehingga user bisa memberi feedback tentang metric mana yang paling dibutuhkan.
3. FE-01 (status colors), FE-02 (validation messages), FE-03 (notifications kritis), FE-06 (Bahasa Indonesia labels) tetap masuk MVP dalam semua opsi — ini tidak dapat dinegosiasikan.
4. Opsi C mempertahankan 10-sprint timeline tanpa mengorbankan fungsi bisnis inti dan tanpa menambah developer.

**Keputusan:** _(belum diisi — PM + PO harus memutuskan dan mengisi bagian ini)_

**Implikasi setelah keputusan:**
- **Opsi A:** Revisi sprint breakdown secara eksplisit — alokasikan slot FE-04 (Sprint 5, 6–7, 8, 9) dan FE-05 (Sprint 9–10) ke Dev 2. Evaluasi apakah perlu Frontend Developer tambahan.
- **Opsi B:** Tentukan 2 print format mana yang masuk MVP dan buat tiket spesifik. Cek apakah dapat diselipkan di Sprint 6–7 tanpa menggeser FG-09.
- **Opsi C:** Tambahkan FE-04 dan FE-05 (role-specific) ke Post-MVP Feature Groups table di `docs/pm/complexity.md`. FG-15 "Basic Dashboard" tetap sebagai delivered MVP item.

**Deadline keputusan: Sebelum Sprint 4 dimulai (Minggu 7).** Setelah Sprint 4 berjalan, TL tidak dapat menyesuaikan sprint plan tanpa disrupting delivery.

---

## Ringkasan Status

| ID | Topik | Status | Keputusan Singkat |
|---|---|---|---|
| D-01 | Grant — bounded context atau sub-domain? | `DECIDED` | Bounded context mandiri (Opsi A) |
| D-02 | Formula Committed | `DECIDED` | Available = Approved Budget − Actual (paid only) |
| D-03 | Versi ERPNext | `DECIDED` | ERPNext v16 |
| D-04 | Multi-currency di MVP? | `DECIDED` | Ya, masuk MVP (Opsi B) |
| D-05 | Source of truth accounting spec | `DECIDED` | Pisahkan by concern (Opsi C) |
| D-06 | Multi-tenancy strategy | `DEFERRED` | One site per org (Opsi A direkomendasikan). Workflow = template default, bukan aturan baku — setiap org punya SOP sendiri |
| D-07 | Frontend MVP scope — FE-04 print formats + FE-05 dashboards | `OPEN` | Rekomendasi Opsi C (post-MVP). Keputusan PM + PO diperlukan sebelum Sprint 4 |

---

## Cara Menggunakan Dokumen Ini

1. Setiap keputusan yang masih `OPEN` adalah blocker untuk area terkait
2. Setelah keputusan dibuat, update status ke `DECIDED`, isi keputusan, alasan, dan implikasi
3. Update dokumen teknis terkait agar konsisten dengan keputusan
4. Catat tanggal dan siapa yang membuat keputusan untuk keperluan audit trail desain
