# Grant Context

## Status Dokumen

> **DRAFT — Keputusan Desain Diperlukan**
>
> File ini adalah stub untuk Grant Context. Sebelum dilengkapi, satu keputusan arsitektur fundamental harus dibuat:
>
> **Apakah Grant adalah Bounded Context mandiri atau sub-domain dari Fund Stewardship Context?**
>
> - **Opsi A — Bounded Context Mandiri:** Grant memiliki DocType sendiri (Grant, Grant Agreement, Grant Budget, Grant Budget Line) yang berdiri terpisah dari Fund. Grant Fund di Fund Stewardship adalah proyeksinya.
> - **Opsi B — Sub-domain Fund Stewardship:** Grant diabsorb ke dalam Fund master sebagai set atribut tambahan pada Grant Fund type. Tidak ada DocType Grant yang berdiri sendiri.
>
> Keputusan ini didokumentasikan di `DECISIONS.md`. Setelah keputusan dibuat, isi dokumen ini harus dilengkapi sesuai pilihan.

---

## 1. Ringkasan

**Grant Context** mengelola siklus hidup dana hibah dari donor institusional — mulai dari pipeline grant, negosiasi perjanjian, setup budget line donor, implementasi, compliance monitoring, donor reporting, hingga closeout.

Grant adalah jenis Fund yang paling kompleks dalam Fundara karena membawa kewajiban eksternal: ada donor yang memonitor, ada budget line yang sudah disepakati, ada aturan eligible/ineligible cost, ada jadwal pelaporan, dan ada audit requirement spesifik.

---

## 2. Tujuan Context

1. Mengelola pipeline grant dari prospek hingga award.
2. Mencatat grant agreement dan syarat-syaratnya.
3. Mengelola budget line donor dan revision anggaran.
4. Mengontrol kepatuhan eligible cost per donor rule.
5. Mengelola jadwal pelaporan donor.
6. Mendukung grant closeout yang terstruktur.

---

## 3. Lifecycle Grant

```text
Pipeline → Submitted → Awarded → Agreement Review → Active → Extended → Suspended → Closing → Closed
                                                                                         ↓
                                                                               Rejected / Cancelled
```

| Status | Keterangan |
|---|---|
| Pipeline | Peluang grant teridentifikasi, sedang dijajaki |
| Submitted | Proposal/aplikasi sudah disubmit ke donor |
| Awarded | Grant dinyatakan diterima, belum ada agreement final |
| Agreement Review | Perjanjian grant sedang direview dan dinegosiasikan |
| Active | Grant sedang berjalan, pengeluaran dapat dibebankan |
| Extended | Periode grant diperpanjang resmi oleh donor |
| Suspended | Grant ditangguhkan sementara (issue compliance atau donor decision) |
| Closing | Grant dalam periode closeout, pengeluaran dibatasi |
| Closed | Grant selesai, laporan final dan audit selesai |
| Rejected | Proposal ditolak donor |
| Cancelled | Grant dibatalkan sebelum atau selama implementasi |

---

## 4. Entitas Utama (Opsi A — Bounded Context Mandiri)

### 4.1 Grant

Master data grant dari donor institusional.

Atribut konseptual:

- grant name
- grant code
- donor
- grant type (bilateral, multilateral, foundation, government, corporate)
- total amount
- currency
- start date
- end date
- grant period (in months)
- program area
- implementing unit
- grant manager
- status

### 4.2 Grant Agreement

Dokumen perjanjian formal antara organisasi dan donor.

Atribut konseptual:

- agreement number
- grant reference
- signing date
- effective date
- end date
- total amount contracted
- eligible cost categories
- ineligible cost categories
- procurement rules
- reporting schedule
- audit requirement
- branding requirement
- amendment history

### 4.3 Grant Budget Line (Donor Budget)

Kategori anggaran yang didefinisikan donor dalam grant agreement.

Atribut konseptual:

- budget line code
- budget line name (sesuai format donor)
- grant
- amount approved
- amount revised
- currency
- allowed cost types
- note / restriction per line

> **Perbedaan penting:** Grant Budget Line adalah kategori anggaran versi donor. Ini berbeda dari Internal Budget Line (kategori anggaran internal organisasi). Keduanya harus bisa di-mapping untuk keperluan pelaporan internal vs donor. Satu internal budget line dapat di-map ke beberapa donor budget line, atau sebaliknya.

### 4.4 Grant Reporting Schedule

Jadwal pelaporan yang harus dipenuhi kepada donor.

Atribut konseptual:

- grant
- report type (financial, narrative, combined, audit)
- report period (monthly, quarterly, semi-annual, annual, final)
- due date
- submitted date
- status
- recipient (donor contact)

### 4.5 Grant Closeout Checklist

Daftar item yang harus diselesaikan sebelum grant dinyatakan closed.

Contoh item:

- semua advance liquidated
- semua procurement diselesaikan
- aset yang dibeli tercatat dan diputuskan statusnya
- laporan final disubmit
- audit final selesai (jika diperlukan)
- dana sisa dikembalikan atau dialihkan sesuai ketentuan donor
- dokumentasi arsip lengkap

---

## 5. Entitas Utama (Opsi B — Sub-domain Fund Stewardship)

Jika Grant diabsorb ke Fund, maka atribut Grant ditambahkan sebagai section khusus di Fund master ketika Fund Type = Grant Fund:

- donor (link ke Donor master)
- agreement number
- total contracted amount
- reporting schedule (child table)
- eligible cost rules (link ke Restriction)
- grant budget lines (child table)
- closeout checklist (child table)

Tidak ada DocType Grant yang berdiri sendiri.

---

## 6. Aturan Bisnis

1. Setiap Grant Fund harus memiliki donor yang terdaftar.
2. Pengeluaran dari Grant Fund harus dapat di-map ke minimal satu donor budget line.
3. Pengeluaran yang tidak eligible sesuai donor rule harus ditandai sebagai compliance exception.
4. Grant tidak boleh menjadi Active tanpa grant agreement yang sudah approved.
5. Pelaporan ke donor harus sesuai jadwal di Grant Reporting Schedule.
6. Grant Closeout tidak bisa dilakukan jika masih ada advance yang belum dilikuidasi.
7. Budget revision harus mendapat persetujuan donor jika melebihi threshold yang disepakati di agreement.

---

## 7. Integrasi dengan Context Lain

| Context | Hubungan |
|---|---|
| Funding Context | Institutional Donor adalah Funding Source yang menghasilkan Grant |
| Fund Stewardship Context | Grant menghasilkan Grant Fund, atau Grant adalah sub-domain Fund (tergantung keputusan) |
| Financial Accountability Context | Setiap transaksi yang charged ke Grant Fund harus bisa di-map ke Grant Budget Line |
| Procurement & Operations Context | Procurement dari Grant Fund harus mengikuti procurement rule donor |
| Evidence & Compliance Context | Grant Agreement mendefinisikan evidence requirement per budget line |
| Reporting Context | Grant Reporting Schedule mendrive Donor Report generation |

---

## 8. MVP Scope

Untuk MVP, Grant Context minimal mencakup:

- Grant master (atau Grant Fund dengan atribut grant)
- Donor master
- Grant Agreement
- Grant Budget Line (donor)
- Grant Reporting Schedule
- Link transaksi ke Grant Budget Line
- Budget vs Actual per Grant Budget Line
- Donor Report template

Belum perlu di MVP:

- grant pipeline management (CRM-like)
- multi-donor grant
- sub-grant management
- grant audit pack otomatis
- grant amendment workflow

---

## 9. Keputusan yang Perlu Dibuat

Lihat `DECISIONS.md` untuk detail. Keputusan utama yang mempengaruhi context ini:

1. **Grant sebagai bounded context atau sub-domain Fund Stewardship?**
2. **Bagaimana mapping Internal Budget Line ↔ Donor Budget Line?** (satu tabel dengan flag, atau dua tabel terpisah)
3. **Budget revision flow:** versi baru vs edit langsung, dan siapa yang approve jika revision butuh persetujuan donor.
