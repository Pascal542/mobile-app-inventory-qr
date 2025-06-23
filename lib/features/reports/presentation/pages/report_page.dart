import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Reportes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue),
                title: const Text('Reporte General'),
                subtitle: const Text('Ventas, inventario y pagos'),
                onTap: () {
                  // TODO: Implementar navegación a reporte general
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory, color: Colors.green),
                title: const Text('Reporte de Inventario'),
                subtitle: const Text('Stock y productos'),
                onTap: () {
                  // TODO: Implementar navegación a reporte de inventario
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.payment, color: Colors.orange),
                title: const Text('Reporte de Pagos'),
                subtitle: const Text('Transacciones y cobros'),
                onTap: () {
                  // TODO: Implementar navegación a reporte de pagos
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
