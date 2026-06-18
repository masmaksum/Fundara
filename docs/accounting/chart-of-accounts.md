# Chart of Accounts

## 1. Prinsip Utama

Fundara perlu menyediakan **template Chart of Account (CoA)** yang lazim dipakai organisasi nirlaba, tetapi CoA tidak boleh menampung semua donor, project, campaign, atau fund sebagai account.

Prinsip:

> CoA untuk struktur akuntansi. Dimensi untuk konteks misi.

Artinya:

- account menjelaskan jenis aset, liabilitas, aset neto, pendapatan, dan beban;
- fund menjelaskan kantong dana;
- donor/campaign/business unit menjelaskan sumber pendanaan;
- project/activity menjelaskan penggunaan dana;
- budget line menjelaskan kategori pelaporan donor atau internal.

## 2. Template CoA Awal

```text
Aset
├── Kas dan Setara Kas
│   ├── Kas Kecil
│   ├── Bank Operasional
│   ├── Bank Dana Terikat
│   └── Deposito
├── Piutang
│   ├── Piutang Donor
│   ├── Piutang Unit Usaha
│   └── Piutang Karyawan
├── Uang Muka
│   ├── Uang Muka Kegiatan
│   ├── Uang Muka Perjalanan
│   └── Uang Muka Operasional
├── Persediaan
├── Aset Tetap
│   ├── Peralatan Kantor
│   ├── Kendaraan
│   ├── Bangunan
│   └── Akumulasi Penyusutan
└── Aset Lainnya

Liabilitas
├── Utang Usaha
├── Utang Pajak
├── Utang Gaji
├── Dana Diterima di Muka
└── Liabilitas Lainnya

Aset Neto
├── Aset Neto Tanpa Pembatasan
├── Aset Neto Dengan Pembatasan
└── Aset Neto Ditetapkan Pengurus

Pendapatan
├── Pendapatan Grant
├── Pendapatan Donasi
├── Pendapatan Fundraising Campaign
├── Pendapatan Unit Usaha
├── Pendapatan Jasa
└── Pendapatan Lainnya

Beban
├── Beban Program
├── Beban Personalia
├── Beban Kegiatan
├── Beban Perjalanan
├── Beban Pengadaan
├── Beban Fundraising
├── Beban Administrasi dan Umum
├── Beban Unit Usaha
└── Beban Penyusutan
```

## 3. Accounting Dimensions

Dimensi utama:

| Dimensi | Fungsi |
|---|---|
| Fund | Menentukan kantong dana |
| Project | Menentukan project implementasi |
| Activity | Menentukan kegiatan spesifik |
| Budget Line | Menentukan kategori budget dan donor report |
| Cost Center | Menentukan unit organisasi |
| Location | Menentukan wilayah/lokasi |
| Donor | Conditional untuk grant/donor fund |
| Campaign | Conditional untuk fundraising campaign |
| Business Unit | Conditional untuk unit usaha |

## 4. Mapping Account ke Budget Line

Budget line donor tidak selalu sama dengan account.

Contoh:

| Transaksi | Account | Budget Line Donor |
|---|---|---|
| Hotel training | Beban Perjalanan / Akomodasi | Training Cost |
| Honor fasilitator | Beban Jasa Profesional | Workshop Cost |
| Laptop project | Aset Tetap / Peralatan | Equipment |
| Transport peserta | Beban Transportasi | Participant Support |

Fundara perlu menyediakan mapping:

```text
Account → Budget Line → Fund → Project → Activity → Donor Report Category
```

## 5. Risiko Desain

Risiko yang harus dihindari:

- membuat account untuk setiap donor;
- membuat account untuk setiap project;
- membuat account untuk setiap campaign;
- membuat CoA terlalu panjang dan sulit dirawat;
- menyamakan budget line donor dengan account secara paksa.

## 6. MVP

MVP CoA:

- template CoA nirlaba Indonesia;
- mapping account ke laporan ISAK 35;
- net asset accounts;
- accounting dimensions untuk fund, project, budget line, cost center;
- import/export CoA.
