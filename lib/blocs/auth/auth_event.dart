import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String emailOrName;
  final String password;
  LoginRequested(this.emailOrName, this.password);
}

class RegisterRequested extends AuthEvent {
  final Map<String, String> userData;
  RegisterRequested(this.userData);
}

class LogoutRequested extends AuthEvent {}
