import '../repositories/sales_repository.dart';

class GetLastDocumentNumberUseCase {
  final SalesRepository _repository;

  GetLastDocumentNumberUseCase(this._repository);

  Future<String> call({
    required String type,
    required String series,
  }) async {
    try {
      return await _repository.getLastDocumentNumber(
        type: type,
        series: series,
      );
    } catch (e) {
      throw Exception('Error in use case while getting last document number: $e');
    }
  }
} 