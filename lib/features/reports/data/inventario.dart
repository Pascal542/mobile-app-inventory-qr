import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../presentation/bloc/reports_bloc.dart';
import '../data/models/report_models.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ReporteInventario extends StatefulWidget {
  const ReporteInventario({super.key});

  @override
  State<ReporteInventario> createState() => _ReporteInventarioState();
}

class _ReporteInventarioState extends State<ReporteInventario> {
  @override
  void initState() {
    super.initState();
    // Cargar estadísticas de inventario al inicializar
    context.read<ReportsBloc>().add(LoadInventoryStatistics());
  }

  @override
  Widget build(BuildContext context) {
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
      body: BlocListener<ReportsBloc, ReportsState>(
        listener: (context, state) {
          if (state is ReportsError) {
            AppSnackbar.error(context, state.message);
          }
        },
        child: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            if (state is ReportsLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando estadísticas de inventario...'),
                  ],
                ),
              );
            }

            if (state is InventoryStatisticsLoaded) {
              return _buildInventoryReport(state.statistics);
            }

            if (state is ReportsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar reporte de inventario',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReportsBloc>().add(LoadInventoryStatistics());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('Cargando estadísticas de inventario...'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInventoryReport(InventoryStatistics statistics) {
    final categories = statistics.productsByCategory.keys.toList();
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.red, Colors.teal];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen general
          const Text(
            '📊 Resumen del Inventario',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Productos',
                          '${statistics.totalProducts}',
                          Icons.inventory,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Stock Bajo',
                          '${statistics.lowStockProducts}',
                          Icons.warning,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Agotados',
                          '${statistics.outOfStockProducts}',
                          Icons.remove_shopping_cart,
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Valor Total',
                          'S/ ${statistics.totalInventoryValue.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Productos con stock bajo
          if (statistics.lowStockItems.isNotEmpty) ...[
            const Text(
              '📉 Productos con Stock Bajo (<10)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...statistics.lowStockItems.map((product) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(product.nombre),
                subtitle: Text('Categoría: ${product.categoria}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stock: ${product.cantidad}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      'S/ ${product.precio.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),
          ],

          // Productos más movidos
          if (statistics.topMovingProducts.isNotEmpty) ...[
            const Text(
              '🔥 Productos Más Movidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...statistics.topMovingProducts.map((product) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.trending_up, color: Colors.green),
                title: Text(product.nombre),
                subtitle: Text('Categoría: ${product.categoria}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stock: ${product.cantidad}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'S/ ${product.precio.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),
          ],

          // Distribución por categoría
          if (statistics.productsByCategory.isNotEmpty) ...[
            const Text(
              '📊 Distribución de Stock por Categoría',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: List.generate(categories.length, (i) {
                      final category = categories[i];
                      final stock = statistics.productsByCategory[category] ?? 0;
                      return PieChartSectionData(
                        color: colors[i % colors.length],
                        value: stock.toDouble(),
                        title: '${category}\n(${stock})',
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 80,
                      );
                    }),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Leyenda
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: categories.asMap().entries.map((entry) {
                final i = entry.key;
                final category = entry.value;
                final stock = statistics.productsByCategory[category] ?? 0;
                return Chip(
                  backgroundColor: colors[i % colors.length],
                  label: Text(
                    '$category: $stock',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
