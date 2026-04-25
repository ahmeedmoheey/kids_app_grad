import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';

class ChildProfile extends StatefulWidget {
  const ChildProfile({super.key});

  @override
  State<ChildProfile> createState() => _ChildProfileState();
}

class _ChildProfileState extends State<ChildProfile> {
  String name = "Loading...";
  String age = "";
  String gender = "";
  String username = "";
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');
    imagePath = prefs.getString('child_avatar_path'); // تحميل مسار الصورة المحفوظة

    if (userDataString != null) {
      final userData = json.decode(userDataString);
      setState(() {
        name = userData['name'] ?? "Unknown";
        age = "${userData['age'] ?? '0'} years";
        gender = userData['gender'] ?? "Unknown";
        username = userData['username'] ?? "@child";
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('child_avatar_path', image.path);
      setState(() {
        imagePath = image.path;
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) GoRouter.of(context).go(RoutesManager.kLoginForParent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Child Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorManager.pinkk),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: Icon(Icons.logout, color: ColorManager.red), onPressed: _logout),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(AssetsManager.backGround), fit: BoxFit.cover),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              _buildAvatar(),
              SizedBox(height: 30.h),
              _buildProfileInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 65.r,
            backgroundColor: ColorManager.ff,
            backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
            child: imagePath == null 
                ? Icon(Icons.person, size: 60.sp, color: ColorManager.pinkk) 
                : null,
          ),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: ColorManager.pinkk,
            child: Icon(Icons.camera_alt, size: 18.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        _buildField("Child Name", name),
        _buildField("Age", age),
        _buildField("Gender", gender),
        _buildField("Username", username),
      ],
    );
  }

  Widget _buildField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: ColorManager.oldGrey)),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: ColorManager.black)),
        )
      ],
    );
  }
}
