import '../../domain/repositories/qr_repository.dart';

class DeleteQrUseCase {
  final QrRepository _repository;

  DeleteQrUseCase(this._repository);

  Future<void> call(String userId) async {
    return await _repository.deleteQr(userId);
  }
} 