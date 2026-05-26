import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Base URL Configuration
  /// إذا كنت تستخدم ngrok، ضعه هنا. إذا كنت تريد استخدام الـ IPs المحلية مباشرة، اتركه فارغاً.
  static const String _ngrokUrl = "https://latitude-battering-scoring.ngrok-free.dev"; 
  
  static String get baseUrl {
    // 1. للـ Web
    if (kIsWeb) return "http://localhost:8000/api";
    
    // 2. الأولوية للـ ngrok إذا كان موجوداً (للموبايل الحقيقي أو الوصول الخارجي)
    if (_ngrokUrl.isNotEmpty && _ngrokUrl.contains("ngrok")) {
      String cleanUrl = _ngrokUrl.endsWith('/') 
          ? _ngrokUrl.substring(0, _ngrokUrl.length - 1) 
          : _ngrokUrl;
      return "$cleanUrl/api";
    }

    // 3. التبديل التلقائي حسب نوع الجهاز (للمحاكيات)
    try {
      if (Platform.isAndroid) {
        return "http://10.0.2.2:8000/api"; // Android Emulator
      } else if (Platform.isIOS) {
        return "http://127.0.0.1:8000/api"; // iOS Simulator
      }
    } catch (e) {
      // fallback في حالة حدوث خطأ في التعرف على المنصة
    }

    // Fallback للـ Localhost
    return "http://127.0.0.1:8000/api"; 
  }

  static String _buildUrl(String path) {
    String base = baseUrl;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    String finalPath = path.startsWith('/') ? path : '/$path';
    
    // منع تكرار /api/ في المسار
    if (finalPath.startsWith('/api/')) {
      finalPath = finalPath.substring(4);
    }
    
    return base + finalPath;
  }

  // Auth & Child Management
  static String get childLogin => _buildUrl("/child/login");
  static String get childLogout => _buildUrl("/child/logout");
  static String get parentLogin => _buildUrl("/parent/login");
  static String get parentRegister => _buildUrl("/parent/register");
  static String get parentMe => _buildUrl("/parent/me");
  static String get parentLogout => _buildUrl("/parent/logout");
  static String get parentForgotPassword => _buildUrl("/parent/forgot-password"); 
  static String get parentVerifyEmail => _buildUrl("/parent/verify-email");
  static String get parentVerifyResetOtp => _buildUrl("/parent/verify-reset-otp");
  static String get parentResendVerification => _buildUrl("/parent/resend-verification");
  
  // Games & Sessions
  static String get listGames => _buildUrl("/child/games");
  static String getGame(int id) => _buildUrl("/child/games/$id");
  static String get sessionStart => _buildUrl("/child/sessions/start");
  static String sessionTrial(int id) => _buildUrl("/child/sessions/$id/trials");
  static String sessionEnd(int id) => _buildUrl("/child/sessions/$id/end");

  // Dashboard & Predictions
  static String get listChildren => _buildUrl("/parent/children");
  static String get createChild => _buildUrl("/parent/children");
  static String childDashboard(int id) => _buildUrl("/parent/children/$id/dashboard");
  static String childPredictions(int id) => _buildUrl("/parent/children/$id/predictions");
  static String childSessions(int id) => _buildUrl("/parent/children/$id/sessions");

  // Chatbot
  static String get chatbotSend => _buildUrl("/child/chatbot/send");
  static String get chatbotHistory => _buildUrl("/child/chatbot/history");
  static String get parentChatbotSend => _buildUrl("/parent/chatbot/send");
  static String get parentChatbotHistory => _buildUrl("/parent/chatbot/history");
  
  static String get health => _buildUrl("/health");
}
