import 'package:flutter/material.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        backgroundColor: const Color(0xFFD2C789),
      ),
      body: const Center(child: Text('Módulo de Ventas')),
    );
  }
}
