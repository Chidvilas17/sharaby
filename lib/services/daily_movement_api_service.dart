import 'dart:convert';

import 'package:http/http.dart' as http;

class DailyMovementApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET DAILY MOVEMENT
  // ============================================================

  static Future<Map<String, dynamic>>
  getDailyMovement({
    required DateTime date,
  }) async {
    final dateString =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse(
      '$baseUrl/DailyMovement?date=$dateString',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load Daily Movement.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid Daily Movement response.',
      );
    }

    return Map<String, dynamic>.from(
      decoded,
    );
  }
}