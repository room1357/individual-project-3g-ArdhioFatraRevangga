import 'package:flutter/material.dart';
import '../services/expense_manager.dart';
import '../models/expense.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'advanced_expense_list_screen.dart'; // 🆕 import halaman advanced list

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = ExpenseManager.expenses;

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
                (route) => false,
              );
            },
          ),
        ],
      ),

      // 🧭 Drawer Navigasi
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0072ff), Color(0xFF00c6ff)],
                ),
              ),
              accountName: const Text("Ardhio Fatra"),
              accountEmail: const Text("user@email.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Profil"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Pengaturan"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),

      // 🌈 Body
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF1F8E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              'Daftar Pengeluaran Terbaru',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 🧾 List pengeluaran utama
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  Expense e = expenses[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          e.category[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        e.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('${e.category} • ${e.description}'),
                      trailing: Text(
                        'Rp${e.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🆕 Tombol menuju halaman Advanced ListView
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                label: const Text(
                  'Lihat Pengeluaran Advanced',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AdvancedExpenseListScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
                        final fadeTween = Tween(begin: 0.0, end: 1.0);
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: FadeTransition(
                            opacity: animation.drive(fadeTween),
                            child: child,
                          ),
                        );
                      },
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
