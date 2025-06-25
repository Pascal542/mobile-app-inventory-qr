import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/reports_bloc.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Reportes'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: BlocListener<ReportsBloc, ReportsState>(
        listener: (context, state) {
          if (state is ReportsError) {
            AppSnackbar.error(context, state.message);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecciona el tipo de reporte que deseas generar:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.blue, size: 32),
                  title: const Text(
                    'Reporte General',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: const Text('Ventas, inventario y estadísticas generales'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/reporte_general'),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.inventory, color: Colors.green, size: 32),
                  title: const Text(
                    'Reporte de Inventario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: const Text('Stock, productos y categorías'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/reporte_inventario'),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.payment, color: Colors.orange, size: 32),
                  title: const Text(
                    'Reporte de Pagos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: const Text('Transacciones y análisis de ventas'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/reporte_pagos'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
