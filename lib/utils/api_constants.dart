class ApiConstants {
  static const String computerIp = "10.0.2.2"; 

  // القاعدة الأساسية للـ URL
  static String get baseUrl => "http://$computerIp:8000/api"; 

  static String _buildUrl(String path) {
    String base = baseUrl;
    
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    String finalPath = path.startsWith('/') ? path : '/$path';

    if (base.endsWith('/api')) {
      if (finalPath.startsWith('/api/')) {
        finalPath = finalPath.substring(4); 
      }
    } else {
      if (!finalPath.startsWith('/api/')) {
        finalPath = '/api$finalPath';
      }
    }

    String finalUrl = base + finalPath;
    print("Final Requested URL: $finalUrl");
    return finalUrl;
  }

  // Parent Authentication
  static String get parentLogin => _buildUrl("/parent/login");
  static String get parentRegister => _buildUrl("/parent/register");
  
  // أضفت /parent/ هنا عشان يطابق الـ Laravel Route
  static String get parentForgotPassword => _buildUrl("/parent/forgot-password");
  static String get parentVerifyResetOtp => _buildUrl("/parent/verify-reset-otp");
  static String get parentResetPassword => _buildUrl("/parent/reset-password");
  
  static String get parentResendVerification => _buildUrl("/parent/resend-verification");
  static String get parentVerifyEmail => _buildUrl("/parent/verify-email");
  
  static String get parentMe => _buildUrl("/parent/me");
  static String get parentLogout => _buildUrl("/parent/logout");

  // Children Management
  static String get createChild => _buildUrl("/parent/children"); 
  static String get listChildren => _buildUrl("/parent/children"); 
  static String parentChildDetails(int id) => _buildUrl("/parent/children/$id");
  
  // Child Authentication
  static String get childLogin => _buildUrl("/child/login");
  static String get childMe => _buildUrl("/child/me");
  static String get childLogout => _buildUrl("/child/logout");

  // Chatbot
  static String get chatbotSend => _buildUrl("/child/chatbot/send");
  static String get chatbotHistory => _buildUrl("/child/chatbot/history");
  static String get parentChatbotSend => _buildUrl("/parent/chatbot/send");
  static String get parentChatbotHistory => _buildUrl("/parent/chatbot/history");

  // Game Sessions
  static String get sessionStart => _buildUrl("/child/sessions/start");
  static String sessionTrial(int id) => _buildUrl("/child/sessions/$id/trials");
  static String sessionEnd(int id) => _buildUrl("/child/sessions/$id/end");
  
  // Dashboard & Analysis
  static String childDashboard(int id) => _buildUrl("/parent/children/$id/dashboard");
  static String childSessions(int id) => _buildUrl("/parent/children/$id/sessions");
  static String childPredictions(int id) => _buildUrl("/parent/children/$id/predictions");
}
