import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicai/Pages/results.dart';

class DiagnosePage extends StatefulWidget {
  @override
  _DiagnosePageState createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage> {
  late Future<List<Map<String, dynamic>>> symptoms;
  Map<int, bool> selectedSymptoms = {}; // Store selected symptoms
  Map<int, String> selectedNames = {};
  List<String> selectedSymptomName = [];
  String searchQuery = '';
  String diseases = '';
  List<Map<String, dynamic>> allSymptoms = [];
  List<Map<String, dynamic>> filteredSymptoms = [];
  bool isLoading = false;
  String precaution = '';

  // Track which body parts are expanded
  Map<String, bool> expandedCategories = {};

  // Group symptoms by body part (this will be populated from the data)
  Map<String, List<Map<String, dynamic>>> symptomsByCategory = {};

  @override
  void initState() {
    super.initState();
    symptoms = fetchSymptoms();
  }

  Future<List<Map<String, dynamic>>> fetchSymptoms() async {
    final response = await http.get(
      Uri.parse(
        'https://django-railway-production-0985.up.railway.app/api/symptoms/',
      ),
    );

    if (response.statusCode == 200) {
      allSymptoms = List<Map<String, dynamic>>.from(json.decode(response.body));
      filteredSymptoms = List.from(allSymptoms);

      // Group symptoms by category (assuming there's a 'category' field)
      // If your API doesn't provide categories, you might need to add them or use another grouping method
      for (var symptom in allSymptoms) {
        String category = symptom['category'] ?? 'General';
        if (!symptomsByCategory.containsKey(category)) {
          symptomsByCategory[category] = [];
          expandedCategories[category] = false; // Initialize as collapsed
        }
        symptomsByCategory[category]!.add(symptom);
      }

      // If no categories exist in the data, create a default grouping
      if (symptomsByCategory.isEmpty) {
        _createDefaultCategories();
      }

      return allSymptoms;
    } else {
      throw Exception('Failed to load symptoms');
    }
  }

  // Create default categories if none exist in the data
  void _createDefaultCategories() {
    // Group alphabetically
    Map<String, List<Map<String, dynamic>>> alphabeticalGroups = {};

    for (var symptom in allSymptoms) {
      String firstLetter =
          (symptom['name'] as String).substring(0, 1).toUpperCase();
      if (!alphabeticalGroups.containsKey(firstLetter)) {
        alphabeticalGroups[firstLetter] = [];
        expandedCategories[firstLetter] = false;
      }
      alphabeticalGroups[firstLetter]!.add(symptom);
    }

    symptomsByCategory = alphabeticalGroups;
  }

  void filterSymptoms(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredSymptoms = List.from(allSymptoms);
      } else {
        filteredSymptoms =
            allSymptoms
                .where(
                  (symptom) => symptom['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid; // Returns null if no user is logged in
  }

  Future<void> fetchDiseasePrecautions(String disease) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://django-railway-production-0985.up.railway.app/api/get_precautions/',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'disease': disease}),
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

  Future<void> fetchSymptomsFromDjangoAPI(List<int> symptomIds) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://django-railway-production-0985.up.railway.app/api/get_symptom_names/',
        ), // Replace with actual API
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'symptom_ids': symptomIds}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data =
            jsonDecode(response.body)['symptoms']; // Extract symptoms array
        setState(() {
          selectedSymptomName =
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

  Future<void> saveDiagnosisHistory(
    int diseaseID,
    String disease,
    List<int> symptomIds,
  ) async {
    await fetchDiseasePrecautions(disease);
    await fetchSymptomsFromDjangoAPI(symptomIds);
    try {
      final response = await http.post(
        Uri.parse(
          "https://django-railway-production-0985.up.railway.app/api/save_diagnosis/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': getCurrentUserId(), // Ensure user_id is passed
          'diagnosis': disease,
          'doctor_notes': precaution,
          'symptoms': selectedSymptomName,
        }),
      );

      if (response.statusCode == 201) {
        print("Diagnosis history saved successfully.");
      } else {
        print("Failed to save history: ${response.body}");
      }
    } catch (e) {
      print("Error saving history: $e");
    }
  }

  void sendSelectedSymptoms() async {
    List<int> selected =
        selectedSymptoms.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key)
            .toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one symptom.")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          'https://django-railway-production-0985.up.railway.app/api/predict_disease/',
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"symptoms": selected}),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        int diseaseID = result['disease_id'];
        String disease = result['disease'];
        double confidence = (result["confidence_score"] ?? 0) * 100;

        // Save diagnose history
        await saveDiagnosisHistory(diseaseID, disease, selected);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DiagnosisResultPage(
                  diseaseID: diseaseID,
                  disease: disease,
                  confidence: confidence,
                  selectedSymptoms: selected,
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      print("❌ Exception: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Request failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom app bar with gradient
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6FDAA8), Color(0xFF3CB371)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      SizedBox(width: 16),
                      // Logo and title
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('lib/Assets/Vector.png', height: 25),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "MedicAI Diagnose",
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
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pilih Gejala",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'BreeSerif',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search symptoms...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF4CAF50)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF4CAF50)),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: filterSymptoms,
            ),
          ),

          // Selected symptoms chips
          if (selectedSymptoms.values.any((selected) => selected))
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3CB371),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          allSymptoms
                              .where(
                                (s) =>
                                    selectedSymptoms[s['symptom_id']] == true,
                              )
                              .map(
                                (symptom) => Padding(
                                  padding: const EdgeInsets.only(
                                    right: 8.0,
                                    top: 4.0,
                                  ),
                                  child: Chip(
                                    label: Text(
                                      symptom['name'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Color(0xFF4CAF50),
                                    deleteIconColor: Colors.white,
                                    onDeleted: () {
                                      setState(() {
                                        selectedSymptoms[symptom['symptom_id']] =
                                            false;
                                      });
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),

          // Main symptom list
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: symptoms,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No symptoms found'));
                } else {
                  return searchQuery.isNotEmpty
                      // Show flat list when searching
                      ? ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredSymptoms.length,
                        separatorBuilder:
                            (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final symptom = filteredSymptoms[index];
                          return Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: Colors.grey[300],
                              checkboxTheme: CheckboxThemeData(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                fillColor: WidgetStateProperty.resolveWith<
                                  Color
                                >((Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Color(0xFF4CAF50);
                                  }
                                  return Colors.white;
                                }),
                              ),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                symptom['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value:
                                  selectedSymptoms[symptom['symptom_id']] ??
                                  false,
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedSymptoms[symptom['symptom_id']] =
                                      value ?? false;
                                });
                              },
                              activeColor: Color(0xFF4CAF50),
                              checkColor: Colors.white,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                            ),
                          );
                        },
                      )
                      // Show categorized list when not searching
                      : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: symptomsByCategory.length,
                        itemBuilder: (context, index) {
                          String category = symptomsByCategory.keys.elementAt(
                            index,
                          );
                          List<Map<String, dynamic>> categorySymptoms =
                              symptomsByCategory[category]!;

                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                initiallyExpanded:
                                    expandedCategories[category] ?? false,
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    expandedCategories[category] = expanded;
                                  });
                                },
                                collapsedBackgroundColor: Colors.grey[50],
                                backgroundColor: Colors.white,
                                title: Row(
                                  children: [
                                    Text(
                                      category,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '(${categorySymptoms.length})',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                children: [
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: categorySymptoms.length,
                                    separatorBuilder:
                                        (context, index) => Divider(height: 1),
                                    itemBuilder: (context, i) {
                                      final symptom = categorySymptoms[i];
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          unselectedWidgetColor:
                                              Colors.grey[300],
                                          checkboxTheme: CheckboxThemeData(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            fillColor:
                                                WidgetStateProperty.resolveWith<
                                                  Color
                                                >((Set<WidgetState> states) {
                                                  if (states.contains(
                                                    WidgetState.selected,
                                                  )) {
                                                    return Color(0xFF4CAF50);
                                                  }
                                                  return Colors.white;
                                                }),
                                          ),
                                        ),
                                        child: CheckboxListTile(
                                          title: Text(
                                            symptom['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          value:
                                              selectedSymptoms[symptom['symptom_id']] ??
                                              false,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              selectedSymptoms[symptom['symptom_id']] =
                                                  value ?? false;
                                            });
                                          },
                                          activeColor: Color(0xFF4CAF50),
                                          checkColor: Colors.white,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 8,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                }
              },
            ),
          ),

          // Diagnose button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: sendSelectedSymptoms,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3CB371),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                "Diagnosa",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
