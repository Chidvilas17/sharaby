import 'dart:convert';
import 'package:http/http.dart' as http;

class DamagesApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // =========================
  // GET CURRENT FAULTS
  // =========================

  static Future<List<dynamic>> getDamages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Damages'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load faults. Status code: ${response.statusCode}',
    );
  }

  // =========================
  // GET FAULT ARCHIVE
  // =========================

  static Future<List<dynamic>> getDamagesArchive() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Damages/archive'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load faults archive. Status code: ${response.statusCode}',
    );
  }

  // =========================
  // GET ONE FAULT
  // =========================

  static Future<Map<String, dynamic>> getDamage(
      int id,
      ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Damages/$id'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)
      as Map<String, dynamic>;
    }

    if (response.statusCode == 404) {
      throw Exception('Fault not found.');
    }

    throw Exception(
      'Failed to load fault. Status code: ${response.statusCode}',
    );
  }

  // =========================
  // ADD FAULT
  // =========================

  static Future<int> addDamage({
    required String deviceName,
    required String damageDetails,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Damages'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'deviceName': deviceName,
        'damageDetails': damageDetails,
      }),
    );

    if (response.statusCode == 200) {
      final data =
      jsonDecode(response.body)
      as Map<String, dynamic>;

      return data['id'] as int;
    }

    if (response.statusCode == 400) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Please check the fault information.',
      );
    }

    throw Exception(
      'Failed to add fault. Status code: ${response.statusCode}',
    );
  }

  // =========================
  // MAINTAIN FAULT
  // =========================

  static Future<void> maintainDamage({
    required int id,
    required String waslNo,
    required int cost,
    required String byEng,
    required String damageDetails,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/Damages/$id/maintain',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'waslNo': waslNo,
        'cost': cost,
        'byEng': byEng,
        'damageDetails': damageDetails,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 404) {
      throw Exception('Fault not found.');
    }

    if (response.statusCode == 400) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Please check the maintenance information.',
      );
    }

    throw Exception(
      'Failed to maintain fault. Status code: ${response.statusCode}',
    );
  }
}