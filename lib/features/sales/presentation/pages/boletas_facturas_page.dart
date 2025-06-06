import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoletasFacturasPage extends StatelessWidget {
  const BoletasFacturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FF),
      appBar: AppBar(
        title: const Text('📄 Boletas y Facturas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
                _actionButton(
                  context,
                  icon: Icons.receipt_long,
                  label: 'Crear Boleta',
                  color: Colors.indigo,
              onPressed: () => context.go('/boleta_form'),
            ),
                const SizedBox(height: 20),
                _actionButton(
                  context,
                  icon: Icons.request_quote,
                  label: 'Crear Factura',
                  color: Colors.indigoAccent,
              onPressed: () => context.go('/factura_form'),
                ),
                const SizedBox(height: 20),
                _actionButton(
                  context,
                  icon: Icons.list_alt,
                  label: 'Ver Ventas',
                  color: Colors.green,
                  onPressed: () => context.go('/sales_list'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 30),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
        ),
      ),
    );
  }
}
