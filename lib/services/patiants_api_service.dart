import 'dart:convert';

import 'package:http/http.dart' as http;

class PatiantsApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // =========================================================
  // GET ALL
  // =========================================================

  static Future<List<Map<String, dynamic>>>
  getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Patiants'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load patients.',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid patient data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) =>
      Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // =========================================================
  // GET ONE
  // =========================================================

  static Future<Map<String, dynamic>>
  getById(int id) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/Patiants/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load patient.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // =========================================================
  // UPDATE
  // =========================================================

  static Future<void> updatePatient({
    required int id,
    String? name,
    String? phone,
    String? address,
    DateTime? dob,
    int? userId,
    DateTime? dor,
    String? importantNote,
    String? noteForSc,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/Patiants/$id',
      ),
      headers: {
        'Content-Type':
        'application/json',
      },
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'address': address,
        'dob':
        dob?.toIso8601String(),
        'userId': userId,
        'dor':
        dor?.toIso8601String(),
        'importantNote':
        importantNote,
        'noteForSc':
        noteForSc,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to update patient.',
      );
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  static Future<void> deletePatient(
      int id,
      ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/Patiants/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete patient.',
      );
    }
  }
}