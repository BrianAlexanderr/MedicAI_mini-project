import 'package:http/http.dart' as http;
import 'dart:convert';

class DiagnosisHistoryService {
  static const String baseUrl =
      'https://django-railway-production-0985.up.railway.app/api';

  // Get all diagnosis history for the current user
  static Future<List<Map<String, dynamic>>> getDiagnosisHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/medical_history/'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required authentication headers here
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
          'Failed to load diagnosis history. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching diagnosis history: ${e.toString()}');
    }
  }

  // Get a specific diagnosis by ID
  static Future<Map<String, dynamic>> getDiagnosisById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_diagnosis_detail?id=$id'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required authentication headers here
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load diagnosis detail. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching diagnosis detail: ${e.toString()}');
    }
  }
}
