import 'dart:convert';
import 'package:http/http.dart' as http;

class StaffSalaryApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ACCOUNTANTS
  // ============================================================
  static Future<List<Map<String, dynamic>>> getAccountants() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/StaffSalary/accountants',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load accountants. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid accountant list returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET LABORERS
  // ============================================================
  static Future<List<Map<String, dynamic>>> getLaborers() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/StaffSalary/laborers',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load laborers. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid laborer list returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET ACCOUNTANT SALARY
  // ============================================================
  static Future<Map<String, dynamic>> getAccountantSalary({
    required int empId,
    required int month,
    required int year,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/StaffSalary/accountant/$empId'
            '?month=$month'
            '&year=$year',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load accountant salary.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    return Map<String, dynamic>.from(decoded);
  }

  // ============================================================
  // GET LABORER SALARY
  // ============================================================
  static Future<Map<String, dynamic>> getLaborerSalary({
    required int empId,
    required int month,
    required int year,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/StaffSalary/laborer/$empId'
            '?month=$month'
            '&year=$year',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load laborer salary.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    return Map<String, dynamic>.from(decoded);
  }
}