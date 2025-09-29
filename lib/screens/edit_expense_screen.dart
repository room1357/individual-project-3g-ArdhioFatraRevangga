import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseService service;
  final int index;
  final Expense expense;

  const EditExpenseScreen({
    super.key,
    required this.service,
    required this.index,
    required this.expense,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _category;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _category = widget.expense.category;
  }

  void _update() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (title.isNotEmpty && amount > 0) {
      widget.service.updateExpense(
        widget.index,
        Expense(
          title: title,
          amount: amount,
          category: _category,
          date: widget.expense.date,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Judul")),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Jumlah")),
            DropdownButton<String>(
              value: _category,
              items: ["Makanan", "Transportasi", "Belanja"]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _update, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
