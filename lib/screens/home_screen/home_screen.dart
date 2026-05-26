import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';
import 'package:kids_app_grad/server/game_session_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String childName = "Little Hero";

  @override
  void initState() {
    super.initState();
    _loadChildData();
    // Fetch games from backend to get IDs
    GameSessionService().fetchGames();
  }

  void _loadChildData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    if (userData != null) {
      final data = json.decode(userData);
      setState(() {
        childName = data['name'] ?? "Little Hero";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsManager.backGround),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  // Header Logo aligned to the right in a circular frame
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        GoRouter.of(context).push(RoutesManager.kChildProfile);
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE97963), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        ),
                        child: Image.asset(
                          AssetsManager.kidzooPhoto,
                          height: 50.h,
                          width: 50.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Top Games Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column (Find items & Shape Match)
                      Expanded(
                        child: Column(
                          children: [
                            _buildGameCard(
                              title: "Find Items",
                              image: AssetsManager.search,
                              color: const Color(0xFFF9C5D5),
                              onTap: () => GoRouter.of(context).push(RoutesManager.kFindItems),
                              height: 135.h,
                            ),
                            SizedBox(height: 15.h),
                            _buildGameCard(
                              title: "Shape Matching",
                              image: AssetsManager.shapes,
                              color: const Color(0xFFBFE3F5),
                              onTap: () => GoRouter.of(context).push(RoutesManager.kShapeMatching),
                              height: 135.h,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.w),
                      // Right Tall Card (Sight & Play)
                      Expanded(
                        child: _buildGameCard(
                          title: "Animal Matching",
                          image: AssetsManager.puzzle,
                          color: const Color(0xFFAED9C7),
                          onTap: () => GoRouter.of(context).push(RoutesManager.kMatchAnimal),
                          height: 285.h,
                          isTall: true,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15.h),

                  // Sequence Card (formerly Next Shape)
                  _buildWideCard(
                    title: "Sequence Game",
                    image: AssetsManager.shapes1,
                    image2: AssetsManager.shapes2,
                    color: const Color(0xFFF8C0C0),
                    onTap: () => GoRouter.of(context).push(RoutesManager.kSequence),
                  ),

                  SizedBox(height: 15.h),

                  // Animal Pairs Card
                  _buildWideCard(
                    title: "Visual Game",
                    image: AssetsManager.pairs,
                    image2: AssetsManager.pairs,
                    color: const Color(0xFFFDF7BB),
                    onTap: () => GoRouter.of(context).push(RoutesManager.kVisualGame),
                    isAnimalPairs: true,
                  ),

                  SizedBox(height: 40.h),

                  // Bottom Play Button
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push(RoutesManager.kFindItems);
                    },
                    child: Image.asset(AssetsManager.icons),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String image,
    required Color color,
    required VoidCallback onTap,
    required double height,
    bool isTall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isTall) const Spacer(flex: 2),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Image.asset(image, fit: BoxFit.contain),
              ),
            ),
            if (isTall) const Spacer(flex: 1),
            Padding(
              padding: EdgeInsets.only(bottom: 15.h),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideCard({
    required String title,
    required String image,
    String? image2,
    required Color color,
    required VoidCallback onTap,
    bool isAnimalPairs = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: isAnimalPairs
            ? Row(
                children: [
                  SizedBox(width: 30.w),
                  Image.asset(image, height: 50.h),
                  if (image2 != null) ...[
                    SizedBox(width: 10.w),
                    Image.asset(image2, height: 50.h),
                  ],
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10.h),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(image, fit: BoxFit.contain),
                        if (image2 != null) ...[
                          SizedBox(width: 15.w),
                          Image.asset(image2, fit: BoxFit.contain),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
