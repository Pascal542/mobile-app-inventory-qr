import '../repositories/sales_repository.dart';

class GetBoletaPdfUseCase {
  final SalesRepository _repository;

  GetBoletaPdfUseCase(this._repository);

  Future<String> call(String documentId, String format, String fileName) async {
    try {
      return await _repository.getBoletaPdf(documentId, format, fileName);
    } catch (e) {
      throw Exception('Error in use case while getting boleta PDF: $e');
    }
  }
} 