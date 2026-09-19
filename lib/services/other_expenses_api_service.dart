import 'dart:convert';
import 'package:http/http.dart' as http;

class OtherExpensesApiService {
  static const String baseUrl = 'http://10.0.2.2:5137/api';

  static Future<List<Map<String, dynamic>>> getByDate(DateTime date) async {
    final dateText =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/OtherExpenses/by-date?date=$dateText'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (_) {}

    return [];
  }

  static Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/OtherExpenses/$id'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete expense: ${response.statusCode}');
    }
  }

  static Future<void> addExpense({
    required String receiptNumber,
    required double cost,
    required String notes,
    required DateTime date,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/OtherExpenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'receiptNumber': receiptNumber,
        'cost': cost,
        'notes': notes,
        'date': date.toIso8601String(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add expense');
    }
  }
}
