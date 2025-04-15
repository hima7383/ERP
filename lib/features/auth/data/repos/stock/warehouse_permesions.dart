import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart'; // Your token helper path
import 'package:erp/features/auth/data/entities/stock/warehouse_permesion.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint

class PriceListRepository {
  final String _baseUrl = 'https://erpdevelopment.runasp.net/Api/inventory/pricelist';

  // Fetches the list of price list summaries
  Future<List<PriceListSummary>> fetchPriceLists() async {
    final token = await TokenStorage.getToken();
    final uri = Uri.parse('$_baseUrl/list');
    debugPrint('Fetching price lists from: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Price List Summary Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody != null && responseBody['succeeded'] == true && responseBody['data'] is List) {
          final List<dynamic> dataList = responseBody['data'];
          return dataList.map((e) => PriceListSummary.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          debugPrint('Unexpected Price List Summary response format: $responseBody');
          throw Exception('Unexpected response format from server.');
        }
      } else {
         debugPrint('Failed to load price lists: ${response.statusCode} ${response.reasonPhrase}');
         debugPrint('Response Body: ${response.body}');
        throw Exception('Failed to load price lists: ${response.statusCode}');
      }
    } catch (e) {
       debugPrint('Error fetching price lists: ${e.toString()}');
      throw Exception('Failed to load price lists: ${e.toString()}');
    }
  }

  // Fetches the full details for a single price list
  Future<PriceListDetails> fetchPriceListDetails(int id) async {
    final token = await TokenStorage.getToken();
    final uri = Uri.parse('$_baseUrl/$id');
    debugPrint('Fetching price list details from: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Price List Detail Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
         if (responseBody != null && responseBody['succeeded'] == true && responseBody['data'] is Map) {
           return PriceListDetails.fromJson(responseBody['data'] as Map<String, dynamic>);
         } else {
            debugPrint('Unexpected Price List Detail response format: $responseBody');
            throw Exception('Unexpected response format from server.');
         }
      } else {
          debugPrint('Failed to load price list details: ${response.statusCode} ${response.reasonPhrase}');
          debugPrint('Response Body: ${response.body}');
        throw Exception('Failed to load price list details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching price list details: ${e.toString()}');
      throw Exception('Failed to load price list details: ${e.toString()}');
    }
  }
}