import 'dart:convert';
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
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode(isEmail 
            ? {'email': event.emailOrName, 'password': event.password}
            : {'username': event.emailOrName, 'password': event.password}),
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_type', isEmail ? 'parent' : 'child');
        await prefs.setString('user_data', json.encode(isEmail ? data['user'] : data['child']));
        
        emit(AuthSuccess("Login Successful!", userData: data));
      } else {
        emit(AuthFailure(data['message'] ?? "Login failed. Please check your credentials."));
      }
    } catch (e) {
      emit(AuthFailure("Connection error. Please check your internet or server."));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.parentRegister),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode(event.userData),
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        emit(AuthSuccess("Registration Successful! Please verify your email."));
      } else {
        String errorMsg = data['message'] ?? "Registration failed.";
        if (data['errors'] != null) {
          errorMsg = data['errors'].values.first[0];
        }
        emit(AuthFailure(errorMsg));
      }
    } catch (e) {
      emit(AuthFailure("Connection error. Server might be down."));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(Unauthenticated());
  }
}
