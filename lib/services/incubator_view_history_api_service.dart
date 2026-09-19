import 'dart:convert';
import 'package:http/http.dart' as http;

class IncubatorViewHistoryApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET HISTORY
  //
  // name == null / empty -> ALL HISTORY
  // name provided        -> SEARCH HISTORY
  // ============================================================

  static Future<List<Map<String, dynamic>>> getHistory({
    String? name,
  }) async {
    final trimmedName = name?.trim() ?? '';

    final Uri uri;

    if (trimmedName.isEmpty) {
      uri = Uri.parse(
        '$baseUrl/IncubatorViewHistory',
      );
    } else {
      uri = Uri.parse(
        '$baseUrl/IncubatorViewHistory'
            '?name=${Uri.encodeQueryComponent(trimmedName)}',
      );
    }

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load history.\n'
            '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid history data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }
}