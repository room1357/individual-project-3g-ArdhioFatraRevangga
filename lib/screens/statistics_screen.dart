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

  // 🔹 Warna kategori konsisten (const map)
  static const Map<String, Color> _catColors = {
    'makanan': Colors.orange,
    'transportasi': Colors.blue,
    'hiburan': Colors.purple,
    'komunikasi': Colors.teal,
    'pendidikan': Colors.green,
    // sisanya → default grey
  };

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

  /// ==========================
  ///  Perhitungan & Utilities
  /// ==========================

  void _calculateStats() {
    // Total semua pengeluaran
    total = _expenses.fold<double>(0, (sum, e) => sum + e.total);

    // Total per kategori (pakai util)
    final raw = _totalsByCategory(_expenses);

    // Gabungkan kategori kecil -> "Lainnya" (mis. < 5% total)
    categoryTotals = _groupSmall(raw, thresholdPct: 0.05);

    // Rata-rata harian (berdasarkan hari unik yang ada transaksi)
    final uniqueDays = _expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();
    final activeDays = uniqueDays.isNotEmpty ? uniqueDays.length : 1;
    avgDaily = total / activeDays;
  }

  Map<String, double> _totalsByCategory(List<Expense> list) {
    final map = <String, double>{};
    for (final e in list) {
      map[e.category] = (map[e.category] ?? 0) + e.total;
    }
    return map;
  }

  /// Gabungkan kategori yang porsinya kecil ke "Lainnya"
  Map<String, double> _groupSmall(Map<String, double> input, {double thresholdPct = 0.05}) {
    if (input.isEmpty) return input;

    final sum = input.values.fold<double>(0, (s, v) => s + v);
    if (sum <= 0) return input;

    final big = <String, double>{};
    double others = 0;

    input.forEach((k, v) {
      final pct = v / sum;
      if (pct >= thresholdPct) {
        big[k] = v;
      } else {
        others += v;
      }
    });

    if (others > 0) {
      big['Lainnya'] = (big['Lainnya'] ?? 0) + others;
    }
    return big;
  }

  Color _colorForCategory(String cat) {
    final key = cat.toLowerCase();
    return _catColors[key] ?? Colors.grey;
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> data) {
    final sum = data.values.fold<double>(0, (s, v) => s + v);
    if (sum <= 0) return [];

    // Tampilkan label persentase (biar pendek & gak numpuk)
    return data.entries.map((e) {
      final value = e.value;
      final pct = (value / sum * 100);
      final title = '${pct.toStringAsFixed(1)}%';
      return PieChartSectionData(
        value: value,
        color: _colorForCategory(e.key),
        radius: 80,
        title: title,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> data) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // besar → kecil
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: entries.map((e) {
        final color = _colorForCategory(e.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('${e.key} — ${formatCurrency(e.value)}'),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pieSections = _buildPieSections(categoryTotals);

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
                    // 💰 Ringkasan
                    Card(
                      color: Colors.blue[50],
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Ringkasan Keuangan',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Total'),
                                    Text(
                                      formatCurrency(total),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Rata-rata Harian'),
                                    Text(
                                      formatCurrency(avgDaily),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🥧 Pie + Legend
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Distribusi Pengeluaran per Kategori',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 280,
                              child: PieChart(
                                PieChartData(
                                  sections: pieSections,
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildLegend(categoryTotals), // ✅ legend rapi & jelas
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 📋 Detail per Kategori (ListView.separated)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildCategoryList(categoryTotals),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// List detail kategori dengan separator rapi
  Widget _buildCategoryList(Map<String, double> data) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 56.0 * entries.length.clamp(0, 8), // batasi tinggi agar tidak terlalu panjang
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(), // ikut scroll parent
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final e = entries[i];
          final color = _colorForCategory(e.key);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.9),
              child: const Icon(Icons.category, color: Colors.white, size: 18),
            ),
            title: Text(e.key),
            trailing: Text(
              formatCurrency(e.value),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
