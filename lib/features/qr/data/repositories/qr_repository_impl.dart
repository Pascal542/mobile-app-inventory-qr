import 'dart:io';
import '../../domain/repositories/qr_repository.dart';
import '../datasources/qr_firestore_service.dart';

class QrRepositoryImpl implements QrRepository {
  final QrFirestoreService _firestoreService;

  QrRepositoryImpl(this._firestoreService);

  @override
  Future<String?> getQrImageUrl(String userId) async {
    final doc = await _firestoreService.getQrDataForUser(userId);
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['imageUrl'] as String?;
    }
    return null;
  }

  @override
  Future<String> uploadAndSaveQr(File image, String userId) async {
    final imageUrl = await _firestoreService.uploadQrImage(image, userId);
    await _firestoreService.saveQrData(userId, imageUrl);
    return imageUrl;
  }

  @override
  Future<void> deleteQr(String userId) async {
    await _firestoreService.deleteQrData(userId);
  }
} 