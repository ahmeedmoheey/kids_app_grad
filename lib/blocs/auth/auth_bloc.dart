import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/api_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      bool isEmail = event.emailOrName.contains('@');
      String url = isEmail ? ApiConstants.parentLogin : ApiConstants.childLogin;
      
      debugPrint(">>> [AUTH] POST: $url");
      
      final body = json.encode(isEmail 
            ? {'email': event.emailOrName, 'password': event.password}
            : {'username': event.emailOrName, 'password': event.password});

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json', 
          'Content-Type': 'application/json',
        },
        body: body,
      );

      debugPrint(">>> [AUTH] Status: ${response.statusCode}");

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        
        if (isEmail) {
          await prefs.setString('user_type', 'parent');
          await prefs.setString('parent_token', data['token']);
          if (data['has_children'] != null) {
             await prefs.setBool('has_children', data['has_children']);
          }
          if (data['children'] != null) {
             await prefs.setString('children', json.encode(data['children']));
          }
        } else {
          await prefs.setString('user_type', 'child');
          await prefs.setString('child_token', data['token']);
        }
        
        var userData = isEmail ? data['user'] : data['child'];
        await prefs.setString('user_data', json.encode(userData));
        
        emit(AuthSuccess("Login Successful!", userData: data));
      } else {
        emit(AuthFailure(data['message'] ?? "Error ${response.statusCode}"));
      }
    } catch (e) {
      debugPrint(">>> [AUTH] Error: $e");
      emit(AuthFailure("System Error: ${e.toString()}"));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.parentRegister),
        headers: {
          'Accept': 'application/json', 
          'Content-Type': 'application/json',
        },
        body: json.encode(event.userData),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(AuthSuccess(data['message'] ?? "Registration Successful!"));
      } else {
        String errorMsg = data['message'] ?? "Registration failed.";
        if (data['errors'] != null) {
          errorMsg = data['errors'].values.first[0];
        }
        emit(AuthFailure(errorMsg));
      }
    } catch (e) {
      emit(AuthFailure("Error: ${e.toString()}"));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userType = prefs.getString('user_type');
      
      String url = (userType == 'child') ? ApiConstants.childLogout : ApiConstants.parentLogout;
      
      if (token != null) {
        await http.post(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      emit(Unauthenticated());
    }
  }
}
