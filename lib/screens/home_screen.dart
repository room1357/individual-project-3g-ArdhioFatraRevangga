import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'advanced_expense_list_screen.dart';
import 'add_expense_screen.dart';
import 'statistics_screen.dart';
import 'category_screen.dart';
import 'export_screen.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _svc = ExpenseService();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _svc.getAllExpenses();
    setState(() => _expenses = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pengeluaran'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0072ff), Color(0xFF00c6ff)]),
              ),
              accountName: Text("Ardhio Fatra"),
              accountEmail: Text("user@email.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Profil"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Pengaturan"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Kategori"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Statistik"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text("Export Data"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen())),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
          _load();
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFF1F8E9)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('Daftar Pengeluaran Terbaru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _expenses.isEmpty
                  ? const Center(child: Text('Belum ada data pengeluaran'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _expenses.length,
                      itemBuilder: (_, i) {
                        final e = _expenses[i];
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.receipt_long, color: Colors.white)),
                            title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${e.category} • ${formatDate(e.date)}'),
                            trailing: Text(formatCurrency(e.total), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                label: const Text('Lihat Pengeluaran Advanced',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, a, __) => const AdvancedExpenseListScreen(),
                      transitionsBuilder: (_, a, __, child) => SlideTransition(
                        position: a.drive(Tween(begin: const Offset(0, 1), end: Offset.zero)),
                        child: FadeTransition(opacity: a, child: child),
                      ),
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
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
