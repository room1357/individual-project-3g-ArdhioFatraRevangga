import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  const EditExpenseScreen({super.key, required this.expense});
  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _svc = ExpenseService();

  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _amount;
  late DateTime _date;

  List<Category> _categories = [];
  Category? _selected;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.expense.title);
    _desc = TextEditingController(text: widget.expense.description);
    _amount = TextEditingController(text: widget.expense.amount.toStringAsFixed(0));
    _date = widget.expense.date;
    _loadCats();
  }

  Future<void> _loadCats() async {
    final cats = await _svc.getAllCategories();
    setState(() {
      _categories = cats;
      _selected = cats.firstWhere((c) => c.name == widget.expense.category, orElse: () => cats.first);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selected == null) return;
    final updated = Expense(
      id: widget.expense.id,
      title: _title.text,
      description: _desc.text,
      category: _selected!.name,
      amount: double.parse(_amount.text),
      date: _date,
    );
    await _svc.updateExpense(updated);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pengeluaran'), backgroundColor: Colors.orangeAccent),
      body: _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _desc, decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Category>(
                      value: _selected,
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text('${c.icon} ${c.name}')))
                          .toList(),
                      onChanged: (v) => setState(() => _selected = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah (Rp)', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Text('Tanggal: ${_date.day}/${_date.month}/${_date.year}')),
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
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.update),
                      label: const Text('Perbarui Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
