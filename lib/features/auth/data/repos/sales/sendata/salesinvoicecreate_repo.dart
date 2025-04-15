import 'dart:convert'; // For jsonEncode
import 'package:dio/dio.dart';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/sales/sendata/salesinvoicecreate_entity.dart'; // Or use http package

abstract class SalesInvoiceRepositorycreate {
  Future<void> createInvoice(InvoiceCreateDTO invoiceData);
}

class SalesInvoiceRepositoryImpl implements SalesInvoiceRepositorycreate {
  final Dio _dio; // Inject Dio (or HttpClient)
  final String _apiUrl = 'https://erpdevelopment.runasp.net/Api/sales/invoice/create';

  SalesInvoiceRepositoryImpl(this._dio); // Or use http.Client

  @override
  Future<void> createInvoice(InvoiceCreateDTO invoiceData) async {
    final token = await TokenStorage.getToken();
    try {
      final response = await _dio.post(
        _apiUrl,
        data: jsonEncode(invoiceData.toJson()), // Encode the DTO to JSON
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'accept': '*/*', // As specified in curl
          },
        ),
      );

      // Check for successful status code (e.g., 200 OK, 201 Created)
      if (response.statusCode != 200 && response.statusCode != 201) {
         // Log the error details
         print("API Error: ${response.statusCode} - ${response.statusMessage}");
         print("Response Data: ${response.data}");
         throw Exception('Failed to create invoice: ${response.statusMessage}');
      }
      // Optionally handle the response body if the API returns data on success
      print('Invoice created successfully.');

    } on DioException catch (e) {
      // Handle Dio-specific errors (network, timeout, etc.)
      print("DioException: ${e.message}");
      print("Response Data (if any): ${e.response?.data}");
      // Provide a user-friendly error message
      throw Exception('Failed to create invoice. Network error or server issue.');
    } catch (e) {
      // Handle other potential errors
      print("Unknown Error: $e");
      throw Exception('An unexpected error occurred while creating the invoice.');
    }
  }
}