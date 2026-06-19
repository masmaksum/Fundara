# Git Branching Strategy — Fundara

Dokumen ini mendefinisikan cara tim Fundara menggunakan Git. Aturan di sini tidak ambigu dan tidak ada pengecualian tanpa diskusi eksplisit dengan Tech Lead.

---

## Branch Structure

```
main          ← production-ready code only. Never commit directly.
staging       ← integrated code for staging / UAT environment
develop       ← integration branch for all active development
  └── feature/[domain]-[description]   ← one per story or feature group
  └── fix/[domain]-[description]       ← bug fixes
  └── docs/[topic]                     ← documentation only changes
  └── infra/[description]              ← infrastructure / DevOps changes
  └── patch/[description]              ← database migration patches
```

Domain prefixes align with Fundara module names: `fund-stewardship`, `grant`, `financial-accountability`, `procurement`, `evidence`, `reporting`, `infra`, `docs`.

---

## Branch Rules

### `main`

| Aturan | Detail |
|---|---|
| Push langsung | Tidak diizinkan untuk siapapun |
| Cara merge | PR dari `staging`, setelah UAT sign-off dari PM |
| Merge strategy | Merge commit (bukan squash) — preserves full history |
| CI yang harus lulus | All tests pass, no migration errors, staging demo verified |
| Siapa yang merge | Tech Lead only |
| Setelah merge | Tag dengan versi: `v0.1.0` |

### `staging`

| Aturan | Detail |
|---|---|
| Push langsung | Tech Lead only (untuk merge dari `develop`) |
| Cara merge | PR dari `develop` ketika sprint dinyatakan selesai oleh PM |
| Merge strategy | Merge commit |
| CI yang harus lulus | All tests pass, `bench migrate` bersih |
| Purpose | UAT, demo ke stakeholder, QA final |

### `develop`

| Aturan | Detail |
|---|---|
| Push langsung | Tidak diizinkan — semua perubahan masuk via PR |
| Cara merge | PR dari feature/fix/docs/patch branch |
| Merge strategy | Squash and merge (satu commit bersih per feature) |
| CI yang harus lulus | Unit tests, `bench migrate` bersih, tidak ada Python traceback |
| Base branch untuk PR | Semua PR fitur menggunakan `develop` sebagai base, bukan `main` |

### `feature/*`, `fix/*`, `docs/*`, `infra/*`, `patch/*`

| Aturan | Detail |
|---|---|
| Dibuat dari | `develop` yang sudah di-pull terbaru |
| Push langsung | Developer pemilik branch bebas push ke branch sendiri |
| Umur branch | Hapus setelah merge. Jangan simpan branch yang sudah merged. |
| PR target | Selalu ke `develop` |

---

## Feature Branch Lifecycle

Urutan eksak dari story start sampai merge:

```bash
# 1. Pastikan develop terbaru
git checkout develop
git pull origin develop

# 2. Buat feature branch — gunakan domain prefix yang tepat
git checkout -b feature/financial-accountability-cash-advance

# 3. Kerjakan. Commit sering dengan pesan yang bermakna.
# Setiap commit harus bisa berdiri sendiri — jangan commit broken code.
git add fundara/financial_accountability/doctype/cash_advance/
git commit -m "cash-advance: add DocType JSON with all MVP fields per spec"

git add fundara/financial_accountability/doctype/cash_advance/cash_advance.py
git commit -m "cash-advance: implement validate_fund_balance and D-02 warning"

# 4. Push ke remote
git push -u origin feature/financial-accountability-cash-advance

# 5. Buka PR di GitHub
# Base: develop (bukan main!)
# Isi PR template (lihat bagian PR Template di bawah)

# 6. PR di-review dan disetujui
# Jika ada perubahan kecil dari review, push ke branch yang sama

# 7. Squash and merge ke develop
# Lakukan via GitHub UI, bukan command line

# 8. Hapus branch setelah merge
git branch -d feature/financial-accountability-cash-advance
git push origin --delete feature/financial-accountability-cash-advance
```

---

## Commit Message Convention

Format:

```
[domain]: verb in present tense, description in English or Indonesian
```

### Contoh commit yang benar

```
fund-stewardship: add available_balance computed field to Fund
cash-advance: fix overdue flag not set when liquidation_due_date passes
grant: implement Grant Closeout Checklist validation before closing
financial-accountability: add GL posting on Cash Advance payment (D-02)
docs: update journal-entries.md with bridging fund edge case
infra: add redis memory alert to monitoring config
patch: backfill amount_base for existing Cash Advance records
evidence: wire evidence_status hook to Cash Disbursement on_submit
```

### Commit body (opsional tapi dianjurkan untuk implementasi DocType)

Ketika mengimplementasikan DocType baru, sertakan referensi ke spec di commit body:

```
fund-stewardship: implement Fund DocType with 5-state lifecycle workflow

Spec: docs/spec/doctypes/03-fund-master.md
GL rules: docs/accounting/journal-entries.md (Fund Transfer section)
Decision: D-02 — budget reduction only on Paid, not Approved
```

### Aturan commit

- Tidak ada `Co-Authored-By` di commit message — kebijakan audit trail proyek ini (lihat `CONTRIBUTING.md` seksi 9.2)
- Tidak ada "WIP", "temp", "fix stuff", "misc" — squash sebelum buka PR
- Tidak ada koma atau titik di akhir subject line
- Subject line maksimal 72 karakter
- Gunakan bahasa Indonesia atau Inggris — konsisten dalam satu commit (jangan campur)
- Verb dalam present tense: `add`, `fix`, `implement`, `update`, `remove`, `refactor` — bukan `added`, `fixed`

---

## PR Template

Paste ini sebagai deskripsi PR ketika membuka PR ke `develop`:

```markdown
## Apa yang diimplementasikan

[Deskripsi singkat — 2-3 kalimat. Apa yang dibangun, bukan bagaimana cara kerjanya secara teknis.]

## Dokumen spec yang diikuti

- [ ] `docs/spec/doctypes/[file].md`
- [ ] `docs/spec/workflows.md` (jika ada workflow baru atau perubahan workflow)
- [ ] `docs/accounting/journal-entries.md` (jika ada GL posting)
- [ ] `docs/spec/permissions.md` (jika ada DocType submittable baru)
- [ ] `DECISIONS.md` — D-02 dipatuhi (budget hanya berkurang saat Paid)

## Cara test

1. Setup: [apa yang perlu dibuat/dikonfigurasi sebelum test]
2. [Langkah test 1]
3. [Langkah test 2]
4. Expected result: [apa yang seharusnya terjadi]

## Checklist

- [ ] Unit tests pass: `bench --site fundara.local run-tests --app fundara --doctype "[DocType]"`
- [ ] No migration errors: `bench --site fundara.local migrate`
- [ ] Manual smoke test selesai sesuai skenario di atas
- [ ] Tidak ada Python traceback atau console error JS dalam penggunaan normal
- [ ] Dokumen spec diikuti dengan tepat — tidak ada field, naming, atau logika yang berbeda dari spec
- [ ] Multi-currency fields lengkap jika DocType menyimpan nilai uang: `currency`, `exchange_rate`, `amount`, `amount_base` (D-04)
- [ ] Fund dimension fields ada jika DocType transaksi: `fund`, `project`, `cost_center` (lihat `CONTRIBUTING.md` seksi 4.2)
```

---

## Release Process

### develop → staging

1. PM menyatakan sprint selesai dan semua exit criteria terpenuhi
2. Tech Lead membuka PR: `develop` → `staging`
3. CI harus lulus (semua tests, `bench migrate` bersih)
4. Tech Lead merge (merge commit, bukan squash)
5. Deploy ke staging server:
   ```bash
   bench --site fundara.staging pull
   bench --site fundara.staging migrate
   bench --site fundara.staging clear-cache
   ```
6. Tech Lead notifikasi PM bahwa staging siap untuk UAT

### staging → main

1. PM melakukan UAT dan memberikan sign-off tertulis (komentar di PR atau email)
2. Tech Lead membuka PR: `staging` → `main`
3. Merge dengan merge commit — jangan squash, agar history sprint tetap utuh
4. Langsung tag setelah merge:
   ```bash
   git tag -a v0.1.0 -m "MVP Sprint 1-2: Fund master + Cash Advance"
   git push origin v0.1.0
   ```
5. Deploy ke production:
   ```bash
   bench --site fundara.local pull
   bench --site fundara.local migrate
   bench --site fundara.local clear-cache
   bench restart
   ```

### Hotfix

Ketika ada bug kritis di production yang tidak bisa menunggu sprint berikutnya:

```bash
# 1. Branch dari main — bukan develop
git checkout main
git pull origin main
git checkout -b fix/financial-accountability-gl-double-entry

# 2. Fix dan commit
git commit -m "financial-accountability: fix GL double-entry on Cash Advance cancel"

# 3. PR ke main (bukan develop)
# Setelah merge ke main, segera buat PR yang sama ke develop
# agar fix tidak hilang pada release berikutnya

# 4. Tag patch release
git tag -a v0.1.1 -m "Hotfix: GL double-entry on Cash Advance cancel"
git push origin v0.1.1
```

> Hotfix HARUS di-merge ke dua branch: `main` DAN `develop`. Jangan lupa yang kedua.

---

## Version Tagging

Format: `v[major].[minor].[patch]`

| Komponen | Kapan naik | Contoh |
|---|---|---|
| `major` | Breaking change pada data model yang membutuhkan migrasi manual | `v1.0.0` |
| `minor` | Selesai satu sprint / feature group baru masuk production | `v0.2.0` |
| `patch` | Hotfix bug fix | `v0.1.1` |

### Tag commands

```bash
# Annotated tag (wajib untuk releases — bukan lightweight tag)
git tag -a v0.1.0 -m "MVP Sprint 1-2: Fund master + Cash Advance"
git push origin v0.1.0

# List semua tags
git tag -l

# Lihat detail sebuah tag
git show v0.1.0

# Checkout kode pada versi tertentu (read-only)
git checkout v0.1.0
```

### Rencana version untuk MVP

| Versi | Sprint | Isi |
|---|---|---|
| `v0.1.0` | Sprint 1-2 | Organization setup + Fund master |
| `v0.2.0` | Sprint 3-4 | Project + Budget + Grant track |
| `v0.3.0` | Sprint 5 | Transaction layer (Cash Receipt/Disbursement, Journal, Evidence) |
| `v0.4.0` | Sprint 6-7 | Advance & Liquidation + Fixed Asset |
| `v0.5.0` | Sprint 8-9 | Bank Reconciliation + Reports + Dashboard |
| `v0.6.0` | Sprint 10 | Hardening, demo dataset, installation docs |

---

## Frequently Asked Questions

**Q: Bisa tidak push langsung ke develop untuk perubahan kecil?**

Tidak. Semua perubahan masuk via PR, sekecil apapun. Ini bukan birokratisme — ini audit trail. Setiap perubahan di Fundara harus bisa di-trace ke story atau bug.

**Q: Kalau branch saya sudah ketinggalan jauh dari develop, bagaimana?**

```bash
git fetch origin
git rebase origin/develop
# Resolve conflicts jika ada, lalu:
git push --force-with-lease origin feature/your-branch
```

Gunakan `rebase`, bukan `merge`, agar history branch tetap bersih. `--force-with-lease` lebih aman dari `--force` karena gagal jika ada push lain yang belum kamu fetch.

**Q: Berapa lama branch boleh hidup?**

Maksimal satu sprint (2 minggu). Branch yang hidup lebih dari 2 minggu adalah sinyal bahwa story terlalu besar — diskusikan dengan Tech Lead untuk dipecah.

**Q: Apa yang harus dilakukan kalau CI gagal di PR saya?**

1. Baca log CI dengan cermat — jangan asal push fix
2. Reproduksi kegagalan di lokal: `bench --site fundara.local run-tests --app fundara`
3. Fix, commit dengan pesan yang menjelaskan root cause, push ke branch yang sama
4. Jangan buka PR baru — push ke branch yang ada, GitHub akan update PR otomatis
