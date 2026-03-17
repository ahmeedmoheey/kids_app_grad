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
  bool passwordVisible = false;

  void loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String input = emailOrNameController.text.trim();
    String password = passwordController.text.trim();

    try {
      if (input.contains('@')) {
        UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
          email: input,
          password: password,
        );

        String uid = userCredential.user!.uid;
        DocumentSnapshot doc =
        await _firestore.collection('users').doc(uid).get();

        String userType =
        doc.exists ? (doc['type'] ?? 'parent') : 'parent';

        if (userType == 'parent') {
          GoRouter.of(context).push(RoutesManager.kDashboardScreen);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not a parent account')),
          );
        }
      } else {
        QuerySnapshot childSnapshot = await _firestore
            .collection('children')
            .where('name', isEqualTo: input)
            .where('password', isEqualTo: password)
            .get();

        if (childSnapshot.docs.isNotEmpty) {
          GoRouter.of(context).push(RoutesManager.kMainScreen);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Child not found')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorManager.pinkk),
          onPressed: () => Navigator.pop(context),
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

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsManager.cover),
            fit: BoxFit.cover,
          ),
        ),

        child: SingleChildScrollView(
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    AssetsManager.girl,
                    height: 280.h,
                  ),

                  SizedBox(height: 20.h),

                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    "Log in to manage your child's learning adventure with Kidzooo.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: ColorManager.oldGrey,
                    ),
                  ),

                  SizedBox(height: 25.h),

                  /// Email
                  TextFormField(
                    controller: emailOrNameController,
                    validator: (value) =>
                    value!.isEmpty ? "Required" : null,
                    decoration: InputDecoration(

                      prefixIcon: Icon(Icons.person),
                      hintText: "Email or Child Name",
                      filled: true,
                      fillColor: ColorManager.ff,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  /// Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    validator: (value) =>
                    value!.isEmpty ? "Required" : null,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                      hintText: "********",
                      filled: true,
                      fillColor: ColorManager.ff,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        GoRouter.of(context)
                            .push(RoutesManager.kForgetPass);
                      },
                      child: Text("Forgot Password?",style: TextStyle(
                        color: ColorManager.pinkk
                      ),),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  /// Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.pinkk,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          :  Text("Login",style: TextStyle(
                        color: Colors.white
                      ),),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).push(
                              RoutesManager.kSignUpForParent);
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: ColorManager.pinkk,
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
      ),
    );
  }
}