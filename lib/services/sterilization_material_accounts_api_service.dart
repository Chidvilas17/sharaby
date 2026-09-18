import 'dart:convert';
import 'package:http/http.dart' as http;

class SterilizationMaterialAccountsApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET PAYMENTS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getPayments() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/SterilizationMaterialAccounts/payments',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load account payments. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid account payments returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET PAYMENT DETAILS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getPaymentDetails(int paymentId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/SterilizationMaterialAccounts/details/$paymentId',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load account details.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid account details returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET PURCHASES SINCE LAST PAYMENT
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getPurchasesSinceLastPayment() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/SterilizationMaterialAccounts/'
            'purchases-since-last-payment',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load purchases since last payment.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid purchase data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET ACCOUNT SUMMARY
  // ============================================================

  static Future<Map<String, dynamic>>
  getSummary() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/SterilizationMaterialAccounts/summary',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load account summary.',
      );
    }

    final decoded = jsonDecode(response.body);

    return Map<String, dynamic>.from(decoded);
  }

  // ============================================================
  // GET COST
  // ============================================================

  static Future<int> getCost({
    required DateTime from,
    required DateTime to,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/SterilizationMaterialAccounts/cost',
    ).replace(
      queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      },
    );

    final response = await http.get(uri);

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
    int? userId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/SterilizationMaterialAccounts/payment',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'paymentAmount': paymentAmount,
        'receiptNumber': receiptNumber,
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to save payment.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }
}