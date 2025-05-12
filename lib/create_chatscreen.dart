import 'dart:convert';

import 'package:flutter/material.dart';

import 'ChatService.dart';
import 'chatscreen.dart';

class CreateChatScreen extends StatefulWidget {
  @override
  _CreateChatScreenState createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final _chatNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ChatService _chatService = ChatService();

  Future<void> _createChat(BuildContext context) async { // Add context parameter
    if (_chatNameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields required')),
      );
      return;
    }

    try {
      final response = await _chatService.createChat(
        _chatNameController.text,
        _passwordController.text,
      );

      if (response.statusCode == 201) {
        final chatId = jsonDecode(response.body)['chatId'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              password: _passwordController.text,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create chat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _chatNameController,
              decoration: InputDecoration(labelText: 'Chat Name'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () => _createChat(context), // Pass context here
              child: Text('Create Chat'),
            ),
          ],
        ),
      ),
    );
  }
}