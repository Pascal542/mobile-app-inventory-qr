import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/inventory_bloc.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../data/models/producto.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DependencyInjection.get<InventoryBloc>()..add(LoadProducts()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📦 Inventario'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/agregar_producto'),
            ),
          ],
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductsLoaded) {
              if (state.products.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay productos en el inventario',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Agrega tu primer producto',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Icon(
                          Icons.inventory_2,
                          color: Colors.deepPurple,
                        ),
                      ),
                      title: Text(
                        product.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Categoría: ${product.categoria}'),
                          Text('Cantidad: ${product.cantidad}'),
                          Text('Precio: S/ ${product.precio.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              context.go('/modificar_producto', extra: product);
                              break;
                            case 'delete':
                              _showDeleteDialog(context, product);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is InventoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar productos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<InventoryBloc>().add(LoadProducts());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            
            return const Center(child: Text('Estado desconocido'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/agregar_producto'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Producto product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar "${product.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<InventoryBloc>().add(DeleteProduct(product.id ?? ''));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}