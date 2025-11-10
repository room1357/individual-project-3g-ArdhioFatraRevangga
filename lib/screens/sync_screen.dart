import 'package:flutter/material.dart';
import '../services/expense_api.dart';
import '../services/sync_service.dart';
import '../models/expense.dart';
import '../models/category.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final _api = ExpenseApi();
  final _sync = SyncService();

  bool _loading = false;
  String _status = 'Belum cek';
  List<Expense> _apiExpenses = [];
  List<Category> _apiCategories = [];

  Future<void> _checkApi() async {
    setState(() {
      _loading = true;
      _status = 'Mengecek...';
    });
    try {
      final exps = await _api.fetchExpenses();
      final cats = await _api.fetchCategories();

      setState(() {
        _apiExpenses = exps;
        _apiCategories = cats;
        _status = 'Terhubung ✅ (expenses: ${exps.length}, categories: ${cats.length})';
      });
    } catch (e) {
      setState(() => _status = 'Gagal konek ❌: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _syncDown() async {
    setState(() {
      _loading = true;
      _status = 'Sinkronisasi dari API → lokal...';
    });
    try {
      await _sync.syncDownFromApi();
      setState(() => _status = 'Sinkronisasi selesai ✅');
    } catch (e) {
      setState(() => _status = 'Sinkron gagal ❌: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _syncUp() async {
    setState(() {
      _loading = true;
      _status = 'Kirim lokal → API (opsional)...';
    });
    try {
      await _sync.syncUpToApi(); // pastikan method ini ada; kalau belum, bisa di-skip
      setState(() => _status = 'Sync up selesai ✅');
    } catch (e) {
      setState(() => _status = 'Sync up gagal ❌: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // auto cek saat dibuka
    _checkApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinkronisasi API'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.blue[50],
              child: ListTile(
                leading: Icon(
                  _status.contains('Terhubung') ? Icons.cloud_done : Icons.cloud_off,
                  color: _status.contains('Terhubung') ? Colors.green : Colors.redAccent,
                ),
                title: const Text('Status Koneksi'),
                subtitle: Text(_status),
                trailing: ElevatedButton.icon(
                  onPressed: _loading ? null : _checkApi,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Cek'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Expenses API', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${_apiExpenses.length} item'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Categories API', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${_apiCategories.length} item'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _syncDown,
                    icon: const Icon(Icons.download),
                    label: const Text('Sync dari API'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _syncUp,
                    icon: const Icon(Icons.upload),
                    label: const Text('Sync ke API'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _apiExpenses.isEmpty
                  ? const Center(child: Text('Tidak ada data expenses dari API'))
                  : ListView.builder(
                      itemCount: _apiExpenses.length,
                      itemBuilder: (_, i) {
                        final e = _apiExpenses[i];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                          title: Text(e.title),
                          subtitle: Text('${e.category} • ${e.formattedDate}'),
                          trailing: Text(e.formattedTotal, style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
