frappe.ui.form.on('Fund Budget', {
	// ==========================================
	// SETUP
	// ==========================================
	setup(frm) {
		frm.set_query('fund', () => ({ filters: { status: 'Active' } }));
		frm.set_query('project', () => ({ filters: { status: ['not in', ['Closed']] } }));
	},

	// ==========================================
	// REFRESH — buttons, locks, indicators
	// ==========================================
	refresh(frm) {
		apply_budget_lock(frm);
		add_budget_buttons(frm);
		toggle_budget_exchange_rate(frm);
	},

	// ==========================================
	// HANDLER: currency → exchange rate (D-04)
	// ==========================================
	currency(frm) {
		toggle_budget_exchange_rate(frm);
	},

	// ==========================================
	// HANDLER: recompute totals saat baris budget berubah
	// ==========================================
	budget_lines_add(frm) { recompute_budget_totals(frm); },
	budget_lines_remove(frm) { recompute_budget_totals(frm); },
});

frappe.ui.form.on('Fund Budget Line', {
	approved_amount(frm) { recompute_budget_totals(frm); },
	actual_amount(frm) { recompute_budget_totals(frm); },
});

// ==========================================
// HELPER: hitung ulang total dari budget_lines
// ==========================================
function recompute_budget_totals(frm) {
	let approved = 0, actual = 0;
	(frm.doc.budget_lines || []).forEach(row => {
		approved += row.approved_amount || 0;
		actual += row.actual_amount || 0;
	});
	frm.set_value('total_approved_amount', approved);
	frm.set_value('total_actual_amount', actual);
	frm.set_value('total_available_amount', approved - actual);
}

// ==========================================
// HELPER: lock semua field saat status Approved atau Active
// ==========================================
function apply_budget_lock(frm) {
	const locked = ['Approved', 'Active'].includes(frm.doc.status);
	if (locked) {
		frm.set_intro(
			__('Budget dalam status <strong>{0}</strong>. Gunakan Revisi Anggaran '
				+ 'untuk mengubah alokasi.', [frm.doc.status]),
			'blue'
		);
	}
	// Lock header fields
	const header_fields = [
		'budget_name', 'budget_type', 'fund', 'project', 'activity',
		'cost_center', 'fiscal_year', 'start_date', 'end_date', 'currency', 'exchange_rate',
	];
	header_fields.forEach(f => frm.set_df_property(f, 'read_only', locked ? 1 : 0));
	// Lock child table
	frm.set_df_property('budget_lines', 'read_only', locked ? 1 : 0);
	// Total fields selalu read_only (computed)
	['total_approved_amount', 'total_actual_amount', 'total_available_amount']
		.forEach(f => frm.set_df_property(f, 'read_only', 1));
}

// ==========================================
// HELPER: exchange rate (D-04)
// ==========================================
function toggle_budget_exchange_rate(frm) {
	const base = frappe.defaults.get_default('currency') || 'IDR';
	const is_base = frm.doc.currency === base;
	frm.set_df_property('exchange_rate', 'read_only', is_base ? 1 : 0);
	frm.set_df_property('exchange_rate', 'reqd', is_base ? 0 : 1);
	if (is_base && frm.doc.exchange_rate !== 1) {
		frm.set_value('exchange_rate', 1);
	}
	frm.refresh_field('exchange_rate');
}

// ==========================================
// HELPER: custom buttons
// ==========================================
function add_budget_buttons(frm) {
	if (frm.doc.__islocal) return;

	// "Revisi Anggaran" — buka Budget Revision baru, hanya saat Active
	if (frm.doc.status === 'Active') {
		frm.add_custom_button(__('Revisi Anggaran'), () => {
			frappe.new_doc('Budget Revision', {
				budget: frm.doc.name,
				fund: frm.doc.fund,
				project: frm.doc.project,
				cost_center: frm.doc.cost_center,
				currency: frm.doc.currency,
				exchange_rate: frm.doc.exchange_rate,
			});
		}, __('Budget'));
	}
}
