import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/sales/salesInvoice_entity.dart';
import 'package:http/http.dart' as http;

class SalesInvoiceRepository {
    
  Future<List<SalesInvoice>> fetchSalesInvoices() async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/sales/invoice/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map && responseBody.containsKey('data')) {
          return (responseBody['data'] as List)
              .map((e) => SalesInvoice.fromJson(e))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to load sales invoices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load sales invoices: ${e.toString()}');
    }
  }

  Future<SalesInvoice> fetchInvoiceDetails(int invoiceId) async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse(
            'https://erpdevelopment.runasp.net/Api/sales/invoice/$invoiceId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('API Response: $responseBody');

        if (responseBody is Map && responseBody.containsKey('data')) {
          return SalesInvoice.fromJson(responseBody['data']);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to load invoice details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load invoice details: ${e.toString()}');
    }
  }
}
