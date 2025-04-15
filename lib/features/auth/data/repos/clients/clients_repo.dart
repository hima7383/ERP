import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/clients/clients.dart';
import 'package:http/http.dart' as http;

class CustomerRepository {

  Future<List<Customer>> fetchCustomers() async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse(
            'https://erpdevelopment.runasp.net/Api/Customers/Customer/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Handle both direct array and wrapped responses
        if (responseBody is List) {
          return responseBody.map((e) => Customer.fromJson(e)).toList();
        } else if (responseBody is Map && responseBody.containsKey('data')) {
          return (responseBody['data'] as List)
              .map((e) => Customer.fromJson(e))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load customers: ${e.toString()}');
    }
  }

  Future<String> getCustomerType(int customerId) async {
    final token = await TokenStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse(
            'https://erpdevelopment.runasp.net/Api/Customers/Customer/GetCustomerTypeById/$customerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is Map && responseBody.containsKey('data')) {
          return responseBody['data']
              .toString(); // Will return "Individual" or "Commercial"
        }
        throw Exception('Invalid type response format');
      } else {
        throw Exception('Failed to get customer type: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get customer type: ${e.toString()}');
    }
  }

  Future<CustomerDetails> fetchCustomerDetails(
      int customerId, String type) async {
        final token = await TokenStorage.getToken();
    try {
      final endpoint = type == 'Commercial'
          ? '/Api/Customers/Customer/GetCommercialCustomerById/$customerId'
          : '/Api/Customers/Customer/GetIndividualCustomerById/$customerId';
      print(type);

      final response = await http.get(
        Uri.parse('https://erpdevelopment.runasp.net$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Handle wrapped responses
        if (responseBody is Map && responseBody.containsKey('data')) {
          return CustomerDetails.fromJson(responseBody['data']);
        } else {
          return CustomerDetails.fromJson(responseBody);
        }
      } else {
        throw Exception(
            'Failed to load customer details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load customer details: ${e.toString()}');
    }
  }
}
