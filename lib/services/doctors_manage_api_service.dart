import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorsManageApiService {
  static const String baseUrl = 'http://10.0.2.2:5137/api';

  static Future<Map<String, dynamic>> getMedical(int medId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/DoctorsManage/$medId'),
    );
    _check(response, 'Failed to load medical record.');
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  static Future<Map<String, dynamic>> getPatient(int patientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/DoctorsManage/patients/$patientId'),
    );
    _check(response, 'Failed to load patient.');
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  static Future<List<Map<String, dynamic>>> getTypes() async {
    return _getList('/DoctorsManage/types', 'Failed to load types.');
  }

  static Future<List<Map<String, dynamic>>> getCo() async {
    return _getList('/DoctorsManage/co', 'Failed to load C/O.');
  }

  static Future<List<Map<String, dynamic>>> getDiagnosis() async {
    return _getList('/DoctorsManage/diagnosis', 'Failed to load diagnosis.');
  }

  static Future<List<Map<String, dynamic>>> getTtt() async {
    return _getList('/DoctorsManage/ttt', 'Failed to load treatments.');
  }

  static Future<List<Map<String, dynamic>>> getDose() async {
    return _getList('/DoctorsManage/dose', 'Failed to load doses.');
  }

  static Future<List<Map<String, dynamic>>> getHistory(int patientId) async {
    return _getList(
      '/DoctorsManage/history/$patientId',
      'Failed to load medical history.',
    );
  }

  static Future<int> createMedical(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/DoctorsManage'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    _check(response, 'Failed to save medical record.');
    final decoded = Map<String, dynamic>.from(jsonDecode(response.body));
    return (decoded['medId'] as num?)?.toInt() ?? 0;
  }

  static Future<void> updateMedical(
      int medId,
      Map<String, dynamic> data,
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/DoctorsManage/$medId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    _check(response, 'Failed to update medical record.');
  }

  static Future<void> deleteMedical(int medId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/DoctorsManage/$medId'),
    );
    _check(response, 'Failed to delete medical record.');
  }

  static Future<Map<String, dynamic>> addCo(String name) async {
    return _addName('/DoctorsManage/co', name, 'Failed to add C/O.');
  }

  static Future<Map<String, dynamic>> addDiagnosis(String name) async {
    return _addName(
      '/DoctorsManage/diagnosis',
      name,
      'Failed to add diagnosis.',
    );
  }

  static Future<Map<String, dynamic>> addTtt(String name) async {
    return _addName('/DoctorsManage/ttt', name, 'Failed to add treatment.');
  }

  static Future<Map<String, dynamic>> addDose(String name) async {
    return _addName('/DoctorsManage/dose', name, 'Failed to add dose.');
  }

  static Future<List<Map<String, dynamic>>> _getList(
      String path,
      String error,
      ) async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    _check(response, error);

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('$error Invalid list returned by API.');
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  static Future<Map<String, dynamic>> _addName(
      String path,
      String name,
      String error,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    _check(response, error);
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  static void _check(http.Response response, String message) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('$message\n${response.body}');
    }
  }
}
