import 'package:flutter/material.dart';

// 🔗 Screens
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/advanced_expense_list_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/category_screen.dart';
import '../screens/export_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  // Core
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  // Expense
  static const String expensesAdvanced = '/expenses-advanced';
  static const String addExpense = '/add-expense';

  // Others
  static const String statistics = '/statistics';
  static const String categories = '/categories';
  static const String export = '/export';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> buildRoutes() => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const HomeScreen(),

        expensesAdvanced: (_) => const AdvancedExpenseListScreen(),
        addExpense: (_) => const AddExpenseScreen(),

        statistics: (_) => const StatisticsScreen(),
        categories: (_) => const CategoryScreen(),
        export: (_) => const ExportScreen(),
        settings: (_) => const SettingsScreen(),
        profile: (_) => const ProfileScreen(),
      };
}
