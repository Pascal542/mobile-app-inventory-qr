import 'package:flutter/material.dart';
import '../api/api_helper.dart';
import '../models/producto.dart';

class InventarioPage extends StatefulWidget {
  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final ApiHelper _apiHelper = ApiHelper();
  List<Producto> _productos = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      var productos = await _apiHelper.obtenerProductosDeApi();
      setState(() {
        _productos = productos;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo conectar al servidor.\nPor favor, revisa tu conexión o el backend.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _agregarProducto() async {
    var nuevoProducto = Producto(nombre: 'Nuevo Producto', cantidad: 10, precio: 99.99);

    try {
      await _apiHelper.agregarProducto(nuevoProducto);
      await _cargarProductos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar producto. Intenta nuevamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Inventarios')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _cargarProductos,
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _productos.length,
                  itemBuilder: (context, index) {
                    final producto = _productos[index];
                    return ListTile(
                      title: Text(producto.nombre),
                      subtitle: Text('Cantidad: ${producto.cantidad}'),
                      trailing: Text('\$${producto.precio.toStringAsFixed(2)}'),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarProducto,
        child: Icon(Icons.add),
      ),
    );
  }
}