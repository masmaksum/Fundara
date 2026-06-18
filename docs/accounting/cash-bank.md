# Cash & Bank

## 1. Ringkasan

Cash & Bank mengelola penerimaan dan pengeluaran yang berhubungan dengan kas atau bank.

Fundara memakai prinsip:

> UI single-entry, accounting engine double-entry.

User tidak perlu membuat jurnal debit/kredit secara manual untuk transaksi kas/bank rutin. User cukup mengisi form penerimaan atau pengeluaran, lalu Fundara membuat jurnal double-entry di belakang layar.

## 2. Penerimaan Kas/Bank

Form penerimaan mencatat:

- tanggal;
- akun kas/bank;
- sumber dana;
- donor/campaign/business unit, jika relevan;
- fund;
- jenis penerimaan;
- jumlah;
- mata uang;
- keterangan;
- dokumen pendukung.

Contoh posting donasi umum:

```text
Dr Bank Operasional
    Cr Pendapatan Donasi
```

Contoh posting donasi restricted:

```text
Dr Bank Dana Terikat
    Cr Pendapatan Donasi Dengan Pembatasan
```

Contoh grant diterima di muka:

```text
Dr Bank
    Cr Dana Diterima di Muka
```

## 3. Pengeluaran Kas/Bank

Form pengeluaran mencatat:

- tanggal;
- akun kas/bank;
- penerima;
- fund;
- project;
- activity;
- budget line;
- account biaya/aset/uang muka;
- jumlah;
- dokumen pendukung;
- status approval.

Contoh biaya program:

```text
Dr Beban Program
    Cr Bank Operasional
```

Contoh uang muka:

```text
Dr Uang Muka Kegiatan
    Cr Bank Operasional
```

Contoh pembelian aset:

```text
Dr Aset Tetap
    Cr Bank Operasional
```

## 4. Validasi

Sebelum transaksi diposting, Fundara perlu memeriksa:

- akun kas/bank valid;
- fund aktif;
- project/activity aktif;
- budget line tersedia;
- budget cukup;
- evidence minimum tersedia;
- approval sesuai threshold;
- periode accounting masih terbuka.

## 5. Relasi dengan Bank Reconciliation

Setiap transaksi bank memiliki status rekonsiliasi:

```text
Unreconciled → Matched → Reconciled
```

Transaksi yang sudah direkonsiliasi tidak boleh diubah tanpa reversal atau correction entry.

## 6. MVP

MVP Cash & Bank:

- cash receipt;
- bank receipt;
- cash disbursement;
- bank disbursement;
- auto-posting double-entry;
- fund/project/budget line tagging;
- attachment evidence;
- reconciliation status.
