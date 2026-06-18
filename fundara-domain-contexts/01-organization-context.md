# Organization Context

## 1. Ringkasan

**Organization Context** adalah domain yang menggambarkan struktur dasar organisasi pengguna Fundara. Context ini menjawab pertanyaan: siapa organisasi yang memakai Fundara, bagaimana struktur internalnya, siapa saja aktornya, dan bagaimana hak akses serta tanggung jawab dibagi.

Dalam Mission Impact Platform seperti Fundara, organisasi bukan sekadar `Company` dalam sistem akuntansi. Organisasi adalah entitas misi sosial yang memiliki struktur hukum, cabang, unit kerja, program, sumber daya manusia, dan mandat akuntabilitas kepada donor, publik, board, komunitas, serta penerima manfaat.

Context ini menjadi fondasi bagi semua domain lain karena fund, project, transaksi, laporan, dan dampak selalu terjadi di dalam konteks organisasi tertentu.

---

## 2. Tujuan Context

Organization Context bertujuan untuk:

1. Mendefinisikan identitas dan struktur organisasi.
2. Mengelola kantor, cabang, unit, dan cost center.
3. Menentukan role, permission, dan tanggung jawab pengguna.
4. Menyediakan struktur dasar untuk approval workflow.
5. Menjadi dasar segmentasi laporan organisasi.
6. Mendukung organisasi multi-cabang, multi-program, dan multi-lokasi.

---

## 3. Pertanyaan Domain yang Dijawab

Organization Context harus mampu menjawab:

- Organisasi apa yang sedang dikelola?
- Apakah organisasi memiliki beberapa cabang atau kantor lapangan?
- Unit mana yang bertanggung jawab atas program, finance, procurement, MEAL, fundraising, atau unit usaha?
- Siapa yang boleh membuat, menyetujui, melihat, atau mengubah dokumen tertentu?
- Cost center mana yang menanggung biaya tertentu?
- Bagaimana struktur approval mengikuti struktur organisasi?
- Laporan perlu dipisahkan berdasarkan kantor, unit, cost center, atau wilayah?

---

## 4. Entitas Utama

### 4.1 Organization

Mewakili entitas utama pengguna Fundara, misalnya NGO, yayasan, komunitas, lembaga filantropi, faith-based organization, social enterprise, atau organisasi misi sosial lainnya.

Atribut konseptual:

- organization name
- legal name
- organization type
- registration number
- country
- base currency
- fiscal year
- default language
- tax profile
- legal status
- mission statement
- website
- active status

Contoh organization type:

- NGO
- Yayasan
- Komunitas
- Social Enterprise
- Lembaga Filantropi
- Faith-based Organization
- Koperasi Sosial
- Program CSR

---

### 4.2 Office / Branch

Mewakili struktur lokasi operasional organisasi.

Contoh:

- Kantor Nasional
- Kantor Regional Jawa Barat
- Field Office Kupang
- Warehouse Medan
- Training Center Yogyakarta

Atribut konseptual:

- office name
- office code
- address
- city
- province/state
- country
- office type
- manager
- active status

Office type:

- head office
- regional office
- field office
- warehouse
- project site
- business unit location

---

### 4.3 Department / Unit

Mewakili unit kerja internal organisasi.

Contoh:

- Program
- Finance
- Operations
- Procurement
- HR
- Fundraising
- Grant Management
- MEAL
- Communications
- Social Enterprise Unit

Atribut konseptual:

- department name
- department code
- parent department
- department head
- linked cost center
- active status

---

### 4.4 Cost Center

Cost Center adalah struktur biaya internal organisasi. Dalam konteks Fundara, cost center dipakai untuk membaca biaya berdasarkan struktur organisasi, bukan untuk menggantikan Fund, Project, atau Activity.

Contoh:

- Head Office
- Finance Department
- Program Education
- Fundraising Team
- Training Center Business Unit

Atribut konseptual:

- cost center name
- cost center code
- parent cost center
- department
- office
- active status

---

### 4.5 User

Mewakili orang yang menggunakan sistem.

Atribut konseptual:

- full name
- email
- employee reference
- office
- department
- default role
- active status
- supervisor

---

### 4.6 Role

Role menentukan hak akses dan tanggung jawab dalam sistem.

Contoh role:

- Executive Director
- Finance Manager
- Finance Officer
- Program Manager
- Project Officer
- Field Staff
- Procurement Officer
- Grant Manager
- Fundraising Officer
- MEAL Officer
- HR Officer
- Auditor
- Board Viewer
- System Administrator

---

### 4.7 Delegation of Authority

Mewakili aturan siapa boleh menyetujui apa, berdasarkan nominal, jenis dokumen, fund type, project, atau unit.

Atribut konseptual:

- authority name
- role
- document type
- minimum amount
- maximum amount
- applicable fund type
- applicable department
- applicable project
- approval level
- active period

---

## 5. Relasi Antar Entitas

```text
Organization
 ├── has many Office / Branch
 ├── has many Department / Unit
 ├── has many Cost Center
 ├── has many User
 ├── has many Role
 └── has Delegation of Authority

Office
 ├── belongs to Organization
 ├── has many Department presence
 └── may own Warehouse / Location

Department
 ├── belongs to Organization
 ├── may have parent Department
 ├── has many User
 └── linked to Cost Center

User
 ├── belongs to Organization
 ├── belongs to Office
 ├── belongs to Department
 ├── has Role
 └── may have Supervisor
```

---

## 6. Batasan Context

Organization Context menangani:

- struktur organisasi
- user dan role
- office, department, cost center
- delegation of authority
- permission dasar
- approval hierarchy

Organization Context tidak menangani:

- detail payroll
- detail grant agreement
- transaksi akuntansi
- pencatatan dampak
- procurement detail
- laporan donor detail

Domain lain boleh menggunakan Organization Context sebagai referensi, tetapi tidak boleh mencampur logika domainnya ke dalam context ini.

---

## 7. Workflow Utama

### 7.1 Setup Organisasi

```text
Create Organization
→ Define Fiscal Year and Base Currency
→ Create Offices / Branches
→ Create Departments
→ Create Cost Centers
→ Create Roles
→ Create Users
→ Assign Users to Role, Office, Department
→ Define Delegation of Authority
→ Activate Organization Setup
```

### 7.2 Perubahan Struktur Organisasi

```text
Draft Change Request
→ Review by Admin / Management
→ Check Impact on Existing Workflow
→ Approve Change
→ Update Office / Department / Cost Center
→ Reassign Users if Needed
→ Archive Old Structure Reference
```

### 7.3 Delegasi Approval

```text
Create Delegation Rule
→ Define Document Type
→ Define Role / User
→ Define Amount Threshold
→ Define Applicable Fund / Project / Department
→ Review by Management
→ Activate Rule
→ Apply in Workflow Engine
```

---

## 8. Aturan Bisnis

1. Setiap user harus terhubung ke minimal satu organization.
2. Setiap user aktif harus memiliki minimal satu role.
3. Approval rule harus jelas berdasarkan role, bukan hanya nama individu.
4. Department boleh berubah, tetapi histori dokumen lama harus tetap membaca struktur pada saat transaksi terjadi.
5. Cost center tidak boleh menggantikan Fund atau Project.
6. User dengan role auditor boleh melihat data, tetapi tidak boleh mengubah transaksi.
7. Perubahan delegation of authority harus tercatat dalam audit trail.
8. Struktur organisasi harus mendukung multi-office dan multi-program sejak awal.

---

## 9. Integrasi dengan Context Lain

| Context | Hubungan |
|---|---|
| Funding Context | Funding source memiliki relationship owner dari organisasi |
| Fund Stewardship Context | Fund memiliki fund owner, approval authority, dan responsible unit |
| Mission Delivery Context | Project dan Activity memiliki manager, office, department, dan responsible person |
| Financial Accountability Context | Transaksi memakai cost center, department, dan approval structure |
| Procurement & Operations Context | Purchase request mengikuti delegation of authority |
| Evidence & Compliance Context | Compliance responsibility dapat ditugaskan ke role tertentu |
| Impact & Learning Context | Indicator owner dapat berupa department atau project team |
| Reporting Context | Report owner dan reviewer berasal dari role organisasi |

---

## 10. Implementasi di ERPNext/Frappe

Komponen ERPNext/Frappe yang dapat dipakai:

- Company
- Branch
- Department
- Cost Center
- User
- Role
- Role Permission Manager
- Workflow
- Employee, jika HR module digunakan

Custom DocType yang mungkin dibutuhkan:

- Organization Profile
- Delegation of Authority
- Approval Matrix
- Organization Unit Mapping
- Program Role Assignment
- Office Permission Rule

---

## 11. MVP Scope

Untuk MVP, Organization Context cukup mencakup:

- Organization
- Office / Branch
- Department
- Cost Center
- User
- Role
- Delegation of Authority sederhana

Belum perlu:

- full HR structure
- payroll
- performance management
- complex matrix organization
- multi-entity consolidation

---

## 12. Risiko Desain

Risiko yang perlu dihindari:

1. Menjadikan struktur organisasi terlalu kaku sehingga sulit dipakai NGO kecil.
2. Membuat cost center terlalu dominan sampai menutupi konsep Fund dan Project.
3. Permission terlalu kompleks di MVP.
4. Approval berbasis individu, bukan role, sehingga sulit dipelihara.
5. Tidak menyimpan histori struktur organisasi pada transaksi lama.

---

## 13. Prinsip Desain

Organization Context harus mengikuti prinsip:

> Struktur organisasi harus membantu akuntabilitas, bukan menambah birokrasi.

Artinya, desain harus cukup kuat untuk approval dan laporan, tetapi tetap sederhana bagi organisasi kecil dan menengah.
