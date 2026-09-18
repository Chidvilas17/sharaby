import 'dart:convert';
import 'package:http/http.dart' as http;

class IncubatorAddNewApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET EXISTING INCUBATOR PATIENTS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getPatients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/IncubatorAddNew'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load incubator patients.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid incubator patient data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }
}