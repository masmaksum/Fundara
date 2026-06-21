import frappe
from frappe import _
from frappe.model.document import Document


# Net asset class routing per journal-entries.md Developer Note §5
_INCOME_ACCOUNT_MAP = {
	"Donation": {
		"Unrestricted": "4-2100",
		"Temporarily Restricted": "4-2200",
		"Permanently Restricted": "4-2200",
		"Board Designated": "4-2100",
	},
	"Grant": {
		"Unrestricted": "4-1100",
		"Temporarily Restricted": "4-1200",
		"Permanently Restricted": "4-1300",
		"Board Designated": "4-1100",
	},
}


class CashReceipt(Document):
	def validate(self):
		self._validate_amount()
		self._compute_amount_base()

	def on_submit(self):
		self._post_journal_entry()

	def on_cancel(self):
		self._cancel_journal_entry()

	# ------------------------------------------------------------------

	def _validate_amount(self):
		if not self.amount or self.amount <= 0:
			frappe.throw(_("Amount must be greater than zero."))
		if not self.exchange_rate or self.exchange_rate <= 0:
			frappe.throw(_("Exchange Rate must be greater than zero."))

	def _compute_amount_base(self):
		self.amount_base = (self.amount or 0) * (self.exchange_rate or 1)

	def _get_income_account(self):
		restriction_class = frappe.db.get_value("Fund", self.fund, "restriction_class") or "Unrestricted"
		source_map = _INCOME_ACCOUNT_MAP.get(self.source_type, {})
		account_code = source_map.get(restriction_class)
		if not account_code:
			# fallback: first income account or let user configure
			return None
		company = frappe.db.get_single_value("Global Defaults", "default_company")
		account = frappe.db.get_value(
			"Account",
			{"account_number": account_code, "company": company},
			"name",
		)
		return account

	def _post_journal_entry(self):
		if self.journal_entry:
			return

		income_account = self._get_income_account()
		if not income_account:
			frappe.throw(
				_("Cannot determine income account for source type '{0}' and fund restriction class. "
				  "Please configure Chart of Accounts with account code matching the fund restriction.").format(
					self.source_type
				)
			)

		company = frappe.db.get_single_value("Global Defaults", "default_company")
		je = frappe.get_doc({
			"doctype": "Journal Entry",
			"voucher_type": "Journal Entry",
			"posting_date": self.posting_date,
			"company": company,
			"user_remark": f"Cash Receipt {self.name} — {self.source_type}",
			"accounts": [
				{
					"account": self.bank_account,
					"debit_in_account_currency": self.amount,
					"credit_in_account_currency": 0,
					"exchange_rate": self.exchange_rate or 1,
					"account_currency": self.currency,
					"fund": self.fund,
					"donor": self.donor,
					"reference_type": "Cash Receipt",
					"reference_name": self.name,
				},
				{
					"account": income_account,
					"debit_in_account_currency": 0,
					"credit_in_account_currency": self.amount,
					"exchange_rate": self.exchange_rate or 1,
					"account_currency": self.currency,
					"fund": self.fund,
					"donor": self.donor,
					"reference_type": "Cash Receipt",
					"reference_name": self.name,
				},
			],
		})
		je.insert(ignore_permissions=True)
		try:
			je.submit()
		except Exception as e:
			frappe.log_error(message=str(e), title=f"Cash Receipt JE submit failed: {self.name}")
			frappe.throw(_("Failed to post Journal Entry for Cash Receipt {0}: {1}").format(self.name, str(e)))

		self.db_set("journal_entry", je.name)

	def _cancel_journal_entry(self):
		if not self.journal_entry:
			return
		je = frappe.get_doc("Journal Entry", self.journal_entry)
		if je.docstatus == 1:
			try:
				je.cancel()
			except Exception as e:
				frappe.log_error(message=str(e), title=f"Cash Receipt JE cancel failed: {self.name}")
				frappe.throw(_("Failed to cancel Journal Entry {0}: {1}").format(self.journal_entry, str(e)))
