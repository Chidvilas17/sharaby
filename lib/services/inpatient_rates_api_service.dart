import 'dart:convert';

import 'package:http/http.dart' as http;

class InpatientRatesApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getRates() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/InpatientRates',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load internal device rates. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid internal device data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) =>
      Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }

  // ============================================================
  // ADD
  // ============================================================

  static Future<Map<String, dynamic>>
  addRate({
    required String type,
    required int price,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/InpatientRates',
      ),
      headers: {
        'Content-Type':
        'application/json',
      },
      body: jsonEncode({
        'type': type,
        'price': price,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to save internal device rate.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  static Future<Map<String, dynamic>>
  updateRate({
    required int id,
    required String type,
    required int price,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/InpatientRates/$id',
      ),
      headers: {
        'Content-Type':
        'application/json',
      },
      body: jsonEncode({
        'type': type,
        'price': price,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to update internal device rate.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<void>
  deleteRate(int id) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/InpatientRates/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete internal device rate.',
      );
    }
  }
}