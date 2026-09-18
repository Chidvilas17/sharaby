import 'dart:convert';
import 'package:http/http.dart' as http;

class OxygenIntakeApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL OXYGEN OPERATIONS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/OxygenIntake'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load oxygen operations. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid oxygen operations returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET SINCE LAST PAYMENT
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getSinceLastPayment() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/OxygenIntake/since-last-payment',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load oxygen operations.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid oxygen data returned from API.',
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

  static Future<Map<String, dynamic>> add({
    required int count,
    required int unitPrice,
    required String receiptNumber,
    required int discount,
    String? discountDetails,
    int? userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/OxygenIntake'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'count': count,
        'unitPrice': unitPrice,
        'receiptNumber': receiptNumber,
        'discount': discount,
        'discountDetails': discountDetails,
        'userId': userId,
        'status': 'Wait',
        'date': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to add oxygen operation.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/OxygenIntake/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete oxygen operation.',
      );
    }
  }

  // ============================================================
  // TOTAL
  // ============================================================

  static Future<int> getTotal() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/OxygenIntake/total',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load oxygen total.',
      );
    }

    final decoded =
    Map<String, dynamic>.from(
      jsonDecode(response.body),
    );

    return int.tryParse(
      decoded['total']?.toString() ?? '0',
    ) ??
        0;
  }
}