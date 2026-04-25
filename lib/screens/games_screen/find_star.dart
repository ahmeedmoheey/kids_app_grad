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
  final int maxLevels = 20;
  int sessionId = 0;
  DateTime? startTime;
  int errorsInLevel = 0;

  late Offset starPos;
  final Random rnd = Random();

  @override
  void initState() {
    super.initState();
    _startSession();
    _generateStarPos();
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

  void _generateStarPos() {
    setState(() {
      errorsInLevel = 0;
      // توليد مكان عشوائي للنجمة داخل الشاشة
      starPos = Offset(rnd.nextDouble() * 0.8 - 0.4, rnd.nextDouble() * 0.8 - 0.4);
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
      title: const Text("🌟 Superstar!"),
      content: Text("You found all $maxLevels stars! You have eagle eyes!"),
      actions: [TextButton(onPressed: () => context.go(RoutesManager.kHomeScreen), child: const Text("Finish"))],
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
        onTapDown: (details) => _handleTap(false), // لو داس في أي مكان غلط
        child: Stack(
          children: [
            const Center(child: Text("Can you see the hidden star?", style: TextStyle(color: Colors.grey))),
            Align(
              alignment: Alignment(starPos.dx, starPos.dy),
              child: GestureDetector(
                onTapDown: (details) {
                  _handleTap(true); // داس على النجمة صح
                },
                child: Icon(Icons.star, color: Colors.amber.withOpacity(0.6), size: 40.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
