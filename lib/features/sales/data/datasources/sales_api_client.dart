import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/boleta_request.dart';
import '../models/boleta_response.dart';
import '../../core/constants/sales_api_constants.dart';

class SalesApiClient {
  final http.Client _client;
  final String _baseUrl;

  SalesApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://back.apisunat.com';

  Future<BoletaResponse> sendBoleta(BoletaRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/personas/v1/sendBill'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return BoletaResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to send boleta: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending boleta: $e');
    }
  }

  Future<BoletaDocumentStatus> getBoletaStatus(String documentId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/documents/$documentId/getById'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return BoletaDocumentStatus.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get boleta status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting boleta status: $e');
    }
  }

  Future<String> getLastDocumentNumber({
    required String type,
    required String series,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/personas/lastDocument'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personaId': ApiConstants.personaId,
          'personaToken': ApiConstants.personaToken,
          'type': type,
          'serie': series,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['suggestedNumber'] as String;
      } else {
        throw Exception('Failed to get last document number: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting last document number: $e');
    }
  }

  Future<String> getBoletaPdf(String documentId, String format, String fileName) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/documents/$documentId/getPDF/$format/$fileName.pdf'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to get boleta PDF: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting boleta PDF: $e');
    }
  }

  Future<BoletaResponse> sendFactura(BoletaRequest request) async {
    final facturaRequest = BoletaRequest(
      personaId: request.personaId,
      personaToken: request.personaToken,
      fileName: request.fileName,
      documentBody: BoletaDocumentBody(
        ublVersionId: request.documentBody.ublVersionId,
        customizationId: request.documentBody.customizationId,
        id: request.documentBody.id,
        issueDate: request.documentBody.issueDate,
        issueTime: request.documentBody.issueTime,
        invoiceTypeCode: '01',
        notes: request.documentBody.notes,
        documentCurrencyCode: request.documentBody.documentCurrencyCode,
        accountingSupplierParty: request.documentBody.accountingSupplierParty,
        accountingCustomerParty: request.documentBody.accountingCustomerParty,
        taxTotal: request.documentBody.taxTotal,
        legalMonetaryTotal: request.documentBody.legalMonetaryTotal,
        invoiceLines: request.documentBody.invoiceLines,
      ),
    );
    return sendBoleta(facturaRequest);
  }
} 