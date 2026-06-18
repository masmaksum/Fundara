# Funding Context

## 1. Ringkasan

**Funding Context** adalah domain yang menjelaskan dari mana sumber daya organisasi berasal. Context ini mencakup donor, donasi individu, fundraising campaign, corporate giving, pendapatan unit usaha, membership fee, government contract, zakat/infaq/wakaf jika relevan, dan sumber dana internal lainnya.

Dalam Fundara, funding tidak hanya dipahami sebagai penerimaan uang. Funding adalah awal dari rantai akuntabilitas. Setiap dana yang diterima membawa konteks: siapa pemberinya, apa tujuannya, apakah penggunaannya dibatasi, apakah perlu laporan, dan bagaimana dana tersebut akan dihubungkan dengan program serta dampak.

---

## 2. Tujuan Context

Funding Context bertujuan untuk:

1. Mengidentifikasi semua sumber pendanaan organisasi.
2. Membedakan berbagai jenis funding source.
3. Mengelola donor, campaign, dan unit usaha sebagai sumber dana.
4. Menentukan karakter awal dana: restricted, unrestricted, atau designated.
5. Menjadi input awal bagi Fund Stewardship Context.
6. Mendukung pelaporan source of funds.

---

## 3. Pertanyaan Domain yang Dijawab

Funding Context harus mampu menjawab:

- Dana ini berasal dari siapa atau dari kanal apa?
- Apakah sumbernya donor institusi, individu, publik, perusahaan, unit usaha, atau internal?
- Apakah dana ini restricted atau unrestricted?
- Apakah funding source memiliki kewajiban laporan?
- Apakah funding source ini menghasilkan satu fund atau beberapa fund?
- Siapa relationship owner untuk donor atau funding source ini?
- Berapa dana yang masuk dari masing-masing sumber?
- Seberapa beragam sumber pendanaan organisasi?

---

## 4. Entitas Utama

### 4.1 Funding Source

Funding Source adalah entitas umum yang mewakili asal dana atau sumber daya.

Jenis funding source:

- Institutional Donor
- Individual Donor
- Corporate Donor
- Public Fundraising
- Fundraising Campaign
- Social Enterprise Revenue
- Service Revenue
- Membership Fee
- Government Contract
- Internal Reserve
- Investment Income
- Zakat/Infaq/Wakaf, jika relevan

Atribut konseptual:

- source name
- source code
- source type
- country
- contact information
- relationship owner
- default restriction type
- reporting expectation
- risk profile
- active status

---

### 4.2 Donor

Donor adalah funding source yang memberikan dana atau sumber daya dengan tujuan mendukung misi organisasi.

Jenis donor:

- individual donor
- institutional donor
- corporate donor
- philanthropic foundation
- multilateral agency
- government donor
- community donor

Atribut konseptual:

- donor name
- donor type
- contact person
- email
- phone
- country
- preferred language
- reporting preference
- acknowledgment preference
- relationship owner
- donor status

---

### 4.3 Institutional Donor Profile

Untuk donor institusi yang memiliki aturan formal.

Atribut konseptual:

- donor legal name
- donor short name
- compliance requirement
- procurement preference
- audit requirement
- branding requirement
- financial reporting format
- narrative reporting format
- allowed currency

---

### 4.4 Fundraising Campaign

Campaign untuk mengumpulkan dana dari publik atau segmen tertentu.

Contoh:

- Campaign Banjir 2026
- Beasiswa Anak Desa
- Emergency Medical Appeal
- Wakaf Klinik Komunitas
- End-of-Year Giving Campaign

Atribut konseptual:

- campaign name
- campaign code
- purpose
- target amount
- start date
- end date
- campaign manager
- channel
- restricted purpose
- public reporting requirement
- status

Status campaign:

```text
Draft → Active → Paused → Completed → Closed
```

---

### 4.5 Donation

Donation adalah penerimaan dana dari donor individual, corporate donor, atau publik.

Atribut konseptual:

- donation number
- donor
- campaign
- amount
- currency
- date received
- payment channel
- restriction
- receipt number
- acknowledgment status
- anonymous flag

---

### 4.6 Business Unit

Business Unit adalah unit usaha atau social enterprise yang menghasilkan pendapatan untuk mendukung misi organisasi.

Contoh:

- Training Center
- Café Sosial
- Konsultansi
- Produk Komunitas
- Merchandise
- Publishing Unit

Atribut konseptual:

- business unit name
- business unit code
- revenue model
- manager
- linked cost center
- tax profile
- surplus allocation policy
- active status

---

### 4.7 Revenue Stream

Kategori pendapatan dari business unit atau layanan organisasi.

Contoh:

- training fee
- consulting fee
- product sales
- event ticket
- membership fee
- rental income
- publication sales

---

## 5. Relasi Antar Entitas

```text
Funding Source
 ├── may be Donor
 ├── may be Fundraising Campaign
 ├── may be Business Unit
 ├── may generate Donation
 ├── may generate Revenue
 └── creates Fund

Donor
 ├── may give Donation
 ├── may award Grant
 └── may support Campaign

Campaign
 ├── receives Donation
 ├── has target amount
 ├── creates Campaign Fund
 └── requires Campaign Report

Business Unit
 ├── generates Revenue
 ├── has Cost Center
 ├── calculates Surplus
 └── creates Business Surplus Fund
```

---

## 6. Batasan Context

Funding Context menangani:

- sumber dana
- donor
- campaign
- donasi
- unit usaha sebagai sumber pendapatan
- revenue stream
- karakter awal dana

Funding Context tidak menangani:

- alokasi dana ke project
- kontrol saldo fund
- transaksi expense detail
- laporan penggunaan dana
- dampak program
- budget control

Begitu dana diterima dan perlu dikelola sebagai kantong amanah, domain berpindah ke Fund Stewardship Context.

---

## 7. Workflow Utama

### 7.1 Registrasi Funding Source

```text
Create Funding Source
→ Define Source Type
→ Add Contact / Relationship Owner
→ Define Default Restriction
→ Define Reporting Expectation
→ Review by Finance / Management
→ Activate Funding Source
```

### 7.2 Penerimaan Donasi

```text
Donation Received
→ Identify Donor / Mark Anonymous
→ Link to Campaign if Applicable
→ Determine Restriction
→ Record Payment Channel
→ Issue Receipt / Acknowledgment
→ Create or Update Fund
→ Update Donation Register
```

### 7.3 Pembuatan Fundraising Campaign

```text
Draft Campaign
→ Define Purpose and Target
→ Define Restriction
→ Define Public Reporting Commitment
→ Review by Fundraising / Finance
→ Approve Campaign
→ Launch Campaign
→ Receive Donations
→ Close Campaign
→ Transfer to Campaign Fund
```

### 7.4 Pencatatan Pendapatan Unit Usaha

```text
Business Revenue Recorded
→ Link to Business Unit
→ Classify Revenue Stream
→ Record Cost if Applicable
→ Calculate Surplus Periodically
→ Allocate Surplus to Fund
```

---

## 8. Aturan Bisnis

1. Setiap funding source harus memiliki tipe yang jelas.
2. Setiap donasi harus memiliki status restricted, unrestricted, atau designated.
3. Donasi anonim tetap harus dapat dicatat tanpa mengorbankan transparansi internal.
4. Campaign restricted tidak boleh dicampur dengan unrestricted fund tanpa keputusan resmi.
5. Business unit revenue harus dipisahkan dari donation income.
6. Surplus unit usaha baru boleh dialokasikan setelah pendapatan dan biaya terkait dihitung.
7. Donor acknowledgment harus dapat dilacak statusnya.
8. Funding source dapat menghasilkan lebih dari satu fund.
9. Funding source tidak sama dengan fund. Funding source adalah asal dana; fund adalah kantong pengelolaan dana.

---

## 9. Integrasi dengan Context Lain

| Context | Hubungan |
|---|---|
| Organization Context | Funding source memiliki relationship owner dan unit penanggung jawab |
| Fund Stewardship Context | Funding source menciptakan Fund |
| Grant Context / Fund Stewardship | Donor dapat memberikan grant |
| Financial Accountability Context | Donation dan revenue menjadi transaksi penerimaan |
| Reporting Context | Source of Funds report dan campaign report memakai data funding |
| Impact & Learning Context | Campaign dapat dikaitkan dengan impact report publik |

---

## 10. Implementasi di ERPNext/Frappe

Komponen ERPNext/Frappe yang dapat dipakai:

- Donor, jika memakai Non Profit module
- Customer, untuk donor atau pembeli jasa
- Sales Invoice, untuk business unit revenue
- Payment Entry
- Campaign, jika CRM dipakai
- Contact dan Address

Custom DocType yang mungkin dibutuhkan:

- Funding Source
- Funding Source Type
- Donor Profile
- Fundraising Campaign
- Donation Receipt
- Donor Acknowledgment
- Business Unit Profile
- Revenue Stream
- Surplus Allocation Policy

---

## 11. MVP Scope

Untuk MVP, Funding Context cukup mencakup:

- Funding Source
- Donor
- Fundraising Campaign
- Donation
- Business Unit
- Revenue Stream sederhana

Belum perlu:

- advanced donor CRM
- recurring donation automation
- tax receipt localization lengkap
- campaign landing page
- payment gateway integration penuh
- donor segmentation kompleks

---

## 12. Risiko Desain

Risiko yang perlu dihindari:

1. Menyamakan donor dengan customer secara mentah tanpa konteks sosial.
2. Menyamakan campaign dengan project.
3. Tidak membedakan donation income dan business revenue.
4. Tidak mencatat restriction sejak dana diterima.
5. Membuat funding source terlalu detail sehingga membebani user kecil.
6. Tidak menyediakan donor anonim.
7. Tidak memisahkan sumber dana dan kantong dana.

---

## 13. Prinsip Desain

Funding Context harus mengikuti prinsip:

> Setiap dana memiliki cerita asal-usulnya.

Fundara harus menjaga agar cerita itu tidak hilang saat dana masuk ke sistem keuangan. Dari awal, sistem harus tahu dana berasal dari siapa, untuk tujuan apa, dan dengan ekspektasi akuntabilitas seperti apa.
