import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/expense_service.dart';
import '../services/user_service.dart';

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

  /// 🔹 Show dialog tambah / edit kategori
  void _showCategoryDialog({Category? category}) async {
    final isEdit = category != null;

    _nameController.text = category?.name ?? '';
    _iconController.text = category?.icon ?? '';
    _colorController.text = category?.color ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
                labelText: 'Warna (#2196F3)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) return;

              final userId = await UserService().getCurrentUserId() ?? 0;

              final updatedCategory = Category(
                id: category?.id,
                userId: userId,
                name: _nameController.text.trim(),
                icon: _iconController.text.trim().isEmpty
                    ? '🏷️'
                    : _iconController.text.trim(),
                color: _colorController.text.trim().isEmpty
                    ? '#2196F3'
                    : _colorController.text.trim(),
              );

              if (isEdit) {
                await _expenseService.updateCategory(updatedCategory);
              } else {
                await _expenseService.insertCategory(updatedCategory);
              }

              Navigator.pop(context);
              _loadCategories();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(dynamic id) async {
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
              itemBuilder: (_, i) {
                final cat = _categories[i];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _parseColor(cat.color),
                      child: Text(cat.icon, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(cat.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // ⬅ taruh di Row, bukan di IconButton
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

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.blueAccent;
    }
  }
}
