class Category {
  final dynamic id;   // Hive key
  final int userId;   // 🔹 pemilik
  final String name;
  final String icon;
  final String color;

  Category({
    this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'name': name,
    'icon': icon,
    'color': color,
  };

  factory Category.fromMap(Map<String, dynamic> m) => Category(
    id: m['id'],
    userId: (m['userId'] ?? 0) is String ? int.tryParse(m['userId']) ?? 0 : (m['userId'] ?? 0),
    name: m['name'],
    icon: m['icon'] ?? '🏷️',
    color: m['color'] ?? '#2196F3',
  );

  Category copyWith({dynamic id}) => Category(
    id: id ?? this.id,
    userId: userId,
    name: name,
    icon: icon,
    color: color,
  );
}
