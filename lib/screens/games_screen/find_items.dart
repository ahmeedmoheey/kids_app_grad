import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/server/game_session_service.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class FindItems extends StatefulWidget {
  const FindItems({super.key});

  @override
  State<FindItems> createState() => _FindItemsState();
}

class _FindItemsState extends State<FindItems> with SingleTickerProviderStateMixin {
  static const String _gameSlug = 'find-items';
  int currentLevel = 1;
  final int totalLevels = 10;
  late String targetImage;
  List<String> displayImages = [];
  String? selectedImage;
  bool isCorrect = false;
  bool isError = false;

  // AI Connection Variables
  int sessionId = 0;
  DateTime? startTime;
  int totalTrials = 0;
  int totalErrors = 0;
  bool isEnding = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final List<String> allImages = [
    AssetsManager.image1, AssetsManager.image2, AssetsManager.image3, AssetsManager.image4, AssetsManager.image5,
    AssetsManager.image6, AssetsManager.image7, AssetsManager.image8, AssetsManager.image9, AssetsManager.image10,
    AssetsManager.image11, AssetsManager.image12, AssetsManager.image13, AssetsManager.image14, AssetsManager.image15,
    AssetsManager.image16, AssetsManager.image17, AssetsManager.image18, AssetsManager.image19, AssetsManager.image20,
    AssetsManager.image21, AssetsManager.image22, AssetsManager.image23, AssetsManager.image24, AssetsManager.image25,
    AssetsManager.image26, AssetsManager.image27, AssetsManager.image28, AssetsManager.image29, AssetsManager.image30,
    AssetsManager.image31, AssetsManager.image32, AssetsManager.image33, AssetsManager.image34, AssetsManager.image35,
    AssetsManager.image36, AssetsManager.image37, AssetsManager.image38, AssetsManager.image39, AssetsManager.image40,
    AssetsManager.image41, AssetsManager.image42, AssetsManager.image43, AssetsManager.image44, AssetsManager.image45,
    AssetsManager.image46, AssetsManager.image47, AssetsManager.image48, AssetsManager.image49, AssetsManager.image50,
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _startSession();
    _generateLevel();
  }

  Future<void> _startSession() async {
    final id = await GameSessionService().startSessionBySlug(
      gameSlug: _gameSlug,
      level: currentLevel,
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

  Future<void> _submitTrial(String selectedId, bool correct) async {
    if (sessionId == 0 || startTime == null) return;

    totalTrials++;
    int durationMs = DateTime.now().difference(startTime!).inMilliseconds;

    await GameSessionService().submitTrial(
      sessionId: sessionId,
      trialNumber: totalTrials,
      taskType: "Discrimination",
      targetType: "Object",
      promptValue: targetImage.split('/').last.split('.').first,
      selectedValue: selectedId.split('/').last.split('.').first,
      stimulusCount: displayImages.length,
      reactionTimeMs: durationMs,
      correct: correct,
      errors: correct ? 0 : 1,
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Analyzing your progress...", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    int stars = (currentLevel >= totalLevels) ? 3 : (currentLevel >= totalLevels / 2 ? 2 : 1);
    final result = await GameSessionService().endSession(
      sessionId: sessionId,
      score: currentLevel,
      maxScore: totalLevels,
      stars: stars,
      resultPayload: {
        "completed_level": currentLevel,
        "game_slug": _gameSlug,
      },
    );

    if (mounted) {
      Navigator.of(context).pop();
      setState(() {
        sessionId = 0;
      });
      if (showResultDialog) {
        _showResultDialog(result);
      }
    }
  }

  void _showResultDialog(Map<String, dynamic>? result) {
    String message = "Fantastic! You found all the items.";
    if (result != null && result['prediction'] != null) {
      if (result['prediction']['status'] == 'visual_disorder') {
        message = "Game over! Your performance analysis has been sent to your parents.";
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Well Done!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.go(RoutesManager.kHomeScreen),
            child: const Text("Back to Home"),
          ),
        ],
      ),
    );
  }

  void _generateLevel() {
    setState(() {
      isCorrect = false;
      isError = false;
      selectedImage = null;

      int itemsCount = (currentLevel * 2).clamp(4, 20);
      List<String> shuffledPool = List.from(allImages)..shuffle();
      displayImages = shuffledPool.take(itemsCount).toList();

      targetImage = displayImages[Random().nextInt(displayImages.length)];
      startTime = DateTime.now();
    });
  }

  void _onItemTap(String image) {
    if (isCorrect || isEnding) return;

    bool correct = image == targetImage;
    setState(() {
      selectedImage = image;
    });

    _submitTrial(image, correct);

    if (correct) {
      setState(() {
        isCorrect = true;
        isError = false;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (currentLevel < totalLevels) {
          if (mounted) {
            setState(() {
              currentLevel++;
            });
            _generateLevel();
          }
        } else {
          _endSession();
        }
      });
    } else {
      setState(() {
        isError = true;
        totalErrors++;
      });
      _shakeController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            isError = false;
            selectedImage = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    if (sessionId != 0 && !isEnding) {
      GameSessionService().endSession(
        sessionId: sessionId,
        score: currentLevel,
        maxScore: totalLevels,
        stars: 0,
        resultPayload: {"completed_level": currentLevel, "game_slug": _gameSlug},
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Column(
            children: [
              const Text("Find the Item", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              Text("LEVEL $currentLevel", style: const TextStyle(color: Colors.orange, fontSize: 12)),
            ],
          ),
          centerTitle: true,
          leading: IconButton(
            icon: SvgPicture.asset(AssetsManager.exit, width: 30),
            onPressed: _handleExit,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Text("Progress", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: currentLevel / totalLevels,
                      backgroundColor: Colors.grey[200],
                      color: Colors.orange,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text("$currentLevel/$totalLevels", style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: displayImages.map((image) {
                      bool isThisSelected = selectedImage == image;
                      return GestureDetector(
                        onTap: () => _onItemTap(image),
                        child: AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            double offset = (isError && isThisSelected) ? _shakeAnimation.value : 0;
                            return Transform.translate(offset: Offset(offset, 0), child: child);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isThisSelected
                                  ? (isCorrect ? Colors.green.withOpacity(0.2) : (isError ? Colors.red.withOpacity(0.2) : Colors.transparent))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isThisSelected
                                    ? (isCorrect ? Colors.green : (isError ? Colors.red : Colors.transparent))
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Image.asset(image, width: 60, height: 60),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 50, top: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Find this item:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  const SizedBox(height: 10),
                  Image.asset(targetImage, width: 80, height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
