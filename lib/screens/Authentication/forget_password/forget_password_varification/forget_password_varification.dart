import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';
import 'package:kids_app_grad/utils/api_constants.dart';

class ForgetPasswordVarification extends StatefulWidget {
  final String email;
  const ForgetPasswordVarification({super.key, required this.email});

  @override
  State<ForgetPasswordVarification> createState() => _ForgetPasswordVarificationState();
}

class _ForgetPasswordVarificationState extends State<ForgetPasswordVarification> {
  final List<TextEditingController> controllers = List.generate(6, (_) => TextEditingController());
  bool isLoading = false;
  bool isResending = false;

  void verifyOtp() async {
    String otp = controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    setState(() => isLoading = true);

    try {
      // محاولة تفعيل الحساب
      final response = await http.post(
        Uri.parse(ApiConstants.parentVerifyEmail),
        headers: {'Accept': 'application/json'},
        body: {'email': widget.email, 'otp': otp},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        
        // حفظ التوكن وبيانات المستخدم عشان الـ SplashScreen تعرفه
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }
        if (data['user'] != null) {
          await prefs.setString('user_data', json.encode(data['user']));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account verified successfully!")));
          // يروح يضيف طفل فوراً
          GoRouter.of(context).go(RoutesManager.kSignUpForChild);
        }
      } else {
        // لو مش تفعيل، جرب يكون Reset Password
        final resetResponse = await http.post(
          Uri.parse(ApiConstants.parentVerifyResetOtp),
          headers: {'Accept': 'application/json'},
          body: {'email': widget.email, 'otp': otp},
        );

        final resetData = json.decode(resetResponse.body);
        if (resetResponse.statusCode == 200) {
          if (mounted) GoRouter.of(context).push(RoutesManager.kSetNewPass, extra: resetData['reset_token']);
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? resetData['message'] ?? "Invalid Code")));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connection error")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void resendOtp() async {
    setState(() => isResending = true);
    try {
      await http.post(
        Uri.parse(ApiConstants.parentResendVerification),
        headers: {'Accept': 'application/json'},
        body: {'email': widget.email},
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP resent!")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error resending code")));
    } finally {
      if (mounted) setState(() => isResending = false);
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
        title: Text("Verification", style: TextStyle(color: ColorManager.black, fontWeight: FontWeight.w700, fontSize: 20.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 60.h),
            Text("Verify Your Account", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: ColorManager.black)),
            SizedBox(height: 15.h),
            Text("Enter the 6-digit code sent to\n${widget.email}", textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: ColorManager.brown.withOpacity(.6))),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) => SizedBox(
                width: 45.w,
                height: 50.h,
                child: TextFormField(
                  controller: controllers[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
                  },
                  decoration: InputDecoration(counterText: "", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none)),
                ),
              )),
            ),
            SizedBox(height: 30.h),
            TextButton(
              onPressed: isResending ? null : resendOtp,
              child: Text(isResending ? "Sending..." : "Didn't receive code? Resend", style: TextStyle(color: ColorManager.pinkk, fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: ColorManager.pinkk, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r))),
                onPressed: isLoading ? null : verifyOtp,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Verify", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
