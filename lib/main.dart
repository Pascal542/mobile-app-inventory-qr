import 'package:flutter/material.dart';
import 'screens/inventario_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Inventarios',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InventarioPage(),
    );
  }
}