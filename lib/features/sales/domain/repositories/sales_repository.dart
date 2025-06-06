import '../../data/models/boleta_request.dart';
import '../../data/models/boleta_response.dart';

abstract class SalesRepository {
  Future<BoletaResponse> sendBoleta(BoletaRequest request);
  Future<BoletaResponse> sendFactura(BoletaRequest request);
  Future<String> getLastDocumentNumber({
    required String type,
    required String series,
  });
  Future<BoletaDocumentStatus> getBoletaStatus(String documentId);
  Future<String> getBoletaPdf(String documentId, String format, String fileName);
} 