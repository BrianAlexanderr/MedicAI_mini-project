import 'package:flutter/material.dart';
import 'dart:convert';

class HospitalDetailPage extends StatelessWidget {
  final dynamic hospital;

  const HospitalDetailPage({Key? key, required this.hospital}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          hospital['name'],
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'BreeSerif',
          ),
        ),
        backgroundColor: Color.fromARGB(255, 19, 170, 92),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(hospital['photoUrl']),
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text(
              hospital['name'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B8A72),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              hospital['address'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Text(
              "Hospital Type: ${hospital['type']}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Future functionality like calling or navigation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 19, 170, 92),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text("Contact Hospital", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
