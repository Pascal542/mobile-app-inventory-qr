import '../datasources/sales_api_client.dart';
import '../models/boleta_request.dart';
import '../models/boleta_response.dart';
import '../../domain/repositories/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesApiClient _apiClient;

  SalesRepositoryImpl({required SalesApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<BoletaResponse> sendBoleta(BoletaRequest request) async {
    try {
      return await _apiClient.sendBoleta(request);
    } catch (e) {
      throw Exception('Error in repository while sending boleta: $e');
    }
  }

  @override
  Future<String> getLastDocumentNumber({
    required String type,
    required String series,
  }) async {
    try {
      return await _apiClient.getLastDocumentNumber(
        type: type,
        series: series,
      );
    } catch (e) {
      throw Exception('Error in repository while getting last document number: $e');
    }
  }

  @override
  Future<BoletaDocumentStatus> getBoletaStatus(String documentId) async {
    try {
      return await _apiClient.getBoletaStatus(documentId);
    } catch (e) {
      throw Exception('Error in repository while getting boleta status: $e');
    }
  }

  @override
  Future<String> getBoletaPdf(String documentId, String format, String fileName) async {
    try {
      return await _apiClient.getBoletaPdf(documentId, format, fileName);
    } catch (e) {
      throw Exception('Error in repository while getting boleta PDF: $e');
    }
  }

  @override
  Future<BoletaResponse> sendFactura(BoletaRequest request) async {
    try {
      return await _apiClient.sendFactura(request);
    } catch (e) {
      throw Exception('Error in repository while sending factura: $e');
    }
  }
} 