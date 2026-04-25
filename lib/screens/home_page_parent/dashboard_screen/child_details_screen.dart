import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart'; // مكتبة الرسم البياني
import 'package:kids_app_grad/utils/api_constants.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';

class ChildDetailsScreen extends StatefulWidget {
  final int childId;
  const ChildDetailsScreen({super.key, required this.childId});

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/parent/children/${widget.childId}/dashboard"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.offWhite,
      appBar: AppBar(
        title: Text("${data?['child']?['name'] ?? 'Child'}'s Diagnosis", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.transparent, elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ColorManager.pinkk),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDetails,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDiagnosisCard(), // كارت الحالة (طبيعي ولا لأ)
                    SizedBox(height: 25.h),
                    Text("Accuracy Evolution", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    _buildChartSection(), // الرسم البياني
                    SizedBox(height: 25.h),
                    Text("Overall Performance", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    _buildStatsGrid(),
                    SizedBox(height: 25.h),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDiagnosisCard() {
    final pred = data?['latest_prediction'];
    if (pred == null) return _buildNoDataCard();

    bool isNormal = pred['status'] == 'normal';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isNormal ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: isNormal ? Colors.green : Colors.red, width: 2),
      ),
      child: Column(
        children: [
          Icon(isNormal ? Icons.verified_user : Icons.warning_amber_rounded, color: isNormal ? Colors.green : Colors.red, size: 50.sp),
          SizedBox(height: 10.h),
          Text(isNormal ? "Normal Child" : "Visual Disorder Detected", 
               style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: isNormal ? Colors.green : Colors.red)),
          SizedBox(height: 5.h),
          Text("Confidence: ${(pred['confidence'] * 100).toStringAsFixed(1)}%", style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
          if (!isNormal) ...[
            SizedBox(height: 15.h),
            Text("Recommendation: Specialized eye exercise and professional consult suggested.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, fontStyle: FontStyle.italic)),
          ]
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final sessions = data?['all_sessions'] as List?;
    if (sessions == null || sessions.isEmpty) return const Center(child: Text("Not enough data for chart"));

    return Container(
      height: 220.h,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(sessions.length, (i) => FlSpot(i.toDouble(), sessions[i]['accuracy'].toDouble())),
              isCurved: true,
              color: ColorManager.pinkk,
              barWidth: 4,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: ColorManager.pinkk.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final summary = data?['summary'];
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, crossAxisSpacing: 15.w, mainAxisSpacing: 15.h,
      childAspectRatio: 1.3,
      children: [
        _statBox("Total Games", summary?['total_sessions'].toString() ?? "0", Icons.games, Colors.blue),
        _statBox("Avg Accuracy", "${summary?['avg_accuracy'] ?? 0}%", Icons.track_changes, Colors.orange),
      ],
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final games = data?['top_games'] as List?;
    if (games == null || games.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Activity Log", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 15.h),
        ...games.map((game) => Card(
          margin: EdgeInsets.only(bottom: 10.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          child: ListTile(
            leading: Icon(Icons.history, color: ColorManager.pinkk),
            title: Text(game['game']['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text("${game['avg_accuracy']}%", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      width: double.infinity, padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(20.r)),
      child: Column(children: [Icon(Icons.analytics_outlined, size: 50.sp, color: Colors.grey), SizedBox(height: 10.h), Text("Analyzing Data...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)), Text("Let the child finish a level to see the result.")]),
    );
  }
}
