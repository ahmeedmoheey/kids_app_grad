import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/server/game_session_service.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class VisualGameItem {
  final String imagePath;
  bool isMatched;
  bool isSelected;

  VisualGameItem({
    required this.imagePath,
    this.isMatched = false,
    this.isSelected = false,
  });
}

class VisualGame extends StatefulWidget {
  const VisualGame({super.key});

  @override
  State<VisualGame> createState() => _VisualGameState();
}

class _VisualGameState extends State<VisualGame> with TickerProviderStateMixin {
  static const String _gameSlug = 'visual-game';

  int currentLevel = 1;
  final int maxLevel = 10;
  List<VisualGameItem> gameItems = [];
  int? firstSelectedIndex;
  bool canClick = true;
  int matchesFound = 0;

  int sessionId = 0;
  DateTime? startTime;
  int totalTrials = 0;
  int errorsInLevel = 0;
  bool isEnding = false;

  final List<String> animalImages = [
    'assets/images/cat.png',
    'assets/images/dog.png',
    'assets/images/lionw.png',
    'assets/images/blackcat.png',
    'assets/images/db.png',
    'assets/images/boma.png',
    'assets/images/monkey.png',
    'assets/images/donkeywhshy.png',
    'assets/images/dofd3.png',
    'assets/images/zrafaa.png',
    'assets/images/snake.png',
    'assets/images/khnzer.png',
  ];

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _startSession();
    _setupLevel();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    if (sessionId != 0 && !isEnding) {
      GameSessionService().endSession(
        sessionId: sessionId,
        score: currentLevel,
        maxScore: maxLevel,
        stars: 0,
        resultPayload: {
          "completed_level": currentLevel,
          "game_slug": _gameSlug,
        },
      );
    }
    super.dispose();
  }

  Future<void> _startSession() async {
    final id = await GameSessionService().startSessionBySlug(
      gameSlug: _gameSlug,
      level: currentLevel,
      difficulty: 'Easy',
    );

    if (id != null && mounted) {
      setState(() {
        sessionId = id;
        startTime = DateTime.now();
      });
    }
  }

  Future<void> _submitTrial({
    required String firstId,
    required String secondId,
    required bool isCorrect,
  }) async {
    if (sessionId == 0 || startTime == null) return;

    totalTrials++;
    final durationMs = DateTime.now().difference(startTime!).inMilliseconds;

    await GameSessionService().submitTrial(
      sessionId: sessionId,
      trialNumber: totalTrials,
      taskType: "Discrimination",
      targetType: "Pattern",
      promptValue: firstId.split('/').last.split('.').first,
      selectedValue: secondId.split('/').last.split('.').first,
      stimulusCount: gameItems.length,
      reactionTimeMs: durationMs,
      correct: isCorrect,
      errors: isCorrect ? 0 : 1,
      missedTargets: 0,
      durationSec: durationMs ~/ 1000,
      metadata: {
        "level": currentLevel,
        "ui_type": "image_grid",
        "game_slug": _gameSlug,
      },
    );
    startTime = DateTime.now();
  }

  Future<void> _endSession({bool showResultDialog = true}) async {
    if (sessionId == 0 || isEnding) return;
    isEnding = true;

    final stars = (currentLevel >= maxLevel) ? 3 : (currentLevel >= maxLevel / 2 ? 2 : 1);

    final result = await GameSessionService().endSession(
      sessionId: sessionId,
      score: currentLevel,
      maxScore: maxLevel,
      stars: stars,
      resultPayload: {
        "completed_level": currentLevel,
        "game_slug": _gameSlug,
      },
    );

    if (mounted) {
      setState(() {
        sessionId = 0;
      });
      if (showResultDialog) {
        _onLevelComplete(isFinal: true, result: result);
      }
    }
  }

  void _setupLevel() {
    final pairsCount = (1 + currentLevel).clamp(2, 10);
    final pool = List<String>.from(animalImages)..shuffle();
    final selectedImages = pool.take(pairsCount).toList();
    final levelImages = [...selectedImages, ...selectedImages]..shuffle();

    gameItems = levelImages.map((path) => VisualGameItem(imagePath: path)).toList();
    matchesFound = 0;
    errorsInLevel = 0;
    firstSelectedIndex = null;
    canClick = true;
    startTime = DateTime.now();
    setState(() {});
  }

  void _onItemTap(int index) {
    if (!canClick || gameItems[index].isMatched || gameItems[index].isSelected) return;

    setState(() {
      gameItems[index].isSelected = true;
    });

    if (firstSelectedIndex == null) {
      firstSelectedIndex = index;
      return;
    }

    canClick = false;
    final firstId = gameItems[firstSelectedIndex!].imagePath;
    final secondId = gameItems[index].imagePath;
    final isMatch = firstId == secondId;

    _submitTrial(firstId: firstId, secondId: secondId, isCorrect: isMatch);

    if (isMatch) {
      HapticFeedback.mediumImpact();
      setState(() {
        gameItems[firstSelectedIndex!].isMatched = true;
        gameItems[index].isMatched = true;
        gameItems[firstSelectedIndex!].isSelected = false;
        gameItems[index].isSelected = false;
        matchesFound++;
        firstSelectedIndex = null;
        canClick = true;
      });

      if (matchesFound == gameItems.length ~/ 2) {
        if (currentLevel >= maxLevel) {
          _endSession();
        } else {
          _onLevelComplete();
        }
      }
      return;
    }

    HapticFeedback.vibrate();
    _shakeController.forward(from: 0);
    setState(() {
      errorsInLevel++;
    });
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        gameItems[firstSelectedIndex!].isSelected = false;
        gameItems[index].isSelected = false;
        firstSelectedIndex = null;
        canClick = true;
      });
    });
  }

  void _onLevelComplete({bool isFinal = false, Map<String, dynamic>? result}) {
    String message = isFinal ? 'Excellent Job! Game completed.' : 'You found all the matches!';

    if (isFinal && result != null && result['prediction'] != null) {
      if (result['prediction']['status'] == 'visual_disorder') {
        message = "Game completed. Pattern analysis has been shared with your parents.";
      }
    }

    Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text(isFinal ? 'Champion!' : 'Bravo!', textAlign: TextAlign.center),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (!isFinal) {
                    setState(() {
                      currentLevel++;
                      _setupLevel();
                    });
                  } else {
                    context.go(RoutesManager.kHomeScreen);
                  }
                },
                child: Text(isFinal ? 'Finish' : 'Next Level', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    });
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
    final crossAxisCount = gameItems.length <= 6 ? 2 : (gameItems.length <= 16 ? 3 : 4);

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
          title: Text(
            'Visual Game - LEVEL $currentLevel / $maxLevel',
            style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
              child: LinearProgressIndicator(
                value: gameItems.isEmpty ? 0 : matchesFound / (gameItems.length / 2),
                backgroundColor: Colors.grey[300],
                color: Colors.orange,
                minHeight: 10.h,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.w,
                  ),
                  itemCount: gameItems.length,
                  itemBuilder: (context, index) {
                    final item = gameItems[index];
                    return GestureDetector(
                      onTap: () => _onItemTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: item.isMatched
                              ? Colors.green.withOpacity(0.05)
                              : (item.isSelected ? Colors.orange.withOpacity(0.05) : Colors.white),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: item.isMatched
                                ? Colors.green
                                : (item.isSelected ? Colors.orange : Colors.grey[200]!),
                            width: item.isMatched || item.isSelected ? 3.w : 1.w,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Opacity(
                            opacity: item.isMatched ? 0.4 : 1.0,
                            child: Image.asset(item.imagePath, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
