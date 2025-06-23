import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class ReporteInventario extends StatelessWidget {
  const ReporteInventario({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> productos = [
      {
        'nombre': 'Camisa Polo',
        'stock': 25,
        'precio': 59.90,
        'categoria': 'Ropa',
        'movimientos': 120,
      },
      {
        'nombre': 'Jean Slim Fit',
        'stock': 8,
        'precio': 99.90,
        'categoria': 'Ropa',
        'movimientos': 200,
      },
      {
        'nombre': 'Zapatillas Urbanas',
        'stock': 4,
        'precio': 149.90,
        'categoria': 'Calzado',
        'movimientos': 170,
      },
      {
        'nombre': 'Casaca de Cuero',
        'stock': 3,
        'precio': 199.90,
        'categoria': 'Ropa',
        'movimientos': 90,
      },
      {
        'nombre': 'Gorra Snapback',
        'stock': 30,
        'precio': 39.90,
        'categoria': 'Accesorios',
        'movimientos': 60,
      },
    ];

    final stockBajo = productos.where((p) => (p['stock'] as int) < 10).toList();

    final masMovidos = [...productos];
    masMovidos.sort((a, b) =>
        (b['movimientos'] as int).compareTo(a['movimientos'] as int));
    final topMovidos = masMovidos.take(3).toList();

    final Map<String, int> categoriaMap = {};
    for (var p in productos) {
      final categoria = p['categoria'] as String;
      final stock = p['stock'] as int;
      categoriaMap[categoria] = (categoriaMap[categoria] ?? 0) + stock;
    }

    final colores = [Colors.blue, Colors.orange, Colors.green];

    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Reporte de Inventario'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/reports'),
        ),
      ),
      body: SingleChildScrollView(
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
              trailing: Text('S/ ${(item['precio'] as double).toStringAsFixed(2)}'),
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
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    );
                  }),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
