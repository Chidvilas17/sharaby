import 'dart:convert';

import 'package:http/http.dart' as http;

class DoctorMonthlyNetApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET DOCTORS
  // ============================================================

  static Future<List<dynamic>> getDoctors() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/DoctorMonthlyNet/doctors',
      ),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return decoded as List<dynamic>;
    }

    throw Exception(
      'Failed to load doctors. '
          'Status code: ${response.statusCode}',
    );
  }

  // ============================================================
  // GET MONTHLY ATTENDANCE
  // ============================================================

  static Future<Map<String, dynamic>>
  getMonthlyAttendance({
    required int doctorId,
    required int month,
    required int year,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/DoctorMonthlyNet'
          '?doctorId=$doctorId'
          '&month=$month'
          '&year=$year',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return decoded as Map<String, dynamic>;
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
        'Doctor not found.',
      );
    }

    throw Exception(
      'Failed to load monthly data. '
          'Status code: ${response.statusCode}',
    );
  }
}