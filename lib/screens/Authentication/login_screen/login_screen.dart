import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/blocs/auth/auth_bloc.dart';
import 'package:kids_app_grad/blocs/auth/auth_event.dart';
import 'package:kids_app_grad/blocs/auth/auth_state.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';
import 'package:kids_app_grad/utils/ui_helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailOrNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            UIHelpers.showSuccessSnackBar(context, state.message);
            // التوجيه بناءً على البيانات اللي جاية في الـ Success
            if (state.userData != null) {
              bool isParent = emailOrNameController.text.contains('@');
              if (isParent) {
                bool hasChildren = state.userData['has_children'] ?? false;
                if (hasChildren) {
                  context.go(RoutesManager.kHomePageParent);
                } else {
                  context.go(RoutesManager.kSignUpForChild);
                }
              } else {
                context.go(RoutesManager.kHomeScreen);
              }
            }
          }
          if (state is AuthFailure) {
            UIHelpers.showErrorDialog(context, state.error);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ColorManager.pinkk),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("Login", style: TextStyle(color: ColorManager.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
            centerTitle: true,
          ),
          body: Container(
            width: double.infinity, height: double.infinity,
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage(AssetsManager.backGround), fit: BoxFit.cover)),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(AssetsManager.girl, height: 280.h),
                    SizedBox(height: 20.h),
                    Text("Welcome Back!", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 25.h),
                    TextFormField(
                      controller: emailOrNameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        hintText: "Email or Child Name",
                        filled: true, fillColor: ColorManager.ff,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r), borderSide: BorderSide.none),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !passwordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => passwordVisible = !passwordVisible),
                        ),
                        hintText: "********",
                        filled: true, fillColor: ColorManager.ff,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r), borderSide: BorderSide.none),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => GoRouter.of(context).push(RoutesManager.kForgetPass),
                        child: Text("Forgot Password?", style: TextStyle(color: ColorManager.pinkk)),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity, height: 50.h,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading 
                                ? null 
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(LoginRequested(
                                        emailOrNameController.text.trim(),
                                        passwordController.text.trim(),
                                      ));
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.pinkk,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                            ),
                            child: state is AuthLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Login", style: TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () => context.push(RoutesManager.kSignUpForParent),
                          child: Text("Sign Up", style: TextStyle(color: ColorManager.pinkk, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
