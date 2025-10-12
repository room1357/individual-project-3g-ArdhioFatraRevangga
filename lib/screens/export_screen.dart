import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../services/storage_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});
  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _svc = ExpenseService();
  final _store = StorageService();
  List<Expense> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _svc.getAllExpenses();
    setState(() {
      _expenses = data;
      _loading = false;
    });
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Data Pengeluaran'), backgroundColor: Colors.blueAccent),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
              ? const Center(child: Text('Tidak ada data untuk diekspor'))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _store.exportToCSV(_expenses);
                          _toast('CSV berhasil disimpan/diunduh');
                        },
                        icon: const Icon(Icons.table_chart),
                        label: const Text('Export ke CSV'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _store.exportToPDF(_expenses);
                          _toast('PDF berhasil disimpan/diunduh');
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export ke PDF'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
