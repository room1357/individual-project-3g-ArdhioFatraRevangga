import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'routes/app_routes.dart';
import 'services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🗃️ Hive init & open boxes
  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('expenses');
  await Hive.openBox('categories');

  // 🌏 Locale Indonesia (tanggal, dll.)
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager App Extended',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      // ✅ Daftarin semua Named Routes di satu tempat
      routes: AppRoutes.buildRoutes(),
      // 🚀 Mulai dari SplashRouter (cek login → redirect ke Login/Home)
      home: const _SplashRouter(),
    );
  }
}

/// Splash ringan yang cek status login lalu redirect pakai Named Routes.
/// Menghindari FutureBuilder di MaterialApp (lebih rapi & aman dari rebuild).
class _SplashRouter extends StatefulWidget {
  const _SplashRouter({super.key});

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _decideStart();
  }

  Future<void> _decideStart() async {
    final userSvc = UserService();
    final id = await userSvc.getCurrentUserId();

    if (!mounted) return;

    // 🔁 Bersihkan stack & arahkan sesuai status login
    if (id != null) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splash sederhana
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
