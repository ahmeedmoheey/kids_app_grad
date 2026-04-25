import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String childName = "Little Hero"; // اسم افتراضي

  @override
  void initState() {
    super.initState();
    _loadChildData();
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
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: const Color(0xffF6F6F6),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Good morning,", style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(childName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            GestureDetector(
              onTap: () => GoRouter.of(context).push(RoutesManager.kChildProfile),
              child: const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(AssetsManager.avatar5),
              ),
            )
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(AssetsManager.backGround), fit: BoxFit.cover),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              children: [
                // تم تعديل هذا الجزء ليصبح كارت واحد فقط بدلاً من اثنين بعد حذف المتاهة
                GestureDetector(
                  onTap: () => GoRouter.of(context).push(RoutesManager.kMatchAnimal),
                  child: _buildWideCard(AssetsManager.tutrle, color: const Color(0xFFAED9C7)),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () => GoRouter.of(context).push(RoutesManager.kFindStar),
                  child: _buildWideCard(AssetsManager.swq, color: const Color(0xFFF8D9C4)),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () => GoRouter.of(context).push(RoutesManager.kShapeMatcher),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(color: const Color(0xFFBFE3F5), borderRadius: BorderRadius.circular(20.r)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _shapeItem(Icons.crop_square, Colors.blue),
                            _shapeItem(Icons.change_history, Colors.orange),
                            _shapeItem(Icons.crop_square, Colors.blue),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _shapeItem(Icons.circle, Colors.pink),
                            _shapeItem(Icons.crop_square, Colors.blue),
                            _shapeItem(Icons.circle, Colors.pink),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () => GoRouter.of(context).push(RoutesManager.kGamesScreen),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(color: ColorManager.pink.withOpacity(.77), borderRadius: BorderRadius.circular(20.r)),
                    child: _buildWideCard(AssetsManager.drag, color: Colors.transparent),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideCard(String image, {Color? color}) {
    return Container(
      height: 100.h,
      width: double.infinity,
      decoration: BoxDecoration(color: color ?? Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: ClipRRect(borderRadius: BorderRadius.circular(20.r), child: Image.asset(image, fit: BoxFit.contain)),
    );
  }

  Widget _shapeItem(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Icon(icon, color: color, size: 26.sp),
    );
  }
}
