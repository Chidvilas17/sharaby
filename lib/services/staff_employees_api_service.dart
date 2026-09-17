import 'dart:convert';
import 'package:http/http.dart' as http;

class StaffEmployeesApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL EMPLOYEES
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getEmployees() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/StaffEmployees',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load employees.\n'
            '${response.body}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid employee list.',
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
  // GET JOB CATEGORIES
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getCategories() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/StaffEmployees/categories',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load job categories.\n'
            '${response.body}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid category list.',
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
  // SEARCH BY JOB
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  searchEmployees({
    int? catId,
  }) async {
    String url =
        '$baseUrl/StaffEmployees/search';

    if (catId != null) {
      url += '?catId=$catId';
    }

    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to search employees.\n'
            '${response.body}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid search result.',
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
  // ADD EMPLOYEE
  // ============================================================

  static Future<int> addEmployee({
    required String name,
    required String phone1,
    required String phone2,
    required String address,
    required String cardNumber,
    required int catId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/StaffEmployees',
      ),
      headers: {
        'Content-Type':
        'application/json',
      },
      body: jsonEncode({
        'name': name,
        'phone1': phone1,
        'phone2': phone2,
        'address': address,
        'national_Id': cardNumber,
        'cat_Id': catId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to add employee.\n'
            '${response.body}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    return decoded['id'] as int;
  }

  // ============================================================
  // UPDATE EMPLOYEE
  // ============================================================

  static Future<void> updateEmployee({
    required int id,
    required String name,
    required String phone1,
    required String phone2,
    required String address,
    required String cardNumber,
    required int catId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/StaffEmployees/$id',
      ),
      headers: {
        'Content-Type':
        'application/json',
      },
      body: jsonEncode({
        'name': name,
        'phone1': phone1,
        'phone2': phone2,
        'address': address,
        'national_Id': cardNumber,
        'cat_Id': catId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update employee.\n'
            '${response.body}',
      );
    }
  }

  // ============================================================
  // DELETE EMPLOYEE
  // ============================================================

  static Future<void> deleteEmployee(
      int id,
      ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/StaffEmployees/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete employee.\n'
            '${response.body}',
      );
    }
  }
}