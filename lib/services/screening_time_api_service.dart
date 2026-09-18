import 'dart:convert';

import 'package:http/http.dart' as http;

class ScreeningTimeApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET SCREENING TIMES
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getScreeningTimes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ScreeningTime'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load screening times.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid screening time data returned by API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // UPDATE SCREENING TIME
  // ============================================================

  static Future<Map<String, dynamic>>
  updateScreeningTime({
    required int timeId,
    required String screeningStart,
    required String screeningEnd,
    required String phoneBookingEnd,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/ScreeningTime/$timeId',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'screeningStart': screeningStart,
        'screeningEnd': screeningEnd,
        'phoneBookingEnd': phoneBookingEnd,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to save screening time.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }
}