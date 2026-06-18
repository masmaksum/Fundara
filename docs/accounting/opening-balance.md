# Opening Balance & Automatic Balancing

## 1. Ringkasan

Opening balance adalah proses memasukkan saldo awal organisasi ketika mulai menggunakan Fundara.

Organisasi nirlaba sering bermigrasi dari Excel atau sistem lama dengan kondisi:

- saldo bank tersedia;
- saldo kas tersedia;
- piutang dan utang tersedia;
- fixed asset tersedia;
- uang muka outstanding tersedia;
- saldo fund donor tersedia;
- tetapi aset neto belum disusun dengan benar.

Fundara perlu menyediakan **Opening Balance Assistant**.

## 2. Tujuan

Opening Balance Assistant bertujuan untuk:

- membantu migrasi dari Excel;
- menghitung aset neto otomatis;
- menyeimbangkan saldo awal;
- memetakan saldo awal per fund;
- memetakan saldo awal per donor;
- memetakan saldo awal berdasarkan pembatasan dana;
- menghasilkan opening journal yang valid.

## 3. Rumus Dasar

```text
Total Aset - Total Liabilitas = Total Aset Neto
```

Aset neto dipetakan menjadi:

```text
Aset Neto Tanpa Pembatasan
Aset Neto Dengan Pembatasan
Aset Neto Ditetapkan Pengurus
```

## 4. Saldo Awal per Fund

Fundara harus mendukung saldo awal:

```text
Saldo awal Fund Donor A
Saldo awal Fund Donor B
Saldo awal Campaign C
Saldo awal Unrestricted Fund
Saldo awal Business Surplus Fund
Saldo awal Reserve Fund
```

## 5. Data yang Diinput

- saldo kas;
- saldo bank;
- piutang;
- utang;
- uang muka outstanding;
- fixed asset;
- akumulasi penyusutan;
- inventory;
- dana diterima di muka;
- fund balance;
- donor balance;
- net asset class.

## 6. Validation Rules

Fundara perlu memeriksa:

- total debit = total credit;
- total aset neto sesuai selisih aset dan liabilitas;
- saldo fund sesuai saldo bank/piutang/utang terkait;
- saldo donor restricted tidak negatif;
- advance outstanding memiliki staff dan due date;
- fixed asset memiliki acquisition date dan cost;
- bank account memiliki saldo awal.

## 7. Workflow

```text
Input Opening Account Balances
→ Input Fund / Donor Balances
→ Validate Assets and Liabilities
→ Calculate Net Assets
→ Allocate Net Assets by Restriction
→ Validate Per Fund Balance
→ Generate Opening Balance Journal
→ Lock Opening Balance
```

## 8. MVP

MVP Opening Balance:

- import opening balance dari Excel;
- opening balance per account;
- opening balance per fund;
- automatic net asset calculation;
- validation report;
- opening journal generation.
