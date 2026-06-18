# Impact & Learning Context

## 1. Ringkasan

**Impact & Learning Context** adalah domain yang menghubungkan kerja misi dengan hasil, pembelajaran, dan dampak. Context ini mencakup impact framework, outcome, output, indicator, target, achievement, beneficiary group, feedback, dan learning.

Fundara bukan hanya platform dana dan operasi. Sebagai Mission Impact Platform, Fundara harus mampu menunjukkan bagaimana fund dan activity berkontribusi terhadap hasil yang terukur. Context ini menjawab: apa yang berubah karena pekerjaan organisasi, bagaimana perubahan itu diukur, dan apa yang dipelajari untuk memperbaiki program.

---

## 2. Tujuan Context

Impact & Learning Context bertujuan untuk:

1. Mendefinisikan kerangka dampak organisasi.
2. Menghubungkan program, project, dan activity dengan output, outcome, dan indicator.
3. Mencatat target dan achievement.
4. Mendukung disaggregated data bila diperlukan.
5. Menghubungkan evidence dengan capaian impact.
6. Mendukung learning, feedback, dan perbaikan program.
7. Menyediakan data untuk impact report dan donor report.

---

## 3. Pertanyaan Domain yang Dijawab

Context ini harus mampu menjawab:

- Dampak apa yang ingin dicapai organisasi?
- Outcome apa yang didukung oleh program atau project?
- Output apa yang dihasilkan activity?
- Indicator apa yang digunakan untuk mengukur capaian?
- Target dan actual achievement berapa?
- Siapa penerima manfaatnya?
- Bukti apa yang mendukung capaian tersebut?
- Apa pembelajaran dari activity atau project?
- Berapa biaya per output?
- Bagaimana dana berhubungan dengan dampak?

---

## 4. Entitas Utama

### 4.1 Impact Framework

Kerangka dampak organisasi, program, atau project.

Atribut konseptual:

- framework name
- scope: organization/program/project
- theory of change summary
- strategic objective
- period
- owner
- status

---

### 4.2 Outcome

Outcome adalah perubahan yang ingin dicapai.

Contoh:

- peningkatan akses pendidikan
- peningkatan pendapatan keluarga
- peningkatan ketahanan komunitas
- penurunan risiko kekerasan
- peningkatan kapasitas organisasi lokal

Atribut konseptual:

- outcome statement
- impact framework
- outcome level
- target group
- period
- owner

---

### 4.3 Output

Output adalah hasil langsung dari activity.

Contoh:

- 100 guru dilatih
- 500 paket bantuan didistribusikan
- 10 desa didampingi
- 1 policy brief diterbitkan
- 25 UMKM menerima pendampingan

Atribut konseptual:

- output name
- activity
- output type
- unit
- target
- actual
- evidence

---

### 4.4 Indicator

Indicator adalah ukuran capaian.

Jenis indicator:

- output indicator
- outcome indicator
- impact indicator
- process indicator
- financial efficiency indicator

Atribut konseptual:

- indicator name
- indicator code
- indicator type
- unit of measure
- baseline
- target
- frequency
- data source
- disaggregation requirement
- responsible person

---

### 4.5 Indicator Achievement

Capaian aktual indicator pada periode tertentu.

Atribut konseptual:

- indicator
- project
- activity
- reporting period
- actual value
- evidence
- submitted by
- verified by
- verification status

---

### 4.6 Beneficiary / Participant

Penerima manfaat atau peserta kegiatan.

Catatan: data beneficiary dapat sangat sensitif. Desain harus privacy-aware dan safeguarding-aware.

Atribut konseptual:

- beneficiary code
- beneficiary group
- demographic attributes, jika diperlukan
- location
- consent status
- service received
- privacy level

---

### 4.7 Beneficiary Group

Kelompok penerima manfaat tanpa harus menyimpan data individu detail.

Contoh:

- perempuan kepala keluarga
- anak usia sekolah
- guru sekolah dasar
- UMKM perempuan
- komunitas terdampak bencana

---

### 4.8 Feedback / Complaint

Umpan balik atau keluhan dari komunitas, beneficiary, donor, atau stakeholder.

Atribut konseptual:

- feedback number
- source type
- project/activity
- category
- description
- severity
- response status
- resolution

---

### 4.9 Learning Note

Catatan pembelajaran dari implementasi program atau activity.

Atribut konseptual:

- learning note title
- project/activity
- what worked
- what did not work
- recommendation
- tags
- shared with

---

## 5. Relasi Antar Entitas

```text
Program
 └── has Impact Framework

Impact Framework
 ├── defines Outcome
 ├── defines Indicator
 └── linked to Project

Project
 ├── contributes to Outcome
 ├── has Indicator
 ├── reaches Beneficiary Group
 └── produces Indicator Achievement

Activity
 ├── produces Output
 ├── records Indicator Achievement
 ├── reaches Beneficiary / Participant
 ├── collects Evidence
 └── generates Learning Note
```

---

## 6. Batasan Context

Impact & Learning Context menangani:

- impact framework
- outcome
- output
- indicator
- target
- achievement
- beneficiary group
- feedback
- complaint
- learning note

Context ini tidak menangani:

- fund balance detail
- accounting transaction
- procurement detail
- donor contract detail
- raw survey platform management

Survey atau data collection eksternal seperti Kobo/ODK dapat diintegrasikan, tetapi tidak harus menjadi bagian inti context ini pada MVP.

---

## 7. Workflow Utama

### 7.1 Impact Framework Setup

```text
Create Impact Framework
→ Define Outcomes
→ Define Indicators
→ Define Baseline and Target
→ Define Data Source
→ Assign Responsible Person
→ Review by Program / MEAL
→ Approve Framework
```

### 7.2 Indicator Achievement Recording

```text
Activity Completed
→ Select Related Indicator
→ Enter Actual Achievement
→ Add Disaggregation if Required
→ Attach Evidence
→ Submit Achievement
→ MEAL Review
→ Verify Achievement
→ Include in Report
```

### 7.3 Feedback Handling

```text
Receive Feedback / Complaint
→ Classify Category and Severity
→ Assign Responsible Person
→ Investigate
→ Respond / Resolve
→ Record Resolution
→ Close Feedback
→ Include Learning if Relevant
```

### 7.4 Learning Capture

```text
Activity / Project Review
→ Document Lessons Learned
→ Identify Recommendations
→ Tag by Theme
→ Share with Program Team
→ Apply to Future Workplan
```

---

## 8. Aturan Bisnis

1. Indicator harus memiliki unit of measure.
2. Indicator achievement harus terhubung ke project atau activity.
3. Outcome harus berada dalam impact framework.
4. Data beneficiary sensitif harus memiliki access control khusus.
5. Achievement yang masuk laporan harus sudah diverifikasi.
6. Evidence untuk achievement harus dapat ditelusuri.
7. Feedback berisiko tinggi harus memiliki escalation workflow.
8. Learning note harus dapat dihubungkan ke project atau activity.
9. Cost per output hanya dapat dihitung jika activity cost dan output terhubung.
10. Disaggregation hanya dikumpulkan jika memang diperlukan dan aman secara privasi.

---

## 9. Integrasi dengan Context Lain

| Context | Hubungan |
|---|---|
| Mission Delivery Context | Activity menghasilkan output, achievement, dan learning |
| Fund Stewardship Context | Fund dapat ditelusuri ke impact melalui activity |
| Financial Accountability Context | Biaya activity dapat dibandingkan dengan output |
| Evidence & Compliance Context | Evidence mendukung capaian indicator |
| Reporting Context | Impact report dan donor report memakai indicator achievement |
| Organization Context | MEAL officer dan program manager menjadi owner dan verifier |

---

## 10. Implementasi di ERPNext/Frappe

Komponen ERPNext/Frappe yang relevan:

- Project
- Task
- Custom DocType
- Dashboard
- Report Builder
- File Attachment
- Role Permission

Custom DocType yang mungkin dibutuhkan:

- Impact Framework
- Outcome
- Output
- Indicator
- Indicator Target
- Indicator Achievement
- Beneficiary Group
- Beneficiary Profile, opsional dan privacy-aware
- Feedback / Complaint
- Learning Note
- Disaggregation Category

---

## 11. MVP Scope

Untuk MVP, context ini cukup mencakup:

- Impact Framework sederhana
- Outcome
- Indicator
- Indicator Target
- Indicator Achievement
- Output per Activity
- Evidence link
- Basic Impact Report

Belum perlu:

- full beneficiary case management
- advanced survey builder
- complex statistical analysis
- longitudinal beneficiary tracking
- AI-based impact analysis

---

## 12. Risiko Desain

Risiko yang perlu dihindari:

1. Menganggap impact hanya sebagai angka indicator.
2. Tidak menghubungkan impact dengan activity.
3. Tidak menghubungkan impact dengan fund dan biaya.
4. Mengumpulkan data beneficiary terlalu detail tanpa kebutuhan jelas.
5. Tidak memikirkan consent dan privacy.
6. Membuat MEAL terlalu terpisah dari operasi harian.
7. Tidak menyediakan ruang untuk pembelajaran kualitatif.

---

## 13. Prinsip Desain

Impact & Learning Context harus mengikuti prinsip:

> Dampak bukan hanya dilaporkan di akhir; dampak dibangun, dibuktikan, dan dipelajari sepanjang perjalanan misi.

Fundara harus membantu organisasi tidak hanya membuktikan hasil, tetapi juga belajar dari pekerjaan mereka untuk meningkatkan dampak sosial dari waktu ke waktu.
