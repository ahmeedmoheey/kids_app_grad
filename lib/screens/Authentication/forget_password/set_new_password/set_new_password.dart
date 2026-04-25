import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';
import 'package:kids_app_grad/utils/api_constants.dart';

class SetNewPassword extends StatefulWidget {
  final String resetToken;
  const SetNewPassword({super.key, required this.resetToken});

  @override
  State<SetNewPassword> createState() => _SetNewPasswordState();
}

class _SetNewPasswordState extends State<SetNewPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool obscure1 = true;
  bool obscure2 = true;
  bool isLoading = false;

  void resetPassword() async {
    if (passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password must be 8+ characters")));
      return;
    }
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/parent/reset-password"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.resetToken}',
        },
        body: {
          'password': passwordController.text.trim(),
          'password_confirmation': confirmController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset successful!")));
        GoRouter.of(context).push(RoutesManager.kLoginForParent);
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? "Error resetting password")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connection error")));
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
        leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back_ios_new, color: ColorManager.pinkk)),
        centerTitle: true,
        title: Text("Recovery", style: TextStyle(color: ColorManager.black, fontWeight: FontWeight.w700, fontSize: 20.sp)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Center(child: Text("Create New Password", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: ColorManager.black))),
              SizedBox(height: 15.h),
              Center(child: Text("Enter a new password to keep your journey safe.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: ColorManager.brown.withOpacity(.6)))),
              SizedBox(height: 40.h),
              Text("New Password", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp)),
              SizedBox(height: 10.h),
              TextFormField(
                controller: passwordController,
                obscureText: obscure1,
                decoration: InputDecoration(
                  hintText: "Min. 8 characters",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(icon: Icon(obscure1 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscure1 = !obscure1)),
                  filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 25.h),
              Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp)),
              SizedBox(height: 10.h),
              TextFormField(
                controller: confirmController,
                obscureText: obscure2,
                decoration: InputDecoration(
                  hintText: "Repeat password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscure2 = !obscure2)),
                  filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity, height: 55.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: ColorManager.pinkk, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r))),
                  onPressed: isLoading ? null : resetPassword,
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Reset Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
