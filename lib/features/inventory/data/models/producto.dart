import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  String? id;
  String nombre;
  int cantidad;
  String categoria;
  double precio;

  Producto({
    this.id,
    required this.nombre,
    required this.cantidad,
    required this.categoria,
    required this.precio,
  });

  // Factory constructor para convertir un DocumentSnapshot en un Producto
  factory Producto.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Producto(
      id: doc.id,  // Asignamos el ID del documento de Firestore aquí
      nombre: data['nombre'],
      cantidad: data['cantidad'],
      categoria: data['categoria'],
      precio: data['precio'],
    );
  }

  // Método para convertir un Producto a un mapa para agregar a Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
      'categoria': categoria,
      'precio': precio,
    };
  }
}
