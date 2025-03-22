import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medicai/Model/list_doctors.dart';

class DiagnosisResultPage extends StatefulWidget {
  final List<int> selectedSymptoms;
  final String disease;
  final double confidence;
  final int diseaseID;

  const DiagnosisResultPage({
    Key? key,
    required this.selectedSymptoms,
    required this.disease,
    required this.confidence,
    required this.diseaseID,
  }) : super(key: key);

  @override
  _DiagnosisResultPageState createState() => _DiagnosisResultPageState();
}

class _DiagnosisResultPageState extends State<DiagnosisResultPage> {
  List<String> selectedSymptomNames = [];
  late Future<List<Doctor>> _doctorsFuture;
  String precaution = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSymptomsFromDatabase();
    fetchDiseasePrecautions();
    _doctorsFuture = DoctorService.fetchDoctors(widget.diseaseID);
  }

  Future<void> fetchDiseasePrecautions() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://django-railway-production-0985.up.railway.app/api/get_precautions/',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'disease': widget.disease}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          precaution =
              data['precautions'] ??
              "No precaution available."; // Get precautions from API response
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchPrecautionFromDatabase() async {
    // Uncomment based on your backend
    // await fetchPrecautionFromFirestore(); // If using Firebase
    await fetchDiseasePrecautions(); // If using Django API
  }

  Future<void> fetchSymptomsFromDjangoAPI() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://django-railway-production-0985.up.railway.app/api/get_symptom_names/',
        ), // Replace with actual API
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'symptom_ids': widget.selectedSymptoms}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data =
            jsonDecode(response.body)['symptoms']; // Extract symptoms array
        setState(() {
          selectedSymptomNames =
              data.map((symptom) => symptom['name'] as String).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void fetchSymptomsFromDatabase() {
    // Uncomment based on your backend
    // fetchSymptomsFromFirestore(); // If using Firebase
    fetchSymptomsFromDjangoAPI(); // If using Django API
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
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
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
                      child: Image.asset('lib/Assets/Vector.png', height: 25),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'MedicAI Diagnose',
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
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Selected symptoms
                            const Text(
                              'Gejala yang dipilih:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...selectedSymptomNames.map(
                              (symptom) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '• ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        symptom,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Divider(height: 32, thickness: 1),

                            // Diagnosis result
                            const Text(
                              'Hasil:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    widget.disease,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const Divider(height: 32, thickness: 1),

                            // Treatment
                            const Text(
                              'Penanganan :',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              precaution,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),

                            const Divider(height: 32, thickness: 1),

                            // Doctor contacts
                            const Text(
                              'Kontak Dokter:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            FutureBuilder<List<Doctor>>(
                              future: _doctorsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  // Fallback to static doctors if API returns empty
                                  return Column(
                                    children: [
                                      _buildDoctorContact(
                                        name: 'dr. Ainstein Elbert',
                                        specialty: 'Dokter Umum',
                                      ),
                                      const Divider(height: 24),
                                      _buildDoctorContact(
                                        name: 'dr. Eliza Susanto',
                                        specialty: 'Dokter Umum',
                                      ),
                                    ],
                                  );
                                } else {
                                  // Use doctors from API
                                  return Column(
                                    children:
                                        snapshot.data!.asMap().entries.map((
                                          entry,
                                        ) {
                                          final doctor = entry.value;
                                          final isLast =
                                              entry.key ==
                                              snapshot.data!.length - 1;

                                          return Column(
                                            children: [
                                              _buildDoctorContact(
                                                name: doctor.name,
                                                specialty:
                                                    doctor.specialization,
                                              ),
                                              if (!isLast)
                                                const Divider(height: 24),
                                            ],
                                          );
                                        }).toList(),
                                  );
                                }
                              },
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
          ),

          // Back button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3CB371),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w500, 
                    fontFamily: 'BreeSerif',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorContact({
    required String name,
    required String specialty,
  }) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Icon(Icons.person, size: 30, color: Colors.black),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                specialty,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              // Chat functionality would go here
            },
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
