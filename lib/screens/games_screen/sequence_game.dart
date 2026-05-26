import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/server/game_session_service.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class SequenceGame extends StatefulWidget {
  const SequenceGame({super.key});

  @override
  State<SequenceGame> createState() => _SequenceGameState();
}

class _SequenceGameState extends State<SequenceGame> {
  static const String _gameSlug = 'sequence-game';
  int level = 1;
  final int maxLevels = 10;

  // AI Tracking
  int sessionId = 0;
  DateTime? startTime;
  int totalTrials = 0;
  bool isEnding = false;

  final List<String> shapes = [
    'assets/images/image45.png', // Circle
    'assets/images/image46.png', // Square
    'assets/images/image47.png', // Triangle
    'assets/images/image48.png', // Star
    'assets/images/image49.png', // Heart
    'assets/images/image50.png', // Diamond
  ];

  late List<String> currentSequence;
  late String targetShape;
  late List<String> options;

  @override
  void initState() {
    super.initState();
    _startSession();
    _generateLevel();
  }

  @override
  void dispose() {
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

  Future<void> _startSession() async {
    final id = await GameSessionService().startSessionBySlug(
      gameSlug: _gameSlug,
      level: level,
      difficulty: 'Easy',
    );

    if (id != null) {
      if (!mounted) return;
      setState(() {
        sessionId = id;
        startTime = DateTime.now();
      });
    }
  }

  Future<void> _submitTrial({required String selected, required bool correct}) async {
    if (sessionId == 0 || startTime == null) return;

    totalTrials++;
    int durationMs = DateTime.now().difference(startTime!).inMilliseconds;

    await GameSessionService().submitTrial(
      sessionId: sessionId,
      trialNumber: totalTrials,
      taskType: "Orientation",
      targetType: "Sequence",
      promptValue: targetShape.split('/').last.split('.').first,
      selectedValue: selected.split('/').last.split('.').first,
      stimulusCount: options.length,
      reactionTimeMs: durationMs,
      correct: correct,
      errors: correct ? 0 : 1,
      missedTargets: 0,
      durationSec: durationMs ~/ 1000,
      metadata: {
        "level": level,
        "ui_type": "sequence_completion",
        "game_slug": _gameSlug,
      },
    );
    startTime = DateTime.now();
  }

  Future<void> _endSession({bool showResultDialog = true}) async {
    if (sessionId == 0 || isEnding) return;
    isEnding = true;

    int stars = (level >= maxLevels) ? 3 : (level >= maxLevels / 2 ? 2 : 1);

    final result = await GameSessionService().endSession(
      sessionId: sessionId,
      score: level,
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

  void _generateLevel() {
    int seqLength = (level <= 3) ? 2 : (level <= 6 ? 3 : 4);
    List<String> pool = List.from(shapes)..shuffle();
    List<String> baseShapes = pool.take(2).toList();

    currentSequence = [];
    for (int i = 0; i < seqLength; i++) {
      currentSequence.add(baseShapes[i % 2]);
    }

    targetShape = baseShapes[seqLength % 2];

    options = List.from(baseShapes)..shuffle();
    if (options.length < 3) {
      options.add(shapes.firstWhere((s) => !baseShapes.contains(s)));
      options.shuffle();
    }

    startTime = DateTime.now();
    setState(() {});
  }

  void _onOptionTap(String selected) {
    bool isCorrect = selected == targetShape;
    _submitTrial(selected: selected, correct: isCorrect);

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      if (level >= maxLevels) {
        _endSession();
      } else {
        setState(() {
          level++;
          _generateLevel();
        });
      }
    } else {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Try again!"), duration: Duration(milliseconds: 500)),
      );
    }
  }

  void _showFinishDialog(Map<String, dynamic>? result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Amazing!"),
        content: const Text("You completed the sequence challenge!"),
        actions: [
          TextButton(
            onPressed: () => context.go(RoutesManager.kHomeScreen),
            child: const Text("Finish"),
          )
        ],
      ),
    );
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
        backgroundColor: const Color(0xffF9F8F4),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.orange),
            onPressed: _handleExit,
          ),
          title: Text("Sequence Game - Level $level", style: const TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("What comes next?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...currentSequence.map((s) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Image.asset(s, width: 60.w),
                )),
                Container(
                  width: 60.w,
                  height: 60.w,
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 2, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.help_outline, color: Colors.orange),
                ),
              ],
            ),
            SizedBox(height: 60.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: options.map((s) => GestureDetector(
                onTap: () => _onOptionTap(s),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: Image.asset(s, width: 70.w),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
