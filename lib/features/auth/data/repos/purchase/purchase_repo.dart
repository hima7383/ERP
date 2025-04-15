import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/purchase/purchase_invoices.dart';
import 'package:http/http.dart' as http;

class PurchaseInvoiceRepository {
  PurchaseInvoiceRepository();

  Future<List<PurchaseInvoice>> fetchPurchaseInvoices() async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
        'https://erpdevelopment.runasp.net/Api/Purchase/PurchaseInvoice/List');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['data'] as List); // Debug statement
        return (data['data'] as List)
            .map((invoice) => PurchaseInvoice.fromJson(invoice))
            .toList();
      } else {
        throw Exception(
            'Failed to load purchase invoices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load purchase invoices: $e');
    }
  }

  Future<PurchaseInvoice> fetchPurchaseInvoiceById(int id) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
        'https://erpdevelopment.runasp.net/Api/Purchase/PurchaseInvoice/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Debug statement
        return PurchaseInvoice.fromJson(data['data']);
      } else {
        throw Exception(
            'Failed to load purchase invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load purchase invoice: $e');
    }
  }
}
