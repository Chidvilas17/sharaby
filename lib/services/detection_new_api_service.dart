import 'dart:convert';
import 'package:http/http.dart' as http;

class DetectionNewApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET DATA
  // ============================================================

  static Future<Map<String, dynamic>>
  getDetectionData() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/DetectionNew',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load detection data.\n'
            '${response.body}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid detection data returned from API.',
      );
    }

    return Map<String, dynamic>.from(
      decoded,
    );
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  static Future<Map<String, dynamic>>
  saveSettings({
    required String currentUser,
    required int time1,
    required int time2,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/DetectionNew/settings',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'currentUser': currentUser,
        'time1': time1,
        'time2': time2,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to save settings.\n'
            '${response.body}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid save response from API.',
      );
    }

    return Map<String, dynamic>.from(
      decoded,
    );
  }
}