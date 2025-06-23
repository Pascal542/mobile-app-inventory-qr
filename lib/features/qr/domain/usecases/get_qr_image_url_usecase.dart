import '../../domain/repositories/qr_repository.dart';

class GetQrImageUrlUseCase {
  final QrRepository _repository;

  GetQrImageUrlUseCase(this._repository);

  Future<String?> call(String userId) async {
    return await _repository.getQrImageUrl(userId);
  }
} 