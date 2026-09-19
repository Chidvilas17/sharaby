import 'dart:convert';

import 'package:http/http.dart' as http;

class IndoorViewCurrentApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET CURRENT PATIENTS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getCurrentPatients() async {
    final uri = Uri.parse(
      '$baseUrl/IndoorViewCurrent',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load Indoor current patients.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid Indoor current patient data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }
}