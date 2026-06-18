# Donor Financial Reporting

## 1. Ringkasan

Laporan per donor adalah fitur penting untuk organisasi nirlaba karena donor sering meminta laporan penggunaan dana berdasarkan format, periode, budget line, dan evidence tertentu.

Dalam Fundara, laporan per donor tidak boleh hanya berupa filter nama donor pada laporan keuangan. Laporan donor harus dibangun dari hubungan:

```text
Donor → Grant → Fund → Project → Activity → Budget Line → Transaction → Evidence → Reporting Period
```

## 2. Jenis Laporan Per Donor

```text
Donor Fund Utilization Report
Budget vs Actual per Donor
Expenditure by Donor Budget Line
Expenditure by Project / Activity
Advance Outstanding per Donor
Procurement List per Donor
Asset Purchased by Donor Fund
Supporting Document Register
Variance Explanation
Report Submission Status
```

## 3. Data yang Dibutuhkan

Setiap transaksi donor-funded perlu memiliki:

- donor;
- grant;
- fund;
- project;
- activity;
- budget line;
- account;
- amount;
- currency;
- transaction date;
- reporting period;
- evidence status;
- approval status.

## 4. Drill-down

Prinsip laporan donor:

> Setiap angka harus dapat ditelusuri sampai transaksi dan bukti.

Contoh:

```text
Training Cost: Rp120.000.000
→ 18 transaksi
→ invoice
→ attendance list
→ foto kegiatan
→ approval
→ payment proof
```

## 5. Variance Explanation

Jika budget vs actual memiliki selisih material, Fundara perlu menyediakan field variance explanation.

Contoh:

- underspending karena activity ditunda;
- overspending karena kenaikan biaya transport;
- budget revision sedang diajukan;
- expense akan dipindahkan ke fund lain;
- procurement belum selesai.

## 6. Donor Report Workflow

```text
Generate Draft Report
→ Finance Review
→ Program Review
→ Management Approval
→ Submit to Donor
→ Archive Submission Evidence
```

## 7. Business Rules

1. Transaksi donor-funded harus memiliki donor/grant/fund reference.
2. Transaksi donor-funded harus memiliki budget line donor.
3. Transaksi di luar grant period harus diberi warning atau diblokir sesuai rule.
4. Laporan donor harus memiliki reporting period.
5. Submitted report harus diarsipkan.
6. Angka laporan harus sesuai dengan transaksi posted.
7. Draft report boleh disesuaikan dengan adjustment explanation, tetapi angka sumber harus traceable.

## 8. MVP

MVP Donor Reporting:

- report per donor/grant/fund;
- budget vs actual;
- expenditure by budget line;
- supporting document register;
- advance outstanding per donor;
- export Excel/PDF;
- report status workflow.
