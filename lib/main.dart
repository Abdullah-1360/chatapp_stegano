
import 'dart:math';

import 'package:flutter/material.dart';

import 'chatscreen.dart';
import 'create_chatscreen.dart'; // Import your service file

void main() => runApp(MaterialApp(home: Scaffold(body: MyApp())));
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(), // Your existing home screen
      routes: {
        '/create-chat': (context) => CreateChatScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stego Chat')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/create-chat'),
          child: Text('Create New Chat'),
        ),
      ),
    );
  }
}