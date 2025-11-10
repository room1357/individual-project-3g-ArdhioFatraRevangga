// 📄 lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'routes/app_routes.dart';
import 'services/user_service.dart';
import 'services/expense_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🗃️ Hive init & open boxes (lokal)
  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('expenses');
  await Hive.openBox('categories');

  // 🌏 Locale Indonesia (tanggal, dll.)
  await initializeDateFormatting('id_ID', null);

  // 🧩 Inisialisasi layanan global (API, user context)
  await _initAppServices();

  runApp(const MyApp());
}

/// ─────────────────────────────────────────────────────────────────────────────
/// AppServices: akses cepat ke ExpenseApi di seluruh app (Bab 8 style)
/// ─────────────────────────────────────────────────────────────────────────────
class AppServices {
  AppServices._();

  static late final ExpenseApi expenseApi; // non-null (di-init sekali)

  /// Panggil sekali di startup
  static Future<void> init() async {
    expenseApi = ExpenseApi(); // ✅ tanpa ApiClient

    // Set userId aktif (0 jika belum login)
    final uid = await UserService().getCurrentUserId() ?? 0;
    expenseApi.setUser(uid);   // ✅ Bab 8: filter data per user di API
  }

  /// Panggil SETIAP kali user login/logout supaya userId di API ikut berubah
  static Future<void> refreshUserContext() async {
    final uid = await UserService().getCurrentUserId() ?? 0;
    expenseApi.setUser(uid);
  }
}

Future<void> _initAppServices() async {
  await AppServices.init();

  // (Opsional) kalau kamu punya SyncService, jalankan background sync di sini.
  // unawaited(Future(() async {
  //   try {
  //     await SyncService(remote: AppServices.expenseApi).syncAll();
  //   } catch (_) {}
  // }));
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
      routes: AppRoutes.buildRoutes(),
      home: const _SplashRouter(),
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter({super.key});

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _decideStart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // (Opsional) saat app resume bisa trigger background sync
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState.resumed) {
    //   unawaited(_tryBackgroundSync());
    // }
  }

  Future<void> _decideStart() async {
    final userSvc = UserService();
    final id = await userSvc.getCurrentUserId();

    // Pastikan context API sesuai user aktif saat app dibuka
    await AppServices.refreshUserContext();

    if (!mounted) return;

    if (id != null) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
