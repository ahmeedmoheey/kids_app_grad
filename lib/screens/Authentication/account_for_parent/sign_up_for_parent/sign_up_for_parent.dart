import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';
import 'package:kids_app_grad/utils/api_constants.dart';

class SignUpForParent extends StatefulWidget {
  const SignUpForParent({super.key});

  @override
  State<SignUpForParent> createState() => _SignUpForParentState();
}

class _SignUpForParentState extends State<SignUpForParent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void signUpParent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.parentRegister),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'password': passwordController.text.trim(),
          'password_confirmation': passwordController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please check the code.')),
          );
          GoRouter.of(context).push(RoutesManager.kForgetPassVarification, extra: emailController.text.trim());
        }
      } else {
        if (mounted) {
          String errorMsg = data['message'] ?? 'Registration failed';
          if (data['errors'] != null) {
            errorMsg = data['errors'].values.first[0];
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection error')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text("Parent Sign Up", style: TextStyle(color: ColorManager.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
      ),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(AssetsManager.backGround), fit: BoxFit.cover)),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Image.asset(AssetsManager.family, height: 200.h, width: double.infinity),
                SizedBox(height: 25.h),
                Text("Join the Adventure", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text("Create an account to start your child’s journey.", style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                SizedBox(height: 25.h),
                buildLabel("Full Name"),
                buildTextField(fullNameController, "Enter your full name", Icons.person_outline, false),
                SizedBox(height: 15.h),
                buildLabel("Email Address"),
                buildTextField(emailController, "parent@example.com", Icons.email_outlined, false, isEmail: true),
                SizedBox(height: 15.h),
                buildLabel("Phone Number"),
                buildTextField(phoneController, "+201...", Icons.phone_android_outlined, false),
                SizedBox(height: 15.h),
                buildLabel("Password"),
                buildTextField(passwordController, "Create a strong password", Icons.lock_outline, true),
                SizedBox(height: 30.h),
                SizedBox(
                  width: double.infinity, height: 55.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: ColorManager.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r))),
                    onPressed: isLoading ? null : signUpParent,
                    child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text("Create Account", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: ColorManager.white)),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => GoRouter.of(context).push(RoutesManager.kLoginForParent),
                      child: Text("Login", style: TextStyle(color: ColorManager.pinkk, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 8.h), child: Text(text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)));

  Widget buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint, prefixIcon: Icon(icon, color: Colors.grey),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
      ),
    );
  }
}
