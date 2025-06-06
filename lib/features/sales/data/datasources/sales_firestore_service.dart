import 'package:cloud_firestore/cloud_firestore.dart';

class SalesFirestoreService {
  static Future<void> saveSale(Map<String, dynamic> saleData, String fileName) async {
    await FirebaseFirestore.instance
        .collection('sales')
        .doc(fileName)
        .set(saleData);
  }
} 