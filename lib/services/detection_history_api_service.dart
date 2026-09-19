import 'dart:convert';
import 'package:http/http.dart' as http;

class DetectionHistoryApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // SEARCH
  // ============================================================

  static Future<List<Map<String, dynamic>>> searchHistory({
    required String name,
  }) async {
    final encodedName =
    Uri.encodeQueryComponent(name);

    final uri = Uri.parse(
      '$baseUrl/DetectionHistory?name=$encodedName',
    );

    final response =
    await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to search patient history.\n'
            '${response.body}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid patient history returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) =>
      Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // DETAIL
  // ============================================================

  static Future<Map<String, dynamic>> getDetail(
      int medId,
      ) async {
    final response =
    await http.get(
      Uri.parse(
        '$baseUrl/DetectionHistory/$medId',
      ),
    );

    if (response.statusCode == 404) {
      throw Exception(
        'Medical record not found.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load patient detail.\n'
            '${response.body}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid patient detail returned from API.',
      );
    }

    return Map<String, dynamic>.from(
      decoded,
    );
  }
}