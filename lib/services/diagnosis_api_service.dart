import 'dart:convert';

import 'package:http/http.dart' as http;

class DiagnosisApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL DIAGNOSIS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Diagnosis'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load diagnosis.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid diagnosis data returned from API.',
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
            a['diagnosis_name']?.toString() ?? '';

        final nameB =
            b['diagnosis_name']?.toString() ?? '';

        return nameA
            .toLowerCase()
            .compareTo(nameB.toLowerCase());
      },
    );

    return result;
  }

  // ============================================================
  // ADD DIAGNOSIS
  // ============================================================

  static Future<Map<String, dynamic>> addDiagnosis({
    required String diagnosisName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Diagnosis'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'diagnosisName': diagnosisName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to add diagnosis.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // UPDATE DIAGNOSIS
  // ============================================================

  static Future<Map<String, dynamic>> updateDiagnosis({
    required int id,
    required String diagnosisName,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Diagnosis/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'diagnosisName': diagnosisName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to update diagnosis.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // DELETE DIAGNOSIS
  // ============================================================

  static Future<void> deleteDiagnosis(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Diagnosis/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete diagnosis.',
      );
    }
  }
}