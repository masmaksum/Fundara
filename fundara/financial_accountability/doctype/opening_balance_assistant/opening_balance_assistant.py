import frappe
from frappe import _
from frappe.model.document import Document


class OpeningBalanceAssistant(Document):
	def validate(self):
		self._validate_lines()
		self._compute_totals()
		self._check_balance()
		self._check_duplicate_fiscal_year()

	def before_submit(self):
		if self.validation_status != "Balanced":
			frappe.throw(
				_("Opening Balance is not balanced. Total Debit must equal Total Credit (difference = {0}).").format(
					frappe.format(self.difference, {"fieldtype": "Currency"})
				)
			)

	def on_submit(self):
		self._post_opening_journal_entry()

	def _validate_lines(self):
		for row in (self.balance_lines or []):
			has_debit = row.opening_debit and row.opening_debit > 0
			has_credit = row.opening_credit and row.opening_credit > 0
			if has_debit and has_credit:
				frappe.throw(
					_("Row {0}: A balance line cannot have both Debit and Credit amounts.").format(row.idx)
				)
			if not has_debit and not has_credit:
				frappe.throw(
					_("Row {0}: Either Opening Debit or Opening Credit must be provided.").format(row.idx)
				)

	def _compute_totals(self):
		total_debit = sum(row.opening_debit or 0 for row in (self.balance_lines or []))
		total_credit = sum(row.opening_credit or 0 for row in (self.balance_lines or []))
		self.total_debit = total_debit
		self.total_credit = total_credit
		self.difference = total_debit - total_credit

	def _check_balance(self):
		self.validation_status = "Balanced" if self.difference == 0 else "Out of Balance"

	def _check_duplicate_fiscal_year(self):
		existing = frappe.db.get_value(
			"Opening Balance Assistant",
			{"fiscal_year": self.fiscal_year, "docstatus": 1, "name": ("!=", self.name)},
			"name",
		)
		if existing:
			frappe.throw(
				_("An Opening Balance Assistant for Fiscal Year '{0}' already exists: {1}.").format(
					self.fiscal_year, existing
				)
			)

	def _post_opening_journal_entry(self):
		if self.opening_journal_entry:
			return
		company = frappe.db.get_single_value("Global Defaults", "default_company")
		default_cost_center = frappe.db.get_value("Company", company, "cost_center")
		accounts = []
		for row in (self.balance_lines or []):
			accounts.append({
				"account": row.account,
				"debit_in_account_currency": row.opening_debit or 0,
				"credit_in_account_currency": row.opening_credit or 0,
				"exchange_rate": row.exchange_rate or 1,
				"cost_center": default_cost_center,
				"project": row.project,
			})
		je = frappe.get_doc({
			"doctype": "Journal Entry",
			"voucher_type": "Opening Entry",
			"posting_date": self.posting_date,
			"fiscal_year": self.fiscal_year,
			"company": company,
			"accounts": accounts,
			"remark": f"Opening Balance as of {self.as_of_date}",
		})
		je.insert(ignore_permissions=True)
		je.submit()
		self.db_set("opening_journal_entry", je.name)
		self.db_set("validation_status", "Posted")
