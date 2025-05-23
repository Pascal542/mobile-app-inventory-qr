import 'package:flutter/material.dart';
import '../models/producto.dart';
import 'agregar_producto_page.dart';
import 'modificar_producto_page.dart';

class ListadoProductosPage extends StatefulWidget {
  @override
  _ListadoProductosPageState createState() => _ListadoProductosPageState();
}

class _ListadoProductosPageState extends State<ListadoProductosPage> {
  List<Producto> productos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              // Navegar a agregar producto y esperar el nuevo producto
              final nuevoProducto = await Navigator.push<Producto>(
                context,
                MaterialPageRoute(builder: (context) => AgregarProductoPage()),
              );
              if (nuevoProducto != null) {
                setState(() {
                  productos.add(nuevoProducto);
                });
              }
            },
          ),
        ],
      ),
      body: productos.isEmpty
          ? Center(child: Text('No hay productos aún'))
          : ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return ListTile(
                  title: Text(producto.nombre),
                  subtitle: Text('Cantidad: ${producto.cantidad}'),
                  trailing: IconButton(
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
                        setState(() {
                          productos[index] = productoModificado;
                        });
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}