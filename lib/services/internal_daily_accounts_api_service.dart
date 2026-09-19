import 'dart:convert';
import 'package:http/http.dart' as http;

class InternalDailyAccountsApiService {
  static const String baseUrl = 'http://10.0.2.2:5137/api';

  static Future<Map<String, dynamic>> getDailyAccounts(DateTime date) async {
    final dateText =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/InternalDailyAccounts?date=$dateText'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }
    } catch (_) {}

    return {
      'income': <Map<String, dynamic>>[],
      'expenses': <Map<String, dynamic>>[],
    };
  }

  static Future<void> deleteIncome(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/InternalDailyAccounts/income/$id'),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete internal income: ${response.statusCode}');
    }
  }

  static Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/InternalDailyAccounts/expense/$id'),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete internal expense: ${response.statusCode}');
    }
  }
}
