import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class MatahaGames extends StatefulWidget {
  const MatahaGames({super.key});

  @override
  State<MatahaGames> createState() => _MatahaGamesState();
}

class _MatahaGamesState extends State<MatahaGames>
    with TickerProviderStateMixin {
  int currentLevel = 0;

  final List<String> matahaList = [
    AssetsManager.mataha,
    AssetsManager.mataha2,
    AssetsManager.mataha3,
    AssetsManager.mataha4,
    AssetsManager.mataha5,
  ];

  final List<String> startList = [
    AssetsManager.mouse,
    AssetsManager.bee,
    AssetsManager.hlazona,
    AssetsManager.ant,
    AssetsManager.bee,
  ];

  final List<String> goalList = [
    AssetsManager.cheese,
    AssetsManager.cell,
    AssetsManager.ftr,
    AssetsManager.seed,
    AssetsManager.cell,
  ];

  List<Offset> points = [];

  bool startedFromStart = false;
  bool levelCompleted = false; // 🔥 الحل هنا

  late AnimationController wrongController;
  late Animation<double> shakeAnim;

  late AnimationController successController;
  late Animation<double> successScale;

  bool showSuccessOverlay = false;

  @override
  void initState() {
    super.initState();

    wrongController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    shakeAnim = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: wrongController, curve: Curves.elasticIn),
    );

    successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    successScale = Tween<double>(begin: 0.5, end: 1.3).animate(
      CurvedAnimation(parent: successController, curve: Curves.elasticOut),
    );
  }

  void resetGame() {
    wrongController.forward(from: 0);
    setState(() {
      points.clear();
      startedFromStart = false;
      levelCompleted = false;
    });
  }

  void nextLevel() {
    if (levelCompleted) return; // يمنع التكرار
    levelCompleted = true;

    successController.forward(from: 0);
    setState(() => showSuccessOverlay = true);

    Future.delayed(const Duration(milliseconds: 1600), () {
      setState(() {
        showSuccessOverlay = false;

        if (currentLevel < matahaList.length - 1) {
          currentLevel++;
          points.clear();
          startedFromStart = false;
          levelCompleted = false;
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("ممتاز! 🎉🎉"),
              content: const Text("خلّصت كل المتاهات!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    GoRouter.of(context)
                        .go(RoutesManager.kHomeScreen);
                  },
                  child: const Text("العودة للرئيسية"),
                ),
              ],
            ),
          );
        }
      });
    });
  }

  bool isInsidePath(Offset point, Size size) {
    return point.dx > size.width * 0.05 &&
        point.dx < size.width * 0.95 &&
        point.dy > size.height * 0.1 &&
        point.dy < size.height * 0.95;
  }

  bool reachedGoal(Offset point, Size size) {
    Rect goalArea = Rect.fromLTWH(
      size.width * 0.78,
      size.height * 0.78,
      size.width * 0.12,
      size.height * 0.12,
    );
    return goalArea.contains(point);
  }

  bool isInsideStart(Offset point, Size size) {
    Rect startArea = Rect.fromLTWH(
      size.width * 0.03,
      size.height * 0.08,
      80,
      80,
    );
    return startArea.contains(point);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      backgroundColor: const Color(0xffF9F8F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () =>
              GoRouter.of(context).go(RoutesManager.kHomeScreen),
          child: Icon(Icons.close, color: Colors.orange, size: 28.w),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'لعبة المتاهة',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 6.h),
            TweenAnimationBuilder(
              tween: Tween<double>(
                  begin: 0,
                  end: (currentLevel + 1) / matahaList.length),
              duration: const Duration(milliseconds: 900),
              builder: (context, value, child) {
                return Container(
                  width: 200.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius:
                        BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 4.h),
            Text(
              "المستوى ${currentLevel + 1}",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size =
          Size(constraints.maxWidth, constraints.maxHeight);

          return AnimatedBuilder(
            animation: shakeAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(shakeAnim.value, 0),
                child: child,
              );
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    matahaList[currentLevel],
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  left: size.width * 0.05,
                  top: size.height * 0.1,
                  child: Image.asset(startList[currentLevel],
                      width: 60),
                ),
                Positioned(
                  left: size.width * 0.75,
                  top: size.height * 0.75,
                  child:
                  Image.asset(goalList[currentLevel], width: 80),
                ),
                GestureDetector(
                  onPanStart: (details) {
                    final point = details.localPosition;

                    if (isInsideStart(point, size)) {
                      startedFromStart = true;
                      setState(() => points = [point]);
                    } else {
                      startedFromStart = false;
                    }
                  },
                  onPanUpdate: (details) {
                    if (!startedFromStart || levelCompleted) return;

                    final point = details.localPosition;

                    if (!isInsidePath(point, size)) {
                      resetGame();
                      return;
                    }

                    if (reachedGoal(point, size)) {
                      nextLevel();
                      return;
                    }

                    setState(() => points.add(point));
                  },
                  child: CustomPaint(
                    size: size,
                    painter: LinePainter(points),
                  ),
                ),
                if (showSuccessOverlay)
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: ScaleTransition(
                        scale: successScale,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.w, vertical: 30.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(20.r),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events,
                                  color: Colors.orange,
                                  size: 70.w),
                              SizedBox(height: 15.h),
                              Text(
                                "المستوى ${currentLevel + 1} خلّصته!",
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10.h),
                              Text("برافو! 🎉",
                                  style: TextStyle(fontSize: 16.sp)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List<Offset> points;

  LinePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}