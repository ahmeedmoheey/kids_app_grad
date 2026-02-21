import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailOrNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  bool passwordVisible = false; // ← للتحكم في عرض الباسورد

  void loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String input = emailOrNameController.text.trim();
    String password = passwordController.text.trim();

    try {
      if (input.contains('@')) {
        // الأب
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: input,
          password: password,
        );

        String uid = userCredential.user!.uid;
        DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
        String userType = doc.exists ? (doc['type'] ?? 'parent') : 'parent';

        if (userType == 'parent') {
          GoRouter.of(context).push(RoutesManager.kDashboardScreen);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed: Not a parent account')),
          );
        }
      } else {
        // الطفل
        QuerySnapshot childSnapshot = await _firestore
            .collection('children')
            .where('name', isEqualTo: input)
            .where('password', isEqualTo: password)
            .get();

        if (childSnapshot.docs.isNotEmpty) {
          GoRouter.of(context).push(RoutesManager.kGamesScreen);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed: Child not found')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
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
          icon: Icon(Icons.arrow_back, color: ColorManager.darkOrange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Login",
          style: TextStyle(
            color: ColorManager.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AssetsManager.photo2,
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20.h),
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Log in to manage your child's learning adventure with Kidzooo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: ColorManager.oldGrey,
                  ),
                ),
                SizedBox(height: 25.h),

                TextFormField(
                  controller: emailOrNameController,
                  validator: (value) =>
                  value == null || value.isEmpty ? "This field is required" : null,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: ColorManager.oldGrey),
                    hintText: "Email or Child's Name",
                    labelText: "Email / Name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 15.h),

                TextFormField(
                  controller: passwordController,
                  obscureText: !passwordVisible, // ← استخدام المتغير
                  validator: (value) =>
                  value == null || value.isEmpty ? "Password is required" : null,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: ColorManager.oldGrey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: ColorManager.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible; // ← تبديل الحالة
                        });
                      },
                    ),
                    hintText: "********",
                    labelText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      GoRouter.of(context).push(RoutesManager.kForgetPass);
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: ColorManager.mshmsh,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.mshmsh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 14.sp, color: ColorManager.oldGrey),
                    ),
                    GestureDetector(
                      onTap: () {
                        GoRouter.of(context).push(RoutesManager.kSignUpForParent);
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: ColorManager.mshmsh,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}