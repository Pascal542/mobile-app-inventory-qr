import 'package:cloud_firestore/cloud_firestore.dart';

class SalesFirestoreService {
  static final _salesCollection = FirebaseFirestore.instance.collection('sales');

  static Future<void> saveSale(Map<String, dynamic> saleData, String fileName) async {
    await _salesCollection.doc(fileName).set(saleData);
  }

  static Stream<QuerySnapshot> getSalesStream() {
    return _salesCollection.orderBy('createdAt', descending: true).snapshots();
  }
  
  static Stream<QuerySnapshot> getSalesStreamForUser(String userId) {
    return _salesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> updateSaleStatus(String docId, String newStatus, Map<String, dynamic> sunatResponse) async {
    await _salesCollection.doc(docId).update({
      'status': newStatus,
      'sunatResponse': sunatResponse,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
} 