// lib/features/auth/logic/auth_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    //final prefs = await SharedPreferences.getInstance();
    final token = await TokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated(token: token));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    emit(AuthUnauthenticated());
  }
}


abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;

  AuthAuthenticated({required this.token});

  @override
  List<Object?> get props => [token];
}

class AuthUnauthenticated extends AuthState {}
