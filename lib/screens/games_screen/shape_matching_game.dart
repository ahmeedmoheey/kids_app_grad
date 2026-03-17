import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class ShapeMatchingGame extends StatefulWidget {
  const ShapeMatchingGame({super.key});

  @override
  State<ShapeMatchingGame> createState() => _ShapeMatchingGameState();
}

class _ShapeMatchingGameState extends State<ShapeMatchingGame>
    with TickerProviderStateMixin {
  int level = 1;

  List<List<String>> patterns = [];
  List<String> options = [];

  int currentSection = 0;

  // Animations
  late AnimationController successController;
  late Animation<double> successAnim;

  late AnimationController wrongController;
  late Animation<double> wrongShakeAnim;
  late Animation<double> wrongFadeAnim;

  late AnimationController confettiController;

  final List<String> shapes = ['square', 'triangle', 'pentagon', 'circle'];

  @override
  void initState() {
    super.initState();

    // success
    successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    successAnim = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: successController, curve: Curves.elasticOut),
    );

    // wrong
    wrongController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    wrongShakeAnim = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: wrongController, curve: Curves.elasticIn),
    );

    wrongFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: wrongController, curve: Curves.easeIn),
    );

    // confetti
    confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    generateLevel();
  }

  // ===== Progressive Difficulty =====
  void generateLevel() {
    final rnd = Random();

    patterns.clear();
    options.clear();
    currentSection = 0;

    int sectionCount = min(level, 5); // عدد السيكشنز

    int patternLength = level < 4 ? 3 : 4; // طول النمط يزيد مع الليفل

    for (int i = 0; i < sectionCount; i++) {
      List<String> pattern = [];
      String a = shapes[rnd.nextInt(shapes.length)];
      String b = shapes[rnd.nextInt(shapes.length)];

      if (patternLength == 3) {
        pattern = [a, b, a];
      } else {
        // أصعب
        String c = shapes[rnd.nextInt(shapes.length)];
        pattern = [a, b, c, a];
      }

      patterns.add(pattern);
    }

    // options difficulty
    int optionCount = min(2 + level, shapes.length);
    options = shapes.take(optionCount).toList()..shuffle();

    setState(() {});
  }

  void checkAnswer(String shape) {
    if (patterns.isEmpty) return;

    int midIndex = patterns[currentSection].length ~/ 2;
    String correct = patterns[currentSection][midIndex];

    if (shape == correct) {
      successController.forward(from: 0);

      Future.delayed(const Duration(milliseconds: 400), () {
        setState(() {
          currentSection++;
        });

        if (currentSection >= patterns.length) {
          // confetti
          confettiController.forward(from: 0);

          Future.delayed(const Duration(milliseconds: 900), () {
            setState(() {
              level++;
              generateLevel();
            });
          });
        }
      });
    } else {
      // ❌ wrong
      wrongController.forward(from: 0);
    }
  }

  Color shapeColor(String shape) {
    switch (shape) {
      case 'square':
        return Colors.blue;
      case 'triangle':
        return Colors.orange;
      case 'pentagon':
        return Colors.green;
      case 'circle':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData shapeIcon(String shape) {
    switch (shape) {
      case 'square':
        return Icons.crop_square;
      case 'triangle':
        return Icons.change_history;
      case 'pentagon':
        return Icons.pentagon;
      case 'circle':
        return Icons.circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // size of your design mockup
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF9F8F4),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            GoRouter.of(context).push(RoutesManager.kHomeScreen);
          },
          child: Icon(Icons.close, color: Colors.orange, size: 28.w),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text('Shape Matcher',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xffFFF1D6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'LEVEL $level',
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 10.h),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(patterns.length, (index) {
                        final pattern = patterns[index];
                        final isActive = index == currentSection;
                        final isDone = index < currentSection;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 8.h),
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green.withOpacity(0.2)
                                : const Color(0xffEFE9DB),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isActive
                                  ? Colors.orange
                                  : Colors.brown.shade200,
                              width: isActive ? 2.5.w : 1.5.w,
                            ),
                          ),
                          child: AnimatedBuilder(
                            animation: wrongShakeAnim,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: isActive
                                    ? Offset(wrongShakeAnim.value, 0)
                                    : Offset.zero,
                                child: child,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: pattern.map((shape) {
                                return Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: ScaleTransition(
                                    scale: isActive
                                        ? successAnim
                                        : kAlwaysCompleteAnimation,
                                    child: Container(
                                      width: 60.w,
                                      height: 60.w,
                                      decoration: BoxDecoration(
                                        color: shapeColor(shape),
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                      child: Icon(shapeIcon(shape),
                                          color: Colors.white, size: 34.sp),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // Wrong message
                FadeTransition(
                  opacity: wrongFadeAnim,
                ),

                // OPTIONS
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28.r)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: options.map((shape) {
                      return GestureDetector(
                        onTap: () => checkAnswer(shape),
                        child: Container(
                          width: 70.w,
                          height: 70.w,
                          decoration: BoxDecoration(
                            color: shapeColor(shape),
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          child: Icon(shapeIcon(shape),
                              color: Colors.white, size: 36.sp),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // ===== CONFETTI LAYER =====
            AnimatedBuilder(
              animation: confettiController,
              builder: (context, child) {
                if (!confettiController.isAnimating) {
                  return const SizedBox.shrink();
                }
                return Positioned.fill(
                  child: Opacity(
                    opacity: 1 - confettiController.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎉 🎊 ⭐ 🎉',
                            style: TextStyle(fontSize: 50.sp)),
                        SizedBox(height: 10.h),
                        Text('bravooooo 👏',
                            style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}