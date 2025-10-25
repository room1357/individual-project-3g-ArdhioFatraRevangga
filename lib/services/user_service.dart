import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class UserService {
  final _userBox = Hive.box('users');

  // Register → simpan ke Hive, kembalikan id (key)
  Future<int> register({required String name, required String email, required String password}) async {
    // Cegah email duplikat
    final exists = _userBox.values.cast<Map>().any((m) =>
        (m['email'] as String).toLowerCase() == email.toLowerCase());
    if (exists) throw Exception('Email sudah terdaftar');

    final id = await _userBox.add({
      'name': name,
      'email': email,
      'password': password,
    });

    await setCurrentUserId(id);
    return id;
  }

  // Login
  Future<int> login({required String email, required String password}) async {
    final entries = _userBox.toMap(); // {key: value}
    for (final e in entries.entries) {
      final m = Map<String, dynamic>.from(e.value as Map);
      if ((m['email'] as String).toLowerCase() == email.toLowerCase() &&
          m['password'] == password) {
        await setCurrentUserId(e.key as int);
        return e.key as int;
      }
    }
    throw Exception('Email / password salah');
  }

  // Profile
  Future<AppUser?> getCurrentUser() async {
    final id = await getCurrentUserId();
    if (id == null) return null;
    final m = _userBox.get(id);
    if (m == null) return null;
    final map = Map<String, dynamic>.from(m as Map);
    map['id'] = id;
    return AppUser.fromMap(map);
  }

  // Current user id di SharedPreferences
  Future<void> setCurrentUserId(int id) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('currentUserId', id);
  }

  Future<int?> getCurrentUserId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt('currentUserId');
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('currentUserId');
  }

  // Semua user (untuk share picker)
  Future<List<AppUser>> getAllUsers() async {
    final data = _userBox.toMap();
    return data.entries.map((e) {
      final m = Map<String, dynamic>.from(e.value as Map);
      m['id'] = e.key;
      return AppUser.fromMap(m);
    }).toList();
  }
}
