import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:erp/Core/Helper/active_modules.dart';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/repos/activemodules/active_modules_repo.dart';
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
class FetchCompanyData extends LoginEvent {}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});
}
class FetchingCompanyData extends LoginState {} // New state for loading company data

class CompanyDataFetched extends LoginState {} // New state for successful fetch

class CompanyDataFetchError extends LoginState { // New state for fetch error
  final String error;
  
  CompanyDataFetchError({required this.error});
}

// Bloc
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final CompanyRepository _companyRepository;

  LoginBloc(this._companyRepository) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<FetchCompanyData>(_onFetchCompanyData);
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
        await TokenStorage.saveToken(token);
        await prefs.setString('token', token);
        emit(LoginSuccess(token: token));
        
        // After successful login, trigger company data fetch
        add(FetchCompanyData());
      } else {
        final error = responseBody['message'] ?? 'Login failed';
        emit(LoginFailure(error: error));
      }
    } catch (e) {
      emit(LoginFailure(error: 'Connection error: ${e.toString()}'));
    }
  }

  Future<void> _onFetchCompanyData(
    FetchCompanyData event,
    Emitter<LoginState> emit,
  ) async {
    emit(FetchingCompanyData());

    try {
      print("Fetching current company data...");
      final companyData = await _companyRepository.getCurrentCompany();
      print("Successfully fetched company data: ${companyData.companyName}");

      // --- Update the static ActiveModules list ---
      print("Resetting ActiveModules list to all zeros.");
      for (int i = 0; i < ActiveModules.activeModules.length; i++) {
        ActiveModules.activeModules[i] = 0;
      }
      print("ActiveModules after reset: ${ActiveModules.activeModules}");

      print("Processing fetched modules...");
      for (var module in companyData.companyModules) {
        int index = module.moduleId - 1;
        if (index >= 0 && index < ActiveModules.activeModules.length) {
          ActiveModules.activeModules[index] = module.isActive ? 1 : 0;
          print(
              " -> Module ID: ${module.moduleId} maps to Index: $index. Setting state to: ${ActiveModules.activeModules[index]} (isActive: ${module.isActive})");
        } else {
          print(
              " -> Warning: Module ID ${module.moduleId} is outside the expected range (1-10) and cannot be stored in the list. Ignoring.");
        }
      }
      print("Final ActiveModules state after update: ${ActiveModules.activeModules}");

      emit(CompanyDataFetched());
    } catch (e) {
      print("Error fetching company data or updating state: $e");
      
      // Reset list on failure
      print("Resetting ActiveModules list due to error.");
      for (int i = 0; i < ActiveModules.activeModules.length; i++) {
        ActiveModules.activeModules[i] = 0;
      }
      
      emit(CompanyDataFetchError(error: 'Failed to load configuration: ${e.toString()}'));
    }
  }
}