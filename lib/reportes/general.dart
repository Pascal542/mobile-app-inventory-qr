import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Para los meses en español

class ReporteGeneral extends StatelessWidget {
  const ReporteGeneral({super.key});

  Future<Map<String, dynamic>> _cargarResumen() async {
    final ventasSnapshot = await FirebaseFirestore.instance.collection('ventas').get();

    double totalIngresos = ventasSnapshot.docs.fold(
      0.0,
          (acc, doc) => acc + (doc['total'] as num).toDouble(),
    );

    int totalProductosVendidos = ventasSnapshot.docs.fold(
      0,
          (acc, doc) => acc + (doc['cantidad'] as num).toInt(),
    );

    return {
      'totalIngresos': totalIngresos,
      'totalProductosVendidos': totalProductosVendidos,
      'totalVentas': ventasSnapshot.docs.length,
    };
  }

  Widget _buildResumenCard({
    required IconData icon,
    required Color color,
    required String titulo,
    required String valor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(titulo),
        subtitle: Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar localización
    initializeDateFormatting('es_PE', null);

    return Scaffold(
      appBar: AppBar(title: const Text('📊 Reporte General')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📅 Ingresos Mensuales (S/.)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ventas')
                  .orderBy('fecha')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final data = snapshot.data!.docs;

                // Agrupar por mes en español
                Map<String, double> ventasPorFecha = {};
                for (var doc in data) {
                  final fecha = (doc['fecha'] as Timestamp).toDate();
                  final fechaStr = DateFormat.MMMM('es_PE').format(fecha); // ejemplo: "junio"
                  final total = (doc['total'] as num).toDouble();
                  ventasPorFecha[fechaStr] = (ventasPorFecha[fechaStr] ?? 0) + total;
                }

                final fechas = ventasPorFecha.keys.toList();
                final valores = ventasPorFecha.values.toList();

                return SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      barGroups: List.generate(fechas.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: valores[index],
                              color: Colors.deepPurple,
                              width: 20,
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(width: 0),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 2000,
                                color: Colors.deepPurple.shade100.withOpacity(0.2),
                              ),
                            ),
                          ],
                          showingTooltipIndicators: [0],
                        );
                      }),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              int index = value.toInt();
                              if (index >= 0 && index < fechas.length) {
                                return Text(fechas[index], style: const TextStyle(fontSize: 10));
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 500,
                            reservedSize: 42, // asegura espacio para textos como "1.8k"
                            getTitlesWidget: (value, _) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('0');
                                case 500:
                                  return const Text('500');
                                case 1000:
                                  return const Text('1k');
                                case 1200:
                                  return const Text('1.2k');
                                case 1300:
                                  return const Text('1.3k');
                                case 1500:
                                  return const Text('1.5k');
                                case 1800:
                                  return const Text('1.8k');
                                case 2000:
                                  return const Text('2k');
                                default:
                                  return const SizedBox.shrink(); // evita mostrar valores incorrectos como "50"
                              }
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.grey.shade800,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              'S/ ${rod.toY.toStringAsFixed(1)}',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            const Text('🏆 Top Productos Vendidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('ventas').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final ventas = snapshot.data!.docs;

                Map<String, int> productosCount = {};
                for (var doc in ventas) {
                  final producto = doc['producto'] as String;
                  final cantidad = (doc['cantidad'] as num).toInt();
                  productosCount[producto] = (productosCount[producto] ?? 0) + cantidad;
                }

                final topProductos = productosCount.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  children: topProductos.take(3).map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(child: Text(entry.key)),
                          Text('${entry.value} vendidos', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),
            const Text('📦 Últimas Ventas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ventas')
                  .orderBy('fecha', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final ventas = snapshot.data!.docs;

                return Column(
                  children: ventas.map((doc) {
                    final fecha = (doc['fecha'] as Timestamp).toDate();
                    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(fecha);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long, color: Colors.purple),
                          const SizedBox(width: 8),
                          Expanded(child: Text(doc['producto'])),
                          Text('S/ ${(doc['total'] as num).toStringAsFixed(2)}'),
                          const SizedBox(width: 8),
                          Text(fechaFormateada, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),
            const Text('📊 Resumen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            FutureBuilder(
              future: _cargarResumen(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final resumen = snapshot.data as Map<String, dynamic>;

                return Column(
                  children: [
                    _buildResumenCard(
                      icon: Icons.attach_money,
                      color: Colors.green,
                      titulo: 'Total Ingresos',
                      valor: 'S/ ${resumen['totalIngresos'].toStringAsFixed(2)}',
                    ),
                    _buildResumenCard(
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                      titulo: 'Total Productos Vendidos',
                      valor: '${resumen['totalProductosVendidos']} unidades',
                    ),
                    _buildResumenCard(
                      icon: Icons.receipt,
                      color: Colors.orange,
                      titulo: 'Total Ventas Registradas',
                      valor: '${resumen['totalVentas']} ventas',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
