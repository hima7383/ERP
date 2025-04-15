import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/sales/recuringinvoice_entity.dart';
import 'package:http/http.dart' as http;

class RecurringInvoiceRepository {
  Future<List<RecurringInvoice>> fetchRecurringInvoices() async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/Sales/RecurringInvoice/List'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is Map && responseBody.containsKey('data')) {
          return (responseBody['data'] as List)
              .map((e) => RecurringInvoice.fromJson(e))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load recurring invoices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load recurring invoices: ${e.toString()}');
    }
  }

  Future<RecurringInvoice> fetchRecurringInvoiceById(int id) async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/Sales/RecurringInvoice/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is Map && responseBody.containsKey('data')) {
          return RecurringInvoice.fromJson(responseBody['data']);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load recurring invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load recurring invoice: ${e.toString()}');
    }
  }
}