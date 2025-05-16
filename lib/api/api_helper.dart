import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class ApiHelper {
  final String apiUrl = 'http://localhost:3000/productos'; // URL de la API

  // Obtener los productos desde la API
  Future<List<Producto>> obtenerProductosDeApi() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((productoJson) => Producto.fromMap(productoJson)).toList();
    } else {
      throw Exception('Error al cargar los productos');
    }
  }

  // Agregar un producto a la API
  Future<void> agregarProducto(Producto producto) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(producto.toMap()),
    );

    if (response.statusCode == 201) {
      print('Producto agregado');
    } else {
      throw Exception('Error al agregar el producto');
    }
  }
}