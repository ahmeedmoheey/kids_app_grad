import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Good morning,", style: TextStyle(fontSize: 12,color: Colors.grey)),
                SizedBox(height: 4),
                Text("Maha Abdelaty",
                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
              ],
            ),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFE4B5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 5),
                      Text("50"),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                GestureDetector(
                  onTap: () {
                    GoRouter.of(context).push(RoutesManager.kChildProfile);
                  },
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(AssetsManager.avatar5),
                  ),
                )
              ],
            )
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 Welcome Card (من غير Padding خارجي)
            Container(
              height: 200.h,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.r),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xffF7C8B8),
                    Color(0xffE7AFA3),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: -10,
                    left: -10,
                    child: Image.asset(
                      AssetsManager.kidzooPhoto,
                      width: 150.w,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 20,
                    child: SizedBox(
                      width: 200.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome to Kidzoo! 🎉",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          Text(
                            "Let's start a fun adventure full of games and surprises",
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: 120.w,
                            height: 40.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(25.r),
                                ),
                              ),
                              onPressed: () {
                              },
                              child: Text("Play",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 👇 باقي الصفحة بقى ياخد Padding
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 15.h),

                  Text(
                    "Pick a Game!",
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20.h),

                  GestureDetector(
                    onTap: () {
                     GoRouter.of(context).push(RoutesManager.kMatahaGames);
                    },
                    child: gameCard(
                      color1: const Color(0xffFCE8C9),
                      color2: const Color(0xffFFF6E6),
                      title: "Maze Game",
                      subtitle: "Help the bee find her honey!",
                      tag: "PUZZLE GAME",
                      image: AssetsManager.game1,
                    ),
                  ),

                  SizedBox(height: 15.h),

                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push(RoutesManager.kGamesScreen);
                    },
                    child: gameCard(
                      color1: const Color(0xffFADADD),
                      color2: const Color(0xffFFF0F3),
                      title: "Shape Matching Game",
                      subtitle: "Match the shapes!",
                      tag: "PUZZLE GAME",
                      image: AssetsManager.game2,
                    ),
                  ),

                  SizedBox(height: 15.h),

                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push(RoutesManager.kShapeMatcher);
                    },
                    child: gameCard(
                      color1: const Color(0xffDFF6F2),
                      color2: const Color(0xffEFFCF9),
                      title: "Shape Matching Game",
                      subtitle: "Learn your A-B-Cs!",
                      tag: "LETTERS",
                      image: AssetsManager.game3,
                    ),
                  ),

                  SizedBox(height: 15.h),

                  gameCard(
                    color1: const Color(0xffE8F5E9),
                    color2: const Color(0xffF4FFF6),
                    title: "Shape Matching Game",
                    subtitle: "Solve the mystery puzzles!",
                    tag: "PUZZLES",
                    image: AssetsManager.game4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget gameCard({
    required Color color1,
    required Color color2,
    required String title,
    required String subtitle,
    required String tag,
    required String image,
  }) {
    return Container(
      height: 110.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),

              SizedBox(height: 10.h),

              Text(title,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold)),

              SizedBox(height: 5.h),

              Text(subtitle,
                  style: TextStyle(fontSize: 12.sp,color: Colors.black54)),
            ],
          ),

          Image.asset(
            image,
            height: 70.h,
          )
        ],
      ),
    );
  }
}