import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExpenseService {
  final _expenseBox = Hive.box('expenses');
  final _categoryBox = Hive.box('categories');

  // 🟢 Ambil semua pengeluaran
  Future<List<Expense>> getAllExpenses() async {
    final data = _expenseBox.values.cast<Map>().toList();
    return data.map((e) => Expense.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  // 🟢 Tambah pengeluaran
  Future<void> insertExpense(Expense exp) async {
    await _expenseBox.add(exp.toMap());
  }

  // 🟢 Hapus pengeluaran
  Future<void> deleteExpense(int index) async {
    await _expenseBox.deleteAt(index);
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

    final data = _categoryBox.values.cast<Map>().toList();
    return data.map((e) => Category.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  // 🟢 Tambah kategori
  Future<void> insertCategory(Category cat) async {
    await _categoryBox.add(cat.toMap());
  }

  // 🟢 Hapus kategori
  Future<void> deleteCategory(int index) async {
    await _categoryBox.deleteAt(index);
  }
}
