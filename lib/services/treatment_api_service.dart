import 'dart:convert';

import 'package:http/http.dart' as http;

class TreatmentApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL TREATMENTS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Treatment'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load treatments.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid treatment data returned from API.',
      );
    }

    final result = decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();

    // ==========================================================
    // ALPHABETICAL ORDER
    // ==========================================================

    result.sort(
          (a, b) {
        final nameA =
            a['treatment']?.toString() ?? '';

        final nameB =
            b['treatment']?.toString() ?? '';

        return nameA
            .toLowerCase()
            .compareTo(nameB.toLowerCase());
      },
    );

    return result;
  }

  // ============================================================
  // ADD TREATMENT
  // ============================================================

  static Future<Map<String, dynamic>> addTreatment({
    required String treatment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Treatment'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'treatment': treatment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to add treatment.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // UPDATE TREATMENT
  // ============================================================

  static Future<Map<String, dynamic>> updateTreatment({
    required int id,
    required String treatment,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Treatment/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'treatment': treatment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to update treatment.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // DELETE TREATMENT
  // ============================================================

  static Future<void> deleteTreatment(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Treatment/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete treatment.',
      );
    }
  }
}