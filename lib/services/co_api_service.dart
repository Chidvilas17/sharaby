import 'dart:convert';

import 'package:http/http.dart' as http;

class CoApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL C/O
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Co'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load C/O list.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid C/O data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // ADD C/O
  // ============================================================

  static Future<Map<String, dynamic>> addCo({
    required String coName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Co'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'coName': coName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to add C/O.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // UPDATE C/O
  // ============================================================

  static Future<Map<String, dynamic>> updateCo({
    required int id,
    required String coName,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Co/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'coName': coName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to update C/O.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // DELETE C/O
  // ============================================================

  static Future<void> deleteCo(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Co/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete C/O.',
      );
    }
  }
}