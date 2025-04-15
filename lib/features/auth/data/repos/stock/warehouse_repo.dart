import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart'; // Your token helper path
import 'package:erp/features/auth/data/entities/stock/warehouse.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint

class WarehouseRepository {
  final String _baseUrl = 'https://erpdevelopment.runasp.net/Api/Inventory/Warehouse';

  // Fetches the list of warehouses (summary view)
  Future<List<Warehouse>> fetchWarehouses() async {
    final token = await TokenStorage.getToken();
    final uri = Uri.parse('$_baseUrl/List');
    debugPrint('Fetching warehouses from: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Warehouse List Status Code: ${response.statusCode}');
      // debugPrint('Warehouse List Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Check if the response format is as expected
        if (responseBody != null && responseBody['succeeded'] == true && responseBody['data'] is List) {
          final List<dynamic> dataList = responseBody['data'];
          return dataList.map((e) => Warehouse.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          debugPrint('Unexpected Warehouse List response format: $responseBody');
          throw Exception('Unexpected response format from server.');
        }
      } else {
         debugPrint('Failed to load warehouses: ${response.statusCode} ${response.reasonPhrase}');
         debugPrint('Response Body: ${response.body}');
        throw Exception('Failed to load warehouses: ${response.statusCode}');
      }
    } catch (e) {
       debugPrint('Error fetching warehouses: ${e.toString()}');
      throw Exception('Failed to load warehouses: ${e.toString()}');
    }
  }

  // Fetches the full details for a single warehouse
  Future<Warehouse> fetchWarehouseDetails(int id) async {
    final token = await TokenStorage.getToken();
    final uri = Uri.parse('$_baseUrl/$id');
     debugPrint('Fetching warehouse details from: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

       debugPrint('Warehouse Detail Status Code: ${response.statusCode}');
      // debugPrint('Warehouse Detail Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Check if the response format is as expected
         if (responseBody != null && responseBody['succeeded'] == true && responseBody['data'] is Map) {
           return Warehouse.fromJson(responseBody['data'] as Map<String, dynamic>);
         } else {
            debugPrint('Unexpected Warehouse Detail response format: $responseBody');
            throw Exception('Unexpected response format from server.');
         }
      } else {
          debugPrint('Failed to load warehouse details: ${response.statusCode} ${response.reasonPhrase}');
          debugPrint('Response Body: ${response.body}');
        throw Exception('Failed to load warehouse details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching warehouse details: ${e.toString()}');
      throw Exception('Failed to load warehouse details: ${e.toString()}');
    }
  }
}