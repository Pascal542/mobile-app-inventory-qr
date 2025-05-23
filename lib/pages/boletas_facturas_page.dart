import 'package:flutter/material.dart';

class BoletasFacturasPage extends StatelessWidget {
  const BoletasFacturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boletas y Facturas')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/boleta_form'),
              child: const Text('Crear Boleta'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/factura_form'),
              child: const Text('Crear Factura'),
            ),
          ],
        ),
      ),
    );
  }
} 