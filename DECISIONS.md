# Keputusan Desain Fundara

Dokumen ini mencatat keputusan arsitektur dan desain yang harus dibuat **sebelum coding dimulai**. Setiap keputusan yang belum diisi akan memblokir implementasi area terkait.

Format setiap entry:

- **Status:** `OPEN` (belum diputuskan) | `DECIDED` (sudah diputuskan)
- **Keputusan:** pilihan yang dipilih
- **Alasan:** mengapa pilihan ini dipilih
- **Implikasi:** apa yang berubah setelah keputusan ini

---

## D-01: Grant — Bounded Context Mandiri atau Sub-domain Fund?

**Status:** `OPEN`

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

**Keputusan:** _(belum diisi)_

**Alasan:** _(belum diisi)_

**Implikasi:** Menentukan schema database, jumlah DocType, dan cara transaksi di-link ke grant.

---

## D-02: Formula Fund Balance — Definisi "Committed"

**Status:** `OPEN`

**Pertanyaan:**
Apa saja yang masuk ke komponen "Committed" dalam formula:
```
Available Budget = Approved Budget − Committed − Actual
```

**Opsi yang perlu diputuskan:**

| DocType | Masuk Committed? | Pada Status Apa? | Kapan Dilepas? |
|---|---|---|---|
| Purchase Request | Ya / Tidak | Approved? Submitted? | Saat PO dibuat? |
| Purchase Order | Ya / Tidak | Submitted? Approved? | Saat Invoice diposting? |
| Cash Advance | Ya / Tidak | Approved? Paid? | Saat Liquidated? Closed? |
| Travel Request | Ya / Tidak | Approved? | Saat Advance dibuat? |
| Contract | Ya / Tidak | Signed? | Saat Invoice diposting? |

**Referensi:**
- `README.md` seksi 10 — menyebut formula tapi tanpa definisi teknis Committed
- `fundara-domain-contexts/03-fund-stewardship-context.md` seksi 4.7 — Fund Balance components
- `workflow.md` — approval matrix

**Keputusan:** _(belum diisi — isi tabel di atas untuk setiap DocType)_

**Implikasi:** Menentukan kapan ERPNext Budget module di-hook, dan apakah perlu custom script untuk commitment tracking.

---

## D-03: Target Versi ERPNext

**Status:** `OPEN`

**Pertanyaan:**
ERPNext versi berapa yang menjadi target minimum Fundara?

**Opsi:**

| Versi | Status | Catatan |
|---|---|---|
| ERPNext v14 | Mendekati end-of-community-support | Masih banyak deployment aktif di Indonesia |
| ERPNext v15 | Stable, community support aktif | Bank reconciliation lebih baik, accounting dimensions lebih mature |
| ERPNext v16 | Stable, terbaru | API terbaru, tapi ekosistem plugin belum semua update |

**Keputusan:** _(belum diisi)_

**Alasan:** _(belum diisi)_

**Implikasi:** Menentukan cara konfigurasi accounting dimensions, fitur bank reconciliation yang tersedia, dan API yang digunakan untuk custom DocType.

---

## D-04: Multi-currency — Masuk MVP atau Tidak?

**Status:** `OPEN`

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

**Keputusan:** _(belum diisi)_

**Implikasi:** Menentukan desain journal entry, laporan donor, dan apakah ERPNext multi-currency fitur diaktifkan atau tidak.

---

## D-05: Source of Truth untuk Accounting Specification

**Status:** `OPEN`

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

**Rekomendasi:** Opsi C — pisahkan dengan jelas antara domain logic (di domain context) dan implementation spec (di docs/accounting/).

**Keputusan:** _(belum diisi)_

**Implikasi:** Developer perlu tahu "baca yang mana" untuk setiap pertanyaan. Harus ada README yang menjelaskan struktur dokumen.

---

## D-06: Multi-tenancy Strategy untuk v1.0

**Status:** `OPEN`

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

**Implikasi:** Menentukan cara deployment script, cara update, dan apakah SaaS model yang shared-infrastructure bisa dikejar di versi selanjutnya.

---

## Keputusan yang Sudah Dibuat

_(kosong untuk saat ini — isi setelah diskusi tim)_

| ID | Keputusan | Tanggal | Diputuskan oleh |
|---|---|---|---|
| — | — | — | — |

---

## Cara Menggunakan Dokumen Ini

1. Setiap keputusan yang masih `OPEN` adalah blocker untuk area terkait
2. Setelah keputusan dibuat, update status ke `DECIDED`, isi keputusan, alasan, dan implikasi
3. Update dokumen teknis terkait agar konsisten dengan keputusan
4. Catat tanggal dan siapa yang membuat keputusan untuk keperluan audit trail desain
