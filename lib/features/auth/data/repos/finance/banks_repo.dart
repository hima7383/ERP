import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/finanse/banks_entity.dart';
import 'package:http/http.dart' as http;

class BankAccountRepository {
  Future<List<BankAccountSummary>> fetchBankAccounts() async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/finance/bankAccount/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Handle both direct array and wrapped responses
        if (responseBody is List) {
          return responseBody.map((e) => BankAccountSummary.fromJson(e)).toList();
        } else if (responseBody is Map && responseBody.containsKey('data')) {
          return (responseBody['data'] as List)
              .map((e) => BankAccountSummary.fromJson(e))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load bank accounts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load bank accounts: ${e.toString()}');
    }
  }

  Future<BankAccount> fetchBankAccountDetails(int id) async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/finance/bankAccount/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        
        // Handle both direct object and wrapped responses
        if (responseBody.containsKey('data')) {
          return BankAccount.fromJson(responseBody['data']);
        } else {
          return BankAccount.fromJson(responseBody);
        }
      } else {
        throw Exception(
            'Failed to load bank account details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load bank account details: ${e.toString()}');
    }
  }

  // Add more methods for creating, updating, deleting bank accounts as needed
  // Future<BankAccount> createBankAccount(BankAccount account) {...}
  // Future<bool> updateBankAccount(BankAccount account) {...}
  // Future<bool> deleteBankAccount(int id) {...}
}