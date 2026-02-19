import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class SignUpForParent extends StatelessWidget {
  const SignUpForParent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.offWhite,
      appBar: AppBar(
        backgroundColor: ColorManager.offWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Parent Sign Up",
          style: TextStyle(
            color: ColorManager.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),

            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: const Color(0xffE8E3D9),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.asset(
                  AssetsManager.photo,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 25.h),

            Text(
              "Join the Adventure",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: ColorManager.black,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              "Create an account to start your child’s\npersonalized learning journey.",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 25.h),

            /// Full Name
            buildLabel("Full Name"),
            SizedBox(height: 8.h),
            buildTextField(
              hint: "Enter your full name",
              icon: Icons.person_outline,
            ),

            SizedBox(height: 20.h),

            /// Email
            buildLabel("Email Address"),
            SizedBox(height: 8.h),
            buildTextField(
              hint: "parent@example.com",
              icon: Icons.email_outlined,
            ),

            SizedBox(height: 20.h),

            buildLabel("Password"),
            SizedBox(height: 8.h),
            buildTextField(
              hint: "Create a strong password",
              icon: Icons.lock_outline,
              isPassword: true,
            ),

            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:  ColorManager.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "Create Account ",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.brown,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

          Center(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account? ",style: TextStyle(
                fontSize: 14.sp,
                color: ColorManager.gry,

              ),),
              SizedBox(width: 8,),

              GestureDetector(
                onTap: () {
                  GoRouter.of(context).push(RoutesManager.kLoginForParent);
                },
                child: Text("Log In ",style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.semony
                ),),
              ),
            ],
          )),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: ColorManager.black,
      ),
    );
  }

  Widget buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 18.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
