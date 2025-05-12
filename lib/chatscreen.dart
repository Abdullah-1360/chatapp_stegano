import 'package:flutter/material.dart';

import 'ChatService.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String password;

  const ChatScreen({required this.chatId, required this.password, Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.getChatMessages(widget.chatId, widget.password);
      if (messages != null) {
        setState(() {
          _messages = messages;
        });
      } else {
        setState(() {
          _messages = []; // Or handle empty case appropriately
        });
      }
    } catch (e) {
      // Handle any exceptions that might occur during API call
      setState(() {
        _messages = []; // Or show error message
      });
      print('Error loading messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.chatId, widget.password, _messageController.text);
      _messageController.clear();
      await _loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat ${widget.chatId.substring(0, 6)}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message['text']),
                  subtitle: Text(DateTime.parse(message['time']).toString()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Type a message'),
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
      ),
    );
  }
}