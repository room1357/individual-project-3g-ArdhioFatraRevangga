import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'user_service.dart';

class ExpenseService {
  final _expenseBox = Hive.box('expenses');
  final _categoryBox = Hive.box('categories');
  final _userSvc = UserService();

  // -------------------- Helpers --------------------
  int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  double _toDouble(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  // ===================== EXPENSES LOCAL =====================

  Future<List<Expense>> getAllExpenses() async {
    final currentId = await _userSvc.getCurrentUserId() ?? -1;

    final data = _expenseBox.toMap();
    final List<Expense> list = [];

    data.forEach((key, value) {
      if (value is! Map) return;

      final m = Map<String, dynamic>.from(value);
      final ownerId = _toInt(m['userId'], fallback: -1);
      if (ownerId != currentId) return;

      final e = Expense(
        id: key,
        title: (m['title'] ?? '').toString(),
        description: (m['description'] ?? '').toString(),
        category: (m['category'] ?? '').toString(),
        price: _toDouble(m['price']),
        quantity: _toInt(m['quantity'], fallback: 1),
        date: DateTime.tryParse((m['date'] ?? '').toString()) ?? DateTime.now(),
      );

      list.add(e);
    });

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<dynamic> insertExpense(Expense exp) async {
    final currentId = await _userSvc.getCurrentUserId() ?? -1;

    final map = {
      'title': exp.title,
      'description': exp.description,
      'category': exp.category,
      'price': exp.price,
      'quantity': exp.quantity,
      'date': exp.date.toIso8601String(),
      'userId': currentId,
    };

    return _expenseBox.add(map);
  }

  Future<void> updateExpense(dynamic localKey, Expense exp) async {
    if (!_expenseBox.containsKey(localKey)) return;

    final existing = _expenseBox.get(localKey);
    int ownerId = await _userSvc.getCurrentUserId() ?? -1;

    if (existing is Map) {
      ownerId = _toInt(existing['userId'], fallback: ownerId);
    }

    final map = {
      'title': exp.title,
      'description': exp.description,
      'category': exp.category,
      'price': exp.price,
      'quantity': exp.quantity,
      'date': exp.date.toIso8601String(),
      'userId': ownerId,
    };

    await _expenseBox.put(localKey, map);
  }

  Future<void> deleteExpense(dynamic id) async {
    if (_expenseBox.containsKey(id)) {
      await _expenseBox.delete(id);
    }
  }

  // ===================== CATEGORIES LOCAL =====================

  Future<List<Category>> getAllCategories() async {
    final currentId = await _userSvc.getCurrentUserId() ?? -1;

    final hasAnyForUser = _categoryBox.toMap().entries.any((e) {
      final m = Map<String, dynamic>.from(e.value as Map);
      return (m['userId'] == currentId);
    });

    if (!hasAnyForUser) {
      final defaults = [
        Category(userId: currentId, name: 'Makanan', icon: '🍔', color: '#FF9800'),
        Category(userId: currentId, name: 'Transportasi', icon: '🚗', color: '#2196F3'),
        Category(userId: currentId, name: 'Hiburan', icon: '🎮', color: '#9C27B0'),
        Category(userId: currentId, name: 'Komunikasi', icon: '📱', color: '#009688'),
        Category(userId: currentId, name: 'Pendidikan', icon: '📚', color: '#4CAF50'),
      ];

      for (final c in defaults) {
        await _categoryBox.add(c.toMap());
      }
    }

    final data = _categoryBox.toMap();

    return data.entries.map((e) {
      final m = Map<String, dynamic>.from(e.value as Map)..['id'] = e.key;
      return Category.fromMap(m);
    }).where((c) => c.userId == currentId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<dynamic> insertCategory(Category cat) async {
    final currentId = await _userSvc.getCurrentUserId() ?? -1;
    final map = cat.copyWith(id: null).toMap()..['userId'] = currentId;
    return _categoryBox.add(map);
  }

  Future<void> updateCategory(Category cat) async {
    if (cat.id == null) return;

    final existing = _categoryBox.get(cat.id);
    int ownerId = await _userSvc.getCurrentUserId() ?? -1;

    if (existing is Map && existing['userId'] != null) {
      ownerId = _toInt(existing['userId'], fallback: ownerId);
    }

    final map = cat.toMap()..['userId'] = ownerId;
    await _categoryBox.put(cat.id, map);
  }

  Future<void> deleteCategory(dynamic id) async {
    if (_categoryBox.containsKey(id)) {
      await _categoryBox.delete(id);
    }
  }
}
