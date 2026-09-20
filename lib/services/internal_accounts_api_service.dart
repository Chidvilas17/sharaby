import 'dart:convert';

import 'package:http/http.dart' as http;

class InternalAccountsApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // =========================================================
  // GET ACCOUNTS FOR DATE
  // =========================================================

  static Future<Map<String, dynamic>>
  getAccounts(DateTime date) async {
    final dateString =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await http.get(
      Uri.parse(
        '$baseUrl/InternalAccounts?date=$dateString',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load inpatient accounts.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid inpatient accounts data.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  // =========================================================
  // DELETE INCOME
  // =========================================================

  static Future<void> deleteIncome(int id) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/InternalAccounts/income/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete income.',
      );
    }
  }

  // =========================================================
  // DELETE EXPENSE
  // =========================================================

  static Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/InternalAccounts/expense/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete expense.',
      );
    }
  }
}