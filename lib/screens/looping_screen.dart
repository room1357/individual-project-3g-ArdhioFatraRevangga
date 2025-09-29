import 'package:flutter/material.dart';

class LoopingScreen extends StatelessWidget {
  const LoopingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh data
    final List<String> fruits = ["Apel", "Jeruk", "Mangga", "Pisang", "Anggur"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Latihan 5: Looping"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Looping dengan for:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              children: [
                for (int i = 0; i < fruits.length; i++)
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: Text(fruits[i]),
                  ),
              ],
            ),
            const Divider(),

            const Text("Looping dengan for-in:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              children: [
                for (var fruit in fruits)
                  ListTile(
                    leading: const Icon(Icons.check),
                    title: Text(fruit),
                  ),
              ],
            ),
            const Divider(),

            const Text("Looping dengan map():", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              children: fruits.map((fruit) {
                return ListTile(
                  leading: const Icon(Icons.circle),
                  title: Text(fruit),
                );
              }).toList(),
            ),
            const Divider(),

            const Text("Looping dengan List.generate():", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              children: List.generate(fruits.length, (index) {
                return ListTile(
                  leading: const Icon(Icons.local_florist),
                  title: Text(fruits[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
