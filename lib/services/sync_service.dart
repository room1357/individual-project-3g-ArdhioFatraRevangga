// 📂 lib/services/sync_service.dart
import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense.dart';
import '../models/category.dart';
import 'expense_api.dart';

/// Sinkronisasi hibrida 2-ara:
/// 1) pushPending: dorong item lokal (isSynced=false) ke server
/// 2) syncDown: tarik data server, merge ke Hive (replace yg sudah isSynced=true, simpan pending)
class SyncService {
  final ExpenseApi remote;

  SyncService({required this.remote});

  /// Jalankan full sync: dorong pending dulu, lalu tarik/merge server
  Future<void> syncAll() async {
    await pushPending();
    await syncDown();
  }

  /// Dorong semua expense lokal yang belum tersinkron (isSynced=false) ke server.
  /// Mengembalikan jumlah item yang berhasil dipush.
  Future<int> pushPending() async {
    final expenseBox = Hive.box('expenses');
    int pushed = 0;

    // Iterasi semua record di Hive
    for (final dynamic key in expenseBox.keys) {
      final raw = expenseBox.get(key);

      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);

      final isSynced = _asBool(map['isSynced']) ?? _asBool(map['is_synced']) ?? false;
      if (isSynced == true) continue; // skip yang sudah sinkron

      // Bangun model Expense dari map lokal (robust terhadap variasi field)
      final localExpense = _expenseFromLocalMap(map);

      try {
        // POST ke server
        final created = await remote.createExpense(localExpense);

        // Update record Hive ini -> set isSynced=true, catat serverId
        final updated = Map<String, dynamic>.from(map)
          ..['isSynced'] = true
          ..['is_synced'] = 1
          ..['serverId'] = created.id
          ..['server_id'] = created.id
          ..['id'] = map['id'] ?? map['serverId'] ?? map['server_id']; // biarkan id lokal tetap ada kalau kamu butuh
        // Simpan juga field lain dari server agar fresh
        updated['title'] = created.title;
        updated['description'] = created.description;
        updated['category'] = created.category;
        updated['price'] = created.price;
        updated['quantity'] = created.quantity;
        updated['date'] = created.date.toIso8601String();
        updated['userId'] = created.userId;
        updated['user_id'] = created.userId;

        await expenseBox.put(key, updated);
        pushed++;
      } catch (e) {
        // Biarkan pending tetap pending; lanjut item berikutnya
        // (opsional) kamu bisa log ke box lain atau console
      }
    }

    return pushed;
  }

  /// Tarik expenses & categories dari server, lalu MERGE ke Hive:
  /// - item lokal yang sudah isSynced=true akan di-replace oleh server
  /// - item lokal pending (isSynced=false) dibiarkan (tidak hilang)
  Future<void> syncDown() async {
    final expenseBox = Hive.box('expenses');
    final categoryBox = Hive.box('categories');

    // fetch remote
    final remoteExpenses = await remote.fetchExpenses();
    final remoteCategories = await remote.fetchCategories();

    // ========== Categories ==========
    // Strategi simple: replace total (biasanya kategori tidak punya pending)
    await categoryBox.clear();
    for (final c in remoteCategories) {
      categoryBox.add(_categoryToLocalMap(c));
    }

    // ========== Expenses ==========
    // 1) Hapus semua entry yg sudah isSynced=true agar bisa digantikan versi server
    final keysToDelete = <dynamic>[];
    for (final key in expenseBox.keys) {
      final raw = expenseBox.get(key);
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final isSynced = _asBool(map['isSynced']) ?? _asBool(map['is_synced']) ?? false;
      if (isSynced == true) keysToDelete.add(key);
    }
    await expenseBox.deleteAll(keysToDelete);

    // 2) Tambahkan data dari server (ditandai synced)
    for (final e in remoteExpenses) {
      final m = _expenseToLocalMap(e, isSynced: true, serverId: e.id);
      await expenseBox.add(m);
    }
  }

  // ───────────────────────── Helpers ─────────────────────────

  // Bangun Expense dari map lokal (robust terhadap variasi penamaan)
  Expense _expenseFromLocalMap(Map<String, dynamic> m) {
    int _toInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim()) ?? fallback;
      return fallback;
    }

    double _toDouble(dynamic v, [double fallback = 0.0]) {
      if (v == null) return fallback;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim()) ?? fallback;
      return fallback;
    }

    DateTime _toDate(dynamic v) {
      if (v == null) return DateTime.now();
      final s = v.toString();
      return DateTime.tryParse(s) ?? DateTime.now();
    }

    String _toString(dynamic v, [String fb = '']) => v?.toString() ?? fb;

    return Expense(
      id: m['id'] is int ? m['id'] as int? : null, // id lokal (opsional)
      title: _toString(m['title']),
      description: _toString(m['description']),
      category: _toString(m['category']),
      price: _toDouble(m['price']),
      quantity: _toInt(m['quantity'], 1),
      date: _toDate(m['date']),
      userId: _toInt(m['userId'] ?? m['user_id']),
      // kalau model kamu punya properti isSynced/serverId, set di sini kalau perlu
      // isSynced: _asBool(m['isSynced']) ?? _asBool(m['is_synced']) ?? false,
      // serverId: m['serverId'] as int? ?? m['server_id'] as int?,
    );
  }

  // Map untuk simpan ke Hive
  Map<String, dynamic> _expenseToLocalMap(Expense e, {required bool isSynced, int? serverId}) {
    return {
      // id: biarkan Hive yang bikin id lokal sebagai key; simpan id server di serverId
      'title': e.title,
      'description': e.description,
      'category': e.category,
      'price': e.price,
      'quantity': e.quantity,
      'date': e.date.toIso8601String(),
      'userId': e.userId,
      'user_id': e.userId,
      'isSynced': isSynced,
      'is_synced': isSynced ? 1 : 0,
      'serverId': serverId,
      'server_id': serverId,
    };
  }

  Map<String, dynamic> _categoryToLocalMap(Category c) {
    return {
      'name': c.name,
      'icon': c.icon,
      'color': c.color,
      'userId': c.userId,
      'user_id': c.userId,
    };
  }

  bool? _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    return null;
    }
}
