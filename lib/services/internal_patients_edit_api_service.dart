import 'dart:convert';

import 'package:http/http.dart' as http;

class InternalPatientsEditApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // =========================================================
  // GET ALL INTERNAL PATIENTS
  // =========================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/InternalPatientsEdit',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load inpatient data.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid inpatient data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }
}