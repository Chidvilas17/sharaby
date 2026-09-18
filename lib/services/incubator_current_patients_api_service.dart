import 'dart:convert';
import 'package:http/http.dart' as http;

class IncubatorCurrentPatientsApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET CURRENT PATIENTS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getCurrentPatients() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/IncubatorCurrentPatients',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load current patients.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid current patient data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }
}