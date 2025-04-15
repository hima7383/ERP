import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/purchase/supplier.dart';
import 'package:http/http.dart' as http;

class SupplierRepository {
  SupplierRepository();

  Future<List<Supplier>> fetchSuppliers() async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
        'https://erpdevelopment.runasp.net/Api/Purchase/Supplier/List');

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
        if (data['succeeded'] == true) {
          return (data['data'] as List)
              .map((json) => Supplier.fromJson(json))
              .toList();
        } else {
          throw Exception('Failed to load suppliers: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load suppliers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load suppliers: $e');
    }
  }

  Future<SupplierData> fetchSupplierById(int supplierId) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
        'https://erpdevelopment.runasp.net/Api/Purchase/Supplier/$supplierId');

    print('Fetching supplier with ID: $supplierId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['succeeded'] == true) {
          return SupplierData.fromJson(responseBody['data']);
        } else {
          throw Exception(
              'Failed to load supplier: ${responseBody['message']}');
        }
      } else {
        throw Exception('Failed to load supplier: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier: $e');
      throw Exception('Failed to load supplier: $e');
    }
  }
}
