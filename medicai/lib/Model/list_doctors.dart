import 'dart:convert';
import 'package:http/http.dart' as http;

class Doctor {
  final int doctorId;
  final String name;
  final String specialization;
  final int hospitalID;

  Doctor({
    required this.doctorId,
    required this.name,
    required this.specialization,
    required this.hospitalID,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorId: json['doctor_id'],
      name: json['name'],
      specialization: json['specialization'],
      hospitalID: json['hospital_id'],
    );
  }
}

class DoctorService {
  static Future<List<Doctor>> fetchDoctors(int diseaseId) async {
    final url = Uri.parse(
      'https://django-railway-production-0985.up.railway.app/api/doctors/$diseaseId/',
    );

    try {
      final response = await http.get(url);
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Check if 'doctors' key exists and is not null
        if (jsonData['doctors'] == null) {
          throw Exception("API returned null for 'doctors'");
        }

        List<dynamic> doctorsJson = jsonData['doctors'];
        return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load doctors: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching doctors: $e');
    }
  }
}
