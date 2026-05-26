import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_app_grad/server/game_session_service.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import '../../utils/routes_manager.dart';

class ShapeModel {
  final String id;
  final IconData icon;
  final Color color;
  bool isMatched;
  ShapeModel({required this.id, required this.icon, required this.color, this.isMatched = false});
}

class ShapeMatching extends StatefulWidget {
  const ShapeMatching({super.key});

  @override
  State<ShapeMatching> createState() => _ShapeMatchingState();
}

class _ShapeMatchingState extends State<ShapeMatching> with TickerProviderStateMixin {
  static const String _gameSlug = 'shape-match';
  int level = 1;
  final int maxLevels = 10;
  int sessionId = 0;
  DateTime? startTime;
  int totalTrials = 0;
  int totalErrors = 0;
  bool isEnding = false;

  List<ShapeModel> shapes = [];
  List<ShapeModel> targets = [];

  late AnimationController successController;
  late Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();
    successController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.3), weight: 50.0),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1.0), weight: 50.0),
    ]).animate(CurvedAnimation(parent: successController, curve: Curves.easeInOut));

    _startSession();
    generateLevel();
  }

  Future<void> _startSession() async {
    final id = await GameSessionService().startSessionBySlug(
        gameSlug: _gameSlug,
        level: level,
        difficulty: 'Medium'
    );
    if (id != null) {
      if (!mounted) return;
      setState(() {
        sessionId = id;
        startTime = DateTime.now();
      });
    }
  }

  Future<void> _submitTrial({required String prompt, required String selected, required bool correct}) async {
    if (sessionId == 0 || startTime == null) return;

    totalTrials++;
    int durationMs = DateTime.now().difference(startTime!).inMilliseconds;

    await GameSessionService().submitTrial(
      sessionId: sessionId,
      trialNumber: totalTrials,
      taskType: "Matching",
      targetType: "Shape",
      promptValue: prompt,
      selectedValue: selected,
      stimulusCount: shapes.length,
      reactionTimeMs: durationMs,
      correct: correct,
      errors: correct ? 0 : 1,
      missedTargets: 0,
      durationSec: durationMs ~/ 1000,
      metadata: {
        "level": level,
        "ui_type": "drag_and_drop",
        "game_slug": _gameSlug,
      },
    );
    startTime = DateTime.now();
  }

  Future<void> _endSession({bool showResultDialog = true}) async {
    if (sessionId == 0 || isEnding) return;
    isEnding = true;

    int score = level;
    int stars = (level >= maxLevels) ? 3 : (level >= maxLevels / 2 ? 2 : 1);

    final result = await GameSessionService().endSession(
      sessionId: sessionId,
      score: score,
      maxScore: maxLevels,
      stars: stars,
      resultPayload: {"completed_level": level, "game_slug": _gameSlug},
    );

    if (mounted) {
      setState(() {
        sessionId = 0;
      });
      if (showResultDialog) {
        _showFinishDialog(result);
      }
    }
  }

  void generateLevel() {
    shapes.clear();
    targets.clear();
    int count = min(2 + (level ~/ 4), 4);
    List<ShapeModel> allOptions = [
      ShapeModel(id: "circle", icon: Icons.circle, color: Colors.pink),
      ShapeModel(id: "square", icon: Icons.crop_square, color: Colors.blue),
      ShapeModel(id: "triangle", icon: Icons.change_history, color: Colors.orange),
      ShapeModel(id: "pentagon", icon: Icons.pentagon, color: Colors.green),
    ];
    allOptions.shuffle();
    shapes = allOptions.take(count).toList();
    targets = List.from(shapes)..shuffle();
    if (mounted) setState(() {});
    startTime = DateTime.now();
  }

  void checkMatch(ShapeModel dragged, ShapeModel target) {
    bool isCorrect = dragged.id == target.id;
    _submitTrial(prompt: target.id, selected: dragged.id, correct: isCorrect);

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      successController.forward(from: 0.0);
      setState(() { target.isMatched = true; });

      if (targets.every((t) => t.isMatched)) {
        if (level >= maxLevels) {
          _endSession();
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() { level++; generateLevel(); });
            }
          });
        }
      }
    } else {
      HapticFeedback.vibrate();
      setState(() { totalErrors++; });
    }
  }

  void _showFinishDialog([Map<String, dynamic>? result]) {
    String message = "Congratulations Champion! You've matched all shapes! ⭐";
    if (result != null && result['prediction'] != null) {
      if (result['prediction']['status'] == 'visual_disorder') {
        message = "Game completed. Performance analysis sent to your parents.";
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
        title: const Text("🏆 Super Hero! 🏆", textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
                onPressed: () => context.go(RoutesManager.kHomeScreen),
                child: const Text("Back Home")
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    successController.dispose();
    if (sessionId != 0 && !isEnding) {
      GameSessionService().endSession(
        sessionId: sessionId,
        score: level,
        maxScore: maxLevels,
        stars: 0,
        resultPayload: {"completed_level": level, "game_slug": _gameSlug},
      );
    }
    super.dispose();
  }

  Future<void> _handleExit() async {
    if (!isEnding) {
      await _endSession(showResultDialog: false);
    }
    if (mounted) {
      context.go(RoutesManager.kHomeScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleExit();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffFDFBF7),
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0.0,
          leading: IconButton(icon: const Icon(Icons.close, color: Colors.orange), onPressed: _handleExit),
          title: Text("Shape Matching - LEVEL $level / $maxLevels", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            SizedBox(height: 10.h),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                itemCount: targets.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 25.w, crossAxisSpacing: 25.w, childAspectRatio: 1.0),
                itemBuilder: (context, index) {
                  final target = targets[index];
                  return DragTarget<ShapeModel>(
                    onWillAcceptWithDetails: (details) => !target.isMatched,
                    onAcceptWithDetails: (details) => checkMatch(details.data, target),
                    builder: (context, candidateData, _) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: target.isMatched ? target.color.withOpacity(0.15) : const Color(0xffF0EBE3),
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(color: target.isMatched ? target.color : Colors.brown.withOpacity(0.05), width: 3.w),
                        ),
                        child: Center(
                          child: target.isMatched
                              ? ScaleTransition(scale: scaleAnim, child: const Icon(Icons.check_circle, color: Colors.green, size: 55))
                              : Icon(target.icon, color: Colors.brown.withOpacity(0.1), size: 65),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(45.r))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: shapes.where((s) => !targets.firstWhere((t) => t.id == s.id).isMatched).map((shape) => Draggable<ShapeModel>(
                  data: shape,
                  feedback: Material(color: Colors.transparent, child: Icon(shape.icon, color: shape.color, size: 85)),
                  childWhenDragging: Opacity(opacity: 0.1, child: Icon(shape.icon, color: shape.color, size: 75)),
                  child: Icon(shape.icon, color: shape.color, size: 75),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
