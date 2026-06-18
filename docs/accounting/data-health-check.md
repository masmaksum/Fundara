# Data Health Check

## 1. Ringkasan

Data Health Check adalah modul untuk memeriksa sinkronisasi dan kualitas data yang diinput user.

Tujuan utama:

> Membantu user menemukan dan memperbaiki kesalahan sebelum laporan donor, laporan manajemen, closing period, atau audit.

## 2. Jenis Pemeriksaan

Contoh pemeriksaan:

```text
Transaksi tanpa Fund
Transaksi tanpa Budget Line
Transaksi project tanpa Activity
Expense tanpa Evidence wajib
Advance overdue
Payment tanpa bank account
Jurnal tidak balance
Budget line overspent
Transaksi di luar periode grant
Transaksi donor tanpa reporting period
Asset tanpa depreciation schedule
Bank transaction unreconciled
Fund balance negatif
Opening balance tidak seimbang
```

## 3. Severity

Setiap issue memiliki tingkat keparahan:

```text
Info
Warning
Error
Critical
```

Contoh:

| Issue | Severity |
|---|---|
| Transaksi tanpa keterangan | Warning |
| Expense tanpa fund | Critical |
| Jurnal tidak balance | Critical |
| Evidence belum lengkap | Error |
| Bank belum direkonsiliasi | Warning/Error, tergantung periode |

## 4. Correction Workflow

```text
Run Data Health Check
→ Show Issue List
→ Open Related Document
→ Fix Data
→ Re-run Check
→ Mark Resolved
```

## 5. Dashboard

Dashboard menampilkan:

- total issue;
- issue by severity;
- issue by context;
- issue by project;
- issue by donor;
- issue aging;
- unresolved critical issue;
- data readiness score.

## 6. Data Readiness Score

Fundara dapat memberikan skor sederhana:

```text
Ready for Reporting
Needs Review
Not Ready
```

Atau dalam angka:

```text
0 - 100%
```

Skor dihitung berdasarkan issue critical, error, warning, dan completeness evidence.

## 7. Business Rules

1. Critical issue harus diselesaikan sebelum period closing.
2. Donor report tidak boleh submitted jika ada critical issue pada transaksi donor tersebut.
3. Data health check harus menyimpan log.
4. User harus dapat membuka dokumen sumber dari daftar issue.
5. Resolved issue harus memiliki timestamp dan user.

## 8. MVP

MVP Data Health Check:

- transaksi tanpa fund;
- transaksi tanpa budget line;
- advance overdue;
- evidence missing;
- budget overspent;
- journal not balanced;
- unreconciled bank transaction;
- issue list dengan link ke dokumen sumber.
