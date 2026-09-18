import 'dart:convert';
import 'package:http/http.dart' as http;

class StaffRatesApiService {
  static const String baseUrl = 'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL EMPLOYEES WITH THEIR RATES
  // ============================================================

  static Future<List<dynamic>> getEmployees() async {
    final response = await http.get(
      Uri.parse('$baseUrl/StaffEmployees'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load employee rates. '
          'Status code: ${response.statusCode}',
    );
  }
}