import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class UserService {
  final Box _userBox = Hive.box('users');

  // 🔹 Registrasi pengguna baru
  Future<bool> register(User user) async {
    if (_userBox.containsKey(user.username)) {
      return false; // username sudah ada
    }
    await _userBox.put(user.username, user.toMap());
    return true;
  }

  // 🔹 Login user
  Future<bool> login(String username, String password) async {
    if (!_userBox.containsKey(username)) return false;
    final stored = User.fromMap(Map<String, dynamic>.from(_userBox.get(username)));
    return stored.password == password;
  }

  // 🔹 Ambil semua user (opsional)
  List<User> getAllUsers() => _userBox.values
      .map((e) => User.fromMap(Map<String, dynamic>.from(e)))
      .toList();
}
