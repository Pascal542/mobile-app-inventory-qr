import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/producto.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final List<Producto> _productos = [
    Producto(nombre: 'Producto 1', cantidad: 10, precio: 100),
    Producto(nombre: 'Producto 2', cantidad: 20, precio: 200),
    Producto(nombre: 'Producto 3', cantidad: 30, precio: 300),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implementar navegación a página de agregar producto
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          return Card(
            child: ListTile(
              title: Text(
                producto.nombre,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Cantidad: ${producto.cantidad} - Precio: \$${producto.precio}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Implementar navegación a página de editar producto
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // TODO: Implementar eliminación de producto
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
