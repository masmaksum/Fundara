# Evidence & Compliance Context

## 1. Ringkasan

**Evidence & Compliance Context** adalah domain yang memastikan setiap activity, transaksi, procurement, laporan, dan penggunaan fund memiliki bukti yang cukup serta memenuhi aturan donor, campaign, organisasi, board, atau regulasi.

Dalam organisasi misi sosial, bukti bukan sekadar lampiran administratif. Bukti adalah penghubung antara kepercayaan publik, penggunaan dana, kerja lapangan, dan laporan dampak. Tanpa evidence yang baik, organisasi sulit membuktikan bahwa dana telah digunakan secara benar.

Context ini menjadikan compliance sebagai bagian dari workflow, bukan pekerjaan manual yang dikejar menjelang audit.

---

## 2. Tujuan Context

Evidence & Compliance Context bertujuan untuk:

1. Mendefinisikan evidence requirement berdasarkan fund, activity, transaction, dan procurement rule.
2. Mengelola dokumen pendukung transaksi dan aktivitas.
3. Menjalankan compliance check otomatis dan manual.
4. Mencatat exception dan approval khusus.
5. Menyediakan audit trail.
6. Menyiapkan supporting document register dan audit pack.

---

## 3. Pertanyaan Domain yang Dijawab

Context ini harus mampu menjawab:

- Bukti apa yang wajib untuk transaksi ini?
- Bukti apa yang wajib untuk activity ini?
- Apakah dokumen procurement sudah lengkap?
- Apakah expense ini eligible menurut fund restriction?
- Apakah transaksi melewati threshold dan butuh approval tambahan?
- Apakah ada exception compliance?
- Siapa yang menyetujui exception?
- Dokumen mana yang masih missing?
- Apakah transaksi siap masuk donor report atau audit pack?

---

## 4. Entitas Utama

### 4.1 Evidence

Evidence adalah bukti pendukung activity, transaksi, procurement, atau laporan.

Jenis evidence:

- invoice
- receipt
- attendance list
- photo
- contract
- quotation
- bid analysis
- delivery note
- service acceptance
- training report
- field report
- beneficiary list
- payment proof
- approval memo
- travel document
- distribution list

Atribut konseptual:

- evidence number
- evidence type
- linked document type
- linked document
- file attachment
- uploaded by
- upload date
- verification status
- confidentiality level
- retention period

---

### 4.2 Evidence Type

Kategori bukti yang dipakai sistem untuk menentukan requirement.

Atribut konseptual:

- evidence type name
- description
- required metadata
- allowed file types
- default retention period
- sensitive data flag

---

### 4.3 Evidence Requirement

Aturan bukti yang wajib berdasarkan kondisi tertentu.

Contoh:

```text
Jika activity type = Training:
- attendance list wajib
- training report wajib
- photo documentation wajib

Jika purchase amount > Rp50 juta:
- minimum 3 quotation wajib
- bid analysis wajib
- procurement approval memo wajib
```

Atribut konseptual:

- requirement name
- applies to document type
- applies to fund type
- applies to activity type
- applies to amount threshold
- required evidence type
- mandatory flag
- rule status

---

### 4.4 Compliance Rule

Aturan yang harus dipenuhi.

Jenis rule:

- fund eligibility rule
- donor procurement rule
- campaign restriction rule
- budget variance rule
- document completeness rule
- approval threshold rule
- period eligibility rule
- vendor eligibility rule

Atribut konseptual:

- rule name
- rule type
- applies to fund / donor / campaign / organization
- condition
- action
- severity
- active status

Severity:

- info
- warning
- blocking
- exception allowed

---

### 4.5 Compliance Check

Hasil pemeriksaan compliance terhadap dokumen tertentu.

Atribut konseptual:

- check number
- linked document
- rule checked
- check result
- checked by
- checked at
- notes
- status

Status:

```text
Not Checked → Passed → Warning → Failed → Exception Approved
```

---

### 4.6 Exception

Pengecualian atas rule yang tidak terpenuhi.

Atribut konseptual:

- exception number
- linked document
- failed rule
- justification
- requested by
- approved by
- approval date
- risk level
- status

---

### 4.7 Audit Trail

Jejak perubahan, approval, submission, posting, dan perubahan dokumen.

Atribut konseptual:

- document type
- document reference
- action
- user
- timestamp
- old value
- new value
- reason, jika ada

---

### 4.8 Audit Pack

Kumpulan dokumen dan bukti untuk audit atau donor review.

Atribut konseptual:

- audit pack name
- fund/project/report period
- included transactions
- included evidence
- missing documents
- generated date
- reviewed by
- status

---

## 5. Relasi Antar Entitas

```text
Fund
 ├── defines Compliance Rule
 └── defines Evidence Requirement

Activity
 ├── requires Evidence
 ├── produces Evidence
 └── creates Field Report

Transaction
 ├── requires Evidence
 ├── checked by Compliance Rule
 ├── may create Exception
 └── included in Audit Pack

Procurement
 ├── requires Quotation / Bid Analysis
 └── checked by Procurement Rule

Evidence
 ├── linked to Transaction / Activity / Procurement / Report
 └── verified by User
```

---

## 6. Batasan Context

Evidence & Compliance Context menangani:

- evidence
- evidence type
- evidence requirement
- compliance rule
- compliance check
- exception
- audit trail
- audit pack

Context ini tidak menangani:

- pembuatan transaksi keuangan
- pemilihan vendor secara detail
- pengukuran impact methodology
- donor communication
- public report narrative

---

## 7. Workflow Utama

### 7.1 Evidence Requirement Setup

```text
Create Evidence Requirement
→ Define Applicable Document Type
→ Define Applicable Fund / Activity / Threshold
→ Select Required Evidence Type
→ Define Mandatory or Optional
→ Review by Compliance / Finance
→ Activate Requirement
```

### 7.2 Evidence Upload and Verification

```text
Document Submitted
→ System Determines Required Evidence
→ User Uploads Evidence
→ System Checks Completeness
→ Reviewer Verifies Evidence
→ Mark Evidence Accepted / Rejected
→ Request Correction if Needed
```

### 7.3 Compliance Check

```text
Document Submitted
→ Run Compliance Rules
→ Mark Passed / Warning / Failed
→ If Failed, Block or Request Exception
→ Reviewer Resolves Issue
→ Approve or Reject Document
```

### 7.4 Exception Approval

```text
Compliance Rule Failed
→ User Requests Exception
→ Provide Justification
→ Attach Supporting Memo
→ Review by Authorized Role
→ Approve / Reject Exception
→ Record Audit Trail
```

### 7.5 Audit Pack Generation

```text
Select Fund / Project / Period
→ Collect Transactions
→ Collect Evidence
→ Check Missing Documents
→ Generate Supporting Document Register
→ Review Audit Pack
→ Export / Archive
```

---

## 8. Aturan Bisnis

1. Evidence requirement harus dapat ditentukan berdasarkan fund, activity type, transaction type, dan amount threshold.
2. Mandatory evidence yang belum lengkap dapat memblokir approval atau posting, tergantung severity.
3. Exception harus memiliki justification dan approval.
4. Evidence sensitif harus memiliki access control khusus.
5. Dokumen yang sudah masuk audit pack tidak boleh dihapus tanpa audit trail.
6. Compliance rule harus configurable, bukan hardcoded.
7. Audit trail harus otomatis untuk tindakan penting.
8. Evidence harus dapat ditelusuri dari report line ke transaksi dan activity.
9. Rejected evidence harus menyimpan alasan penolakan.
10. Retention period harus dapat diatur berdasarkan donor, fund, atau regulasi.

---

## 9. Integrasi dengan Context Lain

| Context | Hubungan |
|---|---|
| Fund Stewardship Context | Fund menentukan restriction dan evidence requirement |
| Mission Delivery Context | Activity menghasilkan evidence dan field report |
| Financial Accountability Context | Expense dan liquidation membutuhkan evidence |
| Procurement & Operations Context | Procurement membutuhkan quotation, bid analysis, receipt, invoice |
| Reporting Context | Audit pack dan supporting document register memakai evidence |
| Organization Context | Verifier dan approver berasal dari role organisasi |
| Impact & Learning Context | Evidence mendukung output dan indicator achievement |

---

## 10. Implementasi di ERPNext/Frappe

Komponen ERPNext/Frappe yang relevan:

- File Attachment
- Document Version
- Workflow
- Assignment
- Role Permission
- Comments
- Activity Log

Custom DocType yang mungkin dibutuhkan:

- Evidence
- Evidence Type
- Evidence Requirement
- Compliance Rule
- Compliance Check
- Compliance Exception
- Audit Pack
- Supporting Document Register
- Document Retention Rule

---

## 11. MVP Scope

Untuk MVP, context ini cukup mencakup:

- Evidence Type
- Evidence Requirement sederhana
- Evidence upload
- Evidence status
- Compliance Check sederhana
- Exception request
- Supporting Document Register

Belum perlu:

- advanced rule engine
- OCR document extraction
- automated fraud detection
- legal retention policy kompleks
- secure data room untuk auditor

---

## 12. Risiko Desain

Risiko yang perlu dihindari:

1. Evidence hanya menjadi attachment tanpa status dan requirement.
2. Compliance dicek manual di akhir proses.
3. Rule hardcoded sehingga sulit mengikuti donor berbeda.
4. Tidak ada exception workflow.
5. Dokumen sensitif terbuka untuk semua user.
6. Audit trail tidak lengkap.
7. Supporting document register masih dibuat manual.

---

## 13. Prinsip Desain

Evidence & Compliance Context harus mengikuti prinsip:

> Akuntabilitas tidak boleh ditunda sampai audit; ia harus tertanam dalam alur kerja harian.

Fundara harus membantu organisasi mengumpulkan bukti dan memenuhi aturan sejak awal, bukan ketika laporan atau audit sudah mendesak.
