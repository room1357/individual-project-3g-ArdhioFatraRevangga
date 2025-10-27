import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/currency_utils.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});
  @override
  State<AdvancedExpenseListScreen> createState() => _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  final _svc = ExpenseService();
  final _search = TextEditingController();

  // ✅ cache kategori sebagai const (hemat rebuild)
  static const _categoriesConst = <String>[
    'Semua','Makanan','Transportasi','Hiburan','Komunikasi','Pendidikan'
  ];

  // 🔎 optional: debounce biar gak ngefilter tiap ketik 1 huruf
  Timer? _debounce;

  List<Expense> expenses = [];
  List<Expense> filteredExpenses = [];
  String selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await _svc.getAllExpenses();
    setState(() {
      expenses = data;
      filteredExpenses = data;
    });
  }

  void _filterExpenses() {
    final q = _search.text.toLowerCase();
    setState(() {
      filteredExpenses = expenses.where((e) {
        final s = e.title.toLowerCase().contains(q) ||
                  e.description.toLowerCase().contains(q);
        final c = selectedCategory == 'Semua' || e.category == selectedCategory;
        return s && c;
      }).toList();
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _filterExpenses);
  }

  double _sum(List<Expense> list) => list.fold(0, (s, e) => s + e.total);
  String _avg(List<Expense> list) =>
      list.isEmpty ? 'Rp 0' : formatCurrency(_sum(list) / list.length);

  IconData _icon(String c) {
    switch (c.toLowerCase()) {
      case 'makanan': return Icons.restaurant;
      case 'transportasi': return Icons.directions_car;
      case 'hiburan': return Icons.videogame_asset;
      case 'komunikasi': return Icons.phone_iphone;
      case 'pendidikan': return Icons.school;
      default: return Icons.category;
    }
  }

  Color _color(String c) {
    switch (c.toLowerCase()) {
      case 'makanan': return Colors.orange;
      case 'transportasi': return Colors.blue;
      case 'hiburan': return Colors.purple;
      case 'komunikasi': return Colors.teal;
      case 'pendidikan': return Colors.green;
      default: return Colors.grey;
    }
  }

  // 🗑️ Hapus + konfirmasi + refresh + snackbar
  Future<void> _deleteExpense(Expense e) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Hapus Pengeluaran'),
        content: Text('Yakin ingin menghapus "${e.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && e.id != null) {
      await _svc.deleteExpense(e.id); // ⚠️ pastikan signature service-mu cocok
      await _load();                  // refresh data dulu
      _filterExpenses();              // apply filter aktif biar konsisten

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengeluaran "${e.title}" berhasil dihapus.'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ gunakan const list yang sudah di-cache
    final categories = _categoriesConst;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Advanced'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // 🔍 Search bar (dengan debounce)
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Cari pengeluaran...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // 🏷️ Category filter (horizontal)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(c),
                  selected: selectedCategory == c,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = c;
                      _filterExpenses();
                    });
                  },
                ),
              )).toList(),
            ),
          ),

          // 📊 Statistics summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statCard('Total', formatCurrency(_sum(filteredExpenses))),
                _statCard('Jumlah', '${filteredExpenses.length} item'),
                _statCard('Rata-rata', _avg(filteredExpenses)),
              ],
            ),
          ),

          // 📜 Expense list
          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(child: Text('Tidak ada pengeluaran ditemukan'))
                : ListView.separated(
                    itemCount: filteredExpenses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final e = filteredExpenses[i];
                      return Card(
                        key: ValueKey(e.id ?? '${e.title}-${e.date.toIso8601String()}'),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _color(e.category),
                            child: Icon(_icon(e.category), color: Colors.white),
                          ),
                          title: Text(e.title),
                          subtitle: Text('${e.category} • ${e.formattedDate}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                e.formattedTotal,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _deleteExpense(e),
                                tooltip: 'Hapus',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) => Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );
}
