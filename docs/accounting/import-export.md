# Import & Export

## 1. Ringkasan

Fundara perlu mendukung import dan export karena banyak organisasi nirlaba masih menggunakan Excel sebagai sistem kerja utama.

Import/export bukan fitur tambahan, tetapi bagian dari strategi migrasi dan interoperabilitas.

## 2. Import Data

Data yang perlu dapat diimport:

```text
Chart of Account
Opening Balance
Donor
Funding Source
Fund
Project
Activity
Budget
Budget Line
Transaction
Cash/Bank Receipt
Cash/Bank Disbursement
Fixed Asset
Bank Statement
Indicator Target
Beneficiary Summary
```

## 3. Import Workflow

```text
Upload File
→ Select Import Type
→ Map Columns
→ Validate Data
→ Preview Errors
→ Fix / Re-upload
→ Confirm Import
→ Create Records
→ Generate Import Log
```

## 4. Validation

Validasi import harus memeriksa:

- field wajib;
- format tanggal;
- format angka;
- currency;
- account valid;
- fund valid;
- project valid;
- budget line valid;
- duplicate record;
- balance debit/credit;
- data referensi belum ada.

## 5. Export Laporan

Format export target:

```text
Excel
CSV
PDF
Word / DOCX
```

Untuk MVP:

```text
CSV / XLSX import
CSV / XLSX / PDF export
```

DOCX dapat menjadi roadmap untuk narrative report dan donor report template.

## 6. Export Template

Fundara perlu memiliki Export Template untuk:

- ISAK 35 reports;
- donor financial report;
- budget vs actual;
- fund utilization;
- bank reconciliation;
- advance aging;
- fixed asset register;
- data health report.

## 7. Business Rules

1. Import harus divalidasi sebelum record dibuat.
2. Import harus menghasilkan log.
3. Import gagal sebagian harus jelas statusnya.
4. User harus dapat mengunduh error file.
5. Export harus menjaga format angka, currency, periode, dan dimensi.
6. Export laporan yang sudah submitted harus memiliki versi arsip.

## 8. MVP

MVP Import/Export:

- template import Excel/CSV;
- import opening balance;
- import budget;
- import transaction sederhana;
- import bank statement;
- export laporan ke Excel/PDF;
- import log dan error preview.
