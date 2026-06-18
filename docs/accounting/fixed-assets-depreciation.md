# Fixed Assets & Depreciation

## 1. Ringkasan

Modul aktiva tetap mengelola aset yang dimiliki organisasi, termasuk aset yang dibeli dari dana donor, campaign, unrestricted fund, atau unit usaha.

Untuk organisasi nirlaba, aset tidak hanya perlu dicatat sebagai aset lembaga, tetapi juga perlu diketahui:

> Aset ini dibeli dari dana siapa, untuk project apa, berada di lokasi mana, digunakan oleh siapa, dan bagaimana perlakuannya dalam laporan donor.

## 2. Entitas

```text
Fixed Asset
Asset Category
Asset Location
Asset Custodian
Asset Funding Source
Asset Acquisition
Asset Transfer
Asset Disposal
Asset Depreciation Schedule
Depreciation Entry
```

## 3. Fixed Asset

Field utama:

- asset code;
- asset name;
- category;
- acquisition date;
- acquisition cost;
- funding source;
- fund;
- donor;
- project;
- location;
- custodian;
- useful life;
- depreciation method;
- residual value;
- status;
- disposal date;
- document evidence.

## 4. Depresiasi Bulanan

Fundara memakai metode depresiasi bulanan.

Fitur:

- depreciation schedule otomatis;
- posting depresiasi bulanan;
- jurnal depresiasi otomatis;
- perhitungan berdasarkan umur manfaat;
- kebijakan mulai depresiasi: bulan perolehan atau bulan berikutnya;
- partial month policy;
- disposal adjustment;
- laporan nilai buku.

Contoh jurnal:

```text
Dr Beban Penyusutan
    Cr Akumulasi Penyusutan
```

## 5. Accounting Depreciation vs Donor Reporting Treatment

Tidak semua donor memperlakukan aset dengan cara yang sama.

Kemungkinan perlakuan:

1. Accounting mencatat aset dan depresiasi bulanan.
2. Donor report mengakui pembelian aset sebagai biaya penuh saat pembelian.
3. Donor report meminta daftar aset, bukan depresiasi.
4. Donor memiliki aturan disposal atau transfer asset saat grant closeout.

Karena itu, Fundara perlu membedakan:

```text
Accounting Depreciation
Donor Reporting Treatment
```

## 6. Laporan Aset

Laporan yang perlu tersedia:

- fixed asset register;
- aset per donor;
- aset per fund;
- aset per project;
- aset per lokasi;
- aset per custodian;
- depreciation report;
- net book value report;
- asset disposal report;
- asset verification report.

## 7. Business Rules

1. Aset tetap harus memiliki asset category.
2. Aset yang dibeli dari dana donor harus memiliki fund/donor reference.
3. Aset harus memiliki lokasi dan custodian.
4. Aset depreciable harus memiliki useful life dan depreciation policy.
5. Depresiasi bulanan tidak boleh double-posting.
6. Disposal aset harus memiliki approval dan dokumen pendukung.
7. Transfer aset antar lokasi harus meninggalkan audit trail.

## 8. MVP

MVP Fixed Asset:

- fixed asset register;
- funding source/fund/donor tagging;
- location and custodian;
- monthly depreciation schedule;
- depreciation journal;
- asset report per donor/project;
- disposal status sederhana.
