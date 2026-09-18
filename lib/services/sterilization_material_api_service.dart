import 'dart:convert';
import 'package:http/http.dart' as http;

class SterilizationMaterialApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET MATERIAL TYPES
  // ============================================================

  static Future<List<Map<String, dynamic>>> getTypes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/SterilizationMaterial/types'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load material types. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Invalid material types returned from API.');
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET ALL PURCHASES
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/SterilizationMaterial'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load purchases. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Invalid purchases returned from API.');
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // ADD PURCHASE
  // ============================================================

  static Future<Map<String, dynamic>> add({
    required int count,
    required String type,
    required String waslNo,
    required int discount,
    String? discountDetails,
    int? userId,
    String? status,
    DateTime? date,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/SterilizationMaterial'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'count': count,
        'type': type,
        'waslNo': waslNo,
        'discount': discount,
        'discountDetails': discountDetails,
        'userId': userId,
        'status': status,
        'date': (date ?? DateTime.now()).toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to add purchase.',
      );
    }

    final decoded = jsonDecode(response.body);

    return Map<String, dynamic>.from(decoded);
  }

  // ============================================================
  // DELETE PURCHASE
  // ============================================================

  static Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/SterilizationMaterial/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete purchase.',
      );
    }
  }

  // ============================================================
  // UPDATE PURCHASE
  // ============================================================

  static Future<void> update({
    required int id,
    required int count,
    required String type,
    required String waslNo,
    required int discount,
    String? discountDetails,
    int? userId,
    String? status,
    DateTime? date,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/SterilizationMaterial/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'count': count,
        'type': type,
        'waslNo': waslNo,
        'discount': discount,
        'discountDetails': discountDetails,
        'userId': userId,
        'status': status,
        'date': date?.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to update purchase.',
      );
    }
  }
}