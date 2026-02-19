import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/utils/app_style.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {

  int currentIndex = 0;
  final PageController controller = PageController();

  List<String> images = [
    AssetsManager.onBoarding1,
    AssetsManager.onBoarding2,
  ];

  List<String> titles = [
    "Fun Learning\nExperience",
    "Track Your Child\nProgress",
  ];

  List<String> descriptions = [
    "Discover a world where play meets education. Our interactive games help children develop essential skills while having a blast.",
    "Our parent dashboard provides deep insights into your child’s learning achievements and milestones.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: currentIndex == 1
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            controller.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
        )
            : null,

        centerTitle: true,

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            SizedBox(width: 6.w),
            Text("Kidzooo", style: AppStyle.kidzoo),
          ],
        ),

        actions: currentIndex == 0
            ? [
          TextButton(
            onPressed: () {
              GoRouter.of(context).push(RoutesManager.kWelcomeScreen);
            },
            child: Text(
              "Skip",
              style: TextStyle(
                color: ColorManager.black,
                fontSize: 16.sp,
              ),
            ),
          )
        ]
            : [],
      ),

      body: Column(
        children: [

          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),

                      Image.asset(
                        images[index],
                        height: 280.h,
                      ),

                      SizedBox(height: 30.h),

                      Text(
                        titles[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        descriptions[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: ColorManager.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// DOTS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: currentIndex == index ? 20.w : 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? ColorManager.red
                      : ColorManager.orange,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 30.h),

          /// BUTTON
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentIndex == 0
                      ? ColorManager.red
                      : ColorManager.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 6,
                ),
                onPressed: () {
                  if (currentIndex == images.length - 1) {
                    GoRouter.of(context).push(RoutesManager.kWelcomeScreen);
                  } else {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  currentIndex == images.length - 1
                      ? "Get Started"
                      : "Next",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: ColorManager.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
