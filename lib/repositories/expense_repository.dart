import '../models/expense.dart';
import '../services/expense_api.dart';
import '../services/expense_local_service.dart';

class ExpenseRepository {
  final ExpenseApi remote;
  final ExpenseLocalService local;

  ExpenseRepository({required this.remote, required this.local});

  /// Create hibrida: coba remote dulu, fallback lokal kalau gagal
  Future<Expense> createHybrid(Expense draft) async {
    try {
      // 1) Coba kirim ke API
      final created = await remote.createExpense(draft);
      // 2) Simpan juga ke lokal sebagai tersinkron (serverId = id server)
      await local.upsert(created.copyWith(isSynced: true, serverId: created.id));
      return created;
    } catch (_) {
      // 3) Kalau gagal, simpan ke lokal sebagai pending (isSynced=false)
      final localDraft = draft.copyWith(isSynced: false, serverId: null);
      await local.insertDraft(localDraft);
      return localDraft; // kembalikan supaya UI tetap update
    }
  }

  /// Ambil data gabungan (opsional: merge remote->lokal dulu)
  Future<List<Expense>> listHybrid() async {
    try {
      final remoteList = await remote.fetchExpenses();
      await local.upsertAll(remoteList); // mark synced
    } catch (_) {
      // kalau gagal network, diamkan - tetap tampilkan lokal
    }
    // tampilkan dari lokal sebagai “sumber kebenaran” UI
    return local.getAll(); // tambahkan getAll() di local service-mu
  }
}
