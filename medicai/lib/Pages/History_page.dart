import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicai/Pages/diagnose.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DiagnosisHistoryPage extends StatefulWidget {
  const DiagnosisHistoryPage({Key? key}) : super(key: key);

  @override
  _DiagnosisHistoryPageState createState() => _DiagnosisHistoryPageState();
}

class _DiagnosisHistoryPageState extends State<DiagnosisHistoryPage> {
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  List<DiagnosisRecord> diagnosisHistory = [];
  String? userID;

  @override
  void initState() {
    super.initState();
    userID = getCurrentUserId();
    fetchDiagnosisHistory();
  }

  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid; // Returns null if no user is logged in
  }

  Future<void> fetchDiagnosisHistory() async {
    print(userID);
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse(
          'https://django-railway-production-0985.up.railway.app/api/api/medical_history/$userID/',
        ),
        headers: {
          'Content-Type': 'application/json',
          // Add any required authentication headers here
          // 'Authorization': 'Bearer $token',
        },
      );

      // Handle 404 as empty state, not as an error
      if (response.statusCode == 404) {
        setState(() {
          diagnosisHistory = [];
          isLoading = false;
        });
        return;
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Parsed Data: $data");
        if (data.isEmpty) {
          // No history records found
          setState(() {
            diagnosisHistory = [];
            isLoading = false;
          });
          return;
        }

        // Parse the data into DiagnosisRecord objects
        final List<DiagnosisRecord> records =
            data.map((record) {
              return DiagnosisRecord.fromJson(record);
            }).toList();

        setState(() {
          diagnosisHistory = records;
          isLoading = false;
        });
      } else {
        // Handle other API errors (not 404)
        setState(() {
          hasError = true;
          errorMessage =
              'Failed to load diagnosis history. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle network or parsing error
      setState(() {
        hasError = true;
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Green gradient header
          Container(
            padding: const EdgeInsets.only(
              top: 40,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6FDAA8), Color(0xFF3CB371)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                // Back button
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3CB371),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                // Logo and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history,
                        color: Color(0xFF3CB371),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Riwayat Diagnosa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BreeSerif',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3CB371)),
      );
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Terjadi kesalahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: fetchDiagnosisHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FDAA8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (diagnosisHistory.isEmpty) {
      return _buildEmptyState();
    }

    return _buildHistoryList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada riwayat diagnosa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontFamily: 'BreeSerif',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Riwayat diagnosa Anda akan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                color: Colors.grey[600],
                fontFamily: 'BreeSerif',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to diagnosis page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DiagnosePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FDAA8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Mulai Diagnosa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'BreeSerif',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: fetchDiagnosisHistory,
      color: const Color(0xFF3CB371),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: diagnosisHistory.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final diagnosis = diagnosisHistory[index];
          return _buildHistoryCard(diagnosis);
        },
      ),
    );
  }

  Widget _buildHistoryCard(DiagnosisRecord diagnosis) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to diagnosis detail page
          Navigator.pushNamed(
            context,
            '/diagnosis_detail',
            arguments: diagnosis.userId,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7EF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xFF3CB371),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnosis.diagnosis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'dd MMMM yyyy, HH:mm',
                          ).format(diagnosis.diagnosisDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                'Gejala:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    diagnosis.symptoms.map((symptom) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          symptom,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3CB371),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(fontFamily: 'BreeSerif'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model class for diagnosis records
class DiagnosisRecord {
  final int historyId;
  final String userId;
  final String diagnosis;
  final List<String> symptoms;
  final DateTime diagnosisDate;

  DiagnosisRecord({
    required this.historyId,
    required this.userId,
    required this.diagnosis,
    required this.symptoms,
    required this.diagnosisDate,
  });

  // Factory method to create a DiagnosisRecord from JSON
  factory DiagnosisRecord.fromJson(Map<String, dynamic> json) {
    return DiagnosisRecord(
      historyId: json['history_id'],
      userId: json['user_id'].toString(),
      diagnosis: json['diagnosis'],
      symptoms: List<String>.from(json['symptoms']),
      diagnosisDate: DateTime.parse(json['created_at']),
    );
  }
}
