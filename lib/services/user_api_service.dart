import 'dart:convert';
import 'package:http/http.dart' as http;

class UserApiService {
  static const String baseUrl = 'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL USERS
  // ============================================================

  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Users'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load users. Status code: ${response.statusCode}',
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String logId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Users/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'log_id': logId,
        'user_password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Wrong Log in ID or Password.',
      );
    }

    if (response.statusCode == 400) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Please enter Log in ID and Password.',
      );
    }

    throw Exception(
      'Login failed. Status code: ${response.statusCode}',
    );
  }

  // ============================================================
  // SEARCH USER
  // ============================================================

  static Future<Map<String, dynamic>> searchUser(
      String loginId,
      ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/Users/search/${Uri.encodeComponent(loginId)}',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 404) {
      throw Exception('User not found.');
    }

    throw Exception(
      'Failed to search user. Status code: ${response.statusCode}',
    );
  }

  // ============================================================
  // ADD USER
  // ============================================================

  static Future<int> addUser({
    required String userName,
    required String password,
    required String logId,
    int? manageId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Users'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_name': userName,
        'user_password': password,
        'log_id': logId,
        'manageID': manageId,
      }),
    );

    if (response.statusCode == 200) {
      final data =
      jsonDecode(response.body) as Map<String, dynamic>;

      return data['user_id'] as int;
    }

    if (response.statusCode == 409) {
      throw Exception(
        'A user with this Login ID already exists.',
      );
    }

    if (response.statusCode == 400) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Please check the entered information.',
      );
    }

    throw Exception(
      'Failed to add user. Status code: ${response.statusCode}',
    );
  }

  // ============================================================
  // UPDATE USER
  // ============================================================

  static Future<void> updateUser({
    required int userId,
    required String userName,
    required String password,
    required String logId,
    int? manageId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Users/$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_name': userName,
        'user_password': password,
        'log_id': logId,
        'manageID': manageId,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 404) {
      throw Exception('User not found.');
    }

    if (response.statusCode == 409) {
      throw Exception(
        'A different user already uses this Login ID.',
      );
    }

    throw Exception(
      'Failed to update user. Status code: ${response.statusCode}',
    );
  }

  // ============================================================
  // DELETE USER
  // ============================================================

  static Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Users/$userId'),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 404) {
      throw Exception('User not found.');
    }

    throw Exception(
      'Failed to delete user. Status code: ${response.statusCode}',
    );
  }

  // ============================================================
  // UPDATE ADMIN DETAILS
  //
  // Admin screen:
  //
  // User name  -> log_id
  // Password   -> user_password
  // Password 2 -> Password
  // ============================================================

  static Future<void> updateAdminDetails({
    required String userName,
    required String password,
    required String password2,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Users/admin/password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userName': userName,
        'password': password,
        'password2': password2,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 400) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Please check the entered information.',
      );
    }

    if (response.statusCode == 404) {
      throw Exception('Admin user not found.');
    }

    if (response.statusCode == 409) {
      throw Exception(
        'A different user already uses this Login ID.',
      );
    }

    throw Exception(
      'Failed to update Admin details. '
          'Status code: ${response.statusCode}',
    );
  }
}