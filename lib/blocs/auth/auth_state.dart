import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  final dynamic userData;
  AuthSuccess(this.message, {this.userData});
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class Authenticated extends AuthState {
  final String userType;
  Authenticated(this.userType);
}

class Unauthenticated extends AuthState {}
