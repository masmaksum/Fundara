frappe.ui.form.on('Project', {
	// ==========================================
	// SETUP
	// ==========================================
	setup(frm) {
		frm.set_query('program', () => ({ filters: { is_active: 1 } }));
	},

	// ==========================================
	// REFRESH — buttons, locks, indicators
	// ==========================================
	refresh(frm) {
		apply_project_lock(frm);
		add_project_buttons(frm);
	},

	// ==========================================
	// VALIDATE — FE-02 pesan Bahasa Indonesia
	// ==========================================
	validate(frm) {
		// Tanggal berakhir harus setelah tanggal mulai
		if (frm.doc.end_date && frm.doc.start_date && frm.doc.end_date < frm.doc.start_date) {
			frappe.throw(__('Tanggal berakhir proyek harus setelah tanggal mulai.'));
		}
	},

	// ==========================================
	// HANDLER: auto-compute total_budget dari child table fund_allocations
	// ==========================================
	fund_allocations_add(frm) { recompute_total_budget(frm); },
	fund_allocations_remove(frm) { recompute_total_budget(frm); },
});

// Trigger recompute juga saat allocated_amount di baris berubah
frappe.ui.form.on('Project Fund Allocation', {
	allocated_amount(frm) { recompute_total_budget(frm); },
	fund(frm, cdt, cdn) {
		// Auto-isi currency dari Fund yang dipilih
		const row = locals[cdt][cdn];
		if (row.fund) {
			frappe.db.get_value('Fund', row.fund, 'currency', (r) => {
				if (r && r.currency) frappe.model.set_value(cdt, cdn, 'currency', r.currency);
			});
		}
	},
});

// ==========================================
// HELPER: hitung ulang total_budget dari semua baris fund_allocations
// ==========================================
function recompute_total_budget(frm) {
	const total = (frm.doc.fund_allocations || [])
		.reduce((sum, row) => sum + (row.allocated_amount || 0), 0);
	frm.set_value('total_budget', total);
}

// ==========================================
// HELPER: lock field saat status Completed atau Closed
// ==========================================
function apply_project_lock(frm) {
	const locked = ['Completed', 'Closed'].includes(frm.doc.status);
	if (locked) {
		frm.set_intro(
			__('Proyek dalam status <strong>{0}</strong>. Budget dan alokasi dana dikunci.',
				[frm.doc.status]),
			'blue'
		);
	}
	// Lock child table saat Completed/Closed — budget tidak boleh diubah
	frm.set_df_property('fund_allocations', 'read_only', locked ? 1 : 0);
	frm.set_df_property('total_budget', 'read_only', 1); // selalu read_only (computed)
}

// ==========================================
// HELPER: custom buttons
// ==========================================
function add_project_buttons(frm) {
	if (frm.doc.__islocal) return;

	// "Lihat Advance" — buka list Cash Advance terkait project ini
	frm.add_custom_button(__('Lihat Advance'), () => {
		frappe.set_route('List', 'Cash Advance', { project: frm.doc.name });
	}, __('Proyek'));

	// "Tambah Fund Alokasi" — scroll ke child table dan tambah baris baru
	if (!['Completed', 'Closed'].includes(frm.doc.status)) {
		frm.add_custom_button(__('Tambah Fund Alokasi'), () => {
			frm.scroll_to_field('fund_allocations');
			frm.add_child('fund_allocations');
			frm.refresh_field('fund_allocations');
		}, __('Proyek'));
	}

	// "Tutup Proyek" — hanya tampil saat status Completed
	if (frm.doc.status === 'Completed') {
		frm.add_custom_button(__('Tutup Proyek'), () => {
			frappe.confirm(
				__('Tutup proyek <strong>{0}</strong>? Tindakan ini tidak dapat diurungkan '
					+ 'dan semua field akan dikunci.', [frm.doc.project_name]),
				() => {
					// Cek ada activity terbuka via frappe.call sebelum close
					frappe.call({
						method: 'frappe.client.get_count',
						args: {
							doctype: 'Activity',
							filters: {
								project: frm.doc.name,
								status: ['not in', ['Completed', 'Reported', 'Verified', 'Closed']],
							},
						},
						callback(r) {
							if (r.message > 0) {
								frappe.msgprint({
									message: __(
										'Tidak dapat menutup proyek: terdapat <strong>{0}</strong> '
										+ 'activity yang belum selesai. Selesaikan semua activity '
										+ 'sebelum menutup proyek.', [r.message]
									),
									indicator: 'red',
									title: __('Proyek Tidak Bisa Ditutup'),
								});
							} else {
								frm.set_value('status', 'Closed');
								frm.save();
							}
						},
					});
				}
			);
		}, __('Proyek'));
	}
}
