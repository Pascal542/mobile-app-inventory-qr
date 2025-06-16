import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReporteInventario extends StatelessWidget {
  const ReporteInventario({super.key});

  // Obtener productos del inventario
  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    final snapshot = await FirebaseFirestore.instance.collection('inventario').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final stock = data['stockActual'];
      final precio = data['precio'];

      return {
        'id': doc.id,
        'nombre': data['producto'] ?? 'Desconocido',
        'categoria': data['categoria'] ?? 'Sin categoría',
        'stock': stock is int ? stock : int.tryParse(stock.toString()) ?? 0,
        'precio': precio is num ? precio : double.tryParse(precio.toString()) ?? 0.0,
      };
    }).toList();
  }

  // Obtener cantidad de movimientos por producto
  Future<int> obtenerMovimientos(String productoId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('inventario')
        .doc(productoId)
        .collection('movimientos')
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📦 Reporte de Inventario')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: obtenerProductos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final productos = snapshot.data!;
          final stockBajo = productos.where((p) {
            final stock = p['stock'];
            return stock is int && stock < 10;
          }).toList();

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: Future.wait(productos.map((p) async {
              final movimientos = await obtenerMovimientos(p['id']);
              return {
                ...p,
                'movimientos': movimientos,
              };
            })),
            builder: (context, movSnapshot) {
              if (!movSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final productosConMov = movSnapshot.data!;
              final masMovidos = [...productosConMov];
              masMovidos.sort((a, b) =>
                  (b['movimientos'] as int).compareTo(a['movimientos'] as int));
              final topMovidos = masMovidos.take(3).toList();

              final Map<String, int> categoriaMap = {};
              for (var p in productosConMov) {
                final categoria = p['categoria'] ?? 'Sin categoría';
                final stock = p['stock'];
                final stockInt = stock is int ? stock : int.tryParse(stock.toString()) ?? 0;
                categoriaMap[categoria] = (categoriaMap[categoria] ?? 0) + stockInt;
              }

              final colores = [Colors.blue, Colors.orange, Colors.green, Colors.purple];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📉 Productos con Stock Bajo (<10)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...stockBajo.map((item) => ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(item['nombre'] as String),
                      subtitle: Text('Stock actual: ${item['stock']}'),
                      trailing: Text(
                        'S/ ${(item['precio'] as num).toStringAsFixed(2)}',
                      ),
                    )),
                    const SizedBox(height: 24),
                    const Text(
                      '🔥 Productos Más Movidos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...topMovidos.map((item) => ListTile(
                      leading: const Icon(Icons.trending_up, color: Colors.green),
                      title: Text(item['nombre'] as String),
                      subtitle: Text('${item['movimientos']} movimientos'),
                      trailing: Text('Stock: ${item['stock']}'),
                    )),
                    const SizedBox(height: 24),
                    const Text(
                      '📊 Distribución de Stock por Categoría',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: List.generate(categoriaMap.length, (i) {
                            final entry = categoriaMap.entries.elementAt(i);
                            return PieChartSectionData(
                              color: colores[i % colores.length],
                              value: entry.value.toDouble(),
                              title: '${entry.key} (${entry.value})',
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            );
                          }),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

