import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:kids_app_grad/utils/api_constants.dart';
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

class MatchShapes extends StatefulWidget {
  const MatchShapes({super.key});

  @override
  State<MatchShapes> createState() => _MatchShapesState();
}

class _MatchShapesState extends State<MatchShapes> {
  final List<int> mekkyCorrectOrder = [
    1, 8,
    5, 7,
    2, 4,
    6, 3
  ];

  int gameState =
      0; // 0: Match 6, 1: Lion, 2: Match 5, 3: Duck, 4: Bee, 5: Turtle, 6: Rabbit, 7: Mickey

  Offset? startPoint;
  Offset? currentPoint;
  String? selectedId;
  List<Map<String, Offset>> lines = [];

  // Data Definitions
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

  // Active Lists
  List<LionPiece> draggablePieces = [];
  List<DuckPiece> draggableDucks = [];
  List<BeePiece> draggableBees = [];
  List<TurtlePiece> draggableTurtles = [];
  List<RabbitPiece> draggableRabbits = [];
  List<MekkyPiece> draggableMekkies = [];

  // State Maps
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
  final GlobalKey _gameKey = GlobalKey();

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

  String _getRabbitImg(int id) =>
      id == 4 ? "assets/images/rabbit4.png" : "assets/images/rabbit$id.png";

  void _initLevel() {
    setState(() {
      lines.clear();
      if (gameState == 1) {
        draggablePieces = List.from(_lionBase)..shuffle();
        for (var p in _lionBase) p.isMatched = false;
        matchedCount = 0;
      } else if (gameState == 3) {
        draggableDucks = List.from(_duckBase)..shuffle();
        for (var d in _duckBase) d.isMatched = false;
        duckMatchedCount = 0;
      } else if (gameState == 4) {
        draggableBees = List.from(_beeBase)..shuffle();
        for (var b in _beeBase) b.isMatched = false;
        beeMatchedCount = 0;
      } else if (gameState == 5) {
        draggableTurtles = List.from(_turtleBase)..shuffle();
        for (var t in _turtleBase) t.isMatched = false;
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
    });
  }

  Future<void> _startSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      int gameId = gameState + 2;
      final response = await http.post(
        Uri.parse(ApiConstants.sessionStart),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'game_id': gameId.toString(),
          'level': '1',
          'difficulty_level': 'Medium',
        },
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        sessionId = data['session']['id'];
        startTime = DateTime.now();
      }
    } catch (e) {}
  }

  Future<void> _submitTrial(bool correct) async {
    if (sessionId == 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      int duration = DateTime.now().difference(startTime!).inSeconds;
      await http.post(
        Uri.parse(ApiConstants.sessionTrial(sessionId)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'trial_number': '1',
          'task_type': 'Matching',
          'difficulty_level': 'Medium',
          'target_type': 'Shape',
          'stimulus_count': '10',
          'reaction_time_ms': (duration * 1000).toString(),
          'correct': correct ? '1' : '0',
          'errors': correct ? '0' : '1',
          'missed_targets': '0',
          'duration_sec': duration.toString(),
        },
      );
    } catch (e) {}
  }

  Future<void> _endSession() async {
    if (sessionId == 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      await http.post(
        Uri.parse(ApiConstants.sessionEnd(sessionId)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    String gameTitle = "Shape Matcher";
    if (gameState == 1) gameTitle = "Lion Game";
    if (gameState == 3) gameTitle = "Duck Puzzle";
    if (gameState == 4) gameTitle = "Bee Puzzle";
    if (gameState == 5) gameTitle = "Turtle Puzzle";
    if (gameState == 6) gameTitle = "Rabbit Puzzle";
    if (gameState == 7) gameTitle = "Mickey Puzzle";

    return Scaffold(
      backgroundColor: const Color(0xffF9F8F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70.h,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.orange, size: 24.sp),
          onPressed: () => Navigator.pop(context),
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
              child: Icon(Icons.star_outline, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
      body: _buildCurrentGame(),
    );
  }

  Widget _buildCurrentGame() {
    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: gameState == 0
              ? _buildLineMatching(
                  6,
                  "assets/images/connect_gam.png",
                  matchesG1,
                )
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
    double totalHeight = 400.h;
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
          image: DecorationImage(image: AssetImage(bgImage), fit: BoxFit.fill),
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
                if (selectedId == null || startPoint == null) return;
                Offset? snapPoint;
                int? snapIndex;
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
                  _submitTrial(true);
                  if (lines.length == currentMatches.length) {
                    Future.delayed(const Duration(seconds: 1), () {
                      _endSession();
                      setState(() {
                        gameState++;
                        _initLevel();
                        _startSession();
                      });
                    });
                  }
                } else if (snapPoint != null) {
                  _submitTrial(false);
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
        onWillAccept: (data) => data == id && !piece.isMatched,
        onAccept: (receivedId) {
          setState(() {
            piece.isMatched = true;
            draggablePieces.removeWhere((p) => p.id == id);
            matchedCount++;
          });
          _submitTrial(true);
          if (matchedCount == 4) {
            Future.delayed(const Duration(seconds: 1), () {
              _endSession();
              setState(() {
                gameState = 2;
                _initLevel();
                _startSession();
              });
            });
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
              fit: BoxFit.contain,
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
          decoration:  BoxDecoration(
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
      onWillAccept: (data) => data == id && !piece.isMatched,
      onAccept: (receivedId) {
        setState(() {
          piece.isMatched = true;
          draggableDucks.removeWhere((p) => p.id == id);
          duckMatchedCount++;
        });
        _submitTrial(true);
        if (duckMatchedCount == 3) {
          Future.delayed(const Duration(seconds: 1), () {
            _endSession();
            setState(() {
              gameState = 4;
              _initLevel();
              _startSession();
            });
          });
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
                image: DecorationImage(
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
      onWillAccept: (data) => data == id && !piece.isMatched,
      onAccept: (receivedId) {
        setState(() {
          piece.isMatched = true;
          draggableBees.removeWhere((p) => p.id == id);
          beeMatchedCount++;
        });
        _submitTrial(true);
        if (beeMatchedCount == 4) {
          Future.delayed(const Duration(seconds: 1), () {
            _endSession();
            setState(() {
              gameState = 5;
              _initLevel();
              _startSession();
            });
          });
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
                image: DecorationImage(
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
          decoration:  BoxDecoration(
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
      onWillAccept: (data) => data == id && !piece.isMatched,
      onAccept: (receivedId) {
        setState(() {
          piece.isMatched = true;
          draggableTurtles.removeWhere((p) => p.id == id);
          turtleMatchedCount++;
        });
        _submitTrial(true);
        if (turtleMatchedCount == 4) {
          Future.delayed(const Duration(seconds: 1), () {
            _endSession();
            setState(() {
              gameState = 6;
              _initLevel();
              _startSession();
            });
          });
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
                image: DecorationImage(
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
                children: List.generate(9, (i) => _buildRabbitDropTarget(i)),
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 140.h,
          decoration:  BoxDecoration(
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
          _checkRabbitWin();
        });
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
                  onDragCompleted: () =>
                      setState(() => rabbitSlotContents[slotIndex] = null),
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
      Map<int, int> solution = {
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
      bool isCorrect = true;
      solution.forEach((slot, pieceId) {
        if (rabbitSlotContents[slot] != pieceId) isCorrect = false;
      });
      if (isCorrect) {
        _submitTrial(true);
        _endSession();
        setState(() {
          gameState = 7;
          _initLevel();
          _startSession();
        });
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
              height:400  ,
              color: const Color(0xffFDFBF7),
              child: GridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: 2,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: 1.0,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(8, (i) => _buildMekkyDropTarget(i)),
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 140.h,
          decoration:  BoxDecoration(
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
        setState(() {
          if (receivedPieceId == mekkyCorrectOrder[slotIndex]) {
            mekkySlotContents[slotIndex] = receivedPieceId;
            draggableMekkies.removeWhere((p) => p.id == receivedPieceId);
            mekkyMatchedCount++;

            _submitTrial(true);

            if (mekkyMatchedCount == 8) {
              _endSession();
              _showFinishDialog();
            }
          } else {
            _submitTrial(false);
          }
        });
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
              color: isHover
                  ? Colors.blue
                  : Colors.grey.withOpacity(0.05),
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

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text("🐰 Excellent Job!", textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.pinkk,
              ),
              onPressed: () => context.go(RoutesManager.kHomeScreen),
              child: const Text(
                "Finish",
                style: TextStyle(color: Colors.white),
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
  final Offset? liveStart, liveEnd;

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
