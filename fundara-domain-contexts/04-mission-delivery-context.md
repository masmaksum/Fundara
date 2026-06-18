# Mission Delivery Context

## 1. Ringkasan

**Mission Delivery Context** adalah domain yang menggambarkan bagaimana organisasi menjalankan misi sosialnya melalui program, project, activity, workplan, deliverable, dan kerja lapangan.

Jika Fund Stewardship Context menjawab bagaimana dana dikelola, Mission Delivery Context menjawab bagaimana dana tersebut diwujudkan menjadi kerja nyata. Di sinilah dana berubah menjadi program, aktivitas, layanan, distribusi, pelatihan, advokasi, pendampingan, riset, atau intervensi sosial lainnya.

Context ini penting agar Fundara tidak menjadi sekadar sistem keuangan. Fundara harus bisa menunjukkan hubungan antara dana, aktivitas, bukti, dan dampak.

---

## 2. Tujuan Context

Mission Delivery Context bertujuan untuk:

1. Mengelola program dan project organisasi.
2. Menghubungkan fund dengan project dan activity.
3. Mengelola workplan, activity plan, dan deliverable.
4. Mendukung pelaksanaan kerja lapangan.
5. Menghubungkan aktivitas dengan transaksi, evidence, dan indicator.
6. Menjadi jembatan antara fund stewardship dan impact reporting.

---

## 3. Pertanyaan Domain yang Dijawab

Context ini harus mampu menjawab:

- Program apa yang dijalankan organisasi?
- Project apa yang sedang aktif?
- Project ini didanai oleh fund mana saja?
- Activity apa yang direncanakan dan sedang berjalan?
- Siapa penanggung jawab activity?
- Berapa planned cost dan actual cost activity?
- Bukti apa yang harus dikumpulkan dari activity?
- Deliverable apa yang harus diselesaikan?
- Activity ini berkontribusi pada output atau indicator apa?

---

## 4. Entitas Utama

### 4.1 Program

Program adalah area kerja strategis organisasi.

Contoh:

- Pendidikan
- Kesehatan
- Perlindungan Anak
- Lingkungan
- Pemberdayaan Ekonomi
- Respon Bencana
- Keadilan Gender
- Penguatan Komunitas

Atribut konseptual:

- program name
- program code
- strategic objective
- program manager
- start date
- end date
- target population
- active status

---

### 4.2 Project

Project adalah unit implementasi yang memiliki tujuan, periode, budget, lokasi, manager, dan hasil yang diharapkan.

Atribut konseptual:

- project name
- project code
- program
- project manager
- location
- start date
- end date
- linked fund
- total budget
- target beneficiaries
- project status

Status project:

```text
Concept → Approved → Active → On Hold → Completed → Closed
```

---

### 4.3 Activity

Activity adalah kegiatan nyata yang dilakukan untuk menjalankan project.

Contoh:

- Training guru
- Distribusi paket bantuan
- Field monitoring visit
- Community dialogue
- Baseline survey
- Workshop advokasi
- Pendampingan UMKM

Atribut konseptual:

- activity name
- activity code
- project
- fund allocation
- budget line
- location
- planned date
- actual date
- responsible person
- planned cost
- actual cost
- activity type
- target output
- status

Status activity:

```text
Planned → Approved → In Progress → Completed → Reported → Verified → Closed
```

---

### 4.4 Workplan

Workplan adalah rencana kerja periodik, biasanya bulanan, kuartalan, atau tahunan.

Atribut konseptual:

- workplan name
- project
- period
- activities
- responsible persons
- planned budget
- expected outputs
- approval status

---

### 4.5 Deliverable

Deliverable adalah hasil kerja yang harus diselesaikan atau diserahkan.

Contoh:

- laporan kegiatan
- training module
- policy brief
- dataset
- distribution completion report
- audit package
- dashboard
- video documentation

Atribut konseptual:

- deliverable name
- project
- activity
- due date
- responsible person
- evidence required
- completion status

---

### 4.6 Field Report

Laporan dari pelaksanaan activity di lapangan.

Atribut konseptual:

- field report number
- activity
- date
- location
- summary
- participants
- issues encountered
- lessons learned
- evidence attachments
- submitted by
- verification status

---

### 4.7 Location

Lokasi implementasi activity atau project.

Atribut konseptual:

- location name
- administrative level
- province/state
- district
- village
- GPS coordinate, jika diperlukan
- risk profile

---

## 5. Relasi Antar Entitas

```text
Program
 └── has many Project

Project
 ├── belongs to Program
 ├── funded by one or more Fund
 ├── has many Activity
 ├── has Workplan
 ├── has Deliverable
 └── has Budget Allocation

Activity
 ├── belongs to Project
 ├── uses Fund Allocation
 ├── consumes Budget Line
 ├── generates Transaction
 ├── produces Evidence
 ├── produces Field Report
 └── contributes to Indicator
```

---

## 6. Batasan Context

Mission Delivery Context menangani:

- program
- project
- activity
- workplan
- deliverable
- field report
- lokasi implementasi
- hubungan activity dengan fund dan impact

Context ini tidak menangani:

- saldo fund detail
- posting accounting
- vendor procurement detail
- donor relationship detail
- compliance rule detail
- analisis dampak lanjutan

---

## 7. Workflow Utama

### 7.1 Pembuatan Project

```text
Create Project Concept
→ Link to Program
→ Define Objective and Location
→ Identify Funding Source / Fund
→ Define Project Manager
→ Draft Budget and Workplan
→ Review by Program and Finance
→ Approve Project
→ Activate Project
```

### 7.2 Activity Planning

```text
Create Activity Plan
→ Link to Project
→ Select Fund Allocation
→ Select Budget Line
→ Define Location and Date
→ Define Planned Cost
→ Define Expected Output
→ Define Evidence Requirement
→ Submit for Approval
→ Approve Activity
```

### 7.3 Activity Implementation

```text
Approved Activity
→ Prepare Procurement / Advance / Logistics
→ Execute Activity
→ Record Actual Date and Location
→ Collect Attendance / Evidence
→ Submit Field Report
→ Review by Project Manager
→ Verify Evidence
→ Close Activity
```

### 7.4 Deliverable Completion

```text
Create Deliverable
→ Assign Responsible Person
→ Define Due Date
→ Upload Output / Evidence
→ Submit for Review
→ Approve Deliverable
→ Mark Completed
```

---

## 8. Aturan Bisnis

1. Setiap project harus berada dalam satu program.
2. Setiap activity harus berada dalam satu project.
3. Activity yang memakai dana harus terhubung ke fund allocation.
4. Activity tidak boleh meminta dana jika belum approved.
5. Activity harus memiliki responsible person.
6. Activity yang selesai harus memiliki field report, jika activity type mewajibkan.
7. Evidence requirement dapat berbeda berdasarkan activity type dan fund.
8. Project tidak boleh ditutup jika masih ada activity, advance, commitment, atau report yang belum selesai.
9. Planned cost dan actual cost harus dapat dibandingkan.
10. Activity harus dapat dihubungkan ke indicator atau output bila relevan.

---

## 9. Integrasi dengan Context Lain

| Context | Hubungan |
|---|---|
| Fund Stewardship Context | Project dan activity menerima fund allocation |
| Financial Accountability Context | Activity menghasilkan expense, advance, payment, dan budget consumption |
| Procurement & Operations Context | Activity dapat membuat purchase request, travel request, atau logistics request |
| Evidence & Compliance Context | Activity menentukan evidence requirement dan menghasilkan bukti |
| Impact & Learning Context | Activity menghasilkan output dan indicator achievement |
| Reporting Context | Project dan activity menjadi sumber laporan donor, campaign, dan impact |
| Organization Context | Project dan activity memiliki manager, department, office, dan role approval |

---

## 10. Implementasi di ERPNext/Frappe

Komponen ERPNext/Frappe yang relevan:

- Project
- Task
- Timesheet
- Cost Center
- Project Template
- Custom Field
- Workflow

Custom DocType yang mungkin dibutuhkan:

- Program
- Activity
- Activity Type
- Workplan
- Field Report
- Deliverable
- Activity Evidence Checklist
- Location / Implementation Area
- Project Fund Allocation

---

## 11. MVP Scope

Untuk MVP, Mission Delivery Context cukup mencakup:

- Program
- Project
- Activity
- Workplan sederhana
- Field Report sederhana
- Deliverable sederhana
- Link ke Fund Allocation
- Link ke Budget Line

Belum perlu:

- complex Gantt planning
- offline mobile app
- detailed beneficiary case management
- advanced geospatial mapping
- full project portfolio management

---

## 12. Risiko Desain

Risiko yang perlu dihindari:

1. Menjadikan project hanya sebagai label transaksi.
2. Tidak membedakan project dan activity.
3. Terlalu memaksa tim program memakai terminologi accounting.
4. Tidak menghubungkan activity dengan evidence dan impact.
5. Membuat activity form terlalu berat untuk field staff.
6. Tidak mendukung multi-fund project.
7. Tidak memiliki status lifecycle yang jelas.

---

## 13. Prinsip Desain

Mission Delivery Context harus mengikuti prinsip:

> Dana menjadi bermakna ketika berubah menjadi kerja misi yang nyata.

Fundara harus membantu tim program merencanakan, menjalankan, membuktikan, dan melaporkan kerja misi tanpa menjadikan sistem terasa seperti beban administrasi tambahan.
