import 'dart:convert';

import 'package:http/http.dart' as http;

class NurseryDailyAccountsApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET DAILY ACCOUNTS
  // ============================================================

  static Future<Map<String, dynamic>> getDailyAccounts(
      DateTime date,
      ) async {
    final dateText =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse(
      '$baseUrl/NurseryDailyAccounts'
          '?date=$dateText',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load nursery accounts. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid nursery accounts returned from API.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  // ============================================================
  // DELETE INCOME
  // ============================================================

  static Future<void> deleteIncome(
      int id,
      ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/NurseryDailyAccounts/income/$id',
      ),
    );

    if (response.statusCode != 200) {
      String message =
          'Failed to delete income. '
          'Status code: ${response.statusCode}';

      try {
        final body = jsonDecode(response.body);

        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }
  }

  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  static Future<void> deleteExpense(
      int id,
      ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/NurseryDailyAccounts/expense/$id',
      ),
    );

    if (response.statusCode != 200) {
      String message =
          'Failed to delete expense. '
          'Status code: ${response.statusCode}';

      try {
        final body = jsonDecode(response.body);

        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }
  }
}