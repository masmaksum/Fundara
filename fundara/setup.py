"""
Layer 0 ERPNext configuration for Fundara.
Run once after site creation:
    bench --site <site> execute fundara.setup.setup_layer_0
"""

import frappe
from frappe import _


COMPANY_NAME = "Yayasan Fundara"
COMPANY_ABBR = "YF"
BASE_CURRENCY = "IDR"
FISCAL_YEAR = 2026


def setup_layer_0():
    """
    Idempotent Layer 0 bootstrap. Each section commits on success so partial
    runs can be resumed safely without re-running completed sections.
    """
    frappe.set_user("Administrator")

    # Pre-requisites (no external dependencies)
    _setup_currencies()
    _setup_warehouse_types()
    _setup_roles()
    _setup_workflow_states()
    frappe.db.commit()

    # Company + dependents (order matters)
    _setup_company()
    frappe.db.commit()
    _setup_fiscal_year()
    _setup_cost_centers()
    frappe.db.commit()
    _setup_bank_account()
    _setup_location()
    frappe.db.commit()

    # Workflow + Workspace (depend on roles + states existing)
    _setup_doa_workflow()
    _setup_workspace()
    frappe.db.commit()

    print("Layer 0 setup complete.")


# ---------------------------------------------------------------------------
# Currencies
# ---------------------------------------------------------------------------

def _setup_currencies():
    for symbol, fraction, enabled in [
        ("IDR", "Sen", 1),
        ("USD", "Cent", 1),
        ("EUR", "Cent", 1),
    ]:
        if not frappe.db.exists("Currency", symbol):
            frappe.get_doc({
                "doctype": "Currency",
                "currency_name": symbol,
                "symbol": symbol,
                "fraction": fraction,
                "enabled": enabled,
            }).insert(ignore_permissions=True)
        else:
            frappe.db.set_value("Currency", symbol, "enabled", 1)

    frappe.db.set_value("Global Defaults", "Global Defaults", "default_currency", BASE_CURRENCY)
    print("  Currencies: IDR, USD, EUR enabled.")


# ---------------------------------------------------------------------------
# Company
# ---------------------------------------------------------------------------

def _setup_warehouse_types():
    """ERPNext requires Warehouse Type 'Transit' when creating a company."""
    for wtype in ["Transit", "Stores", "Manufacturing"]:
        if not frappe.db.exists("Warehouse Type", wtype):
            frappe.get_doc({
                "doctype": "Warehouse Type",
                "name": wtype,
            }).insert(ignore_permissions=True)
    print("  Warehouse Types verified/created.")


def _setup_company():
    if frappe.db.exists("Company", COMPANY_NAME):
        print(f"  Company '{COMPANY_NAME}' already exists, skipping.")
        return

    frappe.local.flags.ignore_chart_of_accounts = False
    company = frappe.get_doc({
        "doctype": "Company",
        "company_name": COMPANY_NAME,
        "abbr": COMPANY_ABBR,
        "default_currency": BASE_CURRENCY,
        "country": "Indonesia",
        "create_chart_of_accounts_based_on": "Standard Template",
        "chart_of_accounts": "Standard with Numbers",
    })
    company.insert(ignore_permissions=True)

    # Ensure CoA was created (may be skipped if flag was set before insert)
    account_count = frappe.db.count("Account", {"company": COMPANY_NAME})
    if not account_count:
        company.create_default_accounts()
        frappe.db.commit()

    print(f"  Company '{COMPANY_NAME}' created.")


# ---------------------------------------------------------------------------
# Fiscal Year
# ---------------------------------------------------------------------------

def _setup_fiscal_year():
    fy_name = f"{FISCAL_YEAR}"
    if frappe.db.exists("Fiscal Year", fy_name):
        print(f"  Fiscal Year {fy_name} already exists, skipping.")
        return

    fy = frappe.get_doc({
        "doctype": "Fiscal Year",
        "year": fy_name,
        "year_start_date": f"{FISCAL_YEAR}-01-01",
        "year_end_date": f"{FISCAL_YEAR}-12-31",
    })
    fy.insert(ignore_permissions=True)
    frappe.db.set_value("Global Defaults", "Global Defaults", "current_fiscal_year", fy_name)
    print(f"  Fiscal Year {fy_name} created.")


# ---------------------------------------------------------------------------
# Cost Centers
# ---------------------------------------------------------------------------

def _setup_cost_centers():
    root_cc = f"{COMPANY_NAME} - {COMPANY_ABBR}"

    hierarchy = [
        # (name, parent, is_group)
        ("Head Office - YF", root_cc, 0),
        ("Programs - YF", root_cc, 1),
        ("Finance & Admin - YF", root_cc, 0),
        ("Field Operations - YF", root_cc, 1),
        ("Program A - YF", "Programs - YF", 0),
        ("Program B - YF", "Programs - YF", 0),
        ("Field Office Jakarta - YF", "Field Operations - YF", 0),
        ("Field Office Bandung - YF", "Field Operations - YF", 0),
    ]

    for cc_name, parent_name, is_group in hierarchy:
        if frappe.db.exists("Cost Center", cc_name):
            continue
        if not frappe.db.exists("Cost Center", parent_name):
            print(f"  Skipping Cost Center '{cc_name}': parent '{parent_name}' not found.")
            continue
        frappe.get_doc({
            "doctype": "Cost Center",
            "cost_center_name": cc_name.split(" - ")[0],
            "parent_cost_center": parent_name,
            "company": COMPANY_NAME,
            "is_group": is_group,
        }).insert(ignore_permissions=True)

    print("  Cost Center hierarchy created.")


# ---------------------------------------------------------------------------
# Bank Account
# ---------------------------------------------------------------------------

def _setup_bank_account():
    bank_name = "Bank BNI"
    if not frappe.db.exists("Bank", bank_name):
        frappe.get_doc({
            "doctype": "Bank",
            "bank_name": bank_name,
        }).insert(ignore_permissions=True)

    if frappe.db.exists("Bank Account", f"Rekening Operasional IDR - {COMPANY_ABBR}"):
        print("  Bank Account already exists, skipping.")
        return

    # Standard CoA has a group bank account; create a leaf account under it
    bank_group = frappe.db.get_value(
        "Account",
        {"company": COMPANY_NAME, "account_type": "Bank", "is_group": 1},
        "name",
    )
    leaf_account_name = f"Rekening Operasional IDR - {COMPANY_ABBR}"
    if bank_group and not frappe.db.exists("Account", leaf_account_name):
        frappe.get_doc({
            "doctype": "Account",
            "account_name": "Rekening Operasional IDR",
            "parent_account": bank_group,
            "company": COMPANY_NAME,
            "account_type": "Bank",
            "is_group": 0,
            "currency": BASE_CURRENCY,
        }).insert(ignore_permissions=True)

    bank_account_head = frappe.db.get_value(
        "Account",
        {"company": COMPANY_NAME, "account_type": "Bank", "is_group": 0},
        "name",
    )

    if not bank_account_head:
        print("  No Bank-type leaf account found in CoA. Skipping Bank Account creation.")
        return

    frappe.get_doc({
        "doctype": "Bank Account",
        "account_name": "Rekening Operasional IDR",
        "bank": bank_name,
        "account": bank_account_head,
        "company": COMPANY_NAME,
        "currency": BASE_CURRENCY,
    }).insert(ignore_permissions=True)
    print("  Bank Account 'Rekening Operasional IDR' created.")


# ---------------------------------------------------------------------------
# Location
# ---------------------------------------------------------------------------

def _setup_location():
    if frappe.db.exists("Location", "Head Office Jakarta"):
        print("  Location already exists, skipping.")
        return

    frappe.get_doc({
        "doctype": "Location",
        "location_name": "Head Office Jakarta",
    }).insert(ignore_permissions=True)
    print("  Location 'Head Office Jakarta' created.")


# ---------------------------------------------------------------------------
# Roles
# ---------------------------------------------------------------------------

# Custom roles not bundled with ERPNext.
# System Manager and Finance Manager are ERPNext built-ins — verified to exist
# but not recreated here.
_MVP_CUSTOM_ROLES = [
    "Finance Officer",
    "Program Manager",
    "Project Officer",
    "Executive Viewer",
    "Auditor Viewer",
]


def _setup_roles():
    for role_name in _MVP_CUSTOM_ROLES:
        if not frappe.db.exists("Role", role_name):
            frappe.get_doc({
                "doctype": "Role",
                "role_name": role_name,
                "desk_access": 1,
            }).insert(ignore_permissions=True)
    print("  MVP custom roles verified/created.")


# ---------------------------------------------------------------------------
# Workflow States
# ---------------------------------------------------------------------------

_WORKFLOW_STATES = [
    ("Draft", ""),
    ("Under Review", ""),
    ("Approved", "Success"),
    ("Rejected", "Danger"),
    ("Cancelled", "Inverse"),
    ("Pending", "Warning"),
]


def _setup_workflow_states():
    for state_name, style in _WORKFLOW_STATES:
        if not frappe.db.exists("Workflow State", state_name):
            doc = {
                "doctype": "Workflow State",
                "workflow_state_name": state_name,
            }
            if style:
                doc["style"] = style
            frappe.get_doc(doc).insert(ignore_permissions=True)
    print("  Workflow States verified/created.")


# ---------------------------------------------------------------------------
# Delegation of Authority Workflow
# ---------------------------------------------------------------------------

_DOA_EXTRA_ACTIONS = ["Submit for Review", "Revise", "Cancel"]


def _setup_doa_workflow():
    if frappe.db.exists("Workflow", "Delegation of Authority"):
        print("  DoA Workflow already exists, skipping.")
        return

    for action in _DOA_EXTRA_ACTIONS:
        if not frappe.db.exists("Workflow Action Master", action):
            frappe.get_doc({
                "doctype": "Workflow Action Master",
                "workflow_action_name": action,
            }).insert(ignore_permissions=True)

    frappe.get_doc({
        "doctype": "Workflow",
        "workflow_name": "Delegation of Authority",
        "document_type": "Delegation of Authority",
        "workflow_state_field": "workflow_state",
        "is_active": 1,
        "states": [
            {
                "doctype": "Workflow Document State",
                "state": "Draft",
                "doc_status": "0",
                "allow_edit": "Program Manager",
            },
            {
                "doctype": "Workflow Document State",
                "state": "Under Review",
                "doc_status": "0",
                "allow_edit": "Finance Manager",
            },
            {
                "doctype": "Workflow Document State",
                "state": "Approved",
                "doc_status": "1",
                "allow_edit": "Finance Manager",
            },
            {
                "doctype": "Workflow Document State",
                "state": "Rejected",
                "doc_status": "0",
                "allow_edit": "Finance Manager",
            },
            {
                "doctype": "Workflow Document State",
                "state": "Cancelled",
                "doc_status": "2",
                "allow_edit": "Finance Manager",
            },
        ],
        "transitions": [
            {
                "doctype": "Workflow Transition",
                "state": "Draft",
                "action": "Submit for Review",
                "next_state": "Under Review",
                "allowed": "Program Manager",
            },
            {
                "doctype": "Workflow Transition",
                "state": "Under Review",
                "action": "Approve",
                "next_state": "Approved",
                "allowed": "Finance Manager",
            },
            {
                "doctype": "Workflow Transition",
                "state": "Under Review",
                "action": "Reject",
                "next_state": "Rejected",
                "allowed": "Finance Manager",
            },
            {
                "doctype": "Workflow Transition",
                "state": "Rejected",
                "action": "Revise",
                "next_state": "Draft",
                "allowed": "Program Manager",
            },
            {
                "doctype": "Workflow Transition",
                "state": "Approved",
                "action": "Cancel",
                "next_state": "Cancelled",
                "allowed": "Finance Manager",
            },
        ],
    }).insert(ignore_permissions=True)
    print("  DoA Workflow created.")


# ---------------------------------------------------------------------------
# Workspace
# ---------------------------------------------------------------------------

def _setup_workspace():
    if frappe.db.exists("Workspace", {"label": "Fundara"}):
        print("  Workspace already exists, skipping.")
        return

    frappe.get_doc({
        "doctype": "Workspace",
        "label": "Fundara",   # autoname field → name = "Fundara"
        "title": "Fundara",
        "module": "Organization",
        "public": 1,
        "shortcuts": [
            {"doctype": "Workspace Shortcut", "label": "Organization", "type": "DocType", "link_to": "Organization"},
            {"doctype": "Workspace Shortcut", "label": "Office", "type": "DocType", "link_to": "Office"},
            {"doctype": "Workspace Shortcut", "label": "Delegation of Authority", "type": "DocType", "link_to": "Delegation of Authority"},
            {"doctype": "Workspace Shortcut", "label": "Donor", "type": "DocType", "link_to": "Donor"},
            {"doctype": "Workspace Shortcut", "label": "Institutional Donor Profile", "type": "DocType", "link_to": "Institutional Donor Profile"},
            {"doctype": "Workspace Shortcut", "label": "Funding Source", "type": "DocType", "link_to": "Funding Source"},
            {"doctype": "Workspace Shortcut", "label": "Fundraising Campaign", "type": "DocType", "link_to": "Fundraising Campaign"},
            {"doctype": "Workspace Shortcut", "label": "Donation", "type": "DocType", "link_to": "Donation"},
        ],
    }).insert(ignore_permissions=True)
    print("  Fundara Workspace created.")
