import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/finanse/recipt_entity.dart';
import 'package:http/http.dart' as http;

class ReceiptRepository {

  Future<List<Receipt>> fetchReceipts() async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/finance/receipt/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is List) {
          return responseBody.map((e) => Receipt.fromJson(e)).toList();
        } else if (responseBody is Map && responseBody.containsKey('data')) {
          return (responseBody['data'] as List)
              .map((e) => Receipt.fromJson(e))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load receipts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load receipts: ${e.toString()}');
    }
  }

  Future<ReceiptDetails> fetchReceiptDetails(int id) async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net/Api/finance/receipt/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody =
            json.decode(response.body);
        return ReceiptDetails.fromJson(responseBody['data']);
      } else {
        throw Exception('Failed to load receipt details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load receipt details: ${e.toString()}');
    }
  }
}
