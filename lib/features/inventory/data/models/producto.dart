import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para representar un producto en el inventario
/// 
/// Este modelo contiene toda la información necesaria para gestionar
/// productos en el sistema de inventario, incluyendo conversiones
/// desde y hacia Firestore.
class Producto {
  /// ID único del producto (opcional, se asigna automáticamente en Firestore)
  final String? id;
  
  /// Nombre del producto
  final String nombre;
  
  /// Cantidad disponible en inventario
  final int cantidad;
  
  /// Categoría del producto
  final String categoria;
  
  /// Precio unitario del producto
  final double precio;

  /// Constructor del modelo Producto
  /// 
  /// [id] - ID único del producto (opcional)
  /// [nombre] - Nombre del producto
  /// [cantidad] - Cantidad disponible en inventario
  /// [categoria] - Categoría del producto
  /// [precio] - Precio unitario del producto
  const Producto({
    this.id,
    required this.nombre,
    required this.cantidad,
    required this.categoria,
    required this.precio,
  });

  /// Factory constructor para convertir un DocumentSnapshot de Firestore en un Producto
  /// 
  /// [doc] - DocumentSnapshot de Firestore que contiene los datos del producto
  /// 
  /// Retorna un objeto Producto con los datos extraídos del documento
  factory Producto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return Producto(
      id: doc.id,
      nombre: data['nombre']?.toString() ?? '',
      cantidad: (data['cantidad'] as num?)?.toInt() ?? 0,
      categoria: data['categoria']?.toString() ?? '',
      precio: (data['precio'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convierte el producto a un mapa para almacenar en Firestore
  /// 
  /// Retorna un Map<String, dynamic> con los datos del producto
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
      'categoria': categoria,
      'precio': precio,
    };
  }

  /// Crea una copia del producto con cambios opcionales
  /// 
  /// [id] - Nuevo ID (opcional)
  /// [nombre] - Nuevo nombre (opcional)
  /// [cantidad] - Nueva cantidad (opcional)
  /// [categoria] - Nueva categoría (opcional)
  /// [precio] - Nuevo precio (opcional)
  /// 
  /// Retorna un nuevo objeto Producto con los cambios aplicados
  Producto copyWith({
    String? id,
    String? nombre,
    int? cantidad,
    String? categoria,
    double? precio,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
    );
  }

  /// Valida si el producto tiene datos válidos
  /// 
  /// Un producto es válido si:
  /// - Tiene un nombre no vacío
  /// - Tiene una cantidad no negativa
  /// - Tiene una categoría no vacía
  /// - Tiene un precio no negativo
  bool get isValid => 
    nombre.isNotEmpty && 
    cantidad >= 0 && 
    categoria.isNotEmpty && 
    precio >= 0;

  /// Obtiene un resumen del producto en formato legible
  /// 
  /// Retorna una cadena con el formato: "Nombre - Cantidad unidades - S/ Precio"
  String get summary => '$nombre - $cantidad unidades - S/ ${precio.toStringAsFixed(2)}';

  @override
  String toString() {
    return 'Producto(id: $id, nombre: $nombre, cantidad: $cantidad, categoria: $categoria, precio: $precio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Producto &&
        other.id == id &&
        other.nombre == nombre &&
        other.cantidad == cantidad &&
        other.categoria == categoria &&
        other.precio == precio;
  }

  @override
  int get hashCode {
    return Object.hash(id, nombre, cantidad, categoria, precio);
  }
}
