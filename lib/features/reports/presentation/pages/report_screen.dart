import 'package:flutter/material.dart';
import '../../data/general.dart';
import '../../data/inventario.dart';
import '../../data/pagos.dart';
import '../../data/generar_pdf.dart';

class ReporteScreen extends StatelessWidget {
  const ReporteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FF),
      appBar: AppBar(
        title: const Text(
          '📁 Reportes',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _reporteButton(
                  context,
                  icon: Icons.bar_chart,
                  label: 'Reporte General',
                  color: Colors.indigoAccent,
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReporteGeneral(),
                        ),
                      ),
                ),
                const SizedBox(height: 20),
                _reporteButton(
                  context,
                  icon: Icons.inventory,
                  label: 'Reporte de Inventario',
                  color: Colors.orangeAccent,
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReporteInventario(),
                        ),
                      ),
                ),
                const SizedBox(height: 20),
                _reporteButton(
                  context,
                  icon: Icons.attach_money,
                  label: 'Reporte de Pagos',
                  color: Colors.greenAccent.shade400,
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportePagos()),
                      ),
                ),
                const SizedBox(height: 20),
                _reporteButton(
                  context,
                  icon: Icons.picture_as_pdf,
                  label: 'Reporte en PDF',
                  color: Colors.blueAccent,
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GenerarPDF()),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reporteButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 30),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
        ),
      ),
    );
  }
}
