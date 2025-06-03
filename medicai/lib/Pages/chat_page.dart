import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;
final userId = user?.uid;

class Message {
  final String text;
  final String? userid;
  final DateTime timestamp;
  final int consultationId;

  Message({
    required this.text,
    required this.userid,
    required this.timestamp,
    required this.consultationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': text,
      'sender_id': userid,
      'sent_at': timestamp.toIso8601String(),
      'consultation': consultationId,
    };
  }
}

class Consultation {
  final String? userId;
  final DateTime createdAt;
  final List<Message> messages;

  Consultation({
    required this.userId,
    required this.createdAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_id': userId,
      'sent_at': createdAt.toIso8601String(),
      'message': messages.map((m) => m.toJson()).toList(),
    };
  }
}

class ChatScreen extends StatefulWidget {
  final int consultationid;
  final int doctorid;
  final String doctorName;
  final String doctorSpecialty;

  const ChatScreen({
    Key? key,
    required this.consultationid,
    required this.doctorid,
    required this.doctorName,
    required this.doctorSpecialty,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final int consultationid = widget.consultationid;
    _loadConversation(consultationid);
    _sendMessage(consultationid);
  }

  Future<void> _loadConversation(consultationid) async {
    // Contoh endpoint ambil conversation, ganti sesuai API kamu
    final url = Uri.parse(
      'http://192.168.0.70:8000/api/consultations/$consultationid/messages/',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        List<Message> loadedMessages = [];
        for (var m in data) {
          loadedMessages.add(
            Message(
              text: m['message'],
              userid: m['sender_id'],
              timestamp: DateTime.parse(m['sent_at']),
              consultationId: consultationid,
            ),
          );
        }
        print(messages);
        setState(() {
          messages = loadedMessages;
        });
        // Scroll ke bawah setelah load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      } else {
        print('Failed to load conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading conversation: $e');
    }
  }

  Future<void> _sendMessage(int consultationid) async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final newMessage = Message(
      text: _messageController.text.trim(),
      userid: userId,
      timestamp: DateTime.now(),
      consultationId: consultationid,
    );

    setState(() {
      messages.add(newMessage);
      _messageController.clear();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Save to database
    await _saveConsultationToDatabase(newMessage);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveConsultationToDatabase(Message message) async {
    try {
      print(json.encode(message.toJson()));
      // Replace with your actual API endpoint
      final response = await http.post(
        Uri.parse('http://192.168.0.70:8000/api/messages/send/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Consultation saved successfully');
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesan berhasil dikirim'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to save consultation');
      }
    } catch (e) {
      print('Error saving consultation: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim pesan. Silakan coba lagi.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildMessage(Message message) {
    return Align(
      alignment: Alignment.centerRight, // Always user's side
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end, // Align all content to the right
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green[100], // User message color
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8, top: 4),
              child: Text(
                'You',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.green, size: 24),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.doctorSpecialty,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              // Handle video call
            },
          ),
          IconButton(
            icon: Icon(Icons.call, color: Colors.white),
            onPressed: () {
              // Handle voice call
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(messages[index]);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Handle emoji picker
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your Message',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) {
                        _sendMessage(widget.consultationid);
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.white),
                  onPressed: () {
                    // Handle file attachment
                  },
                ),
                IconButton(
                  icon: Icon(Icons.mic, color: Colors.white),
                  onPressed: () {
                    // Handle voice recording
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon:
                        isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                            )
                            : Icon(Icons.send, color: Colors.green),
                    onPressed:
                        isLoading
                            ? null
                            : () => _sendMessage(widget.consultationid),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
