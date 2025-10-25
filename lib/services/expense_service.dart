import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'user_service.dart';

class ExpenseService {
  final _expenseBox = Hive.box('expenses');
  final _categoryBox = Hive.box('categories');
  final _userSvc = UserService();

  // 🔹 Ambil semua pengeluaran yang terlihat oleh user:
  //    - milik user (userId == currentUserId)
  //    - dibagikan ke user (sharedWith contains currentUserId)
  Future<List<Expense>> getAllExpenses() async {
    final currentId = await _userSvc.getCurrentUserId() ?? -1;

    final data = _expenseBox.toMap(); // {key: map}
    final list = data.entries.map((entry) {
      final map = Map<String, dynamic>.from(entry.value as Map);
      map['id'] = entry.key;
      return Expense.fromMap(map);
    }).where((e) {
      return e.userId == currentId || e.sharedWith.contains(currentId);
    }).toList();

    // urutkan terbaru
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // 🔹 Tambah pengeluaran (userId otomatis current)
  Future<dynamic> insertExpense(Expense exp) async {
    final currentId = await _userSvc.getCurrentUserId() ?? -1;
    final toSave = exp.copyWith(); // keep fields
    final map = toSave.toMap()..['userId'] = currentId;
    return _expenseBox.add(map);
  }

  // 🔹 Hapus by Hive key (id)
  Future<void> deleteExpense(dynamic id) async {
    if (_expenseBox.containsKey(id)) {
      await _expenseBox.delete(id);
    }
  }

  // ================== CATEGORIES ==================

  // Ambil kategori milik user (auto seed kalau kosong)
  Future<List<Category>> getAllCategories() async {
    final currentId = await _userSvc.getCurrentUserId() ?? -1;

    // Seed default hanya sekali per user
    final hasAnyForUser = _categoryBox.toMap().entries.any((e) {
      final m = Map<String, dynamic>.from(e.value as Map);
      return (m['userId'] == currentId);
    });

    if (!hasAnyForUser) {
      final defaults = [
        Category(userId: currentId, name: 'Makanan',      icon: '🍔', color: '#FF9800'),
        Category(userId: currentId, name: 'Transportasi', icon: '🚗', color: '#2196F3'),
        Category(userId: currentId, name: 'Hiburan',      icon: '🎮', color: '#9C27B0'),
        Category(userId: currentId, name: 'Komunikasi',   icon: '📱', color: '#009688'),
        Category(userId: currentId, name: 'Pendidikan',   icon: '📚', color: '#4CAF50'),
      ];
      for (final c in defaults) {
        await _categoryBox.add(c.toMap());
      }
    }

    final data = _categoryBox.toMap();
    final list = data.entries.map((e) {
      final m = Map<String, dynamic>.from(e.value as Map)..['id'] = e.key;
      return Category.fromMap(m);
    }).where((c) => c.userId == currentId).toList();

    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<dynamic> insertCategory(Category cat) async {
    final currentId = await _userSvc.getCurrentUserId() ?? -1;
    return _categoryBox.add(cat.copyWith(id: null).toMap()..['userId'] = currentId);
  }

  Future<void> deleteCategory(dynamic id) async {
    if (_categoryBox.containsKey(id)) await _categoryBox.delete(id);
  }
}
