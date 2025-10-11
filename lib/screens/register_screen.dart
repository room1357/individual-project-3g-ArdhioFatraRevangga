import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Kembali ke LoginScreen (pop)
            Navigator.pop(context);
          },
          child: const Text('Kembali ke Login'),
        ),
      ),
    );
  }
}
