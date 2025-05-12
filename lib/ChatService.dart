import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  final String baseUrl = 'http://your-backend-url:3000';

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
        return List<Map<String, dynamic>>.from(jsonDecode(response.body)['messages']);
      }
    } catch (e) {
      print('Error retrieving messages: $e');
    }
    return null;
  }
}