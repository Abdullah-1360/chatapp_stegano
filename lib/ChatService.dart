import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  final String baseUrl = 'https://chatapp-stegano.vercel.app';

  Future<String?> sendMessage(String chatId, String password, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/store'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chatId': chatId,
          'password': password,
          'encodedText': message,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body)['id'];
      }
    } catch (e) {
      print('Error sending message: $e');
    }
    return null;
  }
  Future<http.Response> createChat(String chatName, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chatName': chatName,
          'password': password,
        }),
      );
      return response;
    } catch (e) {
      print('Error creating chat: $e');
      throw e;
    }
  }
  Future<List<Map<String, dynamic>>?> getChatMessages(String chatId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/retrieve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chatId': chatId,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Ensure the messages are properly parsed and handle potential nulls
        return (data['messages'] as List?)?.map((item) => {
          'id': item['id']?.toString() ?? 'no-id',
          'text': item['text']?.toString() ?? 'No text',
          'time': item['timestamp']?.toString() ?? DateTime.now().toString(),
        }).toList();
      }
      return null;
    } catch (e) {
      print('Error retrieving messages: $e');
      return null;
    }
  }
}