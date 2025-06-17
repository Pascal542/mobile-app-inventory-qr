import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_inventory_qr/features/inventory/presentation/pages/agregar_producto_page.dart';
import 'package:mobile_app_inventory_qr/features/inventory/presentation/pages/modificar_producto_page.dart';
import '../../services/firestore_service.dart';
import '../../data/models/producto.dart';

class ListadoProductosPage extends StatefulWidget {
  const ListadoProductosPage({super.key});

  @override
  _ListadoProductosPageState createState() => _ListadoProductosPageState();
}

class _ListadoProductosPageState extends State<ListadoProductosPage> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Productos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navegar a agregar producto y esperar el nuevo producto
              final nuevoProducto = await Navigator.push<Producto>(
                context,
                MaterialPageRoute(builder: (context) => const AgregarProductoPage()),
              );
              if (nuevoProducto != null) {
                // Aquí, podrías agregar el nuevo producto directamente a Firestore.
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Producto>>(
        stream: firestoreService.obtenerProductos(),  // Obtener productos de Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());  // Mostrar carga mientras se obtiene la data
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los productos'));  // Si hay error
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay productos aún'));  // Si no hay productos
          }

          // Lista de productos obtenidos de Firestore
          final productos = snapshot.data!;

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              return ListTile(
                title: Text(producto.nombre),
                subtitle: Text('Cantidad: ${producto.cantidad}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Costo unitario: \S/${producto.precio.toStringAsFixed(2)}'),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        // Navegar a modificar producto y esperar el producto modificado
                        final productoModificado = await Navigator.push<Producto>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModificarProductoPage(producto: producto),
                          ),
                        );
                        if (productoModificado != null) {
                          // Aquí puedes actualizar el producto en Firebase si lo has modificado
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
