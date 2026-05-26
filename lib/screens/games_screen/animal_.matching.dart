import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:kids_app_grad/server/game_session_service.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class LionPiece {
  final int id;
  final String image;
  bool isMatched;
  LionPiece({required this.id, required this.image, this.isMatched = false});
}

class DuckPiece {
  final int id;
  final String image;
  bool isMatched;
  DuckPiece({required this.id, required this.image, this.isMatched = false});
}

class BeePiece {
  final int id;
  final String image;
  bool isMatched;
  BeePiece({required this.id, required this.image, this.isMatched = false});
}

class TurtlePiece {
  final int id;
  final String image;
  bool isMatched;
  TurtlePiece({required this.id, required this.image, this.isMatched = false});
}

class RabbitPiece {
  final int id;
  final String image;
  RabbitPiece({required this.id, required this.image});
}

class MekkyPiece {
  final int id;
  final String image;
  bool isMatched;
  MekkyPiece({required this.id, required this.image, this.isMatched = false});
}

class AnimalMatching extends StatefulWidget {
  const AnimalMatching({super.key});

  @override
  State<AnimalMatching> createState() => _AnimalMatchingState();
}

class _AnimalMatchingState extends State<AnimalMatching> {
  static const String _gameSlug = 'animal-match';
  static const int _totalStages = 8;

  final List<int> mekkyCorrectOrder = [1, 8, 5, 7, 2, 4, 6, 3];
  final Map<int, int> _rabbitSolution = {
    0: 2,
    1: 9,
    2: 6,
    3: 5,
    4: 7,
    5: 4,
    6: 8,
    7: 1,
    8: 3,
  };

  int gameState = 0;

  Offset? startPoint;
  Offset? currentPoint;
  String? selectedId;
  List<Map<String, Offset>> lines = [];

  final List<LionPiece> _lionBase = [
    LionPiece(id: 1, image: "assets/images/lion1.png"),
    LionPiece(id: 2, image: "assets/images/lion2.png"),
    LionPiece(id: 3, image: "assets/images/lion3.png"),
    LionPiece(id: 4, image: "assets/images/lion4.png"),
  ];

  final List<DuckPiece> _duckBase = [
    DuckPiece(id: 1, image: "assets/images/duck1.png"),
    DuckPiece(id: 2, image: "assets/images/duck2.png"),
    DuckPiece(id: 3, image: "assets/images/duck3.png"),
  ];

  final List<BeePiece> _beeBase = [
    BeePiece(id: 1, image: "assets/images/beee1.png"),
    BeePiece(id: 2, image: "assets/images/beee2.png"),
    BeePiece(id: 3, image: "assets/images/beee3.png"),
    BeePiece(id: 4, image: "assets/images/beee4.png"),
  ];

  final List<TurtlePiece> _turtleBase = [
    TurtlePiece(id: 1, image: "assets/images/trtt1.png"),
    TurtlePiece(id: 2, image: "assets/images/trtt2.png"),
    TurtlePiece(id: 3, image: "assets/images/trtt3.png"),
    TurtlePiece(id: 4, image: "assets/images/trtt4.png"),
  ];

  final List<RabbitPiece> _rabbitBase = List.generate(
    9,
        (i) => RabbitPiece(
      id: i + 1,
      image: (i + 1) == 4
          ? "assets/images/rabbit4.png"
          : "assets/images/rabbit${i + 1}.png",
    ),
  );

  final List<MekkyPiece> _mekkyBase = List.generate(
    8,
        (i) => MekkyPiece(id: i + 1, image: "assets/images/mekky${i + 1}.png"),
  );

  List<LionPiece> draggablePieces = [];
  List<DuckPiece> draggableDucks = [];
  List<BeePiece> draggableBees = [];
  List<TurtlePiece> draggableTurtles = [];
  List<RabbitPiece> draggableRabbits = [];
  List<MekkyPiece> draggableMekkies = [];

  Map<int, int?> rabbitSlotContents = {};
  Map<int, int?> mekkySlotContents = {};

  int matchedCount = 0;
  int duckMatchedCount = 0;
  int beeMatchedCount = 0;
  int turtleMatchedCount = 0;
  int rabbitMatchedCount = 0;
  int mekkyMatchedCount = 0;

  int sessionId = 0;
  DateTime? startTime;
  int totalTrials = 0;
  int correctTrials = 0;
  bool isEnding = false;
  final GlobalKey _gameKey = GlobalKey();

  bool _isSessionReady = false;
  bool _isSessionStarting = false;
  String? _sessionError;

  Map<String, String> matchesG1 = {
    "0": "2",
    "1": "5",
    "2": "0",
    "3": "1",
    "4": "3",
    "5": "4",
  };

  Map<String, String> matchesG2 = {
    "0": "3",
    "1": "0",
    "2": "1",
    "3": "4",
    "4": "2",
  };

  @override
  void initState() {
    super.initState();
    _initLevel();
    _startSession();
  }

  @override
  void dispose() {
    if (sessionId != 0 && !isEnding) {
      final double accuracy =
      totalTrials > 0 ? (correctTrials / totalTrials) * 100 : 0;
      int stars = 0;
      if (accuracy >= 90) {
        stars = 3;
      } else if (accuracy >= 70) {
        stars = 2;
      } else if (accuracy >= 50) {
        stars = 1;
      }

      GameSessionService()
          .endSession(
        sessionId: sessionId,
        score: _currentScore,
        maxScore: _totalStages,
        stars: stars,
        resultPayload: {
          "completed_level": _currentScore,
          "game_slug": _gameSlug,
          "accuracy": accuracy,
        },
      )
          .catchError((error, stackTrace) {
        _log('dispose endSession failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      });
    }
    super.dispose();
  }

  void _log(String message) {
    debugPrint('[AnimalMatching] $message');
  }

  String _getRabbitImg(int id) =>
      id == 4 ? "assets/images/rabbit4.png" : "assets/images/rabbit$id.png";

  int get _currentLevel => gameState + 1;

  int get _currentScore => gameState.clamp(0, _totalStages);

  String get _currentStageKey {
    switch (gameState) {
      case 0:
        return "connect_6";
      case 1:
        return "lion";
      case 2:
        return "connect_5";
      case 3:
        return "duck";
      case 4:
        return "bee";
      case 5:
        return "turtle";
      case 6:
        return "rabbit";
      case 7:
        return "mekky";
      default:
        return "animal_match";
    }
  }

  String get _currentUiType {
    switch (gameState) {
      case 0:
      case 2:
        return "line_matching";
      case 6:
      case 7:
        return "drag_grid_puzzle";
      default:
        return "drag_and_drop";
    }
  }

  String _trialValue(String label, int id) =>
      "${_currentStageKey}_${label}_$id";

  void _initLevel() {
    setState(() {
      lines.clear();
      startPoint = null;
      currentPoint = null;
      selectedId = null;

      if (gameState == 1) {
        draggablePieces = List.from(_lionBase)..shuffle();
        for (var p in _lionBase) {
          p.isMatched = false;
        }
        matchedCount = 0;
      } else if (gameState == 3) {
        draggableDucks = List.from(_duckBase)..shuffle();
        for (var d in _duckBase) {
          d.isMatched = false;
        }
        duckMatchedCount = 0;
      } else if (gameState == 4) {
        draggableBees = List.from(_beeBase)..shuffle();
        for (var b in _beeBase) {
          b.isMatched = false;
        }
        beeMatchedCount = 0;
      } else if (gameState == 5) {
        draggableTurtles = List.from(_turtleBase)..shuffle();
        for (var t in _turtleBase) {
          t.isMatched = false;
        }
        turtleMatchedCount = 0;
      } else if (gameState == 6) {
        draggableRabbits = List.from(_rabbitBase)..shuffle();
        rabbitSlotContents = Map.fromIterable(
          List.generate(9, (i) => i),
          value: (_) => null,
        );
        rabbitMatchedCount = 0;
      } else if (gameState == 7) {
        draggableMekkies = List.from(_mekkyBase)..shuffle();
        mekkySlotContents = Map.fromIterable(
          List.generate(8, (i) => i),
          value: (_) => null,
        );
        mekkyMatchedCount = 0;
      }

      startTime = DateTime.now();
    });
  }

  Future<void> _startSession() async {
    if (_isSessionStarting) return;

    setState(() {
      _isSessionStarting = true;
      _isSessionReady = false;
      _sessionError = null;
    });

    try {
      _log('Starting session for $_gameSlug');
      final id = await GameSessionService().startSessionBySlug(
        gameSlug: _gameSlug,
        level: 1,
        difficulty: 'Medium',
      );

      if (!mounted) return;

      if (id == null) {
        _log('startSessionBySlug returned null');
        setState(() {
          _sessionError = 'Failed to start session';
        });
        return;
      }

      setState(() {
        sessionId = id;
        startTime = DateTime.now();
        _isSessionReady = true;
      });

      _log('Session started successfully. sessionId=$sessionId');
    } catch (e, st) {
      _log('Session start failed: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;
      setState(() {
        _sessionError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSessionStarting = false;
        });
      }
    }
  }

  Future<void> _submitTrial({
    required bool correct,
    required String promptValue,
    required String selectedValue,
    required int stimulusCount,
  }) async {
    if (!_isSessionReady || sessionId == 0 || startTime == null) {
      _log(
        'Skipping trial because session is not ready. '
            'sessionId=$sessionId, isReady=$_isSessionReady, startTime=$startTime',
      );
      return;
    }

    totalTrials++;
    if (correct) {
      correctTrials++;
    }

    final durationMs = DateTime.now().difference(startTime!).inMilliseconds;

    try {
      _log(
        'Submitting trial #$totalTrials: '
            'correct=$correct, prompt=$promptValue, selected=$selectedValue',
      );

      await GameSessionService().submitTrial(
        sessionId: sessionId,
        trialNumber: totalTrials,
        taskType: "Matching",
        targetType: "Animal",
        promptValue: promptValue,
        selectedValue: selectedValue,
        stimulusCount: stimulusCount,
        reactionTimeMs: durationMs,
        correct: correct,
        errors: correct ? 0 : 1,
        missedTargets: 0,
        durationSec: durationMs ~/ 1000,
        metadata: {
          "level": _currentLevel,
          "ui_type": _currentUiType,
          "game_slug": _gameSlug,
          "stage": _currentStageKey,
        },
      );

      _log('Trial submitted successfully');
      startTime = DateTime.now();
    } catch (e, st) {
      _log('submitTrial failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _endSession({
    bool showResultDialog = false,
    int? scoreOverride,
  }) async {
    if (sessionId == 0 || isEnding) {
      _log('Skipping endSession. sessionId=$sessionId, isEnding=$isEnding');
      return;
    }

    isEnding = true;

    final score = (scoreOverride ?? _currentScore).clamp(0, _totalStages);
    final double accuracy =
    totalTrials > 0 ? (correctTrials / totalTrials) * 100 : 0;
    int stars = 0;
    if (accuracy >= 90) {
      stars = 3;
    } else if (accuracy >= 70) {
      stars = 2;
    } else if (accuracy >= 50) {
      stars = 1;
    }

    try {
      _log('Ending session $sessionId with score=$score, accuracy=$accuracy');

      final response = await GameSessionService().endSession(
        sessionId: sessionId,
        score: score,
        maxScore: _totalStages,
        stars: stars,
        resultPayload: {
          "completed_level": score,
          "game_slug": _gameSlug,
          "accuracy": accuracy,
        },
      );

      if (!mounted) return;

      setState(() {
        sessionId = 0;
        _isSessionReady = false;
      });

      if (showResultDialog) {
        _showFinishDialog(stars: stars, summary: response);
      }
    } catch (e, st) {
      _log('endSession failed: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      isEnding = false;
    }
  }

  Future<void> _handleExit() async {
    if (!isEnding) {
      await _endSession(scoreOverride: _currentScore);
    }
    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(RoutesManager.kHomeScreen);
    }
  }

  void _goToNextStage() {
    if (!mounted) return;
    setState(() {
      gameState++;
    });
    _initLevel();
  }

  @override
  Widget build(BuildContext context) {
    String gameTitle = "Animal Match";
    if (gameState == 1) gameTitle = "Lion Game";
    if (gameState == 3) gameTitle = "Duck Puzzle";
    if (gameState == 4) gameTitle = "Bee Puzzle";
    if (gameState == 5) gameTitle = "Turtle Puzzle";
    if (gameState == 6) gameTitle = "Rabbit Puzzle";
    if (gameState == 7) gameTitle = "Mickey Puzzle";

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
          toolbarHeight: 70.h,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.orange, size: 24.sp),
            onPressed: _handleExit,
          ),
          title: Text(
            gameTitle,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(
                  Icons.star_outline,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            IgnorePointer(
              ignoring: !_isSessionReady,
              child: _buildCurrentGame(),
            ),
            if (!_isSessionReady) _buildSessionOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.92),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSessionStarting) ...[
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text(
                    'Preparing game session...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Icon(Icons.wifi_off_rounded, color: Colors.red, size: 42.sp),
                  SizedBox(height: 12.h),
                  Text(
                    'Failed to start game session',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _sessionError ?? 'Please try again.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _startSession,
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentGame() {
    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: gameState == 0
              ? _buildLineMatching(6, "assets/images/connect_gam.png", matchesG1)
              : (gameState == 1
              ? _buildLionPuzzle()
              : (gameState == 2
              ? _buildLineMatching(
            5,
            "assets/images/connect_gam2.png",
            matchesG2,
          )
              : (gameState == 3
              ? _buildDuckPuzzle()
              : (gameState == 4
              ? _buildBeePuzzle()
              : (gameState == 5
              ? _buildTurtlePuzzle()
              : (gameState == 6
              ? _buildRabbitPuzzle()
              : _buildMekkyPuzzle())))))),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    int total = [6, 4, 5, 3, 4, 4, 9, 8][gameState];
    int current = [
      lines.length,
      matchedCount,
      lines.length,
      duckMatchedCount,
      beeMatchedCount,
      turtleMatchedCount,
      rabbitSlotContents.values.where((v) => v != null).length,
      mekkyMatchedCount,
    ][gameState];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
      child: LinearProgressIndicator(
        value: current / total,
        backgroundColor: Colors.grey.shade200,
        color: Colors.orange,
        minHeight: 8.h,
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }

  Widget _buildLineMatching(
      int count,
      String bgImage,
      Map<String, String> currentMatches,
      ) {
    List<Offset> leftPoints = count == 6
        ? List.generate(6, (i) => Offset(55.w, 70.h * i + 65.h))
        : List.generate(5, (i) => Offset(60.w, 85.h * i + 75.h));

    List<Offset> rightPoints = count == 6
        ? List.generate(6, (i) => Offset(285.w, 70.h * i + 65.h))
        : List.generate(5, (i) => Offset(280.w, 85.h * i + 75.h));

    return Center(
      child: Container(
        height: 480.h,
        width: 340.w,
        key: _gameKey,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage(bgImage),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: ArrowPainter(lines, startPoint, currentPoint),
            ),
            GestureDetector(
              onPanStart: (details) {
                final box =
                _gameKey.currentContext!.findRenderObject() as RenderBox;
                final pos = box.globalToLocal(details.globalPosition);

                for (int i = 0; i < leftPoints.length; i++) {
                  if ((pos - leftPoints[i]).distance < 60) {
                    if (!lines.any((l) => l["start"] == leftPoints[i])) {
                      setState(() {
                        selectedId = "$i";
                        startPoint = leftPoints[i];
                        currentPoint = leftPoints[i];
                      });
                    }
                    break;
                  }
                }
              },
              onPanUpdate: (details) {
                if (startPoint == null) return;
                final box =
                _gameKey.currentContext!.findRenderObject() as RenderBox;
                setState(() {
                  currentPoint = box.globalToLocal(details.globalPosition);
                });
              },
              onPanEnd: (details) {
                if (selectedId == null || startPoint == null || currentPoint == null) {
                  return;
                }

                Offset? snapPoint;
                int? snapIndex;
                final expectedIndex = int.parse(currentMatches[selectedId!]!);

                for (int i = 0; i < rightPoints.length; i++) {
                  if ((currentPoint! - rightPoints[i]).distance < 70) {
                    snapPoint = rightPoints[i];
                    snapIndex = i;
                    break;
                  }
                }

                if (snapPoint != null &&
                    currentMatches[selectedId!] == "$snapIndex") {
                  setState(() {
                    lines.add({"start": startPoint!, "end": snapPoint!});
                  });

                  _submitTrial(
                    correct: true,
                    promptValue: _trialValue("target", expectedIndex + 1),
                    selectedValue: _trialValue("target", snapIndex! + 1),
                    stimulusCount: count * 2,
                  );

                  if (lines.length == currentMatches.length) {
                    Future.delayed(const Duration(seconds: 1), () {
                      _goToNextStage();
                    });
                  }
                } else if (snapPoint != null) {
                  _submitTrial(
                    correct: false,
                    promptValue: _trialValue("target", expectedIndex + 1),
                    selectedValue: _trialValue("target", snapIndex! + 1),
                    stimulusCount: count * 2,
                  );
                }

                setState(() {
                  startPoint = null;
                  currentPoint = null;
                  selectedId = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLionPuzzle() {
    return Column(
      children: [
        SizedBox(height: 30.h),
        Center(
          child: Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.brown.shade100, width: 2),
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/lion.png",
                    fit: BoxFit.contain,
                  ),
                ),
                _buildLionDropTarget(3, 35.w, 35.h),
                _buildLionDropTarget(1, 165.w, 35.h),
                _buildLionDropTarget(4, 35.w, 165.h),
                _buildLionDropTarget(2, 165.w, 165.h),
              ],
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 150.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: draggablePieces
                .map(
                  (p) => Draggable<int>(
                data: p.id,
                feedback: Image.asset(p.image, width: 90.w),
                childWhenDragging: Opacity(
                  opacity: 0.1,
                  child: Image.asset(p.image, width: 75.w),
                ),
                child: Image.asset(p.image, width: 75.w),
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLionDropTarget(int id, double left, double top) {
    var piece = _lionBase.firstWhere((p) => p.id == id);

    return Positioned(
      left: left,
      top: top,
      child: DragTarget<int>(
        onWillAccept: (data) => !piece.isMatched,
        onAccept: (receivedId) {
          final isCorrect = receivedId == id;

          _submitTrial(
            correct: isCorrect,
            promptValue: _trialValue("piece", id),
            selectedValue: _trialValue("piece", receivedId),
            stimulusCount: _lionBase.length,
          );

          if (isCorrect) {
            setState(() {
              piece.isMatched = true;
              draggablePieces.removeWhere((p) => p.id == id);
              matchedCount++;
            });

            if (matchedCount == 4) {
              Future.delayed(const Duration(seconds: 1), () {
                if (!mounted) return;
                setState(() {
                  gameState = 2;
                });
                _initLevel();
              });
            }
          }
        },
        builder: (context, candidateData, _) {
          bool isHover = candidateData.isNotEmpty;
          return Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: piece.isMatched
                  ? Colors.transparent
                  : (isHover
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05)),
              shape: BoxShape.circle,
            ),
            child: piece.isMatched
                ? Center(child: Image.asset(piece.image, width: 85.w))
                : null,
          );
        },
      ),
    );
  }

  Widget _buildDuckPuzzle() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20.w, bottom: 5.h),
            child: Image.asset(
              "assets/images/duck.png",
              width: 80.w,
              height: 80.h,
            ),
          ),
        ),
        Center(
          child: Container(
            width: 320.w,
            height: 350.h,
            decoration: BoxDecoration(
              color: const Color(0xffEFE9DB),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.brown.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDuckDropTarget(2),
                _buildDuckDropTarget(1),
                _buildDuckDropTarget(3),
              ],
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 140.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: draggableDucks
                  .map(
                    (duck) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Draggable<int>(
                    data: duck.id,
                    feedback: Image.asset(
                      duck.image,
                      width: 220.w,
                      height: 60.h,
                      fit: BoxFit.contain,
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        duck.image,
                        width: 180.w,
                        height: 50.h,
                      ),
                    ),
                    child: Image.asset(
                      duck.image,
                      width: 180.w,
                      height: 50.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDuckDropTarget(int id) {
    var piece = _duckBase.firstWhere((p) => p.id == id);

    return DragTarget<int>(
      onWillAccept: (data) => !piece.isMatched,
      onAccept: (receivedId) {
        final isCorrect = receivedId == id;

        _submitTrial(
          correct: isCorrect,
          promptValue: _trialValue("piece", id),
          selectedValue: _trialValue("piece", receivedId),
          stimulusCount: _duckBase.length,
        );

        if (isCorrect) {
          setState(() {
            piece.isMatched = true;
            draggableDucks.removeWhere((p) => p.id == id);
            duckMatchedCount++;
          });

          if (duckMatchedCount == 3) {
            Future.delayed(const Duration(seconds: 1), () {
              if (!mounted) return;
              setState(() {
                gameState = 4;
              });
              _initLevel();
            });
          }
        }
      },
      builder: (context, candidateData, _) {
        bool isHover = candidateData.isNotEmpty;
        return Container(
          width: 290.w,
          height: 85.h,
          decoration: BoxDecoration(
            color: piece.isMatched
                ? Colors.white
                : (isHover
                ? Colors.yellow.withOpacity(0.1)
                : Colors.white.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isHover ? Colors.orange : Colors.grey.withOpacity(0.1),
            ),
          ),
          child: piece.isMatched
              ? Image.asset(piece.image, fit: BoxFit.contain)
              : null,
        );
      },
    );
  }

  Widget _buildBeePuzzle() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 30.w, bottom: 5.h),
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                image: const DecorationImage(
                  image: AssetImage("assets/images/beee.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: DottedBorder(
            color: Colors.brown.withOpacity(0.3),
            strokeWidth: 2,
            dashPattern: const [6, 3],
            borderType: BorderType.RRect,
            radius: Radius.circular(20.r),
            child: Container(
              width: 280.w,
              height: 280.h,
              color: const Color(0xffFDFBF7),
              padding: EdgeInsets.all(10.w),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10.w,
                crossAxisSpacing: 10.w,
                children: [
                  _buildBeeDropTarget(3),
                  _buildBeeDropTarget(2),
                  _buildBeeDropTarget(1),
                  _buildBeeDropTarget(4),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 150.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35.r)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: draggableBees
                .map(
                  (bee) => Draggable<int>(
                data: bee.id,
                feedback: Image.asset(bee.image, width: 90.w, height: 90.h),
                childWhenDragging: Opacity(
                  opacity: 0.1,
                  child: Image.asset(bee.image, width: 60.w, height: 60.h),
                ),
                child: Image.asset(
                  bee.image,
                  width: 60.w,
                  height: 60.h,
                  fit: BoxFit.contain,
                ),
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBeeDropTarget(int id) {
    var piece = _beeBase.firstWhere((p) => p.id == id);

    return DragTarget<int>(
      onWillAccept: (data) => !piece.isMatched,
      onAccept: (receivedId) {
        final isCorrect = receivedId == id;

        _submitTrial(
          correct: isCorrect,
          promptValue: _trialValue("piece", id),
          selectedValue: _trialValue("piece", receivedId),
          stimulusCount: _beeBase.length,
        );

        if (isCorrect) {
          setState(() {
            piece.isMatched = true;
            draggableBees.removeWhere((p) => p.id == id);
            beeMatchedCount++;
          });

          if (beeMatchedCount == 4) {
            Future.delayed(const Duration(seconds: 1), () {
              if (!mounted) return;
              setState(() {
                gameState = 5;
              });
              _initLevel();
            });
          }
        }
      },
      builder: (context, candidateData, _) {
        bool isHover = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: piece.isMatched
                ? Colors.white
                : (isHover
                ? Colors.blue.withOpacity(0.1)
                : Colors.black.withOpacity(0.02)),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: isHover ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: piece.isMatched
              ? ClipRRect(
            borderRadius: BorderRadius.circular(13.r),
            child: Image.asset(piece.image, fit: BoxFit.cover),
          )
              : null,
        );
      },
    );
  }

  Widget _buildTurtlePuzzle() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 30.w, bottom: 5.h),
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
                image: const DecorationImage(
                  image: AssetImage("assets/images/trtt.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: DottedBorder(
            color: Colors.green.withOpacity(0.3),
            strokeWidth: 2,
            dashPattern: const [6, 3],
            borderType: BorderType.RRect,
            radius: Radius.circular(20.r),
            child: Container(
              width: 280.w,
              height: 280.h,
              color: const Color(0xffFDFBF7),
              padding: EdgeInsets.all(10.w),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10.w,
                crossAxisSpacing: 10.w,
                children: [
                  _buildTurtleDropTarget(2),
                  _buildTurtleDropTarget(1),
                  _buildTurtleDropTarget(3),
                  _buildTurtleDropTarget(4),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 150.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35.r)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: draggableTurtles
                .map(
                  (turtle) => Draggable<int>(
                data: turtle.id,
                feedback: Image.asset(
                  turtle.image,
                  width: 90.w,
                  height: 90.h,
                ),
                childWhenDragging: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    turtle.image,
                    width: 60.w,
                    height: 60.h,
                  ),
                ),
                child: Image.asset(
                  turtle.image,
                  width: 60.w,
                  height: 60.h,
                  fit: BoxFit.contain,
                ),
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTurtleDropTarget(int id) {
    var piece = _turtleBase.firstWhere((p) => p.id == id);

    return DragTarget<int>(
      onWillAccept: (data) => !piece.isMatched,
      onAccept: (receivedId) {
        final isCorrect = receivedId == id;

        _submitTrial(
          correct: isCorrect,
          promptValue: _trialValue("piece", id),
          selectedValue: _trialValue("piece", receivedId),
          stimulusCount: _turtleBase.length,
        );

        if (isCorrect) {
          setState(() {
            piece.isMatched = true;
            draggableTurtles.removeWhere((p) => p.id == id);
            turtleMatchedCount++;
          });

          if (turtleMatchedCount == 4) {
            Future.delayed(const Duration(seconds: 1), () {
              if (!mounted) return;
              setState(() {
                gameState = 6;
              });
              _initLevel();
            });
          }
        }
      },
      builder: (context, candidateData, _) {
        bool isHover = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: piece.isMatched
                ? Colors.white
                : (isHover
                ? Colors.green.withOpacity(0.1)
                : Colors.black.withOpacity(0.02)),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: isHover ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: piece.isMatched
              ? ClipRRect(
            borderRadius: BorderRadius.circular(13.r),
            child: Image.asset(piece.image, fit: BoxFit.cover),
          )
              : null,
        );
      },
    );
  }

  Widget _buildRabbitPuzzle() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 30.w, bottom: 5.h),
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.pink.withOpacity(0.3)),
                image: const DecorationImage(
                  image: AssetImage("assets/images/rabbit.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: DottedBorder(
            color: Colors.pink.withOpacity(0.3),
            strokeWidth: 2,
            dashPattern: const [6, 3],
            borderType: BorderType.RRect,
            radius: Radius.circular(20.r),
            child: Container(
              width: 320.w,
              height: 320.w,
              color: const Color(0xffFDFBF7),
              child: GridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: 3,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: 1.0,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                  9,
                      (i) => _buildRabbitDropTarget(i),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 140.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35.r)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: draggableRabbits
                  .map(
                    (piece) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Draggable<int>(
                    data: piece.id,
                    feedback: Image.asset(
                      piece.image,
                      width: 80.w,
                      height: 80.h,
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.1,
                      child: Image.asset(piece.image, width: 70.w),
                    ),
                    child: Image.asset(
                      piece.image,
                      width: 70.w,
                      height: 70.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRabbitDropTarget(int slotIndex) {
    int? pieceId = rabbitSlotContents[slotIndex];

    return DragTarget<int>(
      onWillAccept: (data) => pieceId == null,
      onAccept: (receivedPieceId) {
        setState(() {
          rabbitSlotContents[slotIndex] = receivedPieceId;
          draggableRabbits.removeWhere((p) => p.id == receivedPieceId);
        });
        _checkRabbitWin();
      },
      builder: (context, candidateData, _) {
        bool isHover = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: pieceId != null
                ? Colors.white
                : (isHover
                ? Colors.pink.withOpacity(0.1)
                : Colors.black.withOpacity(0.02)),
            border: Border.all(
              color: isHover ? Colors.pink : Colors.grey.withOpacity(0.05),
            ),
          ),
          child: pieceId != null
              ? Draggable<int>(
            data: pieceId,
            onDragCompleted: () {
              setState(() {
                rabbitSlotContents[slotIndex] = null;
              });
            },
            feedback: Image.asset(_getRabbitImg(pieceId), width: 80.w),
            child: Image.asset(_getRabbitImg(pieceId), fit: BoxFit.fill),
          )
              : null,
        );
      },
    );
  }

  void _checkRabbitWin() {
    if (rabbitSlotContents.values.where((v) => v != null).length == 9) {
      bool isCorrect = true;

      _rabbitSolution.forEach((slot, pieceId) {
        if (rabbitSlotContents[slot] != pieceId) {
          isCorrect = false;
        }
      });

      _submitTrial(
        correct: isCorrect,
        promptValue: "rabbit_full_board",
        selectedValue:
        isCorrect ? "rabbit_correct_board" : "rabbit_incorrect_board",
        stimulusCount: _rabbitBase.length,
      );

      if (isCorrect) {
        setState(() {
          gameState = 7;
        });
        _initLevel();
      }
    }
  }

  Widget _buildMekkyPuzzle() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 30.w, bottom: 5.h),
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                image: const DecorationImage(
                  image: AssetImage("assets/images/mekky.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: DottedBorder(
            color: Colors.blue.withOpacity(0.3),
            strokeWidth: 2,
            dashPattern: const [6, 3],
            borderType: BorderType.RRect,
            radius: Radius.circular(8.r),
            child: Container(
              width: 200,
              height: 400,
              color: const Color(0xffFDFBF7),
              child: GridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: 2,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: 1.0,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                  8,
                      (i) => _buildMekkyDropTarget(i),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 140.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35.r)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: draggableMekkies
                  .map(
                    (p) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Draggable<int>(
                    data: p.id,
                    feedback: Image.asset(
                      p.image,
                      width: 80.w,
                      height: 80.h,
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.1,
                      child: Image.asset(p.image, width: 75.w),
                    ),
                    child: Image.asset(
                      p.image,
                      width: 75.w,
                      height: 75.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMekkyDropTarget(int slotIndex) {
    int? pieceId = mekkySlotContents[slotIndex];

    return DragTarget<int>(
      onWillAccept: (data) => pieceId == null,
      onAccept: (receivedPieceId) {
        final isCorrect = receivedPieceId == mekkyCorrectOrder[slotIndex];
        bool shouldFinish = false;

        if (isCorrect) {
          setState(() {
            mekkySlotContents[slotIndex] = receivedPieceId;
            draggableMekkies.removeWhere((p) => p.id == receivedPieceId);
            mekkyMatchedCount++;
            if (mekkyMatchedCount == 8) {
              shouldFinish = true;
            }
          });
        }

        _submitTrial(
          correct: isCorrect,
          promptValue: _trialValue("slot", slotIndex + 1),
          selectedValue: _trialValue("piece", receivedPieceId),
          stimulusCount: _mekkyBase.length,
        );

        if (shouldFinish) {
          _endSession(showResultDialog: true, scoreOverride: _totalStages);
        }
      },
      builder: (context, candidateData, _) {
        bool isHover = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: pieceId != null
                ? Colors.white
                : (isHover
                ? Colors.blue.withOpacity(0.1)
                : Colors.black.withOpacity(0.02)),
            border: Border.all(
              color: isHover ? Colors.blue : Colors.grey.withOpacity(0.05),
            ),
          ),
          child: pieceId != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.asset(
              "assets/images/mekky$pieceId.png",
              fit: BoxFit.fill,
            ),
          )
              : null,
        );
      },
    );
  }

  void _showFinishDialog({required int stars, Map<String, dynamic>? summary}) {
    final stats = summary?['stats'] ?? {};
    final avgAccuracy =
        double.tryParse(stats['avg_accuracy']?.toString() ?? '100') ?? 100.0;
    final recentAvgAccuracy = double.tryParse(
      stats['recent_avg_accuracy']?.toString() ?? '100',
    ) ??
        100.0;
    final latestAccuracy =
        double.tryParse(stats['latest_accuracy']?.toString() ?? '100') ?? 100.0;

    bool showWeakness =
        avgAccuracy < 60 || recentAvgAccuracy < 60 || latestAccuracy < 50;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: showWeakness ? const Color(0xffFFF5F5) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
          side: BorderSide(
            color: showWeakness ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        title: Column(
          children: [
            if (showWeakness)
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 50.sp,
              ),
            SizedBox(height: 10.h),
            Text(
              showWeakness ? "Attention Needed" : "Excellent Job!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: showWeakness ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22.sp,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (i) => Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 45.sp,
                ),
              ),
            ),
            if (showWeakness) ...[
              SizedBox(height: 25.h),
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Possible Visual Perception Weakness",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Low accuracy may indicate visual perception weakness. We recommend visiting a doctor or specialist for a proper evaluation.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.red.shade900,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  showWeakness ? Colors.red : ColorManager.pinkk,
                  padding:
                  EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                onPressed: () => context.go(RoutesManager.kHomeScreen),
                child: Text(
                  "Finish",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final List<Map<String, Offset>> lines;
  final Offset? liveStart;
  final Offset? liveEnd;

  ArrowPainter(this.lines, this.liveStart, this.liveEnd);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorManager.pinkk
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    for (var line in lines) {
      canvas.drawLine(line["start"]!, line["end"]!, paint);
    }

    if (liveStart != null && liveEnd != null) {
      canvas.drawLine(
        liveStart!,
        liveEnd!,
        paint..color = Colors.grey.withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}