import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/server/parent_service.dart';
import 'package:kids_app_grad/screens/home_page_parent/dashboard_screen/child_details_screen.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> children = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() => isLoading = true);
    final results = await ParentService().getChildren();
    if (mounted) {
      setState(() {
        children = results;
        isLoading = false;
      });
    }
  }

  void _navigateToSignUpForChild() {
    // بدلاً من الـ Dialog، بنروح لصفحة إنشاء حساب الطفل الكاملة
    context.push(RoutesManager.kSignUpForChild);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSignUpForChild,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : children.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("No children added yet."),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: _navigateToSignUpForChild,
                        child: const Text("Add Your First Child"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChildren,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: Text(child['name'][0].toUpperCase()),
                          ),
                          title: Text(child['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Age: ${child['age']} | Gender: ${child['gender']}"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildDetailsScreen(child: child),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
