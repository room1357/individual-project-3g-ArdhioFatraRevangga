import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../services/export_service.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

// 🔹 Import halaman tambahan
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'advanced_list_screen.dart';
import 'login_screen.dart';
import 'category_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _service = ExpenseService();
  final ExportService _exportService = ExportService(); // 🔹 Tambahin ExportService

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddExpenseScreen(service: _service)),
    );
    if (result == true) setState(() {});
  }

  void _navigateToEdit(int index, Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditExpenseScreen(
          service: _service,
          index: index,
          expense: expense,
        ),
      ),
    );
    if (result == true) setState(() {});
  }

  void _deleteExpense(int index) {
    setState(() {
      _service.deleteExpense(index);
    });
  }

  // 🔹 Drawer Menu
  Drawer _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AboutScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Advanced List"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AdvancedListScreen()));
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Logout"),
            onTap: () {
              // balik ke LoginScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🔹 AppBar Actions (Kategori, Statistik, Export)
  List<Widget> _buildActions(List<Expense> expenses) {
    return [
      IconButton(
        icon: const Icon(Icons.category),
        tooltip: "Kelola Kategori",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryScreen()),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.bar_chart),
        tooltip: "Statistik",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StatisticsScreen(service: _service),
            ),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.download),
        tooltip: "Export CSV",
        onPressed: () async {
          await _exportService.exportCSV(expenses);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data berhasil diexport ke CSV")),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.picture_as_pdf),
        tooltip: "Export PDF",
        onPressed: () async {
          await _exportService.exportPDF(expenses);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data berhasil diexport ke PDF")),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _service.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Manager"),
        actions: _buildActions(expenses), // 🔹 Panggil dengan expenses
      ),
      drawer: _buildDrawer(),
      body: expenses.isEmpty
          ? const Center(child: Text("Belum ada data"))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final e = expenses[index];
                return Card(
                  child: ListTile(
                    title: Text(e.title),
                    subtitle: Text("${e.category} - Rp${e.amount}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _navigateToEdit(index, e),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteExpense(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
