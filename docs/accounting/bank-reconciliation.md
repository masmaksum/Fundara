# Bank Reconciliation

## 1. Ringkasan

Rekonsiliasi bank adalah proses mencocokkan transaksi yang dicatat di Fundara dengan mutasi yang dicatat oleh bank.

Tujuannya:

- memastikan saldo bank di sistem sesuai dengan bank statement;
- menemukan transaksi yang belum dicatat;
- menemukan transaksi duplikat;
- menemukan biaya bank atau bunga yang belum dicatat;
- menutup periode keuangan dengan data yang lebih andal.

## 2. Entitas

```text
Bank Account
Bank Statement
Bank Statement Line
Bank Transaction Match
Bank Reconciliation
Reconciliation Exception
```

## 3. Workflow

```text
Import Bank Statement
→ Auto Matching
→ Review Unmatched Items
→ Create Missing Transaction / Manual Match
→ Confirm Reconciliation
→ Generate Bank Reconciliation Report
```

## 4. Matching Rules

Auto-match dapat memakai kombinasi:

- tanggal;
- jumlah;
- nomor referensi;
- deskripsi;
- payee/payer;
- bank account;
- tolerance date;
- tolerance amount.

Jenis match:

```text
Exact Match
Probable Match
Partial Match
Manual Match
Split Match
```

## 5. Status

```text
Recorded
Matched
Unmatched
Partially Matched
Reconciled
Exception
```

## 6. Unmatched Handling

Jika bank statement line belum ada di Fundara, user dapat:

- membuat penerimaan baru;
- membuat pengeluaran baru;
- mencatat bank fee;
- mencatat interest income;
- menandai sebagai duplicate;
- menandai sebagai exception.

## 7. Business Rules

1. Transaksi yang sudah reconciled tidak boleh diubah tanpa reversal/correction.
2. Bank statement import harus memiliki import log.
3. Auto-match harus dapat direview user.
4. Manual match harus meninggalkan audit trail.
5. Reconciliation report harus dapat diekspor.
6. Periode dengan unreconciled item material perlu diberi warning.

## 8. MVP

MVP Bank Reconciliation:

- import bank statement CSV/XLSX;
- auto-match sederhana berdasarkan tanggal dan jumlah;
- manual match;
- unmatched item list;
- create missing transaction;
- reconciliation status;
- reconciliation report.
