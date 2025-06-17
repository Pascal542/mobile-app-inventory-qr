import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/producto.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Función para agregar un producto a Firestore
Future<void> agregarProducto(String nombre, int cantidad, String categoria, double precio) async {
  try {
    var ref = await _db.collection('productos').add({
      'nombre': nombre,
      'cantidad': cantidad,
      'categoria': categoria,
      'precio': precio,
    });

    // Crear el objeto Producto con el ID generado por Firestore
    var producto = Producto(
      id: ref.id,  // El ID generado por Firebase
      nombre: nombre,
      cantidad: cantidad,
      categoria: categoria,
      precio: precio,
    );

    print("Producto agregado exitosamente con ID: ${producto.id}");
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
          precio: doc['precio'],  // Incluyendo el ID del documento aquí
        );
      }).toList();
    });
  }
  // Función para actualizar un producto en Firestore utilizando el objeto Producto
Future<void> actualizarProductoPorNombre(String nombre, String nuevoNombre, int nuevaCantidad, double nuevoPrecio, String nuevaCategoria) async {
  try {
    // Buscar los productos por nombre
    var querySnapshot = await _db.collection('productos').where('nombre', isEqualTo: nombre).get();

    // Verificamos si se encontraron productos con ese nombre
    if (querySnapshot.docs.isEmpty) {
      print("No se encontró ningún producto con ese nombre.");
      return;
    }

    // Si se encuentra el producto, se actualiza
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({
        'nombre': nuevoNombre, 
        'cantidad': nuevaCantidad,
        'precio': nuevoPrecio,
        'categoria': nuevaCategoria,
      });
      print("Producto con nombre '$nombre' actualizado exitosamente.");
    }
  } catch (e) {
    print("Error al actualizar el producto: $e");
  }
}
}