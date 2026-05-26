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
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['reply'] != null) {
          return data['reply'].toString();
        }
        
        if (data['message'] != null) {
          if (data['message'] is Map && data['message']['message'] != null) {
            return data['message']['message'].toString();
          }
          return data['message'].toString();
        }
        
        return "Thinking...";
      } else {
        return "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection error: Please check your Server IP or Internet.";
    }
  }
}
