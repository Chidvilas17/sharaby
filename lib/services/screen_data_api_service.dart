import 'dart:convert';

import 'package:http/http.dart' as http;

class ScreenDataApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // =========================================================
  // GET ALL
  // =========================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ScreenData'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load screen data.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid screen data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // =========================================================
  // UPDATE
  // =========================================================

  static Future<void> update({
    required int id,
    required String type,
    required String text1,
    required String text2,
    required String text3,
    required String text4,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/ScreenData/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'text1': text1,
        'text2': text2,
        'text3': text3,
        'text4': text4,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to save screen data.',
      );
    }
  }
}