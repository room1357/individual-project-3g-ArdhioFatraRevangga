import '../models/expense.dart';

class ExpenseManager {
  static List<Expense> expenses = [
    Expense(
      title: 'Makan Siang',
      description: 'Nasi padang di warung kampus',
      category: 'Makanan',
      amount: 35000,
      date: DateTime(2025, 10, 10),
    ),
    Expense(
      title: 'Bensin Motor',
      description: 'Isi bensin Pertalite',
      category: 'Transportasi',
      amount: 40000,
      date: DateTime(2025, 10, 8),
    ),
    Expense(
      title: 'Kopi',
      description: 'Ngopi bareng teman',
      category: 'Hiburan',
      amount: 25000,
      date: DateTime(2025, 10, 8),
    ),
  ];
}