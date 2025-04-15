import 'dart:convert';

import 'package:erp/Core/Helper/token_helper.dart';
import 'package:erp/features/auth/data/entities/accounts/daily.dart';
import 'package:http/http.dart' as http;

class JournalEntryRepository {
  final String _baseUrl =
      "https://erpdevelopment.runasp.net/Api/Accounts/JournalEntry/List";
  JournalEntryRepository();

  Future<List<JournalEntry>> fetchJournalEntries() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Print the API response for debugging
    print("API Response: ${response.body}");

    if (response.statusCode == 200) {
      // Decode the JSON response
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Check if the 'data' field exists and is a list
      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((json) => JournalEntry.fromJson(json)).toList();
      } else {
        throw Exception(
            "Invalid API response format: 'data' field is missing or not a list");
      }
    } else {
      throw Exception("Failed to load journal entries: ${response.statusCode}");
    }
  }
}
