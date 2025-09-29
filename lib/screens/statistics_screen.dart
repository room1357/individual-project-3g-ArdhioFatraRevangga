import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/expense_service.dart';

class StatisticsScreen extends StatelessWidget {
  final ExpenseService service;
  const StatisticsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final expenses = service.getAll();

    // Hitung total per kategori
    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.amount;
    }

    final sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        radius: 60,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Statistik Pengeluaran")),
      body: Center(
        child: expenses.isEmpty
            ? const Text("Belum ada data untuk statistik")
            : PieChart(PieChartData(sections: sections)),
      ),
    );
  }
}
