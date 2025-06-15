import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';

class Pago {
  final String? ventaId;
  final double monto;
  final Timestamp? fecha;
  final String estado;
  final String tipo;

  Pago({
    this.ventaId,
    required this.monto,
    this.fecha,
    required this.estado,
    required this.tipo,
  });

  factory Pago.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pago(
      ventaId: data['ventaId'] ?? '',
      monto: (data['monto'] as num).toDouble(),
      fecha: data['fecha'],
      estado: data['estado'] ?? 'sin estado',
      tipo: data['tipo'] ?? 'sin tipo',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ventaId': ventaId,
      'monto': monto,
      'fecha': fecha ?? Timestamp.now(),
      'estado': estado,
      'tipo': tipo,
    };
  }
}

class ReportePagos extends StatefulWidget {
  const ReportePagos({super.key});

  @override
  State<ReportePagos> createState() => _ReportePagosState();
}

class _ReportePagosState extends State<ReportePagos> {
  DateTimeRange? rangoSeleccionado;

  Stream<List<Pago>> getPagosStream() {
    return FirebaseFirestore.instance
        .collection('pagos')
        .orderBy('fecha')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Pago.fromFirestore(doc)).toList());
  }

  void seleccionarRangoFechas(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: rangoSeleccionado ??
          DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
    );

    if (rango != null) {
      setState(() {
        rangoSeleccionado = rango;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Reporte de Pagos'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Pago>>(
        stream: getPagosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Pago> pagos = snapshot.data ?? [];

          // Filtrar por rango de fechas
          if (rangoSeleccionado != null) {
            pagos = pagos.where((p) {
              if (p.fecha == null) return false;
              final fecha = p.fecha!.toDate();
              return fecha.isAfter(rangoSeleccionado!.start.subtract(const Duration(days: 1))) &&
                  fecha.isBefore(rangoSeleccionado!.end.add(const Duration(days: 1)));
            }).toList();
          }

          if (pagos.isEmpty) {
            return const Center(child: Text('No hay pagos registrados.'));
          }

          final completados = pagos.where((p) => p.estado.toLowerCase() == 'completado').length;
          final pendientes = pagos.where((p) => p.estado.toLowerCase() == 'pendiente').length;
          final porPeriodo = _agruparPorPeriodo(pagos);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 Gráfico de ingresos por período', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 250, child: _buildBarChart(porPeriodo)),

                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => seleccionarRangoFechas(context),
                    icon: const Icon(Icons.date_range),
                    label: const Text('Seleccionar rango de fechas'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white70),
                  ),
                ),

                const SizedBox(height: 20),
                const Text('🥧 Estado de pagos (completados vs. pendientes)', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 250, child: _buildPieChart(completados, pendientes)),

                const SizedBox(height: 20),
                const Text('📋 Historial de pagos', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...pagos.map((p) => Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.payments_outlined,
                        color: p.estado.toLowerCase() == 'completado' ? Colors.green : Colors.red),
                    title: Text('S/ ${p.monto.toStringAsFixed(2)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estado: ${p.estado}'),
                        Text('Tipo: ${p.tipo}'),
                        if (p.fecha != null)
                          Text('Fecha: ${DateFormat('dd/MM/yyyy').format(p.fecha!.toDate())}'),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, double> _agruparPorPeriodo(List<Pago> pagos) {
    final Map<String, double> agrupado = {};
    for (var p in pagos) {
      if (p.fecha == null) continue;
      DateTime fecha = p.fecha!.toDate();
      String periodo = (fecha.day <= 15)
          ? '01-15 ${_mes(fecha.month)}'
          : '16-${_ultimoDiaDelMes(fecha)} ${_mes(fecha.month)}';
      agrupado[periodo] = (agrupado[periodo] ?? 0) + p.monto;
    }
    final sorted = SplayTreeMap<String, double>.from(agrupado);
    return sorted;
  }

  Widget _buildBarChart(Map<String, double> data) {
    final List<BarChartGroupData> barGroups = [];
    int index = 0;

    data.forEach((key, value) {
      barGroups.add(BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(toY: value, color: Colors.green, width: 16),
        ],
      ));
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(data.keys.elementAt(index), style: const TextStyle(fontSize: 10)),
                );
              },
              reservedSize: 42,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 500,
              getTitlesWidget: (value, _) => Text('S/${value.toInt()}'),
              reservedSize: 40,
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildPieChart(int completado, int pendiente) {
    final total = completado + pendiente;
    if (total == 0) {
      return const Center(child: Text('No hay datos para mostrar.'));
    }

    final List<PieChartSectionData> sections = [];

    if (completado > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.blue,
          value: completado.toDouble(),
          title: '${(completado / total * 100).round()}%\nCompletado',
          radius: 80,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          titlePositionPercentageOffset: 0.55,
        ),
      );
    }

    if (pendiente > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.red,
          value: pendiente.toDouble(),
          title: '${(pendiente / total * 100).round()}%\nPendiente',
          radius: 80,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          titlePositionPercentageOffset: 0.55,
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 4,
        centerSpaceRadius: 40,
      ),
    );
  }

  String _mes(int mes) {
    const meses = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return meses[mes];
  }

  int _ultimoDiaDelMes(DateTime fecha) {
    return DateTime(fecha.year, fecha.month + 1, 0).day;
  }
}


