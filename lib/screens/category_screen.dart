import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/expense_service.dart';
import '../services/user_service.dart'; // pastikan ada di atas

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<Category> _categories = [];

  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _expenseService.getAllCategories();
    setState(() => _categories = cats);
  }

  // 🔹 Tambah atau Edit Kategori
  void _showCategoryDialog({Category? category}) {
    bool isEdit = category != null;
    if (isEdit) {
      _nameController.text = category.name;
      _iconController.text = category.icon;
      _colorController.text = category.color;
    } else {
      _nameController.clear();
      _iconController.clear();
      _colorController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _iconController,
                decoration: const InputDecoration(
                  labelText: 'Ikon (misal: 🎮 / 🍔 / 🚗)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Warna (#hex)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) return;

              final userId = await UserService().getCurrentUserId(); // ambil id user aktif
              final newCategory = Category(
                userId: userId!, // ✅ tambahkan ini
                name: _nameController.text,
                icon: _iconController.text.isEmpty ? '🏷️' : _iconController.text,
                color: _colorController.text.isEmpty ? '#2196F3' : _colorController.text,
              );

              await _expenseService.insertCategory(newCategory);
              Navigator.pop(context);
              _loadCategories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  // 🔻 Hapus kategori
  void _deleteCategory(int id) async {
    await _expenseService.deleteCategory(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _categories.isEmpty
          ? const Center(child: Text('Belum ada kategori'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _parseColor(cat.color),
                      child: Text(cat.icon, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(cat.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showCategoryDialog(category: cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(cat.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🔹 Konversi string warna "#RRGGBB" ke Color Flutter
  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.blueAccent;
    }
  }
}
