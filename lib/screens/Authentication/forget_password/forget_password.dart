import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';
import 'package:kids_app_grad/utils/api_constants.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  void sendResetCode() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      print("Calling API: ${ApiConstants.parentForgotPassword}");
      final response = await http.post(
        Uri.parse(ApiConstants.parentForgotPassword),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': emailController.text.trim()}),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "OTP sent successfully")),
        );
        // التوجيه لشاشة التأكد من الكود
        GoRouter.of(context).push(RoutesManager.kForgetPassVarification, extra: emailController.text.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Error occurred")),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.offWhite,
      appBar: AppBar(
        backgroundColor: ColorManager.offWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => GoRouter.of(context).push(RoutesManager.kLoginForParent),
          icon: Icon(Icons.arrow_back_ios_new, color: ColorManager.pinkk, size: 22),
        ),
        centerTitle: true,
        title: Text(
          "Recovery",
          style: TextStyle(color: ColorManager.black, fontSize: 20.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80.h),
              Text(
                "Forget Your Password",
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorManager.black, fontWeight: FontWeight.w800, fontSize: 24.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                "No worries! Enter your registered email below and we’ll send you a recovery code",
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorManager.brown.withOpacity(.6), fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 50.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Parent's Email Address", style: TextStyle(color: ColorManager.black, fontSize: 14.sp, fontWeight: FontWeight.w700)),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "hello@example.com",
                  prefixIcon: Icon(Icons.email_outlined, color: ColorManager.pinkk),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.pinkk,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  ),
                  onPressed: isLoading ? null : sendResetCode,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Send Reset Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
