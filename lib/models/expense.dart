import 'package:intl/intl.dart';

class Expense {
  final dynamic id;          // Hive key
  final int userId;          // 🔹 pemilik
  final String title;
  final String description;
  final String category;     // nama kategori (punya user)
  final double price;
  final int quantity;
  final DateTime date;
  final List<int> sharedWith; // 🔹 userId lain yang dibagi

  Expense({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.date,
    this.sharedWith = const [],
  });

  double get total => price * quantity;

  String get formattedTotal {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return f.format(total);
  }

  String get formattedDate {
    final f = DateFormat('dd MMM yyyy', 'id_ID');
    return f.format(date);
  }

  // Back-compat
  String get formattedAmount => formattedTotal;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'quantity': quantity,
    'date': date.toIso8601String(),
    'sharedWith': sharedWith,
  };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
    id: m['id'],
    userId: (m['userId'] ?? 0) is String ? int.tryParse(m['userId']) ?? 0 : (m['userId'] ?? 0),
    title: m['title'],
    description: m['description'] ?? '',
    category: m['category'] ?? '',
    price: (m['price'] ?? 0).toDouble(),
    quantity: (m['quantity'] ?? 1).toInt(),
    date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
    sharedWith: (m['sharedWith'] is List) ? List<int>.from(m['sharedWith']) : <int>[],
  );

  Expense copyWith({dynamic id}) => Expense(
    id: id ?? this.id,
    userId: userId,
    title: title,
    description: description,
    category: category,
    price: price,
    quantity: quantity,
    date: date,
    sharedWith: sharedWith,
  );
}
