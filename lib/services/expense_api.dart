import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/expense.dart';

/// Client sederhana untuk akses endpoint Expenses (gaya Bab 8 json-server).
class ExpenseApi {
  /// Base URL API. Bisa di-override via constructor atau --dart-define.
  final String baseUrl;

  /// User yang aktif (dipakai filter `?userId=`).
  int currentUserId;

  /// HTTP client + timeout
  final http.Client _http;
  final Duration timeout;

  ExpenseApi({
    String? baseUrl,
    this.currentUserId = 0,
    http.Client? httpClient,
    Duration? timeout,
  })  : baseUrl = baseUrl ??
            const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000'),
        _http = httpClient ?? http.Client(),
        timeout = timeout ?? const Duration(seconds: 8);

  /// Ganti user aktif setelah login.
  void setUser(int userId) => currentUserId = userId;

  Uri _u(String path, [Map<String, String>? query]) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$p').replace(queryParameters: query);
  }

  // ========================= READ =========================
  /// Ambil expenses. Defaultnya difilter userId aktif (jika > 0).
  Future<List<Expense>> fetchExpenses({int? userId}) async {
    final uid = userId ?? currentUserId;
    final uri = _u('/expenses', uid > 0 ? {'userId': '$uid'} : null);

    try {
      final res = await _http.get(uri).timeout(timeout);
      _throwIfBad(res);
      final List list = jsonDecode(res.body) as List;
      return list.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      throw Exception('Tidak bisa terhubung ke server: ${uri.toString()}');
    }
  }

  // ========================= CREATE =========================
  /// Tambah expense baru; server biasanya mengembalikan objek created.
  Future<Expense> addExpense(Expense e) async {
    final uri = _u('/expenses');
    final body = jsonEncode({
      'title': e.title,
      'description': e.description,
      'category': e.category,
      'price': e.price,
      'quantity': e.quantity,
      'date': e.date.toIso8601String(),
      'userId': currentUserId, // penting untuk filter di API
    });

    try {
      final res = await _http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(timeout);
      _throwIfBad(res, expected: 201); // json-server: 201 Created
      return Expense.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Tidak bisa terhubung ke server: ${uri.toString()}');
    }
  }

  // ========================= UPDATE =========================
  Future<Expense> updateExpense(Expense e) async {
    if (e.id == null) {
      throw ArgumentError('updateExpense: id tidak boleh null');
    }
    final uri = _u('/expenses/${e.id}');
    final body = jsonEncode({
      'id': e.id,
      'title': e.title,
      'description': e.description,
      'category': e.category,
      'price': e.price,
      'quantity': e.quantity,
      'date': e.date.toIso8601String(),
      'userId': currentUserId,
    });

    try {
      final res = await _http
          .put(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(timeout);
      _throwIfBad(res);
      return Expense.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Tidak bisa terhubung ke server: ${uri.toString()}');
    }
  }

  // ========================= DELETE =========================
  Future<void> deleteExpense(dynamic id) async {
    final uri = _u('/expenses/$id');
    try {
      final res = await _http.delete(uri).timeout(timeout);
      _throwIfBad(res, expected: 200); // json-server balas 200/204
    } on SocketException {
      throw Exception('Tidak bisa terhubung ke server: ${uri.toString()}');
    }
  }

  // ========================= Utils =========================
  void _throwIfBad(http.Response res, {int? expected}) {
    final ok = expected != null ? res.statusCode == expected : (res.statusCode >= 200 && res.statusCode < 300);
    if (ok) return;
    // coba ambil message dari body kalau ada
    try {
      final body = jsonDecode(res.body);
      final msg = (body is Map && body['message'] != null) ? body['message'] : res.body;
      throw Exception('HTTP ${res.statusCode}: $msg');
    } catch (_) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  void close() => _http.close();
}
