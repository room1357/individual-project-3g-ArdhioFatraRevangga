import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/app_user.dart';
import '../services/expense_service.dart';
import '../services/user_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final ExpenseService _svc = ExpenseService();
  final UserService _userSvc = UserService();

  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  int _quantity = 1;
  DateTime _date = DateTime.now();

  List<Category> _categories = [];
  Category? _selectedCategory;

  // 🔹 Share ke pengguna lain (opsional)
  List<AppUser> _allUsers = [];
  List<int> _sharedWith = []; // id user lain yang dipilih

  bool _loadingCats = true;
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadUsers();
  }

  Future<void> _loadCategories() async {
    final cats = await _svc.getAllCategories();
    setState(() {
      _categories = cats;
      _loadingCats = false;
    });
  }

  Future<void> _loadUsers() async {
    final me = await _userSvc.getCurrentUser();
    final users = await _userSvc.getAllUsers();
    // Exclude diri sendiri dari daftar share
    final filtered = users.where((u) => u.id != me?.id).toList();
    setState(() {
      _allUsers = filtered;
      _loadingUsers = false;
    });
  }

  Future<void> _pickShareUsers() async {
    if (_loadingUsers) return;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bagikan ke Pengguna Lain',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                if (_allUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('Tidak ada pengguna lain.'),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _allUsers.length,
                      itemBuilder: (_, i) {
                        final u = _allUsers[i];
                        final selected = _sharedWith.contains(u.id);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true && u.id != null) {
                                _sharedWith.add(u.id!);
                              } else {
                                _sharedWith.remove(u.id);
                              }
                            });
                          },
                          title: Text(u.name),
                          subtitle: Text(u.email),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Selesai'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
    setState(() {}); // refresh chip pilihan
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    final price = double.tryParse(_price.text.replaceAll(',', '.')) ?? 0;
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga per item harus lebih dari 0')),
      );
      return;
    }

    final exp = Expense(
      id: null,               // akan diisi Hive
      userId: 0,              // diabaikan; akan dioverride oleh service ke currentUserId
      title: _title.text.trim(),
      description: _desc.text.trim(),
      category: _selectedCategory!.name,
      price: price,
      quantity: _quantity,
      date: _date,
      sharedWith: _sharedWith,
    );

    await _svc.insertExpense(exp);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = _loadingCats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengeluaran'),
        backgroundColor: Colors.blueAccent,
      ),
      body: loading
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
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
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
                      validator: (v) => v == null ? 'Pilih kategori terlebih dahulu' : null,
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
                      onChanged: (val) => _quantity = int.tryParse(val) ?? 1,
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
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
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
                            if (picked != null) setState(() => _date = picked);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Share ke user lain (opsional)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _loadingUsers ? null : _pickShareUsers,
                            icon: const Icon(Icons.group_add),
                            label: const Text('Bagikan ke Pengguna Lain'),
                          ),
                        ),
                      ],
                    ),
                    if (_sharedWith.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _sharedWith.map((id) {
                          final u = _allUsers.firstWhere((x) => x.id == id, orElse: () => AppUser(id: id, name: 'User $id', email: '-', password: ''));
                          return Chip(
                            label: Text(u.name),
                            onDeleted: () => setState(() => _sharedWith.remove(id)),
                          );
                        }).toList(),
                      ),
                    ],

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
