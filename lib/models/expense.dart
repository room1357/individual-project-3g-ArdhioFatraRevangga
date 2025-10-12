import 'package:intl/intl.dart';

class Expense {
  final int? id;
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
    required this.date,
  });

  /// 🔹 Hitung total harga: harga × jumlah
  double get total => price * quantity;

  /// 🔹 Format total jadi Rupiah (IDR)
  String get formattedTotal {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return format.format(total);
  }

  /// 🔹 Format tanggal (contoh: 12 Okt 2025)
  String get formattedDate {
    final format = DateFormat('dd MMM yyyy', 'id_ID');
    return format.format(date);
  }

  /// 🔹 Kompatibilitas ke belakang (buat kode lama yg masih pakai `formattedAmount`)
  String get formattedAmount => formattedTotal;

  /// 🔹 Konversi ke Map untuk Hive / SQLite
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'quantity': quantity,
        'date': date.toIso8601String(),
      };

  /// 🔹 Konversi dari Map
  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        category: map['category'],
        price: (map['price'] ?? 0).toDouble(),
        quantity: map['quantity'] ?? 1,
        date: DateTime.parse(map['date']),
      );
}
