import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class Pago {
  final String cliente;
  final double monto;
  final String fecha;

  Pago({
    required this.cliente,
    required this.monto,
    required this.fecha,
  });
}

final List<Pago> pagos = [
  Pago(
    cliente: 'Juan Pérez',
    monto: 150.00,
    fecha: '01/03/2024',
  ),
  Pago(
    cliente: 'María García',
    monto: 275.50,
    fecha: '28/02/2024',
  ),
  Pago(
    cliente: 'Carlos López',
    monto: 320.75,
    fecha: '27/02/2024',
  ),
  Pago(
    cliente: 'Ana Martínez',
    monto: 180.25,
    fecha: '26/02/2024',
  ),
  Pago(
    cliente: 'Roberto Sánchez',
    monto: 420.00,
    fecha: '25/02/2024',
  ),
];

class ReportePagos extends StatefulWidget {
  const ReportePagos({super.key});

  @override
  State<ReportePagos> createState() => _ReportePagosState();
}

class _ReportePagosState extends State<ReportePagos> {
  DateTimeRange? rangoFechasSeleccionado;

  final List<Map<String, dynamic>> ingresos = [
    {
      'inicio': DateTime(2025, 1, 1),
      'fin': DateTime(2025, 1, 15),
      'periodo': '01-15 Ene',
      'ingreso': 1500,
    },
    {
      'inicio': DateTime(2025, 1, 16),
      'fin': DateTime(2025, 1, 31),
      'periodo': '16-31 Ene',
      'ingreso': 1200,
    },
    {
      'inicio': DateTime(2025, 2, 1),
      'fin': DateTime(2025, 2, 15),
      'periodo': '01-15 Feb',
      'ingreso': 2000,
    },
    {
      'inicio': DateTime(2025, 2, 16),
      'fin': DateTime(2025, 2, 28),
      'periodo': '16-28 Feb',
      'ingreso': 1600,
    },
    {
      'inicio': DateTime(2025, 3, 1),
      'fin': DateTime(2025, 3, 15),
      'periodo': '01-15 Mar',
      'ingreso': 1200,
    },
    {
      'inicio': DateTime(2025, 3, 16),
      'fin': DateTime(2025, 3, 31),
      'periodo': '16-31 Mar',
      'ingreso': 1000,
    },
  ];

  List<Map<String, dynamic>> get ingresosFiltrados {
    if (rangoFechasSeleccionado == null) {
      return ingresos;
    } else {
      return ingresos.where((item) {
        final inicio = item['inicio'] as DateTime;
        final fin = item['fin'] as DateTime;
        final rangoInicio = rangoFechasSeleccionado!.start;
        final rangoFin = rangoFechasSeleccionado!.end;

        return fin.isAfter(rangoInicio.subtract(const Duration(days: 1))) &&
            inicio.isBefore(rangoFin.add(const Duration(days: 1)));
      }).toList();
    }
  }

  Future<void> seleccionarRangoFechas() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      initialDateRange: rangoFechasSeleccionado ??
          DateTimeRange(
            start: DateTime(2025, 1, 1),
            end: DateTime(2025, 3, 31),
          ),
    );
    if (picked != null) {
      setState(() {
        rangoFechasSeleccionado = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Reporte de Pagos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/reports'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Gráfico de ingresos por período',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: IngresosGrafico(
                datos: ingresosFiltrados,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: seleccionarRangoFechas,
              child: Text(rangoFechasSeleccionado == null
                  ? 'Seleccionar rango de fechas'
                  : 'Rango: ${formatoFecha.format(rangoFechasSeleccionado!.start)} - ${formatoFecha.format(rangoFechasSeleccionado!.end)}'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Estado de pagos (completados vs. pendientes)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 200, child: PagosEstadoGrafico()),
            const SizedBox(height: 24),
            const Text(
              'Historial de pagos simulados',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const PagosHistorial(),
          ],
        ),
      ),
    );
  }
}

class IngresosGrafico extends StatelessWidget {
  final List<Map<String, dynamic>> datos;

  const IngresosGrafico({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: datos
                .map((e) => (e['ingreso'] as num?)?.toDouble() ?? 0.0)
                .reduce((a, b) => a > b ? a : b) +
            500,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, _) {
                if (value == 0) {
                  return const Text('S/0');
                } else {
                  return Text('S/${(value / 1000).toStringAsFixed(1)}K');
                }
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= 0 && index < datos.length) {
                  return Text(
                    datos[index]['periodo'],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        barGroups: datos.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (item['ingreso'] as num?)?.toDouble() ?? 0.0,
                color: Colors.green,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class PagosEstadoGrafico extends StatelessWidget {
  const PagosEstadoGrafico({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 75,
            color: Colors.blue,
            title: 'Completados\n75%',
            radius: 60,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          PieChartSectionData(
            value: 25,
            color: Colors.red,
            title: 'Pendientes\n25%',
            radius: 60,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }
}

class PagosHistorial extends StatelessWidget {
  const PagosHistorial({super.key});

  @override
  Widget build(BuildContext context) {
    final pagos = [
      {'fecha': '2025-01-15', 'monto': 25, 'estado': 'Completado'},
      {'fecha': '2025-02-10', 'monto': 50, 'estado': 'Pendiente'},
      {'fecha': '2025-03-05', 'monto': 70, 'estado': 'Completado'},
    ];

    return Column(
      children: pagos
          .map(
            (pago) => ListTile(
              title: Text('Fecha: ${pago['fecha']}'),
              subtitle: Text('Estado: ${pago['estado']}'),
              trailing: Text('S/${pago['monto']}'),
            ),
          )
          .toList(),
    );
  }
}
