import 'package:flutter/material.dart';
import '../../data/models/producto.dart';

class ModificarProductoPage extends StatefulWidget {
  final Producto producto;

  ModificarProductoPage({required this.producto});

  @override
  _ModificarProductoPageState createState() => _ModificarProductoPageState();
}

class _ModificarProductoPageState extends State<ModificarProductoPage> {
  final _formKey = GlobalKey<FormState>();

  late String nombre;
  late int cantidad;
  late double precio;

  @override
  void initState() {
    super.initState();
    nombre = widget.producto.nombre;
    cantidad = widget.producto.cantidad;
    precio = widget.producto.precio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modificar Producto')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: nombre,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Ingrese nombre'
                            : null,
                onSaved: (value) => nombre = value!,
              ),
              TextFormField(
                initialValue: cantidad.toString(),
                decoration: InputDecoration(labelText: 'Cantidad'),
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
                initialValue: precio.toString(),
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Guardar cambios'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final productoModificado = Producto(
                      nombre: nombre,
                      cantidad: cantidad,
                      precio: precio,
                      id: widget.producto.id,
                    );
                    Navigator.pop(
                      context,
                      productoModificado,
                    ); // Devuelve producto modificado
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
