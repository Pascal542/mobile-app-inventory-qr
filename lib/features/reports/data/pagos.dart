import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../presentation/bloc/reports_bloc.dart';
import '../data/models/report_models.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ReportePagos extends StatefulWidget {
  const ReportePagos({super.key});

  @override
  State<ReportePagos> createState() => _ReportePagosState();
}

class _ReportePagosState extends State<ReportePagos> {
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Cargar estadísticas de ventas al inicializar
    context.read<ReportsBloc>().add(const LoadSalesStatistics());
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
      // Recargar estadísticas con el nuevo rango de fechas
      context.read<ReportsBloc>().add(LoadSalesStatistics(dateRange: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Reporte de Pagos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/reports'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Seleccionar rango de fechas',
          ),
        ],
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
                    Text('Cargando estadísticas de pagos...'),
                  ],
                ),
              );
            }

            if (state is SalesStatisticsLoaded) {
              return _buildPaymentsReport(state.statistics);
            }

            if (state is ReportsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar reporte de pagos',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReportsBloc>().add(const LoadSalesStatistics());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('Selecciona un rango de fechas para ver las estadísticas'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentsReport(SalesStatistics statistics) {
    final monthlyData = statistics.monthlyRevenue;
    final months = monthlyData.keys.toList()..sort();
    
    // Calcular estadísticas adicionales
    final totalSales = statistics.totalSales;
    final totalRevenue = statistics.totalRevenue;
    final averageSale = totalSales > 0 ? totalRevenue / totalSales : 0.0;
    
    // Agrupar ventas por estado
    final approvedSales = statistics.recentSales.where((s) => s.status == 'APROBADO').length;
    final pendingSales = statistics.recentSales.where((s) => s.status == 'PENDIENTE').length;
    final rejectedSales = statistics.recentSales.where((s) => s.status == 'RECHAZADO').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtro de fechas
          if (selectedDateRange != null)
            Card(
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Período: ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(
                      onPressed: _selectDateRange,
                      child: const Text('Cambiar'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Resumen de ingresos
          const Text(
            '📊 Resumen de Ingresos',
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
                          'Total Ingresos',
                          'S/ ${totalRevenue.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Total Ventas',
                          '$totalSales',
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Promedio por Venta',
                          'S/ ${averageSale.toStringAsFixed(2)}',
                          Icons.trending_up,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Ventas Aprobadas',
                          '$approvedSales',
                          Icons.check_circle,
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

          // Gráfico de ingresos por período
          if (monthlyData.isNotEmpty) ...[
            const Text(
              '📈 Gráfico de Ingresos por Período',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: monthlyData.values.isNotEmpty 
                      ? monthlyData.values.reduce((a, b) => a > b ? a : b) + 100
                      : 1000,
                  barGroups: months.asMap().entries.map((entry) {
                    final i = entry.key;
                    final month = entry.value;
                    final valor = monthlyData[month] ?? 0.0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: valor,
                          color: Colors.deepPurple,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          if (value.toInt() < months.length) {
                            final month = months[value.toInt()];
                            final parts = month.split('-');
                            return Text(
                              '${parts[1]}/${parts[0].substring(2)}',
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
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
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Estado de pagos
          const Text(
            '📋 Estado de Pagos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: approvedSales.toDouble(),
                      title: 'Aprobados\n($approvedSales)',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      radius: 80,
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: pendingSales.toDouble(),
                      title: 'Pendientes\n($pendingSales)',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      radius: 80,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: rejectedSales.toDouble(),
                      title: 'Rechazados\n($rejectedSales)',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      radius: 80,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Leyenda
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                backgroundColor: Colors.green,
                label: const Text(
                  'Aprobados',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Chip(
                backgroundColor: Colors.orange,
                label: const Text(
                  'Pendientes',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Chip(
                backgroundColor: Colors.red,
                label: const Text(
                  'Rechazados',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Historial de pagos
          const Text(
            '📋 Historial de Pagos Recientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (statistics.recentSales.isNotEmpty)
            ...statistics.recentSales.take(10).map((sale) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(
                  sale.type == '01' ? Icons.receipt_long : Icons.receipt,
                  color: _getStatusColor(sale.status),
                ),
                title: Text(sale.customerName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${sale.type == '01' ? 'Factura' : 'Boleta'} - ${DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt)}'),
                    Text('Estado: ${sale.status}'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'S/ ${sale.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      sale.customerRuc,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ))
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay ventas registradas en el período seleccionado',
                  style: TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APROBADO':
        return Colors.green;
      case 'PENDIENTE':
        return Colors.orange;
      case 'RECHAZADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
