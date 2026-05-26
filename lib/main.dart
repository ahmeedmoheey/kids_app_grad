import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kids_app_grad/my_application/my_application.dart';

// فئة لتخطي فحص شهادات SSL في بيئة التطوير
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تفعيل تخطي فحص الشهادات
  HttpOverrides.global = MyHttpOverrides();
  
  runApp(MyApplication());
}
