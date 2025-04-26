import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/sales/salesinvoice_refund_entiy.dart';
import 'package:http/http.dart' as http;

class RefundInvoiceRepository {
    
  Future<List<SalesInvoiceRefund>> fetchRefundInvoices() async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/sales/refund-invoice/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map && responseBody.containsKey('data')) {
          return (responseBody['data'] as List)
              .map((e) => SalesInvoiceRefund.fromJson(e))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to load refund invoices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load refund invoices: ${e.toString()}');
    }
  }

  Future<SalesInvoiceRefund> fetchRefundInvoiceDetails(int refundInvoiceId) async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse(
            'https://erpdevelopment.runasp.net/Api/sales/refund-invoice/$refundInvoiceId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('API Response: $responseBody');

        if (responseBody is Map && responseBody.containsKey('data')) {
          return SalesInvoiceRefund.fromJson(responseBody['data']);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to load refund invoice details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load refund invoice details: ${e.toString()}');
    }
  }
}