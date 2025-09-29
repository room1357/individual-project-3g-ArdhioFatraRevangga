import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<String> _categories = ["Makanan", "Transportasi", "Belanja"];

  void _addCategory(String name) {
    setState(() => _categories.add(name));
  }

  void _removeCategory(int index) {
    setState(() => _categories.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Kategori")),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_categories[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeCategory(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Tambah Kategori"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: "Nama kategori"),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      _addCategory(controller.text);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
