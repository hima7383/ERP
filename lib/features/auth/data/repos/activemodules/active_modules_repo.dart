import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/activeModles/active_modules_entity.dart';
import 'package:http/http.dart' as http;

class CompanyRepository {
  Future<CompanyEntity> getCurrentCompany() async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse(
            'https://erpdevelopment.runasp.net/Api/main/company/get-current'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Handle wrapped response
        if (responseBody is Map && responseBody.containsKey('data')) {
          if (responseBody['succeeded'] == true) {
            return CompanyEntity.fromJson(responseBody['data']);
          } else {
            throw Exception(responseBody['message'] ?? 'Request failed');
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load company: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load company: ${e.toString()}');
    }
  }
}
