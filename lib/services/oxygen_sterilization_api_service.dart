import 'dart:convert';
import 'package:http/http.dart' as http;

class OxygenSterilizationApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET OXYGEN PRICE
  // ============================================================

  static Future<Map<String, dynamic>>
  getOxygenPrice() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/OxygenSterilization/oxygen-price',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load oxygen cylinder price.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // SAVE OXYGEN PRICE
  // ============================================================

  static Future<Map<String, dynamic>>
  saveOxygenPrice(int price) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/OxygenSterilization/oxygen-price',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': 'Oxygen Cylinder',
        'price': price,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to save oxygen cylinder price.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // GET STERILIZATION MATERIALS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getMaterials() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/OxygenSterilization/materials',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load sterilization materials.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid sterilization materials returned.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // ADD STERILIZATION MATERIAL
  // ============================================================

  static Future<Map<String, dynamic>>
  addMaterial({
    required String type,
    required int price,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/OxygenSterilization/materials',
      ),
      headers: {
        'Content-Type': 'application/json',
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
            : 'Failed to add sterilization material.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }
}