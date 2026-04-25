import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/api_constants.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import '../../utils/routes_manager.dart';

class ShapeModel {
  final String id;
  final IconData icon;
  final Color color;
  bool isMatched;
  ShapeModel({required this.id, required this.icon, required this.color, this.isMatched = false});
}

class ShapeGameScreen extends StatefulWidget {
  const ShapeGameScreen({super.key});

  @override
  State<ShapeGameScreen> createState() => _ShapeGameScreenState();
}

class _ShapeGameScreenState extends State<ShapeGameScreen> with TickerProviderStateMixin {
  int level = 1;
  final int maxLevels = 15;
  int sessionId = 0;
  DateTime? startTime;
  int errorsInLevel = 0;

  List<ShapeModel> shapes = [];
  List<ShapeModel> targets = [];

  late AnimationController successController;
  late Animation<double> scaleAnim;
  late AnimationController confettiController;

  @override
  void initState() {
    super.initState();
    successController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: successController, curve: Curves.easeInOutBack));
    confettiController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    
    _startSession();
    generateLevel();
  }

  Future<void> _startSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse(ApiConstants.sessionStart),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: {'game_id': '4', 'level': level.toString(), 'difficulty_level': 'Medium'},
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
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: {
          'trial_number': level.toString(),
          'task_type': 'ShapeMatching',
          'difficulty_level': 'Medium',
          'target_type': 'Shape',
          'stimulus_count': targets.length.toString(),
          'reaction_time_ms': (duration * 1000).toString(),
          'correct': correct ? '1' : '0',
          'errors': errorsInLevel.toString(),
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
      await http.post(Uri.parse(ApiConstants.sessionEnd(sessionId)),
          headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    } catch (e) {}
  }

  void generateLevel() {
    shapes.clear();
    targets.clear();
    errorsInLevel = 0;
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
  }

  void checkMatch(ShapeModel dragged, ShapeModel target) {
    if (dragged.id == target.id) {
      HapticFeedback.mediumImpact();
      successController.forward(from: 0);
      setState(() { target.isMatched = true; });
      if (targets.every((t) => t.isMatched)) {
        _submitTrial(true);
        if (level >= maxLevels) {
          confettiController.forward(from: 0);
          _endSession();
          _showFinishDialog();
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() { level++; generateLevel(); startTime = DateTime.now(); });
            }
          });
        }
      }
    } else {
      HapticFeedback.vibrate();
      setState(() { errorsInLevel++; });
      _submitTrial(false);
    }
  }

  void _showFinishDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
      title: const Text("🎉 15 Levels Completed!", textAlign: TextAlign.center),
      content: const Text("Great Job! Your progress has been sent for analysis.", textAlign: TextAlign.center),
      actions: [Center(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: ColorManager.pinkk, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))), onPressed: () => context.go(RoutesManager.kHomeScreen), child: const Text("Finish Game", style: TextStyle(color: Colors.white))))],
    ));
  }

  @override
  void dispose() {
    successController.dispose();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: ColorManager.orange, size: 28.sp), onPressed: () => Navigator.pop(context)),
        title: Text("LEVEL $level / $maxLevels", style: TextStyle(color: Colors.orange, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
              itemCount: targets.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 25.w, crossAxisSpacing: 25.w, childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final target = targets[index];
                return DragTarget<ShapeModel>(
                  onWillAccept: (data) => data?.id == target.id,
                  onAccept: (data) => checkMatch(data, target),
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
                          ? ScaleTransition(scale: scaleAnim, child: Icon(Icons.check_circle, color: Colors.green, size: 55.sp)) 
                          : Icon(target.icon, color: Colors.brown.withOpacity(0.1), size: 65.sp),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(45.r)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -10))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: shapes.where((s) => !targets.firstWhere((t) => t.id == s.id).isMatched).map((shape) => Draggable<ShapeModel>(
                data: shape, 
                feedback: Material(color: Colors.transparent, child: Icon(shape.icon, color: shape.color, size: 85.sp)), 
                childWhenDragging: Opacity(opacity: 0.1, child: Icon(shape.icon, color: shape.color, size: 75.sp)), 
                child: Icon(shape.icon, color: shape.color, size: 75.sp),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
