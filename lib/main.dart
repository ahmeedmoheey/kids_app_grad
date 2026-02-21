import 'package:flutter/material.dart';
import 'package:kids_app_grad/my_application/my_application.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApplication());
}