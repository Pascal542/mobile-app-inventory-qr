import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class QrFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://vendify-qr');

  Future<String> uploadQrImage(File image, String userId) async {
    final fileName = 'qr_$userId.png';
    final storageRef = _storage.ref().child('qrs/$fileName');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> saveQrData(String userId, String imageUrl) async {
    await _firestore.collection('qrs').doc(userId).set({
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getQrDataForUser(String userId) async {
    return await _firestore.collection('qrs').doc(userId).get();
  }

  Future<void> deleteQrData(String userId) async {
    final fileName = 'qr_$userId.png';
    final storageRef = _storage.ref().child('qrs/$fileName');

    // Delete from Firestore
    await _firestore.collection('qrs').doc(userId).delete();
    
    // Delete from Storage
    try {
      await storageRef.delete();
    } catch (e) {
      // It's okay if the file doesn't exist, we just want to ensure it's gone.
      print("Error deleting QR from storage (may not exist): $e");
    }
  }
} 