import 'dart:convert';

import 'package:http/http.dart' as http;

class NurseryReservedApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  static Future<List<Map<String, dynamic>>> getReservedCases() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/HdanPatients/reserved',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load reserved nursery cases. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid reserved nursery cases returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }
}