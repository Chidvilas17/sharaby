import 'dart:convert';
import 'package:http/http.dart' as http;

class StaffDiscountsApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET STAFF DISCOUNTS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getStaffDiscounts({
    required int category,
    required int month,
    required int year,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/StaffDiscounts'
          '?category=$category'
          '&month=$month'
          '&year=$year',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load discounts.\n'
            '${response.body}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid discounts response.',
      );
    }

    final employees =
    decoded['employees'];

    if (employees is! List) {
      throw Exception(
        'Invalid employee data returned.',
      );
    }

    return employees
        .map<Map<String, dynamic>>(
          (item) =>
      Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }
}