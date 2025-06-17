import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  // Importar GoRouter

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FF),
      appBar: AppBar(
        title: const Text('📦 Inventario',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),  // Regresar a la página principal
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Botón para agregar productos
                _actionButton(
                  context,
                  icon: Icons.add_box,
                  label: 'Agregar Producto',
                  color: Colors.indigo,
                  onPressed: () => context.go('/agregar_producto'),  // Navegar a la página de agregar producto
                ),
                const SizedBox(height: 20),
                
                // Botón para listar productos
                _actionButton(
                  context,
                  icon: Icons.list_alt,
                  label: 'Listar Productos',
                  color: Colors.indigoAccent,
                  onPressed: () => context.go('/listado_productos'),  // Navegar a la página de listar productos
                ),
                const SizedBox(height: 20),
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