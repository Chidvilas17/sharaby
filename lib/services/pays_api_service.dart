import 'dart:convert';

import 'package:http/http.dart' as http;

class PaysApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL PAYS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Pays'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load pays.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid pays data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET ONE PAY
  // ============================================================

  static Future<Map<String, dynamic>> getById(
      int id,
      ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Pays/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Pay not found.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // ADD PAY
  // ============================================================

  static Future<Map<String, dynamic>> addPay({
    required int payAmount,
    required String type,
    String visible = 'false',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Pays'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'payAmount': payAmount,
        'type': type,
        'visible': visible,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to add pay.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // UPDATE PAY
  // ============================================================

  static Future<Map<String, dynamic>> updatePay({
    required int id,
    required int payAmount,
    required String type,
    required String visible,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Pays/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'payAmount': payAmount,
        'type': type,
        'visible': visible,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to update pay.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // DELETE PAY
  // ============================================================

  static Future<void> deletePay(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Pays/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete pay.',
      );
    }
  }
}