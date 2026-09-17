import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorAttendanceApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // =========================
  // GET DOCTORS
  // =========================

  static Future<List<dynamic>> getDoctors() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/DoctorAttendance/doctors',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)
      as List<dynamic>;
    }

    throw Exception(
      'Failed to load doctors. Status code: ${response.statusCode}',
    );
  }

  // =========================
  // GET ATTENDANCE
  // =========================

  static Future<Map<String, dynamic>>
  getAttendance(
      DateTime date,
      ) async {
    final dateText =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await http.get(
      Uri.parse(
        '$baseUrl/DoctorAttendance?date=$dateText',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)
      as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load attendance. Status code: ${response.statusCode}',
    );
  }

  // =========================
  // ADD ATTENDANCE
  // =========================

  static Future<void> addAttendance({
    required String shift,
    required int doctorId,
    required DateTime date,
    required String notes,
    required bool specialDay,
  }) async {
    final dateText =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await http.post(
      Uri.parse(
        '$baseUrl/DoctorAttendance/$shift',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'emp_Id': doctorId,
        'date': dateText,
        'notes': notes,
        'specialDay': specialDay,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 400) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Please check the attendance information.',
      );
    }

    throw Exception(
      'Failed to add attendance. Status code: ${response.statusCode}',
    );
  }

  // =========================
  // DELETE ATTENDANCE
  // =========================

  static Future<void> deleteAttendance({
    required String shift,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/DoctorAttendance/$shift/$id',
      ),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 404) {
      throw Exception(
        'Attendance record not found.',
      );
    }

    throw Exception(
      'Failed to delete attendance. Status code: ${response.statusCode}',
    );
  }
}