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
        title: const Text('Menu Utama'),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
          _load();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Menu Utama',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _menuCard(
                    context,
                    title: 'Pengeluaran',
                    color1: Colors.indigo,
                    color2: Colors.blueAccent,
                    icon: Icons.wallet_outlined,
                    page: const AdvancedExpenseListScreen(),
                  ),
                  _menuCard(
                    context,
                    title: 'Profil',
                    color1: Colors.blueAccent,
                    color2: Colors.cyan,
                    icon: Icons.person_outline,
                    page: const ProfileScreen(),
                  ),
                  _menuCard(
                    context,
                    title: 'Statistik',
                    color1: Colors.pinkAccent,
                    color2: Colors.orange,
                    icon: Icons.bar_chart,
                    page: const StatisticsScreen(),
                  ),
                  _menuCard(
                    context,
                    title: 'Kategori',
                    color1: Colors.teal,
                    color2: Colors.lightBlueAccent,
                    icon: Icons.category_outlined,
                    page: const CategoryScreen(),
                  ),
                  _menuCard(
                    context,
                    title: 'Export Data',
                    color1: Colors.orange,
                    color2: Colors.amber,
                    icon: Icons.download_outlined,
                    page: const ExportScreen(),
                  ),
                  _menuCard(
                    context,
                    title: 'Pengaturan',
                    color1: Colors.indigo,
                    color2: Colors.deepPurple,
                    icon: Icons.settings,
                    page: const SettingsScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color1,
      required Color color2,
      Widget? page}) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page!),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
