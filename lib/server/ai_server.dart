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
        // قراءة الرد من الحقل reply أو هيكلية الـ message حسب رد السيرفر
        if (data['reply'] != null) return data['reply'];
        if (data['message'] != null && data['message'] is Map) return data['message']['message'];
        return "Thinking...";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection error: Check your Server IP";
    }
  }
}
