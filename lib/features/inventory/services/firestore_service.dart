import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_inventory_qr/core/utils/logger.dart';
import '../data/models/producto.dart';

/// Excepciones personalizadas para el servicio de Firestore
class FirestoreException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  FirestoreException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'FirestoreException: $message';
}

class ProductNotFoundException extends FirestoreException {
  ProductNotFoundException(String productName) 
    : super('No se encontró el producto: $productName', code: 'PRODUCT_NOT_FOUND');
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ruta base para los inventarios de los usuarios
  CollectionReference _inventoriesCollection() => _db.collection('inventories');

  /// Agregar un producto al inventario de un usuario
  Future<String> agregarProducto(
    String userId, 
    String nombre, 
    int cantidad, 
    String categoria, 
    double precio
  ) async {
    try {
      if (userId.isEmpty) {
        throw FirestoreException('El ID de usuario no puede estar vacío', code: 'INVALID_USER_ID');
      }
      if (nombre.trim().isEmpty) {
        throw FirestoreException('El nombre del producto no puede estar vacío', code: 'INVALID_NAME');
      }
      if (cantidad < 0) {
        throw FirestoreException('La cantidad no puede ser negativa', code: 'INVALID_QUANTITY');
      }
      if (precio < 0) {
        throw FirestoreException('El precio no puede ser negativo', code: 'INVALID_PRICE');
      }

      var ref = await _inventoriesCollection()
          .doc(userId)
          .collection('products')
          .add({
        'nombre': nombre.trim(),
        'cantidad': cantidad,
        'categoria': categoria.trim(),
        'precio': precio,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'userId': userId, // Opcional, pero bueno para redundancia
      });

      AppLogger.database("Producto agregado (ID: ${ref.id}) al inventario de $userId");
      return ref.id;
    } on FirebaseException catch (e) {
      AppLogger.error("Error de Firebase al agregar producto", e);
      throw FirestoreException('Error de conexión con la base de datos: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error("Error inesperado al agregar producto", e);
      throw FirestoreException('Error inesperado al agregar el producto: $e', originalError: e);
    }
  }

  /// Obtener todos los productos del inventario de un usuario
  Stream<List<Producto>> obtenerProductos(String userId) {
    try {
      if (userId.isEmpty) {
        AppLogger.warning("Se intentó obtener productos con un UID vacío.");
        return Stream.value(<Producto>[]);
      }

      return _inventoriesCollection()
          .doc(userId)
          .collection('products')
          .orderBy('fechaCreacion', descending: true)
          .snapshots()
          .map((snapshot) {
        try {
          return snapshot.docs.map((doc) {
            try {
              return Producto.fromFirestore(doc);
            } catch (e) {
              AppLogger.error("Error al convertir documento a Producto", e);
              return null;
            }
          }).where((producto) => producto != null && producto.nombre.isNotEmpty).cast<Producto>().toList();
        } catch (e) {
          AppLogger.error("Error al procesar snapshot de productos", e);
          return <Producto>[];
        }
      }).handleError((error) {
        AppLogger.error("Error en stream de productos para $userId", error);
        return <Producto>[];
      });
    } catch (e) {
      AppLogger.error("Error al configurar stream de productos para $userId", e);
      return Stream.value(<Producto>[]);
    }
  }

  /// Actualizar un producto en el inventario de un usuario por ID
  Future<void> actualizarProducto(
    String userId, 
    String productId,
    String nuevoNombre, 
    int nuevaCantidad, 
    double nuevoPrecio, 
    String nuevaCategoria
  ) async {
    try {
      if (userId.isEmpty || productId.isEmpty) {
        throw FirestoreException('El ID de usuario o producto no puede estar vacío', code: 'INVALID_ID');
      }
      if (nuevaCantidad < 0) {
        throw FirestoreException('La cantidad no puede ser negativa', code: 'INVALID_QUANTITY');
      }
      if (nuevoPrecio < 0) {
        throw FirestoreException('El precio no puede ser negativo', code: 'INVALID_PRICE');
      }

      await _inventoriesCollection()
          .doc(userId)
          .collection('products')
          .doc(productId)
          .update({
        'nombre': nuevoNombre.trim(),
        'cantidad': nuevaCantidad,
        'precio': nuevoPrecio,
        'categoria': nuevaCategoria.trim(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      AppLogger.database("Producto con ID '$productId' actualizado en el inventario de $userId");
    } on FirebaseException catch (e) {
      AppLogger.error("Error de Firebase al actualizar producto", e);
      throw FirestoreException('Error de conexión con la base de datos: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error("Error inesperado al actualizar producto", e);
      throw FirestoreException('Error inesperado al actualizar el producto: $e', originalError: e);
    }
  }

  /// Eliminar un producto del inventario de un usuario por ID
  Future<void> eliminarProducto(String userId, String productId) async {
    try {
      if (userId.isEmpty || productId.isEmpty) {
        throw FirestoreException('El ID de usuario o producto no puede estar vacío', code: 'INVALID_ID');
      }

      await _inventoriesCollection()
          .doc(userId)
          .collection('products')
          .doc(productId)
          .delete();
      AppLogger.database("Producto con ID '$productId' eliminado del inventario de $userId");
    } on FirebaseException catch (e) {
      AppLogger.error("Error de Firebase al eliminar producto", e);
      throw FirestoreException('Error de conexión con la base de datos: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error("Error inesperado al eliminar producto", e);
      throw FirestoreException('Error inesperado al eliminar el producto: $e', originalError: e);
    }
  }

  /// Disminuir el stock de un producto específico.
  Future<void> decreaseProductStock(String userId, String productId, int quantityToDecrease) async {
    try {
      if (userId.isEmpty || productId.isEmpty) {
        throw FirestoreException('El ID de usuario o producto no puede estar vacío', code: 'INVALID_ID');
      }
      if (quantityToDecrease <= 0) {
        throw FirestoreException('La cantidad a disminuir debe ser positiva', code: 'INVALID_QUANTITY');
      }

      final productRef = _inventoriesCollection().doc(userId).collection('products').doc(productId);
      
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(productRef);
        if (!snapshot.exists) {
          throw ProductNotFoundException(productId);
        }
        final currentStock = (snapshot.data() as Map<String, dynamic>)['cantidad'] as int;
        if (currentStock < quantityToDecrease) {
          throw FirestoreException('Stock insuficiente para el producto ID: $productId', code: 'INSUFFICIENT_STOCK');
        }
        transaction.update(productRef, {'cantidad': currentStock - quantityToDecrease});
      });

      AppLogger.database("Stock del producto '$productId' disminuido en $quantityToDecrease para el usuario $userId");

    } on FirebaseException catch (e) {
      AppLogger.error("Error de Firebase al disminuir stock", e);
      throw FirestoreException('Error de conexión con la base de datos: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error("Error inesperado al disminuir stock", e);
      throw FirestoreException('Error inesperado al disminuir el stock: $e', originalError: e);
    }
  }
}