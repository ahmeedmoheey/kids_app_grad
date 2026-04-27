import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
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
        Uri.parse(ApiConstants.childDashboard(widget.childId)),
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
    final childName = data?['child']?['name'] ?? 'Child';
    bool isEmpty = data?['is_empty'] ?? false;
    String emptyMessage = data?['empty_state'] ?? "No analysis data found";

    return Scaffold(
      backgroundColor: ColorManager.offWhite,
      appBar: AppBar(
        title: Text("$childName's Analysis", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.transparent, elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ColorManager.pinkk),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : isEmpty 
            ? _buildEmptyState(emptyMessage)
            : RefreshIndicator(
                onRefresh: _fetchDetails,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAIStatusSection(), 
                      SizedBox(height: 25.h),
                      Text("Performance Evolution", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15.h),
                      _buildAccuracyChart(), 
                      SizedBox(height: 25.h),
                      Text("Key Statistics", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15.h),
                      _buildSummaryGrid(), 
                      SizedBox(height: 25.h),
                      _buildTopGames(), 
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80.sp, color: Colors.grey.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: _fetchDetails,
            style: ElevatedButton.styleFrom(backgroundColor: ColorManager.pinkk),
            child: const Text("Refresh", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildAIStatusSection() {
    final pred = data?['latest_prediction'] ?? data?['prediction'];
    if (pred == null) return _buildInfoCard("Waiting for Analysis", "Child needs to complete some games to get AI results.", Icons.hourglass_empty, Colors.orange);

    bool isNormal = pred['status'] == 'normal';
    double confidence = (pred['confidence'] ?? 0.0) * 100;

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
          Icon(isNormal ? Icons.check_circle_outline : Icons.report_problem_outlined, color: isNormal ? Colors.green : Colors.red, size: 45.sp),
          SizedBox(height: 10.h),
          Text(pred['label'] ?? "Processing...", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: isNormal ? Colors.green : Colors.red)),
          SizedBox(height: 5.h),
          Text("AI Confidence Score: ${confidence.toStringAsFixed(1)}%", style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildAccuracyChart() {
    final activity = (data?['weekly_activity'] ?? data?['chart']) as List?;
    if (activity == null || activity.isEmpty) return _smallNoDataCard("Play more games to see your chart.");

    return Container(
      height: 200.h,
      padding: EdgeInsets.only(right: 20.w, top: 10.h, bottom: 10.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(activity.length, (i) => FlSpot(i.toDouble(), (activity[i]['avg_accuracy'] ?? 0).toDouble())),
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

  Widget _buildSummaryGrid() {
    final summary = data?['summary'] ?? data?['stats'];
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, crossAxisSpacing: 15.w, mainAxisSpacing: 15.h,
      childAspectRatio: 1.3,
      children: [
        _statBox("Total Played", (summary?['total_sessions'] ?? summary?['sessions_count'] ?? "0").toString(), Icons.play_lesson_outlined, Colors.blue),
        _statBox("Avg Accuracy", "${summary?['avg_accuracy'] ?? 0}%", Icons.ads_click, Colors.purple),
        _statBox("Completed", (summary?['completed_sessions'] ?? "0").toString(), Icons.task_alt, Colors.green),
        _statBox("Total Trials", (summary?['total_trials'] ?? "0").toString(), Icons.query_stats, Colors.orange),
      ],
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 5.h),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTopGames() {
    final games = data?['top_games'] as List?;
    if (games == null || games.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Best Performing Games", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        ...games.map((g) => Card(
          margin: EdgeInsets.only(bottom: 10.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          child: ListTile(
            leading: Icon(Icons.star, color: Colors.amber, size: 28.sp),
            title: Text(g['game']['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${g['plays']} games played"),
            trailing: Text("${g['avg_accuracy']}%", style: TextStyle(color: ColorManager.pinkk, fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildInfoCard(String title, String sub, IconData icon, Color color) {
    return Container(
      width: double.infinity, padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(25.r)),
      child: Column(children: [Icon(icon, color: color, size: 40.sp), SizedBox(height: 10.h), Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)), Text(sub, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: Colors.grey))]),
    );
  }

  Widget _smallNoDataCard(String text) {
    return Container(width: double.infinity, height: 100.h, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)), child: Text(text, style: const TextStyle(color: Colors.grey)));
  }
}
