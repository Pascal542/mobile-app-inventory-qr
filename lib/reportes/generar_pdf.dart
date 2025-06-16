import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GenerarPdfPage extends StatelessWidget {
  const GenerarPdfPage({Key? key}) : super(key: key);

  Future<Uint8List> _generarPdf() async {
    final pdf = pw.Document();

    final firestore = FirebaseFirestore.instance;

    // 🔹 Obtener inventario
    final inventarioSnapshot = await firestore.collection('inventario').get();
    final productos = inventarioSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'nombre': data['producto'],
        'stock': data['stockActual'],
        'precio': data['precio'],
        'categoria': data['categoria'],
        'movimientos': 0, // Puedes actualizar si implementas historial
      };
    }).toList();

    // 🔹 Obtener ventas
    final ventasSnapshot = await firestore.collection('ventas').get();
    final ventas = ventasSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'producto': data['producto'],
        'cantidad': data['cantidad'],
        'fecha': (data['fecha'] as Timestamp).toDate(),
        'total': data['total'],
      };
    }).toList();

    // 🔹 Obtener pagos
    final pagosSnapshot = await firestore.collection('pagos').get();
    final pagos = pagosSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'estado': data['estado'],
        'monto': data['monto'],
        'fecha': (data['fecha'] as Timestamp).toDate(),
      };
    }).toList();

    // 🔢 Cálculos
    final totalIngresos = ventas.fold<double>(
      0.0,
          (sum, v) => sum + double.tryParse(v['total'].toString())!,
    );

    final totalStock = productos.fold<int>(
      0,
          (sum, p) => sum + int.tryParse(p['stock'].toString())!,
    );

    final productosAgotados = productos.where((p) => int.tryParse(p['stock'].toString()) == 0).length;
    final stockBajo = productos.where((p) => int.tryParse(p['stock'].toString())! < 10).toList();

    final pagosCompletados = pagos.where((p) => p['estado'] == 'completado').length;
    final pagosPendientes = pagos.length - pagosCompletados;
    final completadosPct = pagos.isEmpty ? 0 : (pagosCompletados / pagos.length * 100).round();
    final pendientesPct = 100 - completadosPct;

    final Map<String, int> categoriaMap = {};
    for (var p in productos) {
      final categoria = p['categoria'].toString();
      final stock = int.tryParse(p['stock'].toString()) ?? 0;
      categoriaMap[categoria] = (categoriaMap[categoria] ?? 0) + stock;
    }

    // 📄 Construcción del PDF
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [

          pw.Text('📊 Reporte General', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),

          pw.Text('📦 Inventario Total', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Column(children: productos.map((p) =>
              pw.Bullet(text: '${p['nombre']} - Stock: ${p['stock']} - S/ ${(p['precio'] as num).toStringAsFixed(2)}')
          ).toList()),
          pw.SizedBox(height: 12),

          pw.Text('📈 Ventas Registradas', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ventas.isEmpty
              ? pw.Text('No hay ventas registradas.')
              : pw.Column(children: ventas.map((v) =>
              pw.Bullet(text: '${v['producto']} - Cantidad: ${v['cantidad']} - Total: S/ ${v['total']} - Fecha: ${v['fecha'].toString().substring(0, 10)}')
          ).toList()),
          pw.SizedBox(height: 12),

          pw.Text('💰 Pagos Registrados', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pagos.isEmpty
              ? pw.Text('No hay pagos registrados.')
              : pw.Column(children: pagos.map((p) =>
              pw.Bullet(text: 'S/ ${p['monto']} - ${p['estado']} - Fecha: ${p['fecha'].toString().substring(0, 10)}')
          ).toList()),
          pw.SizedBox(height: 12),

          pw.Text('📋 Resumen General'),
          pw.Text('Total Ingresos: S/ ${totalIngresos.toStringAsFixed(2)}'),
          pw.Text('Total Productos en Stock: $totalStock unidades'),
          pw.Text('Productos Agotados: $productosAgotados'),
          pw.Text('Pagos Completados: $completadosPct%'),
          pw.Text('Pagos Pendientes: $pendientesPct%'),

          pw.SizedBox(height: 24),
          pw.Text('⚠️ Productos con Stock Bajo', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          stockBajo.isEmpty
              ? pw.Text('Todos los productos tienen suficiente stock.')
              : pw.Column(children: stockBajo.map((p) => pw.Bullet(text: '${p['nombre']} - Stock: ${p['stock']}')).toList()),

          pw.SizedBox(height: 12),
          pw.Text('🧮 Distribución de Stock por Categoría', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Column(children: categoriaMap.entries.map((e) => pw.Text('${e.key}: ${e.value} unidades')).toList()),
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
      ),
      backgroundColor: const Color(0xFFF8F3FF),
      body: Center(
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final pdfData = await _generarPdf();
                    await Printing.layoutPdf(onLayout: (format) async => pdfData);
                  },
                  icon: const Icon(Icons.file_download, size: 28),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.0),
                    child: Text(
                      'Generar reporte completo en PDF',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

