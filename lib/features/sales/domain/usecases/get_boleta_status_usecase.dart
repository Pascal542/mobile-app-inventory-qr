import '../repositories/sales_repository.dart';
import '../../data/models/boleta_response.dart';

class GetBoletaStatusUseCase {
  final SalesRepository _repository;

  GetBoletaStatusUseCase(this._repository);

  Future<BoletaDocumentStatus> call(String documentId) async {
    try {
      return await _repository.getBoletaStatus(documentId);
    } catch (e) {
      throw Exception('Error in use case while getting boleta status: $e');
    }
  }
} 