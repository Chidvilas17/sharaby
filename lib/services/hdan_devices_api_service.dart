import 'dart:convert';
import 'package:http/http.dart' as http;

class HdanDevicesApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET DEVICES
  // ============================================================

  static Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/HdanDevices'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load devices. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid devices data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // ADD DEVICE
  // ============================================================

  static Future<Map<String, dynamic>> addDevice({
    required String type,
    required int price,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/HdanDevices'),
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
            : 'Failed to add device.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // UPDATE DEVICE
  // ============================================================

  static Future<Map<String, dynamic>> updateDevice({
    required int id,
    required String type,
    required int price,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/HdanDevices/$id'),
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
            : 'Failed to update device.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // DELETE DEVICE
  // ============================================================

  static Future<void> deleteDevice(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/HdanDevices/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete device.',
      );
    }
  }
}