import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/finanse/expenses_entity.dart';
import 'package:http/http.dart' as http;

class ExpenseRepository {

  Future<List<Expense>> fetchExpenses() async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/finance/expense/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Handle both direct array and wrapped responses
        if (responseBody is List) {
          return responseBody.map((e) => Expense.fromJson(e)).toList();
        } else if (responseBody is Map && responseBody.containsKey('data')) {
          return (responseBody['data'] as List)
              .map((e) => Expense.fromJson(e))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load expenses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load expenses: ${e.toString()}');
    }
  }

  Future<ExpenseDetails> fetchExpenseDetails(int id) async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/finance/expense/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody =
            json.decode(response.body); // Debug: Print API response
        return ExpenseDetails.fromJson(responseBody['data']);
      } else {
        throw Exception(
            'Failed to load expense details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load expense details: ${e.toString()}');
    }
  }
}
