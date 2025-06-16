import 'package:flutter/material.dart';
import '../../data/models/producto.dart';

class AgregarProductoPage extends StatefulWidget {
  const AgregarProductoPage({super.key});

  @override
  _AgregarProductoPageState createState() => _AgregarProductoPageState();
}

class _AgregarProductoPageState extends State<AgregarProductoPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  int cantidad = 0;
  double precio = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Ingrese nombre'
                            : null,
                onSaved: (value) => nombre = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Ingrese cantidad válida';
                  }
                  return null;
                },
                onSaved: (value) => cantidad = int.parse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Ingrese precio válido';
                  }
                  return null;
                },
                onSaved: (value) => precio = double.parse(value!),
              ),
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
