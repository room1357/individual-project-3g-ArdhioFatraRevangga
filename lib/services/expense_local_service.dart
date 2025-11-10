// 📂 lib/services/expense_local_service.dart
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';

/// Service lokal (SQLite) untuk menyimpan & sinkronisasi pengeluaran.
/// Dipakai di mode offline-first / hybrid.
class ExpenseLocalService {
  final Database db;
  ExpenseLocalService(this.db);

  /// Buat tabel kalau belum ada
  Future<void> init() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,   -- id lokal
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        date TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,   -- 0=false, 1=true
        server_id INTEGER                       -- id server setelah tersinkron
      )
    ''');
  }

  /// Simpan draft baru (biasanya saat offline)
  Future<int> insertDraft(Expense e) async {
    return await db.insert(
      'expenses',
      {
        'title': e.title,
        'description': e.description,
        'category': e.category,
        'price': e.price,
        'quantity': e.quantity,
        'date': e.date.toIso8601String(),
        'user_id': e.userId,
        'is_synced': e.isSynced ? 1 : 0,
        'server_id': e.serverId,
      },
    );
  }

  /// Insert/update jika sudah ada id (pakai di repository hybrid)
  Future<void> upsert(Expense e) async {
    if (e.id == null) {
      await insertDraft(e);
    } else {
      await db.update(
        'expenses',
        {
          'title': e.title,
          'description': e.description,
          'category': e.category,
          'price': e.price,
          'quantity': e.quantity,
          'date': e.date.toIso8601String(),
          'user_id': e.userId,
          'is_synced': e.isSynced ? 1 : 0,
          'server_id': e.serverId,
        },
        where: 'id = ?',
        whereArgs: [e.id],
      );
    }
  }

  /// Ambil semua pengeluaran (buat tampilan list utama)
  Future<List<Expense>> getAll() async {
    final rows = await db.query('expenses', orderBy: 'date DESC');
    return rows.map(_mapToExpense).toList();
  }

  /// Ambil semua data yang belum disinkron (is_synced = 0)
  Future<List<Expense>> getPendingExpenses() async {
    final rows = await db.query('expenses', where: 'is_synced = 0');
    return rows.map(_mapToExpense).toList();
  }

  /// Tandai satu item sebagai sudah tersinkron ke server
  Future<void> markAsSynced({
    required int localId,
    required int serverId,
    required Expense merged,
  }) async {
    await db.update(
      'expenses',
      {
        'is_synced': 1,
        'server_id': serverId,
        'title': merged.title,
        'description': merged.description,
        'category': merged.category,
        'price': merged.price,
        'quantity': merged.quantity,
        'date': merged.date.toIso8601String(),
        'user_id': merged.userId,
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Sinkron masal: simpan semua data dari server (overwrite lokal)
  Future<void> upsertAll(List<Expense> list) async {
    final batch = db.batch();
    for (final e in list) {
      batch.insert(
        'expenses',
        {
          'title': e.title,
          'description': e.description,
          'category': e.category,
          'price': e.price,
          'quantity': e.quantity,
          'date': e.date.toIso8601String(),
          'user_id': e.userId,
          'is_synced': 1,       // karena berasal dari server
          'server_id': e.id,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Hapus semua data lokal (opsional, buat reset)
  Future<void> clearAll() async {
    await db.delete('expenses');
  }

  // ---- Helper private ----

  Expense _mapToExpense(Map<String, Object?> m) {
    return Expense(
      id: m['id'] as int?,
      title: (m['title'] ?? '') as String,
      description: (m['description'] ?? '') as String,
      category: (m['category'] ?? '') as String,
      price: (m['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (m['quantity'] as num?)?.toInt() ?? 1,
      date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
      userId: (m['user_id'] as num?)?.toInt() ?? 0,
      isSynced: (m['is_synced'] as int?) == 1,
      serverId: m['server_id'] as int?,
    );
  }
}
