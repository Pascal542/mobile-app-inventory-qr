import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReporteGeneral extends StatelessWidget {
  const ReporteGeneral({super.key});

  @override
  Widget build(BuildContext context) {
    final ingresosMensuales = {
      'Ene': 1200.0,
      'Feb': 1500.0,
      'Mar': 1800.0,
      'Abr': 1000.0,
      'May': 1300.0,
    };

    final topProductos = [
      {'nombre': 'Camisa Polo', 'usos': 120},
      {'nombre': 'Jean Slim Fit', 'usos': 95},
      {'nombre': 'Zapatillas Urbanas', 'usos': 85},
    ];

    final movimientos = [
      {'tipo': 'Entrada', 'producto': 'Camisa Polo', 'cantidad': 10, 'fecha': '20/05'},
      {'tipo': 'Salida', 'producto': 'Jean Slim Fit', 'cantidad': 2, 'fecha': '19/05'},
      {'tipo': 'Entrada', 'producto': 'Zapatillas Urbanas', 'cantidad': 5, 'fecha': '18/05'},
    ];

    final totalIngresos = ingresosMensuales.values.reduce((a, b) => a + b);
    final totalStock = 25 + 8 + 4 + 3 + 30;
    final productosAgotados = 2;

    return Scaffold(
      appBar: AppBar(title: const Text('📊 Reporte General')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Ingresos Mensuales (S/.)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: ingresosMensuales.entries.toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final valor = entry.value.value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(toY: valor, color: Colors.purple),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final labels = ingresosMensuales.keys.toList();
                          return Text(labels[value.toInt()], style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) {
                          if (value >= 1000) {
                            return Text(
                              '${(value / 1000).toStringAsFixed(1)}K',
                              style: const TextStyle(fontSize: 12),
                            );
                          } else {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '🏆 Top Productos Vendidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...topProductos.map((item) => ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(item['nombre'] as String),
              trailing: Text('${item['usos']} vendidos'),
            )),
            const SizedBox(height: 24),
            const Text(
              '📦 Últimos Movimientos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...movimientos.map((item) => ListTile(
              leading: Icon(
                item['tipo'] == 'Entrada' ? Icons.call_received : Icons.call_made,
                color: item['tipo'] == 'Entrada' ? Colors.green : Colors.red,
              ),
              title: Text('${item['tipo']}: ${item['producto']}'),
              subtitle: Text('Cantidad: ${item['cantidad']}'),
              trailing: Text(item['fecha'] as String),
            )),
            const SizedBox(height: 24),
            const Text(
              '📊 Resumen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: const Text('Total Ingresos'),
                trailing: Text('S/ ${totalIngresos.toStringAsFixed(2)}'),
              ),
            ),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.inventory, color: Colors.blue),
                title: const Text('Total Productos en Stock'),
                trailing: Text('$totalStock unidades'),
              ),
            ),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('Productos Agotados'),
                trailing: Text('$productosAgotados'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
