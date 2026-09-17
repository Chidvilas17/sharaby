import 'dart:convert';
import 'package:http/http.dart' as http;

class OtherIncomeApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/OtherIncome'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load other income.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid other income response.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // SEARCH BY DATE
  // ============================================================

  static Future<List<Map<String, dynamic>>> getByDate(
      DateTime date,
      ) async {
    final dateText =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await http.get(
      Uri.parse(
        '$baseUrl/OtherIncome/by-date?date=$dateText',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to search other income.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid search response.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // ADD
  // ============================================================

  static Future<int> addIncome({
    required String type,
    required int price,
    required DateTime date,
    int? userId,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/OtherIncome'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'price': price,
        'date': date.toIso8601String(),
        'user_id': userId,
        'notes': notes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to add other income.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    return decoded['id'] as int;
  }

  // ============================================================
  // UPDATE
  // ============================================================

  static Future<void> updateIncome({
    required int id,
    required String type,
    required int price,
    required DateTime date,
    int? userId,
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/OtherIncome/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'price': price,
        'date': date.toIso8601String(),
        'user_id': userId,
        'notes': notes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update other income.\n'
            '${response.body}',
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<void> deleteIncome(
      int id,
      ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/OtherIncome/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete other income.\n'
            '${response.body}',
      );
    }
  }
}