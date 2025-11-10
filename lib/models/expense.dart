import 'package:intl/intl.dart';

class Expense {
  final dynamic id;            // bisa null / int / String (aman untuk API & Hive)
  final String title;
  final String description;
  final String category;
  final double price;
  final int quantity;
  final DateTime date;

  Expense({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  double get total => price * quantity;

  String get formattedTotal {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return f.format(total);
  }

  String get formattedDate {
    final f = DateFormat('dd MMM yyyy', 'id_ID');
    return f.format(date);
  }

  // ---------------- Helpers parsing ----------------
  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  static double _asDouble(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  static DateTime _asDate(dynamic v) {
    if (v == null) return DateTime.now();
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  static String _asString(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    return v.toString();
  }

  // ---------------- fromJson (API) ----------------
  factory Expense.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return Expense(
      id: rawId, // biarkan dinamis; tidak dipaksa ke int
      title: _asString(json['title']),
      description: _asString(json['description']),
      category: _asString(json['category']),
      price: _asDouble(json['price']),
      quantity: _asInt(json['quantity'], fallback: 1),
      date: _asDate(json['date']),
    );
  }
}
