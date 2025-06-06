import '../repositories/sales_repository.dart';
import '../../data/models/boleta_request.dart';
import '../../data/models/boleta_response.dart';

class SendBoletaUseCase {
  final SalesRepository _repository;

  SendBoletaUseCase(this._repository);

  Future<BoletaResponse> call(BoletaRequest request) async {
    try {
      return await _repository.sendBoleta(request);
    } catch (e) {
      throw Exception('Error in use case while sending boleta: $e');
    }
  }
} 