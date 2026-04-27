import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/api_constants.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List children = [];
  bool isLoading = true;
  String parentName = "";
  bool isEmpty = false;
  String emptyStateMessage = "No analysis data found";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = json.decode(userDataString);
      setState(() {
        parentName = userData['name'] ?? "Parent";
      });
    }
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print("--- FETCHING CHILDREN DATA ---");
      final response = await http.get(
        Uri.parse(ApiConstants.listChildren),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          children = data['children'] ?? [];
          isEmpty = data['is_empty'] ?? (children.isEmpty);
          if (data['empty_state'] != null) {
            emptyStateMessage = data['empty_state'];
          }
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching children: $e");
      setState(() => isLoading = false);
    }
  }

  void _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        await http.post(
          Uri.parse(ApiConstants.parentLogout),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
      await prefs.clear();
      if (mounted) GoRouter.of(context).go(RoutesManager.kLoginForParent);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) GoRouter.of(context).go(RoutesManager.kLoginForParent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.offWhite,
      appBar: AppBar(
        title: Text("Parent Dashboard", style: TextStyle(color: ColorManager.black, fontWeight: FontWeight.bold, fontSize: 20.sp)),
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [IconButton(icon: Icon(Icons.logout, color: ColorManager.red), onPressed: _logout)],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchChildren,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text("Welcome back,", style: TextStyle(color: ColorManager.oldGrey, fontSize: 14.sp)),
              Text(parentName, style: TextStyle(color: ColorManager.black, fontSize: 24.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 25.h),
              Text("Children Analysis Status", style: TextStyle(color: ColorManager.black, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 15.h),
              isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator()))
                  : (children.isEmpty)
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: children.length,
                          itemBuilder: (context, index) {
                            final child = children[index];
                            return GestureDetector(
                              onTap: () => GoRouter.of(context).push(RoutesManager.kChildDetails, extra: child['id']),
                              child: _buildChildCard(child),
                            );
                          },
                        ),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ColorManager.pinkk,
        onPressed: () => GoRouter.of(context).push(RoutesManager.kSignUpForChild),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add New Child", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 80.h),
          Icon(Icons.analytics_outlined, size: 80.sp, color: Colors.grey.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Text(emptyStateMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget _buildChildCard(dynamic child) {
    String status = "Waiting for Analysis";
    Color statusColor = Colors.orange;
    
    if (child['latest_prediction'] != null) {
      status = child['latest_prediction']['status'] == 'normal' ? "Normal" : "Needs Review";
      statusColor = child['latest_prediction']['status'] == 'normal' ? Colors.green : Colors.red;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20.r), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r, 
            backgroundColor: ColorManager.ff, 
            child: Icon(Icons.person, color: ColorManager.pinkk, size: 30.sp)
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(child['name'] ?? "Unknown", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(
                        status, 
                        style: TextStyle(color: statusColor, fontSize: 11.sp, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text("${child['age']} years old • ${child['gender']}", style: TextStyle(fontSize: 14.sp, color: ColorManager.oldGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
