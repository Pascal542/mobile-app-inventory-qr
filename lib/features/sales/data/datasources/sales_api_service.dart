import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/sales_api_constants.dart';
import '../models/sales_document.dart';

class SalesApiService {
  static Future<List<SalesDocument>> fetchDocuments() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/documents/getAll?personaId=${ApiConstants.personaId}&personaToken=${ApiConstants.personaToken}&order=DESC&limit=50',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SalesDocument.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load sales documents');
    }
  }
} 