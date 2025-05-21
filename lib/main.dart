import 'package:flutter/material.dart';
import 'views/pago_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Inventario',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const PagoView(),
    );
  }
}
