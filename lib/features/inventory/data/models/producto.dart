import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  int? id;
  String nombre;
  int cantidad;
  String categoria;
  double precio;

  Producto({this.id, required this.nombre, required this.cantidad, required this.categoria, required this.precio});

  factory Producto.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Producto(
      nombre: data['nombre'],
      cantidad: data['cantidad'],
      categoria: data['categoria'],
      precio: data['precio'],
    );
  }
    Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
      'categoria': categoria,
      'precio': precio,
    };
  }
}
