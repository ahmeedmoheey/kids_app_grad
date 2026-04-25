import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';
import 'package:kids_app_grad/utils/api_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleStartUp();
  }

  void _handleStartUp() async {
    // الانتظار لعرض اللوجو
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? userType = prefs.getString('user_type');

    if (token == null) {
      if (mounted) GoRouter.of(context).go(RoutesManager.kOnBoarding);
      return;
    }

    // لو طفل، يدخل يلعب علطول
    if (userType == 'child') {
      if (mounted) GoRouter.of(context).go(RoutesManager.kHomeScreen);
      return;
    }

    // لو أب، نكلم السيرفر نشوف عنده أطفال ولا لأ
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.parentMe),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool hasChildren = data['has_children'] ?? false;
        await prefs.setString('user_data', json.encode(data['user']));

        if (mounted) {
          if (hasChildren) {
            GoRouter.of(context).go(RoutesManager.kHomePageParent);
          } else {
            GoRouter.of(context).go(RoutesManager.kSignUpForChild);
          }
        }
      } else {
        if (mounted) GoRouter.of(context).go(RoutesManager.kWelcomeScreen);
      }
    } catch (e) {
      if (mounted) GoRouter.of(context).go(RoutesManager.kWelcomeScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: ColorManager.pink,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetsManager.logo,
              color: ColorManager.white,
              width: 200.w,
            ),
            SizedBox(height: 10.h),
            Text(
              "Learn. Play. Grow.",
              style: TextStyle(
                color: ColorManager.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const LinearProgressIndicator(
                  minHeight: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            const Text(
              "Loading your adventure...",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
