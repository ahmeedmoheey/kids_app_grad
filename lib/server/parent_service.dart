import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/api_constants.dart';

class ParentService {
  static final ParentService _instance = ParentService._internal();
  factory ParentService() => _instance;
  ParentService._internal();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> getChildren() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.listChildren),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return data;
        if (data is Map && data['children'] != null) {
          return data['children'] is List ? data['children'] : [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching children: $e");
    }
    return [];
  }

  Future<bool> addChild({
    required String name,
    required String age,
    required String gender,
    required String email,
    required String password,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.createChild),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'age': age,
          'gender': gender,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Failed to add child: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error adding child: $e");
    }
    return false;
  }

  Future<Map<String, dynamic>?> getChildDashboard(int childId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.childDashboard(childId)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : null;
      }
    } catch (e) {
      debugPrint("Error fetching child dashboard: $e");
    }
    return null;
  }

  Future<List<dynamic>> getChildPredictions(int childId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.childPredictions(childId)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle potential different JSON structures
        if (data is List) {
          return data;
        } else if (data is Map) {
          if (data['predictions'] != null && data['predictions'] is List) {
            return data['predictions'];
          } else if (data['data'] != null && data['data'] is List) {
            return data['data'];
          }
        }
        debugPrint(">>> [PARENT_SERVICE] Warning: Predictions data is not a list structure: $data");
      }
    } catch (e) {
      debugPrint("Error fetching predictions: $e");
    }
    return [];
  }
}
