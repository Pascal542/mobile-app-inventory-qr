import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import '../../data/models/sales_document.dart';
import '../../data/datasources/sales_api_service.dart';
import '../../data/datasources/sales_api_client.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SalesListPage extends StatefulWidget {
  const SalesListPage({super.key});

  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage> {
  late Future<List<SalesDocument>> _futureDocs;
  final _apiClient = SalesApiClient();

  @override
  void initState() {
    super.initState();
    _futureDocs = SalesApiService.fetchDocuments();
  }

  Future<void> _downloadAndOpenPdf(SalesDocument doc) async {
    try {
      final pdfContent = await _apiClient.getBoletaPdf(
        doc.documentId,
        'A4',
        doc.fileName,
      );
      
      // Create a temporary file to store the PDF
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${doc.fileName}.pdf');
      await file.writeAsBytes(pdfContent.codeUnits);
      
      // Open the PDF file using open_file
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo abrir el PDF: ${result.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar el PDF: $e')),
        );
      }
    }
  }


  // TODO FALTA IMPLEMENTAR QUE LAS DATOS LOS TRAIGA DE FIREBASE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas Realizadas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/boletas_facturas'),
        ),
      ),
      body: FutureBuilder<List<SalesDocument>>(
        future: _futureDocs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data!;
          if (docs.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final doc = docs[i];
              return ListTile(
                leading: Icon(
                  doc.type == '01' ? Icons.request_quote : Icons.receipt_long,
                  color: doc.type == '01' ? Colors.indigoAccent : Colors.indigo,
                ),
                title: Text(serieCorrelativo(doc.fileName), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.type == '01' ? 'Factura' : 'Boleta'),
                    Text('${DateTime.fromMillisecondsSinceEpoch(doc.issueTime * 1000).toLocal()}'.split(' ')[0]),
                    Text('RUC Emisor: ${rucEmisor(doc.fileName)}'),
                    Text('Estado: ${doc.status}'),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Descargar PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _downloadAndOpenPdf(doc),
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Add navigation to detail or PDF if needed
                },
              );
            },
          );
        },
      ),
    );
  }

  String serieCorrelativo(String fileName) {
    final parts = fileName.split('-');
    if (parts.length >= 4) {
      return '${parts[2]}-${parts[3]}';
    }
    return fileName;
  }

  String rucEmisor(String fileName) {
    return fileName.length >= 11 ? fileName.substring(0, 11) : '';
  }
} 