import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/purchase/debit_note.dart';
import 'package:http/http.dart' as http;

class DebitnoteRepo {

  DebitnoteRepo();

  Future<List<DebitNote>> fetchDebitnoteRepos() async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
        'https://erpdevelopment.runasp.net/Api/Purchase/DebitNote/List');

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
        return (data['data'] as List)
            .map((invoice) => DebitNote.fromJson(invoice))
            .toList();
      } else {
        throw Exception(
            'Failed to load purchase invoices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load purchase invoices: $e');
    }
  }

  Future<DebitNote> fetchDebitnoteRepoById(int id) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
        'https://erpdevelopment.runasp.net/Api/Purchase/DebitNote/$id');

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
        return DebitNote.fromJson(data['data']);
      } else {
        throw Exception(
            'Failed to load purchase invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load purchase invoice: $e');
    }
  }
}
