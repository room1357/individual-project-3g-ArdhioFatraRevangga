import 'package:flutter/material.dart';

class AdvancedListScreen extends StatefulWidget {
  const AdvancedListScreen({super.key});

  @override
  State<AdvancedListScreen> createState() => _AdvancedListScreenState();
}

class _AdvancedListScreenState extends State<AdvancedListScreen> {
  final List<String> _items = ["crf 150", "wr 155", "klx 150"];

  void _addItem() {
    setState(() {
      _items.add("Item ${_items.length + 1}");
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advanced List"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(_items[index]),
            background: Container(color: Colors.red),
            onDismissed: (direction) {
              _removeItem(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${_items[index]} dihapus")),
              );
            },
            child: ListTile(
              leading: CircleAvatar(child: Text("${index + 1}")),
              title: Text(_items[index]),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Kamu pilih ${_items[index]}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
