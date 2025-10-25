import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🟢 Inisialisasi Hive & buka box
  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('expenses');
  await Hive.openBox('categories');

  // 🌏 Locale Indonesia untuk intl (tanggal, dll)
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Tentukan layar awal berdasarkan status login (SharedPreferences)
  Future<bool> _isLoggedIn() async {
    final userSvc = UserService();
    final id = await userSvc.getCurrentUserId();
    return id != null; // true = sudah login
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager App Extended',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            // Splash sederhana
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // true -> HomeScreen, false -> LoginScreen
          return snap.data == true ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
