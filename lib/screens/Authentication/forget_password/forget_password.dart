import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reset email sent! Check your inbox.")),
      );
      GoRouter.of(context).push(RoutesManager.kForgetPassVarification);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
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
          onPressed: () {
            GoRouter.of(context).push(RoutesManager.kLoginForParent);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: ColorManager.orange,
            size: 22,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Recovery",
          style: TextStyle(
            color: ColorManager.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
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
                style: TextStyle(
                  color: ColorManager.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 24.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "No worries! It happens to the best of us. Enter\n"
                    "your registered email below and we’ll send\n"
                    "you a recovery code",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorManager.brown.withOpacity(.6),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 50.h),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Parent's Email Address",
                  style: TextStyle(
                    color: ColorManager.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "hello@example.com",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: ColorManager.orange,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.r),
                    borderSide: BorderSide(
                      color: ColorManager.orange.withOpacity(.3),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.r),
                    borderSide: BorderSide(
                      color: ColorManager.orange,
                      width: 2,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 4,
                  ),
                  onPressed: isLoading ? null : sendResetCode,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Send Reset Code",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}