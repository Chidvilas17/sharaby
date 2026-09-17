import 'dart:convert';

import 'package:http/http.dart' as http;

class HouseholdExpensesApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL EXPENSES
  // ============================================================

  static Future<List<Map<String, dynamic>>> getExpenses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/HouseholdExpenses'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load expenses. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid expenses list returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }


  // ============================================================
  // GET EXPENSES BY DATE
  // ============================================================

  static Future<List<Map<String, dynamic>>> getExpensesByDate(
      DateTime date,
      ) async {
    final dateText =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await http.get(
      Uri.parse(
        '$baseUrl/HouseholdExpenses/date/$dateText',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load expenses for date. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid expenses list returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }


  // ============================================================
  // GET ONE EXPENSE
  // ============================================================

  static Future<Map<String, dynamic>> getExpense(
      int id,
      ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/HouseholdExpenses/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load expense. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid expense returned from API.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }


  // ============================================================
  // ADD EXPENSE
  // ============================================================

  static Future<int> addExpense({
    required int waslNo,
    required int cost,
    String? notes,
    required DateTime date,
    int? userId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/HouseholdExpenses',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'waslNo': waslNo,
        'cost': cost,
        'notes': notes,
        'date': date.toIso8601String(),
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _getErrorMessage(
          response,
          'Failed to add expense.',
        ),
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid response returned after adding expense.',
      );
    }

    final id = decoded['id'];

    if (id == null) {
      throw Exception(
        'Expense was added but no ID was returned.',
      );
    }

    return int.parse(id.toString());
  }


  // ============================================================
  // UPDATE EXPENSE
  // ============================================================

  static Future<void> updateExpense({
    required int id,
    required int waslNo,
    required int cost,
    String? notes,
    required DateTime date,
    int? userId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/HouseholdExpenses/$id',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'waslNo': waslNo,
        'cost': cost,
        'notes': notes,
        'date': date.toIso8601String(),
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _getErrorMessage(
          response,
          'Failed to update expense.',
        ),
      );
    }
  }


  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  static Future<void> deleteExpense(
      int id,
      ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/HouseholdExpenses/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _getErrorMessage(
          response,
          'Failed to delete expense.',
        ),
      );
    }
  }


  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  static String _getErrorMessage(
      http.Response response,
      String defaultMessage,
      ) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is String &&
          decoded.trim().isNotEmpty) {
        return decoded;
      }

      if (decoded is Map) {
        if (decoded['message'] != null) {
          return decoded['message'].toString();
        }

        if (decoded['title'] != null) {
          return decoded['title'].toString();
        }
      }
    } catch (_) {
      // Ignore invalid JSON and use the default message.
    }

    if (response.body.trim().isNotEmpty) {
      return '$defaultMessage ${response.body}';
    }

    return '$defaultMessage '
        'Status code: ${response.statusCode}';
  }
}