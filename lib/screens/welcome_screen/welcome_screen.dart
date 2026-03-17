import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AssetsManager.backGround,
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AssetsManager.onBoarding4,

                ),
                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AssetsManager.icon3,color: ColorManager.pinkk,),
                    SizedBox(width: 10.w,),
                    Text(
                      "Kidzooo",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.pinkk,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Learn, Play, and Grow Together in a safe digital playground.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: ColorManager.gry,
                    ),
                  ),
                ),
                SizedBox(height: 40),

                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {

                      GoRouter.of(context).push(RoutesManager.kSignUpForParent);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.pinkk,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).push(RoutesManager.kLoginForParent);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.pinkk,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: ColorManager.pinkk),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Already have an account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: ColorManager.white
                        ,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
