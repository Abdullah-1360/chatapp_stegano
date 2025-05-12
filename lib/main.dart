
import 'dart:math';

import 'package:flutter/material.dart';

import 'chatscreen.dart'; // Import your service file

void main() => runApp(MaterialApp(home: Scaffold(body: CreateChatScreen())));
class CreateChatScreen extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _chatNameController = TextEditingController();

  CreateChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _chatNameController,
              decoration: const InputDecoration(labelText: 'Chat Name'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () {
                String chatId = generateRandomId(); // Implement this function
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatId: chatId,
                      password: _passwordController.text,
                    ),
                  ),
                );
              },
              child: const Text('Create Chat'),
            ),
          ],
        ),
      ),
    );
  }

  String generateRandomId() {
    // Implement a secure random ID generator (e.g., UUID)
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000000).toString();
  }
}