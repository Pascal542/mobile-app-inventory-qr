import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/sales_api_constants.dart';
import '../models/sales_document.dart';

// TODO FALTA IMPLEMENTAR QUE HAGA UN GETBYID PARA MANDAR LOS DATOS A FIREBASE
class SalesApiService {
  static Future<List<SalesDocument>> fetchDocuments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sales')
          .orderBy('issueTime', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SalesDocument.fromJson({
          ...data,
          'documentId': data['documentId'] ?? '', // Use the documentId from the data
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to load sales documents: $e');
    }
  }
} 