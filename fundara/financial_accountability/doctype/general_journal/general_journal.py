import frappe
from frappe import _
from frappe.model.document import Document


class GeneralJournal(Document):
	def validate(self):
		self._validate_lines()
		self._compute_totals()
		self._validate_balanced()
		self._validate_fund_dimensions()

	def on_submit(self):
		self._post_journal_entry()

	def on_cancel(self):
		self._cancel_journal_entry()

	# ------------------------------------------------------------------

	def _validate_lines(self):
		if not self.journal_lines:
			frappe.throw(_("Journal Lines cannot be empty."))
		for row in self.journal_lines:
			has_debit = row.debit and row.debit > 0
			has_credit = row.credit and row.credit > 0
			if has_debit and has_credit:
				frappe.throw(
					_("Row {0}: A journal line cannot have both Debit and Credit amounts.").format(row.idx)
				)
			if not has_debit and not has_credit:
				frappe.throw(
					_("Row {0}: Either Debit or Credit must be provided.").format(row.idx)
				)

	def _compute_totals(self):
		self.total_debit = sum(row.debit or 0 for row in self.journal_lines)
		self.total_credit = sum(row.credit or 0 for row in self.journal_lines)

	def _validate_balanced(self):
		if abs((self.total_debit or 0) - (self.total_credit or 0)) >= 0.01:
			frappe.throw(
				_("Journal is not balanced. Total Debit: {0}, Total Credit: {1}, Difference: {2}.").format(
					frappe.format(self.total_debit, {"fieldtype": "Currency"}),
					frappe.format(self.total_credit, {"fieldtype": "Currency"}),
					frappe.format(abs(self.total_debit - self.total_credit), {"fieldtype": "Currency"}),
				)
			)

	def _validate_fund_dimensions(self):
		# Fund dimension is mandatory on any line touching an expense or income account
		for row in self.journal_lines:
			if not row.account:
				continue
			account_type = frappe.db.get_value("Account", row.account, "account_type")
			if account_type in ("Expense Account", "Income Account") and not row.fund:
				frappe.throw(
					_("Row {0}: Fund dimension is mandatory for account '{1}' (type: {2}).").format(
						row.idx, row.account, account_type
					)
				)

	def _post_journal_entry(self):
		if frappe.db.get_value("General Journal", self.name, "journal_entry"):
			return

		company = frappe.db.get_single_value("Global Defaults", "default_company")
		accounts = []
		for row in self.journal_lines:
			accounts.append({
				"account": row.account,
				"debit_in_account_currency": row.debit or 0,
				"credit_in_account_currency": row.credit or 0,
				"exchange_rate": row.exchange_rate or 1,
				"account_currency": row.currency,
				"fund": row.fund,
				"project": row.project,
				"activity": row.activity,
				"cost_center": row.cost_center,
				"donor": row.donor,
				"user_remark": row.remarks,
				"reference_type": "General Journal",
				"reference_name": self.name,
			})

		je = frappe.get_doc({
			"doctype": "Journal Entry",
			"voucher_type": "Journal Entry",
			"posting_date": self.posting_date,
			"company": company,
			"user_remark": f"General Journal {self.name} — {self.journal_type}",
			"accounts": accounts,
		})
		je.insert(ignore_permissions=True)
		try:
			je.submit()
		except Exception as e:
			frappe.log_error(message=str(e), title=f"General Journal JE submit failed: {self.name}")
			frappe.throw(_("Failed to post Journal Entry for General Journal {0}: {1}").format(self.name, str(e)))

		self.db_set("journal_entry", je.name)

	def _cancel_journal_entry(self):
		journal_entry = frappe.db.get_value("General Journal", self.name, "journal_entry")
		if not journal_entry:
			return
		je = frappe.get_doc("Journal Entry", journal_entry)
		if je.docstatus == 1:
			try:
				je.cancel()
			except Exception as e:
				frappe.log_error(message=str(e), title=f"General Journal JE cancel failed: {self.name}")
				frappe.throw(_("Failed to cancel Journal Entry {0}: {1}").format(journal_entry, str(e)))
