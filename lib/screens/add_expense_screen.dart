import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final ExpenseService _svc = ExpenseService();

  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  int _quantity = 1;
  DateTime _date = DateTime.now();

  List<Category> _categories = [];
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _svc.getAllCategories();
    setState(() => _categories = cats);
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    final expense = Expense(
      title: _title.text.trim(),
      description: _desc.text.trim(),
      category: _selectedCategory!.name,
      price: double.tryParse(_price.text) ?? 0,
      quantity: _quantity,
      date: _date,
    );

    await _svc.insertExpense(expense);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengeluaran'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _categories.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Judul
                    TextFormField(
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    // Deskripsi
                    TextFormField(
                      controller: _desc,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dropdown kategori
                    DropdownButtonFormField<Category>(
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text('${c.icon} ${c.name}'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      validator: (v) =>
                          v == null ? 'Pilih kategori terlebih dahulu' : null,
                    ),
                    const SizedBox(height: 12),

                    // Jumlah barang
                    TextFormField(
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Barang',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) =>
                          _quantity = int.tryParse(val) ?? 1,
                    ),
                    const SizedBox(height: 12),

                    // Harga per item
                    TextFormField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga per Item (Rp)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    // Tanggal
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tanggal: ${_date.day}/${_date.month}/${_date.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _date = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tombol simpan
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Simpan Pengeluaran'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _saveExpense,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
