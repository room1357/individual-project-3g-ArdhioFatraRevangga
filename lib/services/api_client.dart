import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException; // aman di mobile/desktop; web akan tree-shake
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Client sederhana dengan baseUrl, timeout, dan error handling.
/// Set via --dart-define=API_BASE_URL=http://127.0.0.1:3000
class ApiClient {
  final String baseUrl;
  final Duration timeout;
  final http.Client _http;

  ApiClient({
    String? baseUrl,
    Duration? timeout,
    http.Client? httpClient,
  })  : baseUrl = (baseUrl ??
            const String.fromEnvironment('API_BASE_URL',
                defaultValue: 'http://127.0.0.1:3000'))
          .replaceAll(RegExp(r'/*$'), ''), // hapus trailing slash
        timeout = timeout ?? const Duration(seconds: 10),
        _http = httpClient ?? http.Client();

  /// Builder URI yang robust: handle leading/trailing slash + query
  Uri _u(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final base = Uri.parse(baseUrl);
    final uri = base.resolve(normalized);
    return (query == null) ? uri : uri.replace(queryParameters: query);
  }

  // ---- HTTP ----

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) =>
      _wrap(() => _http.get(_u(path, query), headers: headers));

  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) =>
      _wrap(() => _http.post(_u(path), body: body, headers: _jsonHeaders(headers)));

  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) =>
      _wrap(() => _http.put(_u(path), body: body, headers: _jsonHeaders(headers)));

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) =>
      _wrap(() => _http.delete(_u(path), headers: headers));

  // ---- Utils ----

  Map<String, String> _jsonHeaders(Map<String, String>? headers) => {
        'Content-Type': 'application/json',
        ...?headers,
      };

  Future<http.Response> _wrap(
    Future<http.Response> Function() f,
  ) async {
    try {
      final res = await f().timeout(timeout);
      _throwIfNeeded(res);
      return res;
    } on TimeoutException {
      throw 'Timeout: server tidak merespons dalam ${timeout.inSeconds}s.';
    } on SocketException {
      throw 'Tidak bisa terhubung ke server (periksa koneksi & alamat $baseUrl).';
    } on http.ClientException catch (e) {
      // Di Flutter Web, kegagalan CORS seringnya jatuh ke sini
      if (kIsWeb &&
          (e.message.contains('XMLHttpRequest error') ||
           e.message.toLowerCase().contains('failed to fetch'))) {
        throw 'Gagal terhubung ke API. Jika di Chrome/Web, pastikan server mengaktifkan CORS '
              '(jalankan json-server dengan --cors) dan baseUrl benar: $baseUrl';
      }
      rethrow;
    }
  }

  void _throwIfNeeded(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    try {
      final body = jsonDecode(res.body);
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : res.body.toString();
      throw 'HTTP ${res.statusCode}: $msg';
    } catch (_) {
      throw 'HTTP ${res.statusCode}: ${res.body}';
    }
  }

  /// Ping endpoint sederhana untuk cek koneksi (opsional panggil saat app start)
  Future<bool> ping() async {
    try {
      final r = await get('/'); // atau '/health' kalau ada
      return r.statusCode >= 200 && r.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  void close() => _http.close();
}
