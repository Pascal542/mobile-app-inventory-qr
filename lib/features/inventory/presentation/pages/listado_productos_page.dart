import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_inventory_qr/features/inventory/presentation/bloc/inventory_bloc.dart';
import '../../data/models/producto.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ListadoProductosPage extends StatefulWidget {
  const ListadoProductosPage({super.key});

  @override
  State<ListadoProductosPage> createState() => _ListadoProductosPageState();
}

class _ListadoProductosPageState extends State<ListadoProductosPage> {
  @override
  void initState() {
    super.initState();
    // Disparamos el evento para cargar los productos del usuario
    context.read<InventoryBloc>().add(LoadProducts());
  }
  
  void _deleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<InventoryBloc>().add(DeleteProduct(productId));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Mi Inventario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/inventory'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/agregar_producto'),
          ),
        ],
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is ProductDeleted) {
            AppSnackbar.success(context, 'Producto eliminado exitosamente');
          } else if (state is InventoryError) {
            AppSnackbar.error(context, 'Error: ${state.message}');
          }
        },
        builder: (context, state) {
          if (state is InventoryLoading || state is InventoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InventoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar tu inventario',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Tu inventario está vacío',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega tu primer producto usando el botón +',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final productos = state.products;

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.withOpacity(0.1),
                      child: const Icon(Icons.inventory, color: Colors.deepPurple),
                    ),
                    title: Text(
                      producto.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Cantidad: ${producto.cantidad} unidades'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('S/ ${producto.precio.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => context.push('/modificar_producto', extra: producto),
                        ),
                        if (producto.id != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(producto.id!),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          // Estado por defecto o inesperado
          return const Center(child: Text('Cargando inventario...'));
        },
      ),
    );
  }
}
