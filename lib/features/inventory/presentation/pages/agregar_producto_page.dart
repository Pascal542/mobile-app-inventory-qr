import 'package:flutter/material.dart';
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
      appBar: AppBar(title: Text('Agregar Producto')),
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
                  if (cantidadValue < 0) {
                    return 'La cantidad no puede ser negativa';
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
                  if (precioValue < 0) {
                    return 'El precio no puede ser negativo';
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
                    Navigator.pop(context); // Regresar a la lista de productos
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