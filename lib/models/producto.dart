class Producto {
  int? id;
  String nombre;
  int cantidad;
  double precio;

  Producto({this.id, required this.nombre, required this.cantidad, required this.precio});

  // Convertir de un mapa a un objeto Producto
  factory Producto.fromMap(Map<String, dynamic> json) => Producto(
        id: json['id'],
        nombre: json['nombre'],
        cantidad: json['cantidad'],
        precio: json['precio'],
      );

  // Convertir un objeto Producto a un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
      'precio': precio,
    };
  }
}