# Developer Guide — Fundara

Panduan ini ditujukan untuk developer yang akan mengerjakan Fundara: custom Frappe app untuk fund-centric ERP organisasi sosial berbasis ERPNext v16.

---

## 1. Onboarding — Baca Ini Dulu

### 1.1 Urutan baca dokumen

| Urutan | Dokumen | Waktu | Tujuan |
|---|---|---|---|
| 1 | `README.md` | 30 menit | Konteks produk dan konsep fund-centric |
| 2 | `DECISIONS.md` | 15 menit | 6 keputusan arsitektur yang sudah final |
| 3 | `READINESS.md` | 10 menit | Peta seluruh dokumen |
| 4 | `roadmap.md` | 20 menit | Scope MVP dan fase selanjutnya |
| 5 | `arsitektur.md` | 45 menit | Stack, struktur app, deployment |
| 6 | `workflow.md` | 60 menit | 46 proses bisnis lengkap |
| 7 | Domain context tugas pertama | 30 menit | Entitas dan business rules domain terkait |

Jangan lewati urutan ini. Developer yang langsung coding tanpa membaca DECISIONS.md akan membuat keputusan yang sudah pernah didiskusikan dan ada alasannya.

### 1.2 Keputusan arsitektur yang wajib diketahui

Semua ada di `DECISIONS.md`. Ringkasan:

| ID | Keputusan | Implikasi coding |
|---|---|---|
| D-01 | Grant = bounded context mandiri | DocType Grant terpisah dari Fund, Fund punya FK ke Grant |
| D-02 | Budget = Approved − Actual (paid only) | Jangan kurangi budget saat Approve — hanya saat Paid |
| D-03 | ERPNext v16 | API, DocType JSON, hooks mengacu v16 |
| D-04 | Multi-currency masuk MVP | Setiap Currency field wajib punya companion `currency` dan `exchange_rate` |
| D-05 | Domain context = logic, `docs/accounting/` = implementasi | Jangan duplikasi spec di dua tempat |
| D-06 | Multi-tenancy DEFERRED | Jangan design untuk multi-tenant dulu |

---

## 2. Setup Development Environment

### 2.1 Prerequisites

- Ubuntu 24.04 LTS
- Python 3.11+
- Node.js 18+
- MariaDB 10.6+
- Redis 6+
- Frappe Bench

### 2.2 Install Frappe Bench

```bash
pip install frappe-bench
bench init --frappe-branch version-16 fundara-bench
cd fundara-bench
bench new-site fundara.local --mariadb-root-password <password> --admin-password admin
```

### 2.3 Install ERPNext v16

```bash
bench get-app --branch version-16 erpnext
bench --site fundara.local install-app erpnext
```

### 2.4 Buat dan Install Custom App Fundara

```bash
bench new-app fundara
bench --site fundara.local install-app fundara
bench start
```

### 2.5 Enable Developer Mode

```bash
bench --site fundara.local set-config developer_mode 1
bench --site fundara.local clear-cache
```

---

## 3. Struktur Aplikasi

```
fundara/
├── fundara/
│   ├── hooks.py                    ← event hooks, scheduler jobs
│   ├── modules.txt                 ← daftar modul
│   ├── patches.txt                 ← patch migrations
│   │
│   ├── organization/               ← Module: Organization
│   │   └── doctype/
│   │       ├── organization/
│   │       └── department/
│   │
│   ├── funding/                    ← Module: Funding
│   │   └── doctype/
│   │       ├── funding_source/
│   │       ├── donor/
│   │       └── fundraising_campaign/
│   │
│   ├── fund_stewardship/           ← Module: Fund Stewardship
│   │   └── doctype/
│   │       ├── fund/
│   │       ├── fund_allocation/
│   │       └── fund_transfer/
│   │
│   ├── grant/                      ← Module: Grant
│   │   └── doctype/
│   │       ├── grant/
│   │       ├── grant_agreement/
│   │       └── grant_budget_line/
│   │
│   ├── mission_delivery/           ← Module: Mission Delivery
│   ├── financial_accountability/   ← Module: Financial Accountability
│   ├── procurement/                ← Module: Procurement
│   ├── evidence_compliance/        ← Module: Evidence & Compliance
│   ├── impact_learning/            ← Module: Impact & Learning
│   └── reporting/                  ← Module: Reporting
│
├── docs/
│   ├── spec/
│   │   ├── doctypes/               ← Field specs semua DocType
│   │   ├── permissions.md          ← RBAC matrix
│   │   ├── workflows.md            ← Frappe workflow configs
│   │   ├── multicurrency.md        ← Multi-currency algorithm
│   │   ├── cost-sharing.md         ← Split-fund GL formula
│   │   └── test-scenarios.md       ← 34 BDD test scenarios
│   └── accounting/
│       ├── journal-entries.md      ← 28 GL posting rules
│       └── isak-35.md              ← ISAK 35 compliance spec
│
└── fundara-domain-contexts/        ← 10 bounded context specs
```

---

## 4. Membuat DocType Baru

### 4.1 Gunakan field spec yang sudah ada

Sebelum membuat DocType, baca file yang relevan di `docs/spec/doctypes/`. Setiap DocType sudah memiliki:
- Daftar field lengkap (field name, label, fieldtype, options, mandatory)
- Naming series
- Business rules

### 4.2 Konvensi wajib

**Field names:**
- snake_case selalu
- Link ke Fund: field name = `fund`
- Link ke Project: field name = `project`
- Link ke Grant: field name = `grant`
- Tanggal posting: `posting_date`
- Tanggal mulai/selesai: `from_date`, `to_date`
- Status: selalu `status`
- Keterangan panjang: `notes`

**Multi-currency (D-04 — wajib untuk semua DocType yang menyimpan nilai uang):**
```
currency          → Link, Currency, mandatory
exchange_rate     → Float, default 1
amount            → Currency (dalam transaction currency)
amount_base       → Currency (dalam IDR, = amount × exchange_rate), read-only
```

**Fund dimension (wajib untuk semua DocType transaksi):**
```
fund              → Link, Fund, mandatory
project           → Link, Project
cost_center       → Link, Cost Center
```

**Submittable DocType:**
- Set `is_submittable = 1`
- Tambahkan `amended_from` (Link ke DocType yang sama)
- Setiap perubahan setelah submit harus lewat Amendment, bukan edit langsung

### 4.3 Membuat DocType via bench

```bash
bench --site fundara.local execute frappe.core.doctype.doctype.doctype.get_doctype --args "['Fund']"
```

Atau buat via Frappe UI (Developer Mode aktif), lalu export ke JSON:

```bash
bench --site fundara.local export-doc "DocType" "Fund"
```

---

## 5. Accounting — Journal Entry Rules

Setiap kali ada status transition yang mempengaruhi General Ledger, baca `docs/accounting/journal-entries.md` terlebih dahulu.

Format implementasi server script untuk GL posting:

```python
def post_gl_entries(doc, method):
    from erpnext.accounts.general_ledger import make_gl_entries
    
    gl_entries = []
    
    # Debit side
    gl_entries.append(doc.get_gl_dict({
        "account": doc.expense_account,
        "debit": doc.amount_base,
        "debit_in_account_currency": doc.amount,
        "against": doc.fund,
        "cost_center": doc.cost_center,
        # Custom dimensions
        "fund": doc.fund,
        "project": doc.project,
    }))
    
    # Credit side
    gl_entries.append(doc.get_gl_dict({
        "account": "Kas/Bank",
        "credit": doc.amount_base,
        "credit_in_account_currency": doc.amount,
        "against": doc.fund,
    }))
    
    make_gl_entries(gl_entries)
```

**D-02 constraint:** budget check dan budget reduction hanya dipanggil saat status = `Paid`, bukan saat `Approved`.

---

## 6. Frappe Workflow

Konfigurasi workflow ada di `docs/spec/workflows.md`. Implementasi via:

1. **Frappe UI** — Setup > Workflow, buat workflow baru sesuai spec
2. **JSON fixture** — buat file di `fundara/fixtures/workflow/[workflow_name].json`

Untuk load fixtures otomatis, tambahkan ke `hooks.py`:

```python
fixtures = [
    {"dt": "Workflow", "filters": [["module", "=", "Fundara"]]},
    {"dt": "Workflow Action Master"},
    {"dt": "Workflow State"},
]
```

---

## 7. Permission Setup

Baca `docs/spec/permissions.md` untuk matriks lengkap. Setup via:

```bash
bench --site fundara.local execute frappe.permissions.reset_perms --args "['Fund']"
```

Atau via Frappe UI: Setup > Role Permission Manager.

Untuk conditional permissions (user hanya bisa edit record milik sendiri), gunakan `has_permission` hook:

```python
# hooks.py
has_permission = {
    "Activity": "fundara.mission_delivery.doctype.activity.activity.has_permission"
}

# activity.py
def has_permission(doc, ptype, user):
    if ptype == "write" and frappe.get_roles(user) == ["Project Manager"]:
        return doc.project_manager == user
    return True
```

---

## 8. Testing

### 8.1 Skenario BDD

Semua test scenario ada di `docs/spec/test-scenarios.md` dalam format Given/When/Then. Gunakan ini sebagai dasar unit test dan UAT checklist.

### 8.2 Membuat unit test

```python
# fundara/fund_stewardship/doctype/fund/test_fund.py
import frappe
import unittest

class TestFund(unittest.TestCase):
    def test_fund_balance_paid_only(self):
        """D-02: budget hanya berkurang saat Paid, bukan Approved"""
        fund = frappe.get_doc("Fund", "FUND-2026-0001")
        advance = frappe.get_doc({
            "doctype": "Cash Advance",
            "fund": fund.name,
            "amount": 3000000,
            "status": "Approved"
        }).insert()
        
        balance_after_approve = fund.get_available_balance()
        self.assertEqual(balance_after_approve, fund.approved_budget)
        
        advance.status = "Paid"
        advance.save()
        
        balance_after_paid = fund.get_available_balance()
        self.assertEqual(balance_after_paid, fund.approved_budget - 3000000)
```

### 8.3 Jalankan test

```bash
bench --site fundara.local run-tests --app fundara --module fund_stewardship
```

---

## 9. Git Workflow

### 9.1 Branch naming

```
feature/[domain]-[deskripsi-singkat]   → feature/fund-stewardship-balance-calc
fix/[domain]-[deskripsi]               → fix/cash-advance-overdue-trigger
docs/[topik]                           → docs/journal-entry-multicurrency
```

### 9.2 Commit message

Gunakan format:

```
[domain]: [deskripsi singkat dalam bahasa Indonesia atau Inggris]

Contoh:
fund-stewardship: tambah validasi fund period saat posting transaksi
cash-advance: fix status transition Approved -> Paid tidak update budget
grant: implementasi auto-generate Grant Reporting Schedule dari Agreement
```

**Jangan gunakan Co-Authored-By** di commit message — ini kebijakan audit trail proyek ini.

### 9.3 Sebelum push

```bash
bench --site fundara.local run-tests --app fundara
bench --site fundara.local clear-cache
```

---

## 10. Referensi Cepat

| Butuh apa | Lihat di mana |
|---|---|
| Field spec DocType X | `docs/spec/doctypes/[XX]-*.md` |
| Aturan GL posting untuk transaksi Y | `docs/accounting/journal-entries.md` |
| Siapa yang bisa approve Z | `docs/spec/permissions.md` + `docs/spec/workflows.md` |
| Cara hitung exchange rate | `docs/spec/multicurrency.md` |
| Cara split expense ke 3 fund | `docs/spec/cost-sharing.md` |
| Skenario test untuk fitur W | `docs/spec/test-scenarios.md` |
| Business rules domain V | `fundara-domain-contexts/[XX]-*.md` |
| Keputusan arsitektur | `DECISIONS.md` |
| Scope MVP | `roadmap.md` seksi 3 |
| ERPNext v16 API docs | https://frappeframework.com/docs |
