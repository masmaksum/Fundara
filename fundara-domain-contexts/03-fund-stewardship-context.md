# Fund Stewardship Context

## 1. Ringkasan

**Fund Stewardship Context** adalah jantung Fundara. Context ini mengelola dana sebagai amanah yang memiliki sumber, tujuan, batasan, saldo, alokasi, aturan penggunaan, dan kewajiban pertanggungjawaban.

Jika Funding Context menjawab “dana berasal dari mana”, maka Fund Stewardship Context menjawab “dana ini dikelola sebagai kantong apa, boleh digunakan untuk apa, dan bagaimana memastikan penggunaannya tetap akuntabel”.

Fundara tidak boleh menjadikan akun akuntansi sebagai pusat domain. Pusat domain haruslah **Fund**, karena organisasi misi sosial dapat menerima dana dari banyak sumber: grant, donasi publik, campaign, unit usaha, dana cadangan, co-funding, atau unrestricted fund.

---

## 2. Tujuan Context

Fund Stewardship Context bertujuan untuk:

1. Mengelola fund sebagai kantong dana amanah.
2. Membedakan restricted, unrestricted, board-designated, dan campaign-designated fund.
3. Mengatur tujuan, periode, aturan penggunaan, dan saldo fund.
4. Mengalokasikan fund ke program, project, activity, atau budget line.
5. Mengelola transfer antar fund.
6. Mendukung bridging fund dan reimbursement antar fund.
7. Menjadi basis fund utilization report.

---

## 3. Pertanyaan Domain yang Dijawab

Context ini harus mampu menjawab:

- Fund ini berasal dari funding source mana?
- Apakah fund ini restricted atau unrestricted?
- Apa tujuan penggunaan fund ini?
- Periode fund ini kapan?
- Berapa total dana masuk?
- Berapa yang sudah dialokasikan?
- Berapa yang sudah committed?
- Berapa yang sudah actual?
- Berapa saldo tersedia?
- Apakah biaya tertentu boleh memakai fund ini?
- Apakah fund ini boleh ditransfer ke fund lain?
- Apakah fund ini sudah siap ditutup?

---

## 4. Entitas Utama

### 4.1 Fund

Fund adalah kantong dana yang memiliki tujuan, aturan, periode, dan saldo.

Jenis fund:

- Grant Fund
- Campaign Fund
- Unrestricted Fund
- Business Surplus Fund
- Reserve Fund
- Co-funding Fund
- Bridging Fund
- Endowment Fund
- Board-designated Fund

Atribut konseptual:

- fund name
- fund code
- fund type
- funding source
- restriction type
- purpose
- start date
- end date
- currency
- fund owner
- approval authority
- opening balance
- status

Status fund:

```text
Draft → Active → Suspended → Closing → Closed
```

---

### 4.2 Fund Type

Kategori fund yang menentukan perilaku dasar.

Contoh:

- Grant Fund: memiliki donor, grant agreement, budget line donor, reporting schedule.
- Campaign Fund: memiliki campaign purpose dan public accountability report.
- Unrestricted Fund: lebih fleksibel, mengikuti kebijakan internal.
- Business Surplus Fund: berasal dari surplus unit usaha.
- Reserve Fund: digunakan untuk cadangan atau emergency.
- Bridging Fund: digunakan untuk dana talangan sementara.

---

### 4.3 Fund Restriction

Aturan pembatasan penggunaan fund.

Jenis restriction:

- restricted
- temporarily restricted
- unrestricted
- board-designated
- donor-designated
- campaign-designated

Atribut konseptual:

- restriction type
- allowed cost
- disallowed cost
- allowed program
- allowed project
- allowed location
- allowed period
- procurement requirement
- reporting requirement
- exception rule

---

### 4.4 Fund Allocation

Alokasi fund ke program, project, activity, atau budget line.

Atribut konseptual:

- fund
- allocated to type: program/project/activity/cost center
- allocated to reference
- budget line
- amount
- currency
- allocation period
- allocation status

Status allocation:

```text
Draft → Submitted → Approved → Active → Revised → Closed
```

---

### 4.5 Fund Transfer

Pemindahan dana antar fund secara internal.

Contoh:

- Unrestricted Fund → Co-funding Fund
- Business Surplus Fund → Program Fund
- Reserve Fund → Emergency Fund

Atribut konseptual:

- source fund
- target fund
- amount
- reason
- approval reference
- transfer date
- status

---

### 4.6 Bridging Fund Settlement

Penyelesaian dana talangan.

Contoh:

Biaya project dibayar dulu dengan Unrestricted Fund karena grant belum cair. Setelah grant cair, Unrestricted Fund diganti dari Grant Fund.

Atribut konseptual:

- original fund
- recoverable fund
- transaction reference
- eligible amount
- settlement amount
- settlement date
- status

---

### 4.7 Fund Balance

Ringkasan posisi dana.

Komponen:

- opening balance
- income received
- transfer in
- transfer out
- allocated amount
- committed amount
- actual amount
- paid amount
- available balance
- forecast balance

---

## 5. Relasi Antar Entitas

```text
Funding Source
 └── provides Fund

Fund
 ├── has Fund Type
 ├── has Fund Restriction
 ├── has Fund Allocation
 ├── has Fund Transfer
 ├── has Fund Balance
 ├── funds Project
 ├── funds Activity
 ├── funds Transaction
 └── produces Fund Utilization Report

Fund Allocation
 ├── belongs to Fund
 ├── targets Program / Project / Activity
 └── consumes Budget Line

Fund Transfer
 ├── moves amount from Source Fund
 └── moves amount to Target Fund
```

---

## 6. Batasan Context

Fund Stewardship Context menangani:

- fund master
- fund type
- fund restriction
- fund allocation
- fund transfer
- bridging settlement
- fund balance
- fund lifecycle

Context ini tidak menangani:

- detail donor relationship
- detail procurement process
- posting accounting debit/kredit
- pengukuran indicator dampak
- penyusunan laporan naratif

---

## 7. Workflow Utama

### 7.1 Pembuatan Fund

```text
Create Fund
→ Select Funding Source
→ Define Fund Type
→ Define Restriction
→ Define Purpose
→ Define Period and Currency
→ Assign Fund Owner
→ Review by Finance / Management
→ Approve Fund
→ Activate Fund
```

### 7.2 Alokasi Fund ke Project / Activity

```text
Create Fund Allocation
→ Select Fund
→ Select Project / Activity
→ Select Budget Line
→ Define Amount and Period
→ Check Fund Availability
→ Review by Fund Owner / Finance
→ Approve Allocation
→ Activate Allocation
```

### 7.3 Transfer Antar Fund

```text
Request Fund Transfer
→ Select Source Fund
→ Select Target Fund
→ Provide Reason
→ Check Restriction Rule
→ Review by Finance
→ Approve by Authority
→ Post Transfer
→ Update Fund Balance
```

### 7.4 Bridging Settlement

```text
Expense Paid by Bridging Fund
→ Mark as Recoverable
→ Link to Target Grant / Fund
→ Grant Fund Received
→ Review Eligibility
→ Approve Settlement
→ Transfer Amount to Bridging Fund
→ Close Settlement
```

### 7.5 Closeout Fund

```text
Start Fund Closing
→ Check Outstanding Commitments
→ Check Unliquidated Advances
→ Check Missing Evidence
→ Check Remaining Balance
→ Resolve Exceptions
→ Generate Final Fund Report
→ Approve Closure
→ Close Fund
```

---

## 8. Aturan Bisnis

1. Setiap fund harus memiliki funding source.
2. Setiap fund harus memiliki restriction type.
3. Restricted fund hanya boleh digunakan sesuai tujuan yang ditentukan.
4. Fund yang sudah closed tidak boleh menerima transaksi baru.
5. Fund allocation tidak boleh melebihi available balance kecuali ada override resmi.
6. Fund transfer dari restricted fund harus mengikuti restriction rule.
7. Bridging settlement hanya boleh dilakukan untuk biaya yang eligible.
8. Perubahan fund restriction harus memiliki approval dan audit trail.
9. Fund balance harus membedakan committed, actual, paid, dan available.
10. Fund bukan account dalam Chart of Accounts; fund adalah dimensi akuntabilitas.

---

## 9. Integrasi dengan Context Lain

| Context | Hubungan |
|---|---|
| Funding Context | Funding source menciptakan Fund |
| Organization Context | Fund memiliki owner, responsible unit, dan approval authority |
| Mission Delivery Context | Fund dialokasikan ke program, project, dan activity |
| Financial Accountability Context | Transaction memakai fund sebagai dimensi utama |
| Procurement & Operations Context | Procurement request mengecek fund availability dan restriction |
| Evidence & Compliance Context | Fund menentukan evidence dan compliance requirement |
| Reporting Context | Fund menghasilkan fund utilization report |
| Impact & Learning Context | Fund dihubungkan ke output dan outcome melalui activity |

---

## 10. Implementasi di ERPNext/Frappe

Komponen ERPNext/Frappe yang relevan:

- Accounting Dimension
- Cost Center
- Project
- Budget
- Payment Entry
- Journal Entry
- Workflow
- Custom Field
- Custom DocType

Custom DocType yang mungkin dibutuhkan:

- Fund
- Fund Type
- Fund Restriction
- Fund Allocation
- Fund Transfer
- Fund Balance Snapshot
- Bridging Fund Settlement
- Fund Closure Checklist

---

## 11. MVP Scope

Untuk MVP, context ini harus mencakup:

- Fund
- Fund Type
- Fund Restriction
- Fund Allocation
- Fund Balance sederhana
- Fund Transfer sederhana
- Fund Utilization Report

Belum perlu:

- endowment fund
- complex investment income
- advanced inter-fund settlement
- multi-currency revaluation detail
- automated forecast engine

---

## 12. Risiko Desain

Risiko yang perlu dihindari:

1. Menjadikan fund hanya sebagai field teks.
2. Membuat Chart of Accounts terlalu panjang untuk menggantikan fund.
3. Tidak membedakan fund source dan fund.
4. Tidak membedakan allocated, committed, actual, paid, dan available.
5. Tidak menyimpan histori perubahan restriction.
6. Tidak mendukung unrestricted dan business surplus fund sejak awal.
7. Mengunci sistem hanya untuk grant sehingga tidak cocok bagi organisasi multi-source funding.

---

## 13. Prinsip Desain

Fund Stewardship Context harus mengikuti prinsip:

> Fund adalah amanah yang harus dapat ditelusuri dari sumbernya hingga dampaknya.

Setiap desain transaksi, alokasi, approval, dan laporan harus menjaga keterlacakan fund sebagai pusat akuntabilitas Fundara.
