import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  // Asegúrate de que GoRouter esté importado
import '../../services/firestore_service.dart';  // Importa el servicio de Firestore

class AgregarProductoPage extends StatefulWidget {
  const AgregarProductoPage({super.key});

  @override
  _AgregarProductoPageState createState() => _AgregarProductoPageState();
}

class _AgregarProductoPageState extends State<AgregarProductoPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  int cantidad = 0;
  String categoria = '';
  double precio = 0.0;

  // Instancia del servicio Firestore
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Producto'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Flecha hacia atrás
          onPressed: () {
            // Usar GoRouter para redirigir a la página de inventario
            context.go('/inventory');
          },
        ),
      ),
      appBar: AppBar(title: const Text('Agregar Producto')),
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese nombre' : null,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Ingrese nombre'
                            : null,
              TextFormField(
                decoration: InputDecoration(labelText: 'Categoría'),
                onSaved: (value) => categoria = value!,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    child: Text('Guardar'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Llamar al servicio para agregar el producto a Firestore
                        await firestoreService.agregarProducto(
                          nombre, 
                          cantidad, 
                          categoria, 
                          precio,
                        );
                        // Usar GoRouter para redirigir a la página de inventario
                        context.go('/inventory'); // Asegúrate de que '/inventory' esté configurado correctamente en GoRouter
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Usar GoRouter para redirigir a la página de inventario
                      context.go('/inventory');
                    },
                    child: Text('Regresar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Cambia el color si lo deseas
                    ),
                  ),
                ],
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Guardar'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final nuevoProducto = Producto(
                      nombre: nombre,
                      cantidad: cantidad,
                      precio: precio,
                    );
                    Navigator.pop(
                      context,
                      nuevoProducto,
                    ); // Devuelve el producto creado
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}