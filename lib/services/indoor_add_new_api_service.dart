import 'dart:convert';

import 'package:http/http.dart' as http;

class IndoorAddNewApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET PATIENTS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getPatients() async {
    final uri = Uri.parse(
      '$baseUrl/IndoorAddNew',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load Indoor Add New patients.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! List) {
      throw Exception(
        'Invalid patient data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }
}