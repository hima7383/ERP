import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Event
abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});
}

// State
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;

  LoginSuccess({required this.token});
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});
}

// Bloc
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    if (event.email.isEmpty || event.password.isEmpty) {
      emit(LoginFailure(error: 'Email and password are required'));
      return;
    }

    try {
      final uri = Uri.parse(
        'https://erpdevelopment.runasp.net/Api/Authentication/SignIn',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['Email'] = event.email
        ..fields['Password'] = event.password;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['succeeded'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final token = responseBody['data'];
        await TokenStorage.saveToken(token); // Save token using TokenStorage
        await prefs.setString('token', token);
        emit(LoginSuccess(token: token));
      } else {
        final error = responseBody['message'] ?? 'Login failed';
        emit(LoginFailure(error: error));
      }
    } catch (e) {
      emit(LoginFailure(error: 'Connection error: ${e.toString()}'));
    }
  }
}
