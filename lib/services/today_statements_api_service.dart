import 'dart:convert';

import 'package:http/http.dart' as http;

class TodayStatementsApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // =========================================================
  // GET STATEMENTS BY DATE
  // =========================================================

  static Future<List<Map<String, dynamic>>> getStatements(
      DateTime date,
      ) async {
    final dateText =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await http.get(
      Uri.parse(
        '$baseUrl/TodayStatements?date=$dateText',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load today statements.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid statements data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) =>
      Map<String, dynamic>.from(item),
    )
        .toList();
  }
}