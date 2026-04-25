import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/api_constants.dart';

class AIService {
  static Future<String> sendMessage(String userMessage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.chatbotSend),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': userMessage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? (data['message'] != null ? data['message']['message'] : "No response from AI");
      } else {
        final errorData = jsonDecode(response.body);
        return "Error: ${errorData['message'] ?? 'Failed to get response'}";
      }
    } catch (e) {
      return "Connection error: Please check your server.";
    }
  }
}
