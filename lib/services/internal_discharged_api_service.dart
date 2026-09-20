import 'dart:convert';

import 'package:http/http.dart' as http;

class InternalDischargedApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // =========================================================
  // GET ALL DISCHARGED CASES
  // =========================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/InternalDischarged',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load discharged cases.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid discharged cases data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // =========================================================
  // SEARCH DISCHARGED CASES BY NAME
  // =========================================================

  static Future<List<Map<String, dynamic>>> search(
      String name,
      ) async {
    final encodedName =
    Uri.encodeQueryComponent(name);

    final response = await http.get(
      Uri.parse(
        '$baseUrl/InternalDischarged/search?name=$encodedName',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to search discharged cases.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid discharged cases data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }
}