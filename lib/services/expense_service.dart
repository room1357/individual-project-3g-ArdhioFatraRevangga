import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExpenseService {
  final _expenseBox = Hive.box('expenses');
  final _categoryBox = Hive.box('categories');

  // 🟢 Ambil semua pengeluaran
  Future<List<Expense>> getAllExpenses() async {
    final data = _expenseBox.toMap(); // 🔹 ambil dengan key agar tahu posisi aslinya
    return data.entries.map((entry) {
      final map = Map<String, dynamic>.from(entry.value as Map);
      map['id'] = entry.key; // 🔹 simpan key Hive sebagai id
      return Expense.fromMap(map);
    }).toList();
  }

  // 🟢 Tambah pengeluaran
  Future<void> insertExpense(Expense exp) async {
    await _expenseBox.add(exp.toMap());
  }

  // 🟢 Hapus pengeluaran berdasarkan id (bukan index tampilan)
  Future<void> deleteExpense(dynamic id) async {
    if (_expenseBox.containsKey(id)) {
      await _expenseBox.delete(id);
    }
  }

  // 🟢 Ambil semua kategori (otomatis isi default kalau kosong)
  Future<List<Category>> getAllCategories() async {
    if (_categoryBox.isEmpty) {
      final defaultCats = [
        Category(name: 'Makanan', icon: '🍔', color: '#FF9800'),
        Category(name: 'Transportasi', icon: '🚗', color: '#2196F3'),
        Category(name: 'Hiburan', icon: '🎮', color: '#9C27B0'),
        Category(name: 'Komunikasi', icon: '📱', color: '#009688'),
        Category(name: 'Pendidikan', icon: '📚', color: '#4CAF50'),
      ];
      for (var cat in defaultCats) {
        await _categoryBox.add(cat.toMap());
      }
    }

    final data = _categoryBox.toMap();
    return data.entries.map((entry) {
      final map = Map<String, dynamic>.from(entry.value as Map);
      map['id'] = entry.key;
      return Category.fromMap(map);
    }).toList();
  }

  // 🟢 Tambah kategori
  Future<void> insertCategory(Category cat) async {
    await _categoryBox.add(cat.toMap());
  }

  // 🟢 Hapus kategori berdasarkan id Hive
  Future<void> deleteCategory(dynamic id) async {
    if (_categoryBox.containsKey(id)) {
      await _categoryBox.delete(id);
    }
  }
}
