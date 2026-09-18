import 'dart:convert';

import 'package:http/http.dart' as http;

class TblFlashaApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL SCREEN DATA
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getAll() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/TblFlasha',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load screen data.\n'
            '${response.body}',
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

  // ============================================================
  // UPDATE ALL SCREEN DATA
  // ============================================================

  static Future<void> updateAll(
      List<Map<String, dynamic>> items,
      ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/TblFlasha',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(items),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to save screen data.\n'
            '${response.body}',
      );
    }
  }
}