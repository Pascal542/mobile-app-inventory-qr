import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../presentation/bloc/reports_bloc.dart';
import '../data/models/report_models.dart';
import '../../../../core/widgets/app_snackbar.dart';

class GenerarPDF extends StatefulWidget {
  const GenerarPDF({super.key});

  @override
  State<GenerarPDF> createState() => _GenerarPDFState();
}

class _GenerarPDFState extends State<GenerarPDF> {
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos para el PDF
    context.read<ReportsBloc>().add(LoadSalesStatistics());
    context.read<ReportsBloc>().add(LoadInventoryStatistics());
  }

  Future<Uint8List> _generarPdf(SalesStatistics salesStats, InventoryStatistics inventoryStats) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Construcción del PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '📊 Reporte Vendify',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Generado: ${dateFormat.format(now)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // 📊 Reporte General
          pw.Text(
            '📊 Reporte General',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),

          // Resumen de ventas
          pw.Text(
            '📈 Resumen de Ventas',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Total Ingresos: S/ ${salesStats.totalRevenue.toStringAsFixed(2)}'),
          pw.Text('Total Ventas: ${salesStats.totalSales}'),
          pw.Text('Facturas Emitidas: ${salesStats.totalInvoices}'),
          pw.Text('Boletas Emitidas: ${salesStats.totalReceipts}'),
          pw.SizedBox(height: 12),

          // Top productos vendidos
          if (salesStats.topProducts.isNotEmpty) ...[
            pw.Text(
              '🏆 Top Productos Vendidos',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            ...salesStats.topProducts.entries.take(5).map((entry) => 
              pw.Bullet(text: '${entry.key} - ${entry.value} vendidos')
            ),
            pw.SizedBox(height: 12),
          ],

          // Ventas recientes
          if (salesStats.recentSales.isNotEmpty) ...[
            pw.Text(
              '📦 Ventas Recientes',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            ...salesStats.recentSales.take(5).map((sale) => 
              pw.Bullet(text: '${sale.customerName} - ${sale.type == '01' ? 'Factura' : 'Boleta'} - S/ ${sale.total.toStringAsFixed(2)} - ${dateFormat.format(sale.createdAt)}')
            ),
            pw.SizedBox(height: 12),
          ],

          // 📦 Reporte de Inventario
          pw.SizedBox(height: 24),
          pw.Text(
            '📦 Reporte de Inventario',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),

          // Resumen de inventario
          pw.Text(
            '📋 Resumen del Inventario',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Total Productos: ${inventoryStats.totalProducts}'),
          pw.Text('Productos con Stock Bajo: ${inventoryStats.lowStockProducts}'),
          pw.Text('Productos Agotados: ${inventoryStats.outOfStockProducts}'),
          pw.Text('Valor Total del Inventario: S/ ${inventoryStats.totalInventoryValue.toStringAsFixed(2)}'),
          pw.SizedBox(height: 12),

          // Productos con stock bajo
          if (inventoryStats.lowStockItems.isNotEmpty) ...[
            pw.Text(
              '⚠️ Productos con Stock Bajo',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            ...inventoryStats.lowStockItems.map((product) => 
              pw.Bullet(text: '${product.nombre} - Stock: ${product.cantidad} - S/ ${product.precio.toStringAsFixed(2)}')
            ),
            pw.SizedBox(height: 12),
          ],

          // Productos más movidos
          if (inventoryStats.topMovingProducts.isNotEmpty) ...[
            pw.Text(
              '🔥 Productos Más Movidos',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            ...inventoryStats.topMovingProducts.map((product) => 
              pw.Bullet(text: '${product.nombre} - Stock: ${product.cantidad} - S/ ${product.precio.toStringAsFixed(2)}')
            ),
            pw.SizedBox(height: 12),
          ],

          // Distribución por categoría
          if (inventoryStats.productsByCategory.isNotEmpty) ...[
            pw.Text(
              '🧮 Distribución de Stock por Categoría',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            ...inventoryStats.productsByCategory.entries.map((entry) => 
              pw.Text('${entry.key}: ${entry.value} unidades')
            ),
            pw.SizedBox(height: 12),
          ],

          // 💰 Reporte de Pagos
          pw.SizedBox(height: 24),
          pw.Text(
            '💰 Reporte de Pagos',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),

          // Ingresos por mes
          if (salesStats.monthlyRevenue.isNotEmpty) ...[
            pw.Text(
              '📅 Ingresos por Mes',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            ...salesStats.monthlyRevenue.entries.map((entry) {
              final parts = entry.key.split('-');
              final month = '${parts[1]}/${parts[0].substring(2)}';
              return pw.Text('$month: S/ ${entry.value.toStringAsFixed(2)}');
            }),
            pw.SizedBox(height: 12),
          ],

          // Estado de pagos
          pw.Text(
            '📊 Estado de Pagos',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...(() {
            final approvedSales = salesStats.recentSales.where((s) => s.status == 'APROBADO').length;
            final pendingSales = salesStats.recentSales.where((s) => s.status == 'PENDIENTE').length;
            final rejectedSales = salesStats.recentSales.where((s) => s.status == 'RECHAZADO').length;
            final totalRecentSales = salesStats.recentSales.length;
            
            if (totalRecentSales > 0) {
              return [
                pw.Text('Aprobados: ${((approvedSales / totalRecentSales) * 100).toStringAsFixed(1)}%'),
                pw.Text('Pendientes: ${((pendingSales / totalRecentSales) * 100).toStringAsFixed(1)}%'),
                pw.Text('Rechazados: ${((rejectedSales / totalRecentSales) * 100).toStringAsFixed(1)}%'),
              ];
            } else {
              return [pw.Text('No hay ventas recientes para analizar')];
            }
          })(),

          // Pie de página
          pw.SizedBox(height: 40),
          pw.Text(
            'Reporte generado automáticamente por Vendify - ${dateFormat.format(now)}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧾 Generar PDF'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/reports'),
        ),
      ),
      backgroundColor: const Color(0xFFF8F3FF),
      body: BlocListener<ReportsBloc, ReportsState>(
        listener: (context, state) {
          if (state is ReportsError) {
            AppSnackbar.error(context, state.message);
          }
        },
        child: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 64, color: Colors.deepPurple),
                    const SizedBox(height: 20),
                    const Text(
                      'Presiona el botón para generar un informe PDF con todos los datos consolidados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 40),
                    if (state is ReportsLoading)
                      const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Cargando datos para el reporte...'),
                        ],
                      )
                    else if (state is SalesStatisticsLoaded)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : () async {
                            setState(() => _isGenerating = true);
                            try {
                              // Obtener estadísticas de inventario
                              context.read<ReportsBloc>().add(LoadInventoryStatistics());
                              
                              // Esperar un momento para que se carguen los datos
                              await Future.delayed(const Duration(milliseconds: 500));
                              
                              // Generar PDF con datos reales
                              final currentState = context.read<ReportsBloc>().state;
                              if (currentState is SalesStatisticsLoaded) {
                                // Por ahora usamos datos de ventas, en una implementación completa
                                // necesitaríamos esperar también los datos de inventario
                                final pdfData = await _generarPdf(
                                  currentState.statistics,
                                  InventoryStatistics(
                                    totalProducts: 0,
                                    lowStockProducts: 0,
                                    outOfStockProducts: 0,
                                    totalInventoryValue: 0,
                                    productsByCategory: {},
                                    lowStockItems: [],
                                    topMovingProducts: [],
                                  ),
                                );
                                await Printing.layoutPdf(onLayout: (format) async => pdfData);
                              }
                            } catch (e) {
                              AppSnackbar.error(context, 'Error al generar PDF: $e');
                            } finally {
                              setState(() => _isGenerating = false);
                            }
                          },
                          icon: _isGenerating 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.file_download, size: 28),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Text(
                              _isGenerating ? 'Generando PDF...' : 'Generar reporte completo en PDF',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                        ),
                      )
                    else if (state is ReportsError)
                      Column(
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar datos',
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
                      )
                    else
                      const Text(
                        'Cargando datos...',
                        style: TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

