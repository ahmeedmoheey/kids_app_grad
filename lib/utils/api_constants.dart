import 'dart:io';

class ApiConstants {
  // الـ IP الخاص بجهاز الكمبيوتر بتاعك (IPv4 من cmd > ipconfig)
  static const String computerIp = "192.168.1.5"; 

  // اختيار الـ IP المناسب أوتوماتيكياً بناءً على الجهاز
  static String get serverIp {
    if (Platform.isAndroid) {
      // الـ Android Emulator بيستخدم الـ IP ده للوصول للجهاز المضيف
      // بنحاول نكتشف لو إحنا على إيموليتر (طريقة بسيطة)
      // ملحوظة: في بعض الحالات قد تحتاج للتأكد يدوياً، لكن 10.0.2.2 هو المعيار للإيموليتر
      return "10.0.2.2"; 
    }
    return computerIp;
  }

  // القاعدة الأساسية للـ URL
  // ملاحظة: لو شغال على تليفون حقيقي، يفضل تثبيت الـ computerIp مباشرة
  // سأقوم بضبطها لتكون مرنة:
  static String get baseUrl => "http://$computerIp:8000/api"; 
  // نصيحة: لو الإيموليتر مش شايف السيرفر بـ computerIp، غير السطر اللي فوق لـ:
  // static String get baseUrl => Platform.isAndroid ? "http://10.0.2.2:8000/api" : "http://$computerIp:8000/api";

  // Parent Auth
  static String get parentRegister => "$baseUrl/parent/register";
  static String get parentVerifyEmail => "$baseUrl/parent/verify-email";
  static String get parentResendVerification => "$baseUrl/parent/resend-verification";
  static String get parentLogin => "$baseUrl/parent/login";
  static String get parentMe => "$baseUrl/parent/me";
  static String get parentForgotPassword => "$baseUrl/parent/forgot-password";
  static String get parentVerifyResetOtp => "$baseUrl/parent/verify-reset-otp";
  static String get parentResetPassword => "$baseUrl/parent/reset-password";

  // Children Management
  static String get createChild => "$baseUrl/parent/children"; 
  static String get listChildren => "$baseUrl/parent/children"; 
  
  // Child Auth
  static String get childLogin => "$baseUrl/child/login";
  static String get childMe => "$baseUrl/child/me";

  // Games & Chat
  static String get chatbotSend => "$baseUrl/child/chatbot/send";
  static String get chatbotHistory => "$baseUrl/child/chatbot/history";

  // Sessions & Trials
  static String get sessionStart => "$baseUrl/child/sessions/start";
  static String sessionTrial(int id) => "$baseUrl/child/sessions/$id/trials";
  static String sessionEnd(int id) => "$baseUrl/child/sessions/$id/end";
}
