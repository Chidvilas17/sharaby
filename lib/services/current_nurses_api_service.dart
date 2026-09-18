import 'dart:convert';

import 'package:http/http.dart' as http;

class CurrentNursesApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET NURSES
  // ============================================================

  static Future<List<dynamic>> getNurses() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/CurrentNurses/nurses',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load nurses. '
          'Status code: ${response.statusCode}',
    );
  }

  // ============================================================
  // GET MONTHLY ATTENDANCE
  // ============================================================

  static Future<Map<String, dynamic>> getMonthlyAttendance({
    required int nurseId,
    required int month,
    required int year,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/CurrentNurses'
          '?nurseId=$nurseId'
          '&month=$month'
          '&year=$year',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 400) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Invalid information.',
      );
    }

    if (response.statusCode == 404) {
      throw Exception(
        'Nurse not found.',
      );
    }

    throw Exception(
      'Failed to load monthly data. '
          'Status code: ${response.statusCode}',
    );
  }
}