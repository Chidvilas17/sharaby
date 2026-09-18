import 'dart:convert';
import 'package:http/http.dart' as http;

class OxygenCalculationApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // OLD ACCOUNT
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getOldAccount() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/OxygenCalculation/old-account',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load old account.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid old account data.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // OLD ACCOUNT TOTAL
  // ============================================================

  static Future<int> getOldAccountTotal() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/OxygenCalculation/old-account-total',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load old account total.',
      );
    }

    final decoded =
    Map<String, dynamic>.from(
      jsonDecode(response.body),
    );

    return int.tryParse(
      decoded['oldAccount']?.toString() ?? '0',
    ) ??
        0;
  }

  // ============================================================
  // OLD ACCOUNT DETAILS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getOldAccountDetails(int paymentId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/OxygenCalculation/old-account-details/$paymentId',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load old account details.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid old account details.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // PURCHASES SINCE LAST PAYMENT
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getPurchasesSinceLastPayment() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/OxygenCalculation/purchases-since-last-payment',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load oxygen purchases.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid oxygen purchase data.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // TOTAL ACCOUNT
  // ============================================================

  static Future<Map<String, dynamic>>
  getTotalAccount() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/OxygenCalculation/total-account',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load total account.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // COST
  // ============================================================

  static Future<int> getCost({
    required DateTime from,
    required DateTime to,
  }) async {
    final fromText =
    from.toIso8601String();

    final toText =
    to.toIso8601String();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/OxygenCalculation/cost'
            '?from=$fromText'
            '&to=$toText',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load cost.',
      );
    }

    final decoded =
    Map<String, dynamic>.from(
      jsonDecode(response.body),
    );

    return int.tryParse(
      decoded['cost']?.toString() ?? '0',
    ) ??
        0;
  }

  // ============================================================
  // SAVE PAYMENT
  // ============================================================

  static Future<Map<String, dynamic>>
  savePayment({
    required int paymentAmount,
    required String receiptNumber,
    required DateTime fromDate,
    required DateTime toDate,
    int? userId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/OxygenCalculation/payment',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'paymentAmount': paymentAmount,
        'receiptNumber': receiptNumber,
        'userId': userId,
        'fromDate':
        fromDate.toIso8601String(),
        'toDate':
        toDate.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to save oxygen payment.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }
}