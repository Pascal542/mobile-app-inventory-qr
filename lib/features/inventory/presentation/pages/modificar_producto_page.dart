import 'package:flutter/material.dart';
import '../../data/models/producto.dart';
import '../../services/firestore_service.dart'; // Asegúrate de que el servicio Firestore esté importado

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

  // Instancia del servicio Firestore
  final FirestoreService firestoreService = FirestoreService();

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
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese nombre' : null,
                onSaved: (value) => nombre = value!,
              ),
              TextFormField(
                initialValue: cantidad.toString(),
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Ingrese cantidad válida';
                  }
                  int cantidadValue = int.parse(value);
                  // Validación para que la cantidad no sea menor a 0
                  if (cantidadValue < 0) {
                    return 'La cantidad no puede ser menor a 0';
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
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingrese precio válido';
                  }
                  double precioValue = double.parse(value);
                  // Validación para que el precio sea mayor a 0
                  if (precioValue <= 0) {
                    return 'El precio debe ser mayor a 0';
                  }
                  return null;
                },
                onSaved: (value) => precio = double.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Guardar cambios'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Llamar al servicio de Firestore para actualizar el producto por su nombre
                    await firestoreService.actualizarProductoPorNombre(
                      widget.producto.nombre, // El nombre original del producto
                      nombre,  // El nuevo nombre
                      cantidad,  // La nueva cantidad
                      precio,  // El nuevo precio
                      widget.producto.categoria,  // La nueva categoría
                    );

                    // Regresar a la página anterior
                    Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}