import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];

  double total = 0;
  double avgDaily = 0;
  Map<String, double> categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _expenseService.getAllExpenses();
    setState(() {
      _expenses = data;
      _calculateStats();
    });
  }

  void _calculateStats() {
    total = _expenses.fold(0, (sum, e) => sum + e.total);

    // Hitung total per kategori
    categoryTotals.clear();
    for (var e in _expenses) {
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.total;
    }

    // Rata-rata pengeluaran harian
    final uniqueDays = _expenses
        .map((e) => "${e.date.year}-${e.date.month}-${e.date.day}")
        .toSet();
    avgDaily = total / (uniqueDays.isNotEmpty ? uniqueDays.length : 1);
  }

  @override
  Widget build(BuildContext context) {
    final sections = categoryTotals.entries.map((entry) {
      final color = _getColorForCategory(entry.key);
      return PieChartSectionData(
        value: entry.value,
        color: color,
        radius: 80,
        title: '${entry.key}\n${formatCurrency(entry.value)}',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Pengeluaran'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _expenses.isEmpty
          ? const Center(child: Text('Belum ada data pengeluaran'))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 💰 Total dan Rata-rata
                    Card(
                      color: Colors.blue[50],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Ringkasan Keuangan',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Total'),
                                    Text(formatCurrency(total),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Rata-rata Harian'),
                                    Text(formatCurrency(avgDaily),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🥧 Grafik Pie Chart
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Distribusi Pengeluaran per Kategori',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 280,
                              child: PieChart(
                                PieChartData(
                                  sections: sections,
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 📋 List Detail per Kategori
                    ...categoryTotals.entries.map((entry) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getColorForCategory(entry.key).withOpacity(0.8),
                            child: const Icon(Icons.category,
                                color: Colors.white, size: 20),
                          ),
                          title: Text(entry.key),
                          trailing: Text(
                            formatCurrency(entry.value),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  // 🔹 Warna unik tiap kategori
  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Colors.orangeAccent;
      case 'transportasi':
        return Colors.blueAccent;
      case 'hiburan':
        return Colors.purpleAccent;
      case 'komunikasi':
        return Colors.green;
      case 'pendidikan':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
