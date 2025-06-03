import 'package:flutter/material.dart';
import 'package:medicai/Pages/home_page.dart';
import 'package:medicai/Pages/chat_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;
final userId = user?.uid;

class ListContact {
  final int consultation_id;
  final int doctor_id;
  final String doctor_name;
  final String last_message;
  final String doctor_speciality;
  final String time;

  ListContact({
    required this.consultation_id,
    required this.doctor_id,
    required this.doctor_name,
    required this.last_message,
    required this.doctor_speciality,
    required this.time,
  });

  factory ListContact.fromJson(Map<String, dynamic> json) {
    return ListContact(
      consultation_id: json['consultation_id'],
      doctor_id: json['doctor_id'],
      doctor_name: json['doctor_name'],
      last_message: json['last_message'] ?? '',
      doctor_speciality: json['doctor_speciality'] ?? 'Unknown',
      time: json['last_message_time'] ?? '',
    );
  }
}

class MedicAIChatApp extends StatelessWidget {
  const MedicAIChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedicAI Chat',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      home: const ChatListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ListContact> contacts = [];
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    fetchContact(userId);
  }

  Future<void> fetchContact(String? userId) async {
    final url = Uri.parse(
      'http://192.168.0.70:8000/api/patients/$userId/chats/',
    ); // Ganti URL sesuai API kamu
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          contacts = data.map((json) => ListContact.fromJson(json)).toList();
          _isloading = false;
        });
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'MedicAI Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),
          // Doctor List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final chat = contacts[index];
                return DoctorListItem(
                  consultationid: chat.consultation_id,
                  doctorid: chat.doctor_id,
                  name: chat.doctor_name,
                  message: chat.last_message,
                  doctorSpecialty: chat.doctor_speciality,
                  time: chat.time,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorListItem extends StatelessWidget {
  final int consultationid;
  final int doctorid;
  final String doctorSpecialty;
  final String name;
  final String message;
  final String time;

  const DoctorListItem({
    super.key,
    required this.consultationid,
    required this.doctorid,
    required this.doctorSpecialty,
    required this.name,
    required this.message,
    required this.time,
  });

  String formatTime(String timeString) {
    final dt = DateTime.parse(timeString);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              consultationid: consultationid,
              doctorid: doctorid,
              doctorName: name,
              doctorSpecialty: doctorSpecialty,
              // Pass any other necessary data
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Message Time
            Text(
              formatTime(time),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
