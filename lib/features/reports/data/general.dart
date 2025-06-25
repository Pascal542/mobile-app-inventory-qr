import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../presentation/bloc/reports_bloc.dart';
import '../data/models/report_models.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ReporteGeneral extends StatefulWidget {
  const ReporteGeneral({super.key});

  @override
  State<ReporteGeneral> createState() => _ReporteGeneralState();
}

class _ReporteGeneralState extends State<ReporteGeneral> {
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Cargar estadísticas de ventas al inicializar
    context.read<ReportsBloc>().add(LoadSalesStatistics());
    // Cargar estadísticas de inventario
    context.read<ReportsBloc>().add(LoadInventoryStatistics());
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
        title: const Text('📊 Reporte General'),
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
                    Text('Cargando estadísticas...'),
                  ],
                ),
              );
            }

            if (state is SalesStatisticsLoaded) {
              return _buildSalesReport(state.statistics);
            }

            if (state is ReportsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar reporte',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReportsBloc>().add(LoadSalesStatistics());
                        context.read<ReportsBloc>().add(LoadInventoryStatistics());
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

  Widget _buildSalesReport(SalesStatistics statistics) {
    final monthlyData = statistics.monthlyRevenue;
    final months = monthlyData.keys.toList()..sort();
    
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

          // Gráfico de ingresos mensuales
          if (monthlyData.isNotEmpty) ...[
            const Text(
              '📈 Ingresos Mensuales (S/.)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
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
                              style: const TextStyle(fontSize: 16),
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
            const SizedBox(height: 18),
          ],

          // Ventas recientes
          if (statistics.recentSales.isNotEmpty) ...[
            const Text(
              '📦 Ventas Recientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...statistics.recentSales.take(5).map((sale) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(
                  sale.type == '01' ? Icons.receipt_long : Icons.receipt,
                  color: sale.status == 'APROBADO' ? Colors.green : Colors.orange,
                ),
                title: Text(sale.customerName),
                subtitle: Text('${sale.type == '01' ? 'Factura' : 'Boleta'} - ${DateFormat('dd/MM/yyyy').format(sale.createdAt)}'),
                trailing: Text(
                  'S/ ${sale.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            )),
            const SizedBox(height: 24),
          ],

          // Resumen
          const Text(
            '📊 Resumen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.green),
              title: const Text('Total Ingresos'),
              trailing: Text(
                'S/ ${statistics.totalRevenue.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.blue),
              title: const Text('Total Ventas'),
              trailing: Text(
                '${statistics.totalSales}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.purple),
              title: const Text('Facturas Emitidas'),
              trailing: Text(
                '${statistics.totalInvoices}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.receipt, color: Colors.orange),
              title: const Text('Boletas Emitidas'),
              trailing: Text(
                '${statistics.totalReceipts}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}