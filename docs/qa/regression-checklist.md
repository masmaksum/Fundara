# Regression Checklist — Fundara

**Proyek:** Fundara — Fund-centric ERP untuk Organisasi Nirlaba  
**Platform:** ERPNext v16 / Frappe Framework  
**Versi:** 1.0  
**Tanggal:** 2026-06-19  
**Pemilik dokumen:** QA Engineer  
**Ditujukan untuk:** QA Engineer yang menjalankan regression setiap sprint

---

## Prinsip Checklist Ini

Regression checklist ini harus bisa diselesaikan dalam **2–3 jam**, bukan 2 hari. Fokusnya adalah happy path dari fitur-fitur yang sudah delivered di sprint sebelumnya. Tujuannya satu: memastikan bahwa perubahan di sprint ini tidak merusak apa yang sudah jalan.

Edge case, negative test, dan skenario kompleks ada di `docs/spec/test-scenarios.md` — bukan di sini.

---

## Bagian 1: Cara Menggunakan Checklist Ini

### Kapan Dijalankan

Jalankan checklist ini di staging **setelah deploy sprint terbaru**, sebelum sprint review dilakukan.

### Simbol Status

| Simbol | Artinya |
|---|---|
| ✅ | Pass — perilaku sesuai expected |
| ❌ | Fail — catat detail di kolom Catatan, buka bug report sebelum lanjut |
| ⏭ | Skip — fitur belum ada di sprint ini (bukan bug, catat alasan skip) |

### Aturan Penting

- Jika ada ❌ pada item berlabel **[WAJIB]**: **stop dan buka bug report sebelum lanjut ke item berikutnya**
- Jika ada ❌ pada item biasa: catat, lanjutkan, laporkan di akhir
- Gunakan akun demo data standar kecuali disebutkan berbeda
- Jalankan dengan browser dalam mode incognito untuk menghindari cache

---

## Bagian 2: Setup Pra-Regression

Langkah wajib sebelum mulai. Jika salah satu gagal, jangan lanjutkan — perbaiki dulu.

| # | Langkah | Expected | Status | Catatan |
|---|---|---|---|---|
| S-01 | Login sebagai Administrator ke staging | Login berhasil, dashboard terbuka | | |
| S-02 | Cek `bench doctor` — semua worker dan background job running | Output: "No issues" atau semua service running | | |
| S-03 | Reset demo data ke state awal (bench restore atau fresh fixture import) | Demo data ter-load, tidak ada data sisa dari test sebelumnya | | |
| S-04 | Verifikasi akun demo tersedia: Finance Manager, Finance Officer, Field Staff, Executive Viewer | Login ke-4 akun berhasil (cek satu per satu) | | |
| S-05 | Verifikasi setidaknya 1 Fund aktif ada di demo data | Fund list menampilkan minimal 1 Fund dengan status Active | | |
| S-06 | Verifikasi Currency Exchange: rate USD/IDR hari ini ada | Currency Exchange master punya entry untuk hari ini | | |

---

## Bagian 3: Checklist per Area — Happy Path Only

### 3A: Core System — Login dan Permission Dasar

| # | Langkah | Expected | Status | Catatan |
|---|---|---|---|---|
| A-01 **[WAJIB]** | Login sebagai Finance Manager | Login berhasil, dashboard Finance Manager tampil | | |
| A-02 | Login sebagai Field Staff | Login berhasil, menu yang tampil terbatas sesuai role (tidak ada akses ke modul keuangan admin) | | |
| A-03 | Login sebagai Executive Viewer | Login berhasil, dashboard read-only tampil | | |
| A-04 | Logout dari semua role | Session berakhir, redirect ke halaman login | | |
| A-05 **[WAJIB]** | Login sebagai Field Staff, coba buka Fund List (admin-only) | Akses DIBLOKIR — permission error atau halaman tidak tampil | | |
| A-06 | Login sebagai Finance Officer, coba buka Role Manager | Akses DIBLOKIR | | |

---

### 3B: Fund Management

| # | Langkah | Expected | Status | Catatan |
|---|---|---|---|---|
| B-01 | Login sebagai Finance Manager. Buat Fund baru: tipe Grant Fund, currency USD, isi semua field wajib | Fund tersimpan dengan status Draft | | |
| B-02 | Lanjutkan: activate Fund tersebut (ubah status ke Active) | Status berubah ke Active. Fund muncul di dropdown transaksi | | |
| B-03 | Buka Fund Balance panel untuk Fund yang baru diaktifkan | Panel tampil tanpa error. Angka balance terlihat (0 jika baru, atau sesuai demo data) | | |
| B-04 | Verifikasi Fund muncul di dropdown saat membuat Cash Advance | Fund aktif tersedia di field pemilihan Fund | | |
| B-05 | Coba buat Fund dengan End Date lebih awal dari Start Date | Sistem MEMBLOKIR dengan pesan error yang jelas | | |

---

### 3C: Cash Advance — Alur Penuh [WAJIB setiap sprint]

Ini adalah tes regression paling penting. Jalankan lengkap tanpa skip.

| # | Langkah | Expected | Status | Catatan |
|---|---|---|---|---|
| C-01 **[WAJIB]** | Login sebagai Field Staff. Buat Cash Advance baru: Fund = demo fund aktif, jumlah = IDR 500.000, tujuan = "Test regression", isi activity | Tersimpan dengan status Draft | | |
| C-02 **[WAJIB]** | Submit Cash Advance | Status berubah ke Submitted. Notifikasi terkirim ke Finance | | |
| C-03 | Login sebagai Finance Officer. Buka Cash Advance yang baru disubmit. Klik "Begin Review" | Status berubah ke Under Review | | |
| C-04 **[WAJIB]** | Cek Budget vs Actual Dashboard sebelum approve: status advance = Under Review | Available budget TIDAK berubah — advance belum mengurangi budget (D-02 compliance) | | |
| C-05 **[WAJIB]** | Finance Officer menyetujui (Approve) Cash Advance | Status berubah ke Approved. Tidak ada GL Entry yang dibuat | | |
| C-06 **[WAJIB]** | Cek Budget vs Actual Dashboard setelah approve: status = Approved | Available budget MASIH TIDAK berubah. Advance muncul di panel "Pending Payment" saja (D-02) | | |
| C-07 **[WAJIB]** | Finance Officer mencatat pembayaran (Mark as Paid): isi payment reference | Status berubah ke Paid. GL Entry dibuat: Dr Uang Muka / Cr Bank | | |
| C-08 **[WAJIB]** | Cek Budget vs Actual Dashboard setelah Paid | Available budget BERKURANG sesuai jumlah advance (D-02 — budget baru berkurang di sini) | | |
| C-09 **[WAJIB]** | Login sebagai Field Staff. Buka advance yang statusnya Paid. Submit Liquidasi: actual spend = IDR 450.000, sisa IDR 50.000 | Liquidasi tersimpan, status advance berubah ke Liquidated | | |
| C-10 **[WAJIB]** | Login sebagai Finance Officer. Review dan setujui Liquidasi | Status advance berubah ke Closed (setelah sisa dikembalikan). GL Entry liquidasi dibuat: Dr Beban / Cr Uang Muka | | |
| C-11 | Cek Fund balance setelah advance Closed | Fund balance berkurang sesuai actual spend (IDR 450.000), BUKAN jumlah advance (IDR 500.000) | | |
| C-12 | Cek Advance Aging Report | Advance yang baru saja Closed sudah tidak muncul sebagai outstanding | | |

---

### 3D: Procurement

| # | Langkah | Expected | Status | Catatan |
|---|---|---|---|---|
| D-01 | Login sebagai Field Staff / Project Officer. Buat Purchase Request: item, jumlah estimasi, Fund, budget line | PR tersimpan dengan status Draft | | |
| D-02 | Submit PR | Status berubah ke Submitted | | |
| D-03 | Login sebagai Project Manager / Finance Officer. Approve PR | Status berubah ke Approved | | |
| D-04 | Login sebagai Finance Officer / Procurement Officer. Buat Purchase Order dari PR yang Approved | PO tersimpan, status PR berubah ke Ordered, PO terhubung ke PR | | |
| D-05 | Cek Available Budget setelah PO dibuat (sebelum ada invoice dibayar) | Available budget TIDAK berubah — PO belum mengurangi budget (D-02) | | |

---

### 3E: Donor dan Fundraising Campaign

| # | Langkah | Expected | Status | Catatan |
|---|---|---|---|---|
| E-01 | Login sebagai Finance Manager. Buat Donor baru (individual atau institutional) | Donor tersimpan | | |
| E-02 | Buat Fundraising Campaign baru: isi nama, target amount, tanggal | Campaign tersimpan dengan status Draft | | |
| E-03 | Submit Campaign untuk review | Status berubah ke Under Review | | |

---

### 3F: Grant Management (jalankan hanya jika FG-05 sudah delivered)

| # | Langkah | Expected | Status | Catatan |
|---|---|---|---|---|
| F-01 | Login sebagai Finance Manager / Donor Relationship Manager. Buat Grant baru | Grant tersimpan dengan status Pipeline | | |
| F-02 | Tambahkan Grant Budget Line ke Grant | Budget line tersimpan, total amount terhitung | | |
| F-03 | Transisi Grant ke status Submitted (mark as submitted to donor) | Status berubah ke Submitted | | |

---

### 3G: Reporting

| # | Langkah | Expected | Status | Catatan |
|---|---|---|---|---|
| G-01 **[WAJIB]** | Login sebagai Finance Manager. Buka Fund Utilization Report | Report terbuka tanpa error. Angka tampil (tidak blank, tidak traceback) | | |
| G-02 **[WAJIB]** | Buka Budget vs Actual Report | Report terbuka tanpa error | | |
| G-03 | Buka Advance Aging Report | Report terbuka tanpa error. Advance yang outstanding tampil | | |
| G-04 | Buka Donor Report | Report terbuka tanpa error | | |
| G-05 | Export salah satu report ke XLSX | File XLSX berhasil didownload dan bisa dibuka | | |

---

## Bagian 4: Multi-Currency Sanity Check [WAJIB setiap sprint]

Test cepat untuk memvalidasi Decision D-04 (multi-currency) tidak rusak.

| # | Langkah | Expected | Status | Catatan |
|---|---|---|---|---|
| M-01 **[WAJIB]** | Login sebagai Finance Officer. Buat Cash Advance dengan currency USD, amount = 100, exchange_rate = 15.800 | `amount_base` (IDR equivalent) = 1.580.000. Kolom base amount tampil otomatis | | |
| M-02 **[WAJIB]** | Ubah exchange_rate di advance tadi menjadi 16.000 | `amount_base` auto-update menjadi 1.600.000 (tanpa perlu simpan manual) | | |
| M-03 | Buka Fund Balance panel untuk Fund ber-currency USD | Balance tampil dalam dua baris: USD dan IDR equivalent | | |
| M-04 | Buat Cash Advance IDR terhadap Fund USD | System menghitung USD equivalent secara otomatis (`amount_in_fund_currency`) | | |

---

## Bagian 5: Fixed Regression Tests

Item berikut ditambahkan karena pernah menjadi bug regression di sprint sebelumnya. Jalankan setiap sprint.

| # | Bug Asal | Langkah | Expected | Status | Catatan |
|---|---|---|---|---|---|
| R-01 | *(tambahkan di sini setelah bug pertama ditemukan dan diperbaiki)* | | | | |

*Format untuk menambahkan: `[kode bug] | Deskripsi singkat langkah | Apa yang harus terjadi jika fix-nya tidak rusak`*

---

## Bagian 6: Regression Report Template

Isi dan simpan setelah setiap regression selesai. File: `docs/qa/regression-report-sprint-[N].md`

```
REGRESSION REPORT — SPRINT [N]
================================
Tanggal: ___________________
QA: ________________________
Environment: staging / [URL staging]
ERPNext version: ___________
Fundara app version / git hash: ___________

RINGKASAN
---------
Total checklist item dijalankan: ___
Pass (✅): ___
Fail (❌): ___
Skip / fitur belum ada (⏭): ___

D-02 COMPLIANCE CHECK (budget formula)
---------------------------------------
[ ] Pass — available budget tidak berubah saat advance Approved
[ ] Pass — available budget berkurang saat advance Paid
[ ] Pass — budget berkurang sesuai actual spend (bukan advance amount) saat Closed
[ ] FAIL — deskripsi: ___________________

MULTI-CURRENCY CHECK (D-04)
-----------------------------
[ ] Pass — amount_base auto-calculate benar
[ ] Pass — exchange rate update memicu recalculate
[ ] FAIL — deskripsi: ___________________

BUG DITEMUKAN
--------------
(kosong jika tidak ada)
- [Critical] [FUND-xxx] Deskripsi singkat — link ke issue
- [High] [CA-xxx] Deskripsi singkat — link ke issue
- [Medium] [RP-xxx] Deskripsi singkat — link ke issue

REKOMENDASI
-----------
[ ] ✅ PASS — lanjut ke sprint review, tidak ada blocking issue
[ ] ❌ FAIL — hold sprint review, fix bug berikut dulu: [list bug Critical/High]

Catatan tambahan:
___________________
```

---

## Bagian 7: Kapan Checklist Ini Diperbarui

Tambahkan baris baru ke checklist ini setiap kali salah satu kondisi berikut terjadi:

| Kondisi | Apa yang ditambahkan | Di bagian mana |
|---|---|---|
| Feature group baru di-deliver (sesuai urutan sprint di `complexity.md`) | Happy path dari feature group tersebut | Section baru (3H, 3I, dst) |
| Bug regression ditemukan dan diperbaiki | Test untuk memastikan bug tidak kembali | Bagian 5: Fixed Regression Tests |
| Perilaku berubah karena keputusan desain baru (entry baru di DECISIONS.md) | Update kolom Expected di baris terkait | Item yang relevan |

### Mapping Feature Group ke Section Checklist

| Sprint | Feature Group | Section yang Ditambahkan |
|---|---|---|
| Sprint 1 | FG-01 Organization, FG-02 Donor | 3A (sudah ada) |
| Sprint 2 | FG-03 Fund Master | 3B (sudah ada) |
| Sprint 3–4 | FG-04 Program/Project/Activity, FG-06 Budget | 3D extended, tambah 3H: Budget |
| Sprint 5 | FG-07 Cash Receipt/Disbursement, FG-08 Campaign, FG-14 General Journal | 3E extended, tambah 3I: Cash Receipt/Disbursement |
| Sprint 6–7 | FG-09 Advance & Liquidation, FG-11 Fixed Asset | 3C (sudah ada, extended), tambah 3J: Fixed Asset |
| Sprint 8 | FG-12 Bank Reconciliation | Tambah 3K: Bank Reconciliation |
| Sprint 9 | FG-15 Reporting & Dashboard | 3G extended |

---

*Dokumen ini bersifat living document. Update kolom Expected jika ada perubahan perilaku yang sudah disepakati dan terdokumentasi di DECISIONS.md. Jangan update Expected secara unilateral — harus ada keputusan dari TL terlebih dahulu.*
