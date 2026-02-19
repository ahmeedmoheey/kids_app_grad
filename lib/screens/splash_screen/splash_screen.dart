import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
void initState(){
    super.initState();
navigateToOnBoarding();


}
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: AlignmentGeometry.bottomRight,
              colors: [
            ColorManager.pink,
            ColorManager.nely
          ])
        ),
        child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
               SvgPicture.asset(AssetsManager.icon,),
                  Text("Kidzoo", style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.white,
                  ),),
                    SizedBox(height: 25.h,),
            Image.asset(AssetsManager.splashPhoto),
            SizedBox(height: 25.h,),

            Text("Learn. Play. Grow.",style: TextStyle(
              color: ColorManager.white,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 25.h,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const LinearProgressIndicator(
                  minHeight: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Loading your adventure...",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),



          ],
        ),
      ),
    );
  }

  void navigateToOnBoarding() {
    Future.delayed(const Duration(seconds: 3), () {
      GoRouter.of(context).push(RoutesManager.kOnBoarding);
    },
    );
  }
}
