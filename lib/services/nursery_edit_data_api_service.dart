import 'dart:convert';

import 'package:http/http.dart' as http;

class NurseryEditDataApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET NURSERY PATIENTS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getPatients() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/HdanPatients',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load nursery patients. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid nursery patients returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }
}