import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_manager.dart';
import 'package:intl/intl.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});

  @override
  State<AdvancedExpenseListScreen> createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  List<Expense> expenses = ExpenseManager.expenses;
  List<Expense> filteredExpenses = [];
  String selectedCategory = 'Semua';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredExpenses = expenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Advanced'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengeluaran...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => _filterExpenses(),
            ),
          ),

          // 🏷️ Category Filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                'Semua',
                'Makanan',
                'Transportasi',
                'Hiburan',
                'Komunikasi',
                'Pendidikan'
              ]
                  .map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          selectedColor: Colors.blueAccent,
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                              _filterExpenses();
                            });
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),

          // 📊 Statistics Summary
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', _calculateTotal(filteredExpenses)),
                _buildStatCard('Jumlah', '${filteredExpenses.length} item'),
                _buildStatCard('Rata-rata', _calculateAverage(filteredExpenses)),
              ],
            ),
          ),

          // 📋 Expense List
          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(child: Text('Tidak ada pengeluaran ditemukan'))
                : ListView.builder(
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getCategoryColor(expense.category),
                            child: Icon(
                              _getCategoryIcon(expense.category),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            expense.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: Text(
                            '${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.date)}',
                          ),
                          trailing: Text(
                            'Rp${expense.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () => _showExpenseDetails(context, expense),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 🔍 Filter Function
  void _filterExpenses() {
    setState(() {
      filteredExpenses = expenses.where((expense) {
        bool matchesSearch = searchController.text.isEmpty ||
            expense.title
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            expense.description
                .toLowerCase()
                .contains(searchController.text.toLowerCase());
        bool matchesCategory =
            selectedCategory == 'Semua' || expense.category == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // 📊 Statistik Card
  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0, (sum, e) => sum + e.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
  }

  String _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 'Rp 0';
    double avg = expenses.fold(0.0, (sum, e) => sum + e.amount) / expenses.length;
    return 'Rp ${avg.toStringAsFixed(0)}';
  }

  // 🎨 Category Colors
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan':
        return Colors.orangeAccent;
      case 'Transportasi':
        return Colors.blueAccent;
      case 'Hiburan':
        return Colors.purpleAccent;
      case 'Komunikasi':
        return Colors.green;
      case 'Pendidikan':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // 🧭 Category Icons
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Hiburan':
        return Icons.movie;
      case 'Komunikasi':
        return Icons.phone;
      case 'Pendidikan':
        return Icons.school;
      default:
        return Icons.attach_money;
    }
  }

  // 💬 Detail Dialog
  void _showExpenseDetails(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(expense.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Kategori: ${expense.category}'),
            Text('Deskripsi: ${expense.description}'),
            Text(
                'Tanggal: ${DateFormat('dd MMM yyyy').format(expense.date)}'),
            Text('Jumlah: Rp${expense.amount.toStringAsFixed(0)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }
}
