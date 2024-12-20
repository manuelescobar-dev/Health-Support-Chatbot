import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription<User?> _userSubscription;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    // Detect when a user signs in or out
    _userSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
        });

        if (user == null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (_) => false,
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Health Support Chatbot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'My Appointments',
            onPressed: () {
              Navigator.of(context).pushNamed('/appointments');
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: ChatbotWidget(),
    );
  }
}

class ChatbotWidget extends StatefulWidget {
  @override
  _ChatbotWidgetState createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _messageController = TextEditingController();
  Map<String, String> _userMessage = {};
  Map<String, String> _botMessage = {};
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userMessage = _messageController.text;

      setState(() {
        _userMessage = {
          "role": "user",
          "content": userMessage,
        };
        _botMessage = {}; // Clear bot message
        _isLoading = true;
      });

      _messageController.clear();

      try {
        final uri = Uri.parse('https://get-response-x3c5bq4a3q-uc.a.run.app')
            .replace(queryParameters: {
          'userId': userId,
          'message': userMessage,
        });

        final response = await http.get(uri);
        if (response.statusCode == 200) {
          setState(() {
            _botMessage = {
              "role": "bot",
              "content": response.body ?? "", // Adjust key if needed
            };
          });
        } else {
          setState(() {
            _botMessage = {
              "role": "bot",
              "content": "Failed to get a response from the server.",
            };
          });
        }
      } catch (e) {
        setState(() {
          _botMessage = {
            "role": "bot",
            "content": "An error occurred: $e",
          };
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_userMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _userMessage["content"] ?? "",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          )
        else
          Container(),
        if (_isLoading)
          Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_botMessage.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MarkdownBody(
                    data: _botMessage["content"] ?? "",
                  ),
                ),
              ),
            ),
          )
        else
          Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
