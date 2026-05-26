import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_app_grad/server/parent_service.dart';

class ChildDetailsScreen extends StatefulWidget {
  final dynamic child;
  const ChildDetailsScreen({super.key, required this.child});

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  Map<String, dynamic>? dashboardData;
  List<dynamic> predictions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final data = await ParentService().getChildDashboard(widget.child['id']);
    final preds = await ParentService().getChildPredictions(widget.child['id']);
    if (mounted) {
      setState(() {
        dashboardData = data;
        predictions = preds;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.child['name']}'s Progress"),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAssessmentCard(),
                  SizedBox(height: 20.h),
                  _buildSummarySection(),
                  SizedBox(height: 20.h),
                  const Text("Recent History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.h),
                  _buildHistoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildAssessmentCard() {
    // Priority: dashboard_assessment, then prediction, then latest_prediction
    final assessment = dashboardData?['dashboard_assessment'] ?? 
                      dashboardData?['prediction'] ?? 
                      dashboardData?['latest_prediction'];
                      
    if (assessment == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No AI analysis available yet. Let the child play some games!"),
        ),
      );
    }

    final title = (assessment['title'] ?? assessment['label'] ?? "Progress Assessment").toString();
    final severity = (assessment['severity'] ?? '').toString().toLowerCase();
    
    Color baseColor = Colors.green;
    IconData icon = Icons.check_circle_outline;

    if (severity == 'high' || severity == 'critical' || severity == 'danger' || title.toLowerCase().contains('weakness')) {
      baseColor = Colors.red;
      icon = Icons.warning_amber_rounded;
    } else if (severity == 'medium' || severity == 'warning') {
      baseColor = Colors.orange;
      icon = Icons.info_outline;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: baseColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: baseColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: baseColor.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            assessment['message'] ?? "",
            style: TextStyle(color: Colors.black87, fontSize: 14.sp),
          ),
          Divider(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallStat("Avg Accuracy", "${assessment['avg_accuracy']}%"),
              _buildSmallStat("Latest Accuracy", "${assessment['latest_accuracy']}%"),
            ],
          ),
          if (assessment['latest_game_name'] != null) ...[
            SizedBox(height: 12.h),
            Text(
              "Latest: ${assessment['latest_game_name']} (${assessment['latest_score_text']})",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSummarySection() {
    final summary = dashboardData?['summary'];
    if (summary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Performance Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        Row(
          children: [
            _buildStatCard("Total Sessions", summary['total_sessions'].toString(), Colors.blue),
            SizedBox(width: 10.w),
            // Updated: API returns accuracy as percentage, so we don't multiply by 100
            _buildStatCard("Avg Accuracy", "${summary['avg_accuracy']}%", Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final history = dashboardData?['recent_history'] ?? dashboardData?['recent_sessions'] ?? [];
    
    if (history.isEmpty) {
      return const Text("No recent history found.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final gameName = item['game_name'] ?? "Unknown Game";
        final scoreText = item['score_text'] ?? "";
        final accuracyText = item['accuracy_text'] ?? "";
        final stars = item['stars'] ?? 0;
        final confidence = item['prediction']?['confidence'];

        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Icon(Icons.videogame_asset_outlined, color: Colors.blue.shade400, size: 20.sp),
            ),
            title: Text("$gameName — $scoreText", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Accuracy: $accuracyText"),
                if (confidence != null) 
                  Text("AI Confidence: ${((confidence is num ? confidence : double.tryParse(confidence.toString()) ?? 0) * 100).toStringAsFixed(0)}%",
                       style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Icon(
                Icons.star,
                size: 16.sp,
                color: i < stars ? Colors.amber : Colors.grey.shade300,
              )),
            ),
          ),
        );
      },
    );
  }
}
