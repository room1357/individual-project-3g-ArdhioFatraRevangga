import 'package:flutter/material.dart';

import '../services/expense_service.dart';
import '../services/user_service.dart';

import '../models/expense.dart';

// Screens
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'advanced_expense_list_screen.dart';
import 'add_expense_screen.dart';
import 'statistics_screen.dart';
import 'category_screen.dart';
import 'export_screen.dart';
import 'api_data_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _svc = ExpenseService();
  List<Expense> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalOnly(); // ✅ hanya dari Hive lokal
  }

  Future<void> _loadLocalOnly() async {
    setState(() => _loading = true);
    try {
      final cached = await _svc.getAllExpenses();
      if (!mounted) return;
      setState(() => _expenses = cached);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _expenses.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Utama'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            tooltip: 'Refresh Data Lokal',
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocalOnly,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await UserService().logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        onPressed: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (changed == true) _loadLocalOnly();
        },
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF1F8E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Menu Utama',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text('$totalItems item'),
                        avatar: const Icon(Icons.receipt_long, size: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _menu('Pengeluaran', Icons.wallet_outlined, () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AdvancedExpenseListScreen()),
                          );
                        }),
                        _menu('Profil', Icons.person_outline, () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        }),
                        _menu('Statistik', Icons.bar_chart, () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                          );
                        }),
                        _menu('Kategori', Icons.category_outlined, () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const CategoryScreen()),
                          );
                        }),
                        _menu('Export Data', Icons.download_outlined, () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ExportScreen()),
                          );
                        }),

                        /// ✅ Menu ke API Bab 8 (READ ONLY)
                        _menu('Data API', Icons.cloud, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ApiDataScreen()),
                          );
                        }),

                        _menu('Pengaturan', Icons.settings, () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _menu(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 6, offset: const Offset(2, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.bold),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
