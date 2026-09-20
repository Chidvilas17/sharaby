import 'dart:convert';
import 'package:http/http.dart' as http;

class InternalPatientsApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // =========================================================
  // GET ALL INTERNAL PATIENTS
  // =========================================================

  static Future<List<Map<String, dynamic>>>
  getPatients() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/InternalPatients',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load internal patients.',
      );
    }

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! List) {
      throw Exception(
        'Invalid internal patient data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) =>
      Map<String, dynamic>.from(item),
    )
        .toList();
  }
}