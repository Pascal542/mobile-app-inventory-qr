import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/producto.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;  // Asegúrate de tener esta línea

  // Función para agregar un producto a Firestore
  Future<void> agregarProducto(String nombre, int cantidad, String categoria, double precio) async {
    try {
      var ref = await _db.collection('productos').add({
        'nombre': nombre,
        'cantidad': cantidad,
        'categoria': categoria,
        'precio': precio,
      });
      print("Producto agregado exitosamente con ID: ${ref.id}");
    } catch (e) {
      print("Error al agregar el producto: $e");
    }
  }

  // Función para obtener todos los productos desde Firestore
  Stream<List<Producto>> obtenerProductos() {
    return _db.collection('productos') // Cambiado a 'productos'
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Producto(
          nombre: doc['nombre'],
          cantidad: doc['cantidad'],
          categoria: doc['categoria'],
          precio: doc['precio'],
        );
      }).toList();
    });
  }

  // Función para actualizar un producto en Firestore
  Future<void> actualizarProducto(String id, String nombre, int cantidad, String categoria, double precio) async {
    try {
      await _db.collection('productos').doc(id).update({
        'nombre': nombre,
        'cantidad': cantidad,
        'categoria': categoria,
        'precio': precio,
      });
      print("Producto actualizado exitosamente.");
    } catch (e) {
      print("Error al actualizar el producto: $e");
    }
  }
}