import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/routes_manager.dart';
import 'package:kids_app_grad/utils/api_constants.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'package:kids_app_grad/utils/ui_helpers.dart';

class SignUpForChild extends StatefulWidget {
  final String parentId;
  const SignUpForChild({super.key, required this.parentId});

  @override
  State<SignUpForChild> createState() => _SignUpForChildState();
}

class _SignUpForChildState extends State<SignUpForChild> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  int _age = 4;
  int _selectedAvatar = 0;
  String _selectedGender = "Boy";
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<String> _avatars = [
    AssetsManager.avatar1,
    AssetsManager.avatar2,
    AssetsManager.avatar3,
    AssetsManager.avatar4,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveChildProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // تجنب الهارد كود للـ Avatar URL، يفضل إرسال رقم الأفاتار أو المسار
      String dummyAvatarUrl = "avatar_${_selectedAvatar + 1}";

      final response = await http.post(
        Uri.parse(ApiConstants.createChild),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'name': _nameController.text.trim(),
          'username': _nameController.text.trim().toLowerCase().replaceAll(' ', '_'),
          'password': _passwordController.text.trim(),
          'password_confirmation': _passwordController.text.trim(),
          'age': _age.toString(),
          'gender': _selectedGender.toLowerCase(),
          'avatar_url': dummyAvatarUrl,
        },
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        if (mounted) {
          UIHelpers.showSuccessSnackBar(context, 'Child profile created successfully!');
          context.go(RoutesManager.kHomePageParent); // العودة للداش بورد لرؤية الطفل الجديد
        }
      } else {
        String message = data['message'] ?? 'Failed to create profile';
        if (data['errors'] != null) {
          message = data['errors'].values.first[0];
        }
        if (mounted) UIHelpers.showErrorDialog(context, message);
      }
    } catch (e) {
      if (mounted) UIHelpers.showErrorDialog(context, 'Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text("Create Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Pick a Buddy"),
              const SizedBox(height: 15),
              _buildAvatarPicker(),
              const SizedBox(height: 30),
              _buildSectionTitle("What's their name?"),
              const SizedBox(height: 10),
              _buildNameField(),
              const SizedBox(height: 20),
              _buildSectionTitle("Set Password"),
              const SizedBox(height: 10),
              _buildPasswordField(),
              const SizedBox(height: 30),
              _buildSectionTitle("How old are they?"),
              const SizedBox(height: 10),
              _buildAgePicker(),
              const SizedBox(height: 30),
              _buildSectionTitle("Gender"),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildGenderCard(AssetsManager.male, "Boy")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildGenderCard(AssetsManager.female, "Girl")),
                ],
              ),
              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _buildAvatarPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_avatars.length, (index) {
        return GestureDetector(
          onTap: () => setState(() => _selectedAvatar = index),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _selectedAvatar == index ? ColorManager.pinkk : Colors.transparent, width: 3),
                ),
                child: CircleAvatar(radius: 30, backgroundColor: Colors.white, backgroundImage: AssetImage(_avatars[index])),
              ),
              const SizedBox(height: 5),
              Text("Buddy ${index + 1}", style: TextStyle(color: _selectedAvatar == index ? ColorManager.pinkk : Colors.grey, fontSize: 12)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Name is required';
        if (value.length < 3) return 'Name must be at least 3 characters';
        return null;
      },
      decoration: InputDecoration(
        hintText: "Enter child's name",
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password is required';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
      decoration: InputDecoration(
        hintText: "Enter password",
        prefixIcon: const Icon(Icons.lock_outline),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: ColorManager.pinkk),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _buildAgePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.remove_circle, color: ColorManager.pinkk, size: 30), 
            onPressed: () => _age > 1 ? setState(() => _age--) : null
          ),
          Text("$_age", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.add_circle, color: ColorManager.pinkk, size: 30), 
            onPressed: () => _age < 18 ? setState(() => _age++) : null
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(String image, String gender) {
    final bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? ColorManager.pinkk : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            SvgPicture.asset(image, height: 35, colorFilter: ColorFilter.mode(isSelected ? ColorManager.pinkk : Colors.grey, BlendMode.srcIn)),
            const SizedBox(height: 8),
            Text(gender, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? ColorManager.pinkk : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.pinkk, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 2,
        ),
        onPressed: _isLoading ? null : _saveChildProfile,
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text("Save Profile", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
