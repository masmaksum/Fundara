frappe.ui.form.on('Fund', {
	// ==========================================
	// SETUP — filter queries
	// ==========================================
	setup(frm) {
		frm.set_query('funding_source', () => ({ filters: { is_active: 1 } }));
		frm.set_query('grant', () => ({ filters: { status: 'Active' } }));
		frm.set_query('recoverable_from_fund', () => ({
			filters: { status: 'Active', name: ['!=', frm.doc.name || ''] }
		}));
	},

	// ==========================================
	// REFRESH — buttons, locks, indicators
	// ==========================================
	refresh(frm) {
		apply_status_lock(frm);
		refresh_grant_visibility(frm);
		toggle_exchange_rate(frm);
		add_custom_buttons(frm);
	},

	// ==========================================
	// VALIDATE — FE-02: pesan validasi Bahasa Indonesia
	// ==========================================
	validate(frm) {
		// VA-FUND-03: tanggal berakhir harus setelah tanggal mulai
		if (frm.doc.end_date && frm.doc.start_date && frm.doc.end_date < frm.doc.start_date) {
			frappe.throw(__(
				'Tanggal berakhir Fund harus setelah tanggal mulai. Periksa kembali periode Fund.'
			));
		}

		// VA-FUND-05: Fund non-IDR wajib punya exchange rate
		const base_currency = frappe.defaults.get_default('currency') || 'IDR';
		if (frm.doc.currency && frm.doc.currency !== base_currency) {
			if (!frm.doc.exchange_rate_on_creation || frm.doc.exchange_rate_on_creation <= 0) {
				frappe.throw(__(
					'Fund dengan currency selain {0} harus memiliki nilai tukar (exchange rate) yang valid.',
					[base_currency]
				));
			}
		}
	},

	// ==========================================
	// HANDLER 1: fund_type — fetch flags, update mandatory + default
	// ==========================================
	fund_type(frm) {
		if (!frm.doc.fund_type) {
			frm.set_df_property('grant', 'reqd', 0);
			frm.set_df_property('grant', 'hidden', 1);
			frm.set_df_property('end_date', 'reqd', 0);
			frm.refresh_fields(['grant', 'end_date']);
			return;
		}
		frappe.db.get_value(
			'Fund Type', frm.doc.fund_type,
			['requires_grant', 'has_end_date', 'default_restriction_type'],
			(r) => {
				if (!r) return;

				// Toggle grant field mandatory + visibility
				const need_grant = Boolean(r.requires_grant);
				frm.set_df_property('grant', 'reqd', need_grant ? 1 : 0);
				frm.set_df_property('grant', 'hidden', need_grant ? 0 : 1);

				// Toggle end_date mandatory
				frm.set_df_property('end_date', 'reqd', r.has_end_date ? 1 : 0);

				// Auto-set default restriction_type if not yet chosen
				if (r.default_restriction_type && !frm.doc.restriction_type) {
					frm.set_value('restriction_type', r.default_restriction_type);
				}

				frm.refresh_fields(['grant', 'end_date', 'restriction_type']);
			}
		);
	},

	// ==========================================
	// HANDLER 2: live balance / currency update (D-04)
	// ==========================================
	currency(frm) {
		toggle_exchange_rate(frm);
		recompute_balance_base(frm);
	},

	exchange_rate_on_creation(frm) {
		recompute_balance_base(frm);
	},

	opening_balance(frm) {
		recompute_balance_base(frm);
	},

	// ==========================================
	// HANDLER 3: warning if restriction_type changes on Active fund
	// ==========================================
	restriction_type(frm) {
		if (frm.doc.status === 'Active' && !frm.doc.__islocal) {
			frappe.msgprint({
				message: __(
					'Mengubah Restriction Type pada Fund yang sedang <strong>Aktif</strong> '
					+ 'akan mempengaruhi validasi semua transaksi baru. '
					+ 'Pertimbangkan membuat dokumen Fund Restriction terpisah via tombol '
					+ '"Ajukan Pembatasan" untuk menjaga audit trail.'
				),
				indicator: 'orange',
				title: __('Perhatian — Fund Aktif'),
			});
		}
	},
});

// ==========================================
// HELPER: refresh grant field visibility on refresh
// (HANDLER 4 — conditional grant mandatory)
// ==========================================
function refresh_grant_visibility(frm) {
	if (!frm.doc.fund_type) {
		frm.set_df_property('grant', 'hidden', 1);
		frm.set_df_property('grant', 'reqd', 0);
		frm.refresh_field('grant');
		return;
	}
	frappe.db.get_value('Fund Type', frm.doc.fund_type, ['requires_grant', 'has_end_date'], (r) => {
		if (!r) return;
		const need_grant = Boolean(r.requires_grant);
		frm.set_df_property('grant', 'reqd', need_grant ? 1 : 0);
		frm.set_df_property('grant', 'hidden', need_grant ? 0 : 1);
		frm.set_df_property('end_date', 'reqd', r.has_end_date ? 1 : 0);
		frm.refresh_fields(['grant', 'end_date']);
	});
}

// ==========================================
// HELPER: lock all fields when status is Closing or Closed
// (HANDLER 5)
// ==========================================
function apply_status_lock(frm) {
	const locked = ['Closing', 'Closed'].includes(frm.doc.status);
	if (locked) {
		frm.set_intro(
			__('Fund dalam status <strong>{0}</strong>. Semua field dikunci. '
				+ 'Tidak ada transaksi baru yang dapat diproses terhadap fund ini.', [frm.doc.status]),
			'red'
		);
	}
	const lockable = [
		'fund_name', 'fund_code', 'fund_type', 'restriction_type', 'purpose',
		'funding_source', 'grant', 'fund_owner', 'approval_authority',
		'start_date', 'end_date', 'currency', 'exchange_rate_on_creation',
		'opening_balance', 'is_bridging_fund', 'recoverable_from_fund',
		'allowed_cost_categories', 'disallowed_cost_categories',
		'allowed_programs', 'allowed_projects', 'procurement_requirement',
		'reporting_requirement', 'exception_rule', 'notes',
	];
	lockable.forEach(f => frm.set_df_property(f, 'read_only', locked ? 1 : 0));
}

// ==========================================
// HELPER: exchange_rate read_only / required (D-04)
// ==========================================
function toggle_exchange_rate(frm) {
	const base_currency = frappe.defaults.get_default('currency') || 'IDR';
	const is_base = frm.doc.currency === base_currency;
	frm.set_df_property('exchange_rate_on_creation', 'read_only', is_base ? 1 : 0);
	frm.set_df_property('exchange_rate_on_creation', 'reqd', is_base ? 0 : 1);
	if (is_base && frm.doc.exchange_rate_on_creation !== 1) {
		frm.set_value('exchange_rate_on_creation', 1);
	}
	frm.refresh_field('exchange_rate_on_creation');
}

// ==========================================
// HELPER: recompute opening_balance_base (D-04)
// ==========================================
function recompute_balance_base(frm) {
	const base = (frm.doc.opening_balance || 0) * (frm.doc.exchange_rate_on_creation || 1);
	frm.set_value('opening_balance_base', base);
}

// ==========================================
// HELPER: custom buttons
// ==========================================
function add_custom_buttons(frm) {
	if (frm.doc.__islocal) return;

	// "Lihat Alokasi" — buka list Fund Allocation terkait fund ini
	frm.add_custom_button(__('Lihat Alokasi'), () => {
		frappe.set_route('List', 'Fund Allocation', { fund: frm.doc.name });
	}, __('Fund'));

	// "Ajukan Pembatasan" — buat Fund Restriction baru untuk fund ini
	if (['Active', 'Suspended'].includes(frm.doc.status)) {
		frm.add_custom_button(__('Ajukan Pembatasan'), () => {
			frappe.new_doc('Fund Restriction', {
				fund: frm.doc.name,
				restriction_type: frm.doc.restriction_type,
			});
		}, __('Fund'));
	}
}
