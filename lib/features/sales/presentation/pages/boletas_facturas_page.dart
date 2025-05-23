import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoletasFacturasPage extends StatelessWidget {
  const BoletasFacturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boletas y Facturas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/boleta_form'),
              child: const Text('Crear Boleta'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/factura_form'),
              child: const Text('Crear Factura'),
            ),
          ],
        ),
      ),
    );
  }
}
