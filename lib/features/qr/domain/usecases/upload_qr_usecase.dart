import 'dart:io';
import '../../domain/repositories/qr_repository.dart';

class UploadQrUseCase {
  final QrRepository _repository;

  UploadQrUseCase(this._repository);

  Future<String> call(File image, String userId) async {
    return await _repository.uploadAndSaveQr(image, userId);
  }
} 