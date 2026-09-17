import 'dart:convert';
import 'package:http/http.dart' as http;

class NurseAttendanceApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET NURSES
  // ============================================================
  static Future<List<Map<String, dynamic>>> getNurses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/NurseAttendance/nurses'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load nurses. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid nurse list returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // ADD SHIFT A
  // ============================================================
  static Future<int> addShiftA({
    required int empId,
    required DateTime date,
    String? notes,
    int? userId,
  }) async {
    return _addShift(
      endpoint: 'shift-a',
      empId: empId,
      date: date,
      notes: notes,
      userId: userId,
    );
  }

  // ============================================================
  // ADD SHIFT B
  // ============================================================
  static Future<int> addShiftB({
    required int empId,
    required DateTime date,
    String? notes,
    int? userId,
  }) async {
    return _addShift(
      endpoint: 'shift-b',
      empId: empId,
      date: date,
      notes: notes,
      userId: userId,
    );
  }

  // ============================================================
  // ADD SHIFT C
  // ============================================================
  static Future<int> addShiftC({
    required int empId,
    required DateTime date,
    String? notes,
    int? userId,
  }) async {
    return _addShift(
      endpoint: 'shift-c',
      empId: empId,
      date: date,
      notes: notes,
      userId: userId,
    );
  }

  // ============================================================
  // COMMON SAVE METHOD
  // ============================================================
  static Future<int> _addShift({
    required String endpoint,
    required int empId,
    required DateTime date,
    String? notes,
    int? userId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/NurseAttendance/$endpoint',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'emp_Id': empId,
        'date': date.toIso8601String(),
        'notes': notes,
        'user_id': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to save $endpoint attendance. '
            'Status code: ${response.statusCode}\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response from $endpoint API.',
      );
    }

    return decoded['id'] as int;
  }

  // ============================================================
  // GET ATTENDANCE FOR DATE
  // ============================================================
  static Future<Map<String, dynamic>> getAttendance(
      DateTime date,
      ) async {
    final dateString =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await http.get(
      Uri.parse(
        '$baseUrl/NurseAttendance/attendance?date=$dateString',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load nurse attendance. '
            'Status code: ${response.statusCode}\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid attendance response from API.',
      );
    }

    return decoded;
  }
}