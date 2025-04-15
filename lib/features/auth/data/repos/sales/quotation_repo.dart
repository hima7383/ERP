import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/sales/quotation_entity.dart';
import 'package:http/http.dart' as http;

class QuotationRepository {

  Future<List<Quotation>> fetchQuotations() async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/Sales/Quotation/List'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is Map && responseBody.containsKey('data')) {
          return (responseBody['data'] as List)
              .map((e) => Quotation.fromJson(e))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load quotations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load quotations: ${e.toString()}');
    }
  }

  Future<Quotation> fetchQuotationById(int id) async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/Sales/Quotation/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is Map && responseBody.containsKey('data')) {
          return Quotation.fromJson(responseBody['data']);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load quotation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load quotation: ${e.toString()}');
    }
  }
}