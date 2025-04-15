import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/stock/prdouct.dart';
import 'package:erp/features/auth/data/entities/stock/product_response.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  ProductRepository();

  Future<ProductResponse> fetchProducts({int page = 1}) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
        'https://erpdevelopment.runasp.net/Api/inventory/product-and-service/Paginated');

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
        print('API Response: $data'); // Debug: Print API response
        return ProductResponse.fromJson(data);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<ProductDetailEntity> fetchProductById(int productId) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
        'https://erpdevelopment.runasp.net/Api/inventory/product/$productId');

    print('Fetching product with ID: $productId'); // Debug: Print productId
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('API Response: ${response.body}'); // Debug: Print API response

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['succeeded'] == true) {
          return ProductDetailEntity.fromJson(responseBody['data']);
        } else {
          throw Exception('Failed to load product: ${responseBody['message']}');
        }
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product: $e'); // Debug: Print the error
      throw Exception('Failed to load product: $e');
    }
  }
}
