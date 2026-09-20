import 'dart:convert';
import 'package:http/http.dart' as http;

class TblArchiveApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // =========================================================
  // LOAD ARCHIVE RECORDS FOR DATE
  // =========================================================

  static Future<List<Map<String, dynamic>>> getArchive({
    required DateTime date,
  }) async {
    final dateText =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await http.get(
      Uri.parse(
        '$baseUrl/TblArchive?date=$dateText',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load delete list.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid delete list data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // =========================================================
  // DELETE ONE ARCHIVE RECORD
  // =========================================================

  static Future<void> deleteArchive(int delId) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/TblArchive/$delId',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete archive record.',
      );
    }
  }
}