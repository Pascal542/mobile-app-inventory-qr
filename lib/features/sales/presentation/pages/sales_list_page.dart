import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../data/datasources/sales_api_client.dart';
import '../../data/datasources/sales_firestore_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/boleta_bloc.dart';
import '../bloc/factura_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/di/dependency_injection.dart';

class SalesListPage extends StatelessWidget {
  const SalesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthBloc>().state;

    if (authState is! Authenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ventas Realizadas')),
        body: const Center(
          child: Text('Error: Debes estar autenticado para ver las ventas.'),
        ),
      );
    }

    final userId = authState.user.uid.split('_').last;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ventas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/boletas_facturas'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: SalesFirestoreService.getSalesStreamForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final doc = docs[i].data() as Map<String, dynamic>;
              final docId = doc['documentId'] as String;
              final status = doc['status'] as String;
              final type = doc['type'] as String;
              final fileName = doc['fileName'] as String?;
              final sunatResponse = doc['sunatResponse'] as Map<String, dynamic>?;
              final apiDocumentId = sunatResponse?['documentId'] as String?;

              return ListTile(
                leading: Icon(
                  type == '01' ? Icons.request_quote : Icons.receipt_long,
                  color: _getStatusColor(status),
                ),
                title: Text(docId, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type == '01' ? 'Factura' : 'Boleta'),
                    Text('Cliente: ${doc['customerName'] ?? 'N/A'}'),
                    Text('Total: S/ ${(doc['total'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                    Text('Estado: $status'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                          label: const Text('PDF'),
                          onPressed: (apiDocumentId != null && fileName != null)
                            ? () => _downloadAndOpenPdf(context, fileName, apiDocumentId)
                            : null,
                        ),
                        const SizedBox(width: 8),
                        if (status == 'PENDIENTE' && apiDocumentId != null)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.sync, size: 16),
                            label: const Text('Verificar'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                            onPressed: () {
                              if (type == '01') {
                                context.read<FacturaBloc>().add(CheckFacturaStatusEvent(
                                  apiDocumentId: apiDocumentId,
                                  firestoreDocumentId: docId,
                                ));
                              } else {
                                context.read<BoletaBloc>().add(CheckBoletaStatusEvent(
                                  apiDocumentId: apiDocumentId,
                                  firestoreDocumentId: docId,
                                ));
                              }
                              AppSnackbar.info(context, 'Verificando estado...');
                            },
                          ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APROBADO':
        return Colors.green;
      case 'RECHAZADO':
        return Colors.red;
      case 'PENDIENTE':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _downloadAndOpenPdf(BuildContext context, String fileName, String docId) async {
    try {
      final apiClient = SalesApiClient();
      final pdfContent = await apiClient.getBoletaPdf(docId, 'A4', fileName);
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName.pdf');
      await file.writeAsBytes(pdfContent.codeUnits);
      
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          AppSnackbar.error(context, 'No se pudo abrir el PDF: ${result.message}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Error al descargar el PDF: $e');
      }
    }
  }
} 