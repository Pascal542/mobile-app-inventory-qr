import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  // Asegúrate de que GoRouter esté importado
import '../../services/firestore_service.dart';  // Importa el servicio de Firestore

class AgregarProductoPage extends StatefulWidget {
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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese nombre' : null,
                onSaved: (value) => nombre = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Ingrese cantidad válida';
                  }
                  int cantidadValue = int.parse(value);
                  // Asegurarse de que la cantidad sea un número entero positivo
                  if (cantidadValue <= 0) {
                    return 'La cantidad debe ser un número entero positivo';
                  }
                  return null;
                },
                onSaved: (value) => cantidad = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingrese precio válido';
                  }
                  double precioValue = double.parse(value);
                  // Asegurarse de que el precio sea un número positivo
                  if (precioValue <= 0) {
                    return 'El precio debe ser un número positivo';
                  }
                  return null;
                },
                onSaved: (value) => precio = double.parse(value!),
              ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}