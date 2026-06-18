# Fundara Accounting Documentation

Folder ini berisi dokumentasi khusus untuk aspek finance dan accounting Fundara.

Fundara memandang accounting bukan sekadar general ledger, tetapi sebagai sistem akuntabilitas dana nirlaba yang menghubungkan standar pelaporan, fund restriction, donor reporting, transaksi kas/bank, uang muka, aset tetap, rekonsiliasi, kualitas data, dan laporan dampak.

## Daftar Dokumen

| File | Isi |
|---|---|
| `accounting-standards.md` | Posisi Fundara terhadap ISAK 35, FASB ASC 958, ASU 2016-14, dan prinsip standards-aware |
| `isak-35.md` | Elaborasi pelaporan ISAK 35 untuk konteks Indonesia |
| `chart-of-accounts.md` | Template CoA organisasi nirlaba dan prinsip accounting dimensions |
| `cash-bank.md` | Penerimaan dan pengeluaran kas/bank dengan UI sederhana dan double-entry posting |
| `advance-liquidation.md` | Modul uang muka, pembayaran tambahan, pertanggungjawaban, refund, reimbursement, dan aging |
| `fixed-assets-depreciation.md` | Aktiva tetap, funding source aset, dan depresiasi bulanan |
| `bank-reconciliation.md` | Rekonsiliasi bank, import statement, auto-match, manual match, dan reconciliation report |
| `donor-reporting.md` | Laporan per donor dan drill-down dari angka laporan ke transaksi dan evidence |
| `opening-balance.md` | Opening balance assistant dan balance otomatis per fund, donor, dan aset neto |
| `data-health-check.md` | Data analysis, integrity check, dan correction workflow |
| `import-export.md` | Import Excel/CSV dan export laporan ke Excel, CSV, PDF, dan DOCX sebagai roadmap |
| `dashboards-localization.md` | Grafik, dashboard finansial, dan dual bahasa Indonesia/Inggris |

## Prinsip Umum

1. **Standards-aware** — Fundara mendukung ISAK 35 untuk Indonesia dan mengadopsi prinsip FASB ASC 958/ASU 2016-14 untuk konteks global.
2. **Simple input, proper accounting** — form transaksi dibuat sederhana, tetapi posting accounting tetap double-entry.
3. **Fund-aware by design** — setiap transaksi membawa fund, donor, project, activity, budget line, dan restriction status bila relevan.
4. **Donor-reportable** — transaksi donor-funded dapat ditelusuri sampai laporan donor dan bukti pendukung.
5. **Audit-ready** — semua transaksi, jurnal, koreksi, approval, dan attachment memiliki audit trail.
6. **Migration-friendly** — Fundara mendukung import, opening balance assistant, dan data health check.
7. **Localized but extensible** — Fundara mendukung bahasa Indonesia dan Inggris serta dapat dikembangkan untuk standar lokal lain.
