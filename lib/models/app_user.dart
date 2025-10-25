class AppUser {
  final int? id;        // Hive key (nullable saat belum disimpan)
  final String name;
  final String email;
  final String password; // simple (untuk tugas). Produksi: hash!

  AppUser({this.id, required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'],
    name: m['name'],
    email: m['email'],
    password: m['password'],
  );
}
