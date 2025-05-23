import 'package:flutter/material.dart';
import 'screens/listado_productos_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventarios',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ListadoProductosPage(),
    );
  }
}