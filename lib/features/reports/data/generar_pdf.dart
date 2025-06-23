import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:go_router/go_router.dart';

class GenerarPDF extends StatelessWidget {
  const GenerarPDF({super.key});

  Future<Uint8List> _generarPdf() async {
    final pdf = pw.Document();

    // Datos de ejemplo
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
    const totalStock = 25 + 8 + 4 + 3 + 30;
    const productosAgotados = 2;

    final ingresosPorPeriodo = [
      {'periodo': '01-15 Ene', 'ingreso': 1500},
      {'periodo': '16-31 Ene', 'ingreso': 1200},
      {'periodo': '01-15 Feb', 'ingreso': 2000},
      {'periodo': '16-28 Feb', 'ingreso': 1600},
      {'periodo': '01-15 Mar', 'ingreso': 1200},
      {'periodo': '16-31 Mar', 'ingreso': 1000},
    ];

    final pagosHistorial = [
      {'fecha': '2025-01-15', 'monto': 25, 'estado': 'Completado'},
      {'fecha': '2025-02-10', 'monto': 50, 'estado': 'Pendiente'},
      {'fecha': '2025-03-05', 'monto': 70, 'estado': 'Completado'},
    ];

    final productos = [
      {'nombre': 'Camisa Polo', 'stock': 25, 'precio': 59.90, 'categoria': 'Ropa', 'movimientos': 120},
      {'nombre': 'Jean Slim Fit', 'stock': 8, 'precio': 99.90, 'categoria': 'Ropa', 'movimientos': 200},
      {'nombre': 'Zapatillas Urbanas', 'stock': 4, 'precio': 149.90, 'categoria': 'Calzado', 'movimientos': 170},
      {'nombre': 'Casaca de Cuero', 'stock': 3, 'precio': 199.90, 'categoria': 'Ropa', 'movimientos': 90},
      {'nombre': 'Gorra Snapback', 'stock': 30, 'precio': 39.90, 'categoria': 'Accesorios', 'movimientos': 60},
    ];

    final stockBajo = productos.where((p) => (p['stock'] as int) < 10).toList();
    final masMovidos = [...productos]..sort((a, b) => (b['movimientos'] as int).compareTo(a['movimientos'] as int));
    final topMovidos = masMovidos.take(3).toList();

    final Map<String, int> categoriaMap = {};
    for (var p in productos) {
      final categoria = p['categoria'] as String;
      final stock = p['stock'] as int;
      categoriaMap[categoria] = (categoriaMap[categoria] ?? 0) + stock;
    }

    // Construcción del PDF
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [

          // 📊 Reporte General
          pw.Text('📊 Reporte General', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),

          pw.Text('📈 Ingresos Mensuales', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Column(children: ingresosMensuales.entries.map((e) => pw.Text('${e.key}: S/ ${e.value.toStringAsFixed(2)}')).toList()),
          pw.SizedBox(height: 12),

          pw.Text('🏆 Top Productos Vendidos', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Column(children: topProductos.map((p) => pw.Bullet(text: '${p['nombre']} - ${p['usos']} vendidos')).toList()),
          pw.SizedBox(height: 12),

          pw.Text('📦 Últimos Movimientos', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Column(children: movimientos.map((m) => pw.Bullet(text: '${m['tipo']}: ${m['producto']} - Cant: ${m['cantidad']} - Fecha: ${m['fecha']}')).toList()),
          pw.SizedBox(height: 12),

          pw.Text('📋 Resumen', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text('Total Ingresos: S/ ${totalIngresos.toStringAsFixed(2)}'),
          pw.Text('Total Productos en Stock: $totalStock unidades'),
          pw.Text('Productos Agotados: $productosAgotados'),

          // 📦 Reporte de Inventario
          pw.SizedBox(height: 24),
          pw.Text('📦 Reporte de Inventario', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),

          pw.Text('⚠️ Productos con Stock Bajo', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          stockBajo.isEmpty
              ? pw.Text('Todos los productos tienen suficiente stock.')
              : pw.Column(children: stockBajo.map((p) => pw.Bullet(text: '${p['nombre']} - Stock: ${p['stock']} - S/ ${(p['precio'] as double).toStringAsFixed(2)}')).toList()),
          pw.SizedBox(height: 12),

          pw.Text('🔥 Productos Más Movidos', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Column(children: topMovidos.map((p) => pw.Bullet(text: '${p['nombre']} - ${p['movimientos']} movimientos - Stock: ${p['stock']}')).toList()),
          pw.SizedBox(height: 12),

          pw.Text('🧮 Distribución de Stock por Categoría', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Column(children: categoriaMap.entries.map((e) => pw.Text('${e.key}: ${e.value} unidades')).toList()),

          // 💰 Reporte de Pagos
          pw.SizedBox(height: 24),
          pw.Text('💰 Reporte de Pagos', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),

          pw.Text('📅 Gráfico de Ingresos por Periodo', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Column(children: ingresosPorPeriodo.map((p) => pw.Text('${p['periodo']}: S/ ${p['ingreso']}')).toList()),
          pw.SizedBox(height: 12),

          pw.Text('📊 Reporte de Pagos (Completados vs Pendientes)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text('Completados: 75%'),
          pw.Text('Pendientes: 25%'),
          pw.SizedBox(height: 12),

          pw.Text('📋 Historial de Pagos Simulados', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Column(children: pagosHistorial.map((p) => pw.Text('Fecha: ${p['fecha']} - S/ ${p['monto']} - ${p['estado']}')).toList()),
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

