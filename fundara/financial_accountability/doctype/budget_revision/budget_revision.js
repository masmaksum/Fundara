frappe.ui.form.on('Budget Revision', {
	// ==========================================
	// SETUP
	// ==========================================
	setup(frm) {
		frm.set_query('budget', () => ({
			filters: { status: 'Active' }
		}));
	},

	// ==========================================
	// REFRESH
	// ==========================================
	refresh(frm) {
		apply_revision_lock(frm);
		toggle_revision_exchange_rate(frm);
	},

	// ==========================================
	// HANDLER: budget dipilih → auto-isi fund, project, currency
	// ==========================================
	budget(frm) {
		if (!frm.doc.budget) return;
		frappe.db.get_value(
			'Fund Budget', frm.doc.budget,
			['fund', 'project', 'cost_center', 'currency', 'exchange_rate'],
			(r) => {
				if (!r) return;
				frm.set_value('fund', r.fund);
				frm.set_value('project', r.project);
				frm.set_value('cost_center', r.cost_center);
				frm.set_value('currency', r.currency);
				frm.set_value('exchange_rate', r.exchange_rate || 1);
			}
		);
	},

	// ==========================================
	// HANDLER: currency → exchange rate (D-04)
	// ==========================================
	currency(frm) {
		toggle_revision_exchange_rate(frm);
	},

	// ==========================================
	// HANDLER: recompute totals saat baris revision berubah
	// ==========================================
	revision_lines_add(frm) { recompute_revision_total(frm); },
	revision_lines_remove(frm) { recompute_revision_total(frm); },
});

frappe.ui.form.on('Budget Revision Line', {
	revised_amount(frm, cdt, cdn) {
		// Auto-compute change_amount = revised - original
		const row = locals[cdt][cdn];
		const change = (row.revised_amount || 0) - (row.original_amount || 0);
		frappe.model.set_value(cdt, cdn, 'change_amount', change);
		recompute_revision_total(frm);
	},

	// Saat budget_line dipilih → auto-isi original_amount dari Fund Budget Line
	budget_line(frm, cdt, cdn) {
		const row = locals[cdt][cdn];
		if (!row.budget_line) return;
		frappe.db.get_value('Fund Budget Line', row.budget_line, 'approved_amount', (r) => {
			if (r && r.approved_amount !== undefined) {
				frappe.model.set_value(cdt, cdn, 'original_amount', r.approved_amount);
				// Reset revised_amount agar user mengisi manual
				frappe.model.set_value(cdt, cdn, 'revised_amount', r.approved_amount);
				frappe.model.set_value(cdt, cdn, 'change_amount', 0);
			}
		});
	},
});

// ==========================================
// HELPER: hitung total revised dari semua baris
// (tidak ada field total di DocType, tapi berguna untuk live display)
// ==========================================
function recompute_revision_total(frm) {
	let total_change = 0;
	(frm.doc.revision_lines || []).forEach(row => {
		total_change += row.change_amount || 0;
	});
	// Tampilkan summary di form intro
	if (frm.doc.revision_lines && frm.doc.revision_lines.length > 0) {
		const sign = total_change >= 0 ? '+' : '';
		const currency = frm.doc.currency || '';
		frm.set_intro(
			__('Total perubahan anggaran: <strong>{0} {1}{2}</strong>',
				[currency, sign, format_number(total_change)]),
			total_change > 0 ? 'blue' : total_change < 0 ? 'orange' : 'grey'
		);
	}
}

// ==========================================
// HELPER: lock field saat Approved atau Rejected
// ==========================================
function apply_revision_lock(frm) {
	const locked = ['Approved', 'Rejected'].includes(frm.doc.status);
	if (locked) {
		frm.set_intro(
			__('Revisi Anggaran dalam status <strong>{0}</strong> — tidak dapat diedit.',
				[frm.doc.status]),
			frm.doc.status === 'Approved' ? 'green' : 'red'
		);
	}
	['budget', 'fund', 'project', 'cost_center', 'currency', 'exchange_rate',
		'posting_date', 'revision_justification']
		.forEach(f => frm.set_df_property(f, 'read_only', locked ? 1 : 0));
	frm.set_df_property('revision_lines', 'read_only', locked ? 1 : 0);
}

// ==========================================
// HELPER: exchange rate (D-04)
// ==========================================
function toggle_revision_exchange_rate(frm) {
	const base = frappe.defaults.get_default('currency') || 'IDR';
	const is_base = frm.doc.currency === base;
	frm.set_df_property('exchange_rate', 'read_only', is_base ? 1 : 0);
	frm.set_df_property('exchange_rate', 'reqd', is_base ? 0 : 1);
	if (is_base && frm.doc.exchange_rate !== 1) {
		frm.set_value('exchange_rate', 1);
	}
	frm.refresh_field('exchange_rate');
}
