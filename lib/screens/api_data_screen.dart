// 📄 lib/screens/api_data_screen.dart
import 'package:flutter/material.dart';
import '../services/expense_api.dart';
import '../models/expense.dart';

class ApiDataScreen extends StatelessWidget {
  const ApiDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ExpenseApi(); // baseUrl diatur di ExpenseApi

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pengeluaran (API)'),
      ),
      body: FutureBuilder<List<Expense>>(
        future: api.fetchExpenses(), // GET /expenses (read-only)
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorView(
              message: 'Gagal memuat data API:\n${snap.error}',
              onRetry: () {
                // paksa rebuild FutureBuilder
                (context as Element).markNeedsBuild();
              },
            );
          }

          final items = snap.data ?? const <Expense>[];
          if (items.isEmpty) {
            return const _EmptyView(text: 'Belum ada data dari API.');
          }

          return RefreshIndicator(
            onRefresh: () async {
              // paksa rebuild FutureBuilder
              (context as Element).markNeedsBuild();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = items[i];
                return ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(e.title),
                  subtitle: Text('${e.category} • x${e.quantity}'),
                  trailing: Text(e.formattedTotal,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExpenseDetailScreen(expense: e),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(expense.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 15.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KV('Kategori', expense.category),
              _KV('Jumlah', 'x${expense.quantity}'),
              _KV('Harga Total', expense.formattedTotal),
              _KV('Tanggal', expense.formattedDate),
              const SizedBox(height: 12),
              const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                expense.description.isEmpty ? '-' : expense.description,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String k;
  final String v;
  const _KV(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(k, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String text;
  const _EmptyView({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: const TextStyle(color: Colors.black54)));
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
