import '../../data/models/boleta_request.dart';
import '../../data/models/boleta_response.dart';
import '../repositories/sales_repository.dart';

class SendFacturaUseCase {
  final SalesRepository repository;
  SendFacturaUseCase(this.repository);

  Future<BoletaResponse> call(BoletaRequest request) async {
    try {
      return await repository.sendFactura(request);
    } catch (e) {
      throw Exception('Error in use case while sending factura: $e');
    }
  }
} 