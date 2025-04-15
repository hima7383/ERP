import 'dart:convert';
import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/Core/network/api_client.dart'; // Assuming ApiEndpoints is here
// Import your entity classes
import 'package:erp/features/auth/data/entities/accounts/accounts.dart'; // Contains Account
import 'package:http/http.dart' as http;

class AccountsRepository {
  // --- Helper for Headers ---
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken(); // Assuming TokenStorage works
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- Existing Methods (Keep or Remove as needed) ---

  // Fetches ALL primary accounts (if still needed)
  Future<List<Account>> fetchMainAccounts() async {
    // ... (implementation remains the same) ...
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(
          ApiEndpoints.getMainAccountsList()), // Ensure this endpoint exists
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      // Assuming the response structure is {..., "data": [AccountJson, ...]}
      final List<dynamic> data = responseBody['data'] ?? [];
      return data.map((json) => Account.fromJson(json)).toList();
    } else {
      print(
          'Failed fetchMainAccounts: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load main accounts');
    }
  }

  // Fetches ALL secondary accounts (if still needed)
  Future<List<Assets>> fetchassests() async {
    // ... (implementation remains the same) ...
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(
          "https://erpdevelopment.runasp.net/Api/accounts/account/secondaryAccountsList"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      // Assuming the response structure is {..., "data": [AssetsJson, ...]}
      final List<dynamic> data = responseBody['data'] ?? [];
      return data.map((json) => Assets.fromJson(json)).toList();
    } else {
      print('Failed fetchassests: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load assets');
    }
  }

  // --- Methods for the New Workflow ---

  // Fetch the sequence of parent IDs for a given starting ID
  // Adjusted to return List<int>
  Future<List<int>> fetchSequence(int startId) async {
    final headers = await _getHeaders();
    // IMPORTANT: Adjust URL structure if needed. Is it a query param?
    // Example assuming query parameter: 'accountID' or 'id'
    final url = Uri.parse(
        "https://erpdevelopment.runasp.net/Api/accounts/account/parents-squence?id=$startId");
    // Or if it's part of the path: Uri.parse(".../parents-squence/$startId")

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      // Assuming the structure is {"data": {"squence": [1, 2, 3]}}
      if (responseBody['data'] is Map<String, dynamic>) {
        final Map<String, dynamic> dataMap = responseBody['data'];
        // Use SequenceData.fromJson to handle the 'squence' key and list parsing
        final sequenceData = SequenceData.fromJson(dataMap);
        return sequenceData.sequence; // Return the List<int>
      } else {
        print(
            'Failed fetchSequence: Unexpected data format - ${response.body}');
        throw Exception('Failed to parse sequence data format');
      }
    } else {
      print('Failed fetchSequence: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load sequence');
    }
  }

  // In AccountsRepository class:

// Get account type (returns "Primary" or "Secondary")
  Future<String> getAccountTypeById(int accountId) async {
    // Param is int
    final headers = await _getHeaders();
    // Ensure ApiEndpoints.getAccountTypeById takes an int or string as needed
    final url = Uri.parse(ApiEndpoints.getAccountTypeById(
        accountId.toString())); // Make sure endpoint URL is correct
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // --- FIX STARTS HERE ---
      // Check if 'data' exists and is a String
      if (responseBody.containsKey('data') && responseBody['data'] is String) {
        final String accountTypeString = responseBody['data'];
        // Optionally check if the string is one of the expected values
        if (accountTypeString == "Primary" ||
            accountTypeString == "Secondary") {
          return accountTypeString; // Return "Primary" or "Secondary" directly
        } else {
          print(
              'Failed getAccountTypeById: Unexpected type string value - ${response.body}');
          throw Exception(
              'Account type value ($accountTypeString) not recognized');
        }
      } else {
        // Data field is missing or not a String
        print(
            'Failed getAccountTypeById: Unexpected data format or missing data field - ${response.body}');
        throw Exception('Failed to parse account type data format');
      }
      // --- FIX ENDS HERE ---
    } else {
      print(
          'Failed getAccountTypeById: ${response.statusCode} - ${response.body}');
      throw Exception(
          'Failed to get account type (HTTP ${response.statusCode})');
    }
  }

  // Fetch Main Account details by ID
  // Renamed/Used getPrimaryAccountById, ensuring it returns Account
  Future<Account> fetchMainAccountById(int accountId) async {
    // Changed param to int
    final headers = await _getHeaders();
    // Ensure ApiEndpoints.getPrimaryAccountById takes an int or string as needed
    final url =
        Uri.parse(ApiEndpoints.getPrimaryAccountById(accountId.toString()));
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      // Assuming structure {"data": AccountJson}
      if (responseBody['data'] is Map<String, dynamic>) {
        return Account.fromJson(
            responseBody['data']); // Extract and parse the 'data' field
      } else {
        print(
            'Failed fetchMainAccountById: Unexpected data format - ${response.body}');
        throw Exception('Failed to parse main account data format');
      }
    } else {
      print(
          'Failed fetchMainAccountById: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to get main account details');
    }
  }

  // Fetch Asset Account details by ID
  // Adjusted to return single Assets object
  Future<Assets> fetchAssetById(int accountId) async {
    // Changed param to int, return type Assets
    final headers = await _getHeaders();
    final url = Uri.parse(
        "https://erpdevelopment.runasp.net/Api/accounts/account/getSecondaryAccountById/$accountId");
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      // Assuming structure {"data": AssetsJson} OR {"data": [AssetsJson]}
      dynamic data = responseBody['data'];
      if (data is Map<String, dynamic>) {
        return Assets.fromJson(data); // Directly parse if data is an object
      } else if (data is List &&
          data.isNotEmpty &&
          data.first is Map<String, dynamic>) {
        return Assets.fromJson(
            data.first); // Parse first element if data is a list
      } else {
        print(
            'Failed fetchAssetById: Unexpected data format - ${response.body}');
        throw Exception('Failed to parse asset data format');
      }
    } else {
      print('Failed fetchAssetById: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load asset by id');
    }
  }
}
