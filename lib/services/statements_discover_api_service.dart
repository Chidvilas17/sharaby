import 'dart:convert';

import 'package:http/http.dart' as http;

class StatementsDiscoverApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET DATA
  // ============================================================

  static Future<List<Map<String, dynamic>>> getData({
    String name = '',
  }) async {
    final encodedName =
    Uri.encodeQueryComponent(name.trim());

    final url = name.trim().isEmpty
        ? '$baseUrl/StatementsDiscover'
        : '$baseUrl/StatementsDiscover?name=$encodedName';

    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load screening registrations.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid screening data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) =>
      Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<void> delete(
      int medId,
      ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/StatementsDiscover/$medId',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete medical record.',
      );
    }
  }
}