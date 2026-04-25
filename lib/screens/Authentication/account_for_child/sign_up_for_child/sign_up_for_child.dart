import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';
import 'package:kids_app_grad/utils/api_constants.dart';

class SignUpForChild extends StatefulWidget {
  final String parentId;
  const SignUpForChild({super.key, required this.parentId});

  @override
  State<SignUpForChild> createState() => _SignUpForChildState();
}

class _SignUpForChildState extends State<SignUpForChild> {
  int age = 4;
  int selectedAvatar = 0;
  String selectedGender = "Boy";
  bool obscurePassword = true;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final List<String> avatars = [
    AssetsManager.avatar1,
    AssetsManager.avatar2,
    AssetsManager.avatar3,
    AssetsManager.avatar4,
  ];

  final List<String> avatarNames = ["Ahmed", "Pola", "JOY", "Maha"];

  void saveChildProfile() async {
    if (nameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // هبعت رابط وهمي عشان يعدي من الـ Laravel Validation
      // لأن السيرفر بيطلب URL حقيقي
      String dummyAvatarUrl = "https://example.com/avatars/avatar_${selectedAvatar + 1}.png";

      final response = await http.post(

        Uri.parse(ApiConstants.createChild),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'name': nameController.text.trim(),
          'username': nameController.text.trim().toLowerCase().replaceAll(' ', '_'),
          'password': passwordController.text.trim(),
          'password_confirmation': passwordController.text.trim(),
          'age': age.toString(),
          'gender': selectedGender.toLowerCase(),
          'avatar_url': dummyAvatarUrl, // بعتنا رابط وهمي
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Child profile created successfully!')),
          );
          GoRouter.of(context).push(RoutesManager.kLoginForParent);
        }
      } else {
        if (mounted) {
          String message = data['message'] ?? 'Failed to create profile';
          if (data['errors'] != null) {
            message = data['errors'].values.first[0];
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection error')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F4),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F5F4),
        title: const Text("Create Profile", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pick a Buddy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(avatars.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedAvatar = index),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: selectedAvatar == index ? const Color(0xFFF4A896) : Colors.transparent, width: 3),
                        ),
                        child: CircleAvatar(radius: 30, backgroundColor: Colors.white, backgroundImage: AssetImage(avatars[index])),
                      ),
                      const SizedBox(height: 5),
                      Text(avatarNames[index], style: TextStyle(color: selectedAvatar == index ? const Color(0xFFF4A896) : Colors.grey)),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            const Text("What's their name?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter child's name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Set Password", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                hintText: "Enter password",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFF4A896)),
                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text("How old are they?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(backgroundColor: const Color(0xFFF4A896), child: IconButton(icon: const Icon(Icons.remove, color: Colors.white), onPressed: () => age > 1 ? setState(() => age--) : null)),
                  Text("$age", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  CircleAvatar(backgroundColor: const Color(0xFFF4A896), child: IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () => setState(() => age++))),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Gender (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: genderCard(AssetsManager.male, "Boy")),
                const SizedBox(width: 15),
                Expanded(child: genderCard(AssetsManager.female, "Girl")),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4A896), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                onPressed: isLoading ? null : saveChildProfile,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Profile", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget genderCard(String image, String gender) {
    final bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? const Color(0xFFF4A896) : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            SvgPicture.asset(image, height: 40, colorFilter: ColorFilter.mode(isSelected ? const Color(0xFFF4A896) : Colors.grey, BlendMode.srcIn)),
            const SizedBox(height: 10),
            Text(gender, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFFF4A896) : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
