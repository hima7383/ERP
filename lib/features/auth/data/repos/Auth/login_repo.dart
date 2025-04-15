// lib/features/auth/data/repos/auth_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String baseUrl = "https://erpdevelopment.runasp.net/Api/Authentication";

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/SignIn'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw error['errors']['Email']?.first ?? 'Login failed';
      } else {
        throw 'Login failed: ${response.statusCode}';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
