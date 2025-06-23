import 'dart:io';

abstract class QrRepository {
  Future<String?> getQrImageUrl(String userId);
  Future<String> uploadAndSaveQr(File image, String userId);
  Future<void> deleteQr(String userId);
} 