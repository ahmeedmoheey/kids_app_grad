import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/api_constants.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class FindStar extends StatefulWidget {
  const FindStar({super.key});

  @override
  State<FindStar> createState() => _FindStarState();
}

class _FindStarState extends State<FindStar> {
  int level = 1;
  final int maxLevels = 10; // قللت المستويات لـ 10 عشان النتيجة تظهر أسرع للأب
  int sessionId = 0;
  DateTime? startTime;
  int errorsInLevel = 0;
  bool isEnding = false;

  late Offset starPos;
  final Random rnd = Random();

  @override
  void initState() {
    super.initState();
    _startSession();
    _generateStarPos();
  }

  @override
  void dispose() {
    if (sessionId != 0 && !isEnding) {
      _endSession(); // غلق الجلسة لو الطفل خرج فجأة
    }
    super.dispose();
  }

  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      context.go(RoutesManager.kWelcomeScreen);
    }
  }

  Future<void> _startSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse(ApiConstants.sessionStart),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: {'game_id': '5', 'level': level.toString(), 'difficulty_level': 'Medium'},
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        sessionId = data['session']['id'];
        startTime = DateTime.now();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {}
  }

  Future<void> _submitTrial(bool correct) async {
    if (sessionId == 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      int duration = DateTime.now().difference(startTime!).inSeconds;
      
      final response = await http.post(
        Uri.parse(ApiConstants.sessionTrial(sessionId)),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: {
          'trial_number': level.toString(),
          'task_type': 'VisualSearch',
          'difficulty_level': 'Medium',
          'target_type': 'Star',
          'stimulus_count': '1',
          'reaction_time_ms': (duration * 1000).toString(),
          'correct': correct ? '1' : '0',
          'errors': errorsInLevel.toString(),
          'missed_targets': '0',
          'duration_sec': duration.toString(),
        },
      );

      if (response.statusCode == 401) _handleUnauthorized();
    } catch (e) {}
  }

  Future<void> _endSession() async {
    if (sessionId == 0) return;
    isEnding = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      await http.post(Uri.parse(ApiConstants.sessionEnd(sessionId)),
          headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    } catch (e) {}
  }

  void _generateStarPos() {
    setState(() {
      errorsInLevel = 0;
      starPos = Offset(rnd.nextDouble() * 1.6 - 0.8, rnd.nextDouble() * 1.2 - 0.6);
    });
  }

  void _handleTap(bool isStar) {
    if (isStar) {
      HapticFeedback.mediumImpact();
      _submitTrial(true);
      if (level >= maxLevels) {
        _endSession();
        _showFinishDialog();
      } else {
        setState(() {
          level++;
          _generateStarPos();
          startTime = DateTime.now();
        });
      }
    } else {
      HapticFeedback.vibrate();
      setState(() { errorsInLevel++; });
      _submitTrial(false);
    }
  }

  void _showFinishDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("🌟 Superstar!", textAlign: TextAlign.center),
      content: Text("You found all $maxLevels stars!\nYour progress has been saved for your parents.", textAlign: TextAlign.center),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ColorManager.pinkk),
            onPressed: () => context.go(RoutesManager.kHomeScreen), 
            child: const Text("Finish", style: TextStyle(color: Colors.white))
          ),
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text("Find the Star ($level/$maxLevels)", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context)),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _handleTap(false), 
        child: Stack(
          children: [
            const Center(child: Text("Can you see the hidden star?", style: TextStyle(color: Colors.grey))),
            Align(
              alignment: Alignment(starPos.dx, starPos.dy),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  _handleTap(true);
                },
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Icon(Icons.star, color: Colors.amber.withOpacity(0.8), size: 50.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
