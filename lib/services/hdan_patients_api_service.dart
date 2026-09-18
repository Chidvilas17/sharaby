import 'dart:convert';
import 'package:http/http.dart' as http;

class HdanPatientsApiService {
  static const String baseUrl =
      'http://10.0.2.2:5137/api';

  // ============================================================
  // GET ALL PATIENTS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getPatients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/HdanPatients'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load nursery patients. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid nursery patient data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET ONE PATIENT
  // ============================================================

  static Future<Map<String, dynamic>> getPatient(
      int id,
      ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/HdanPatients/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to load patient.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // GET DOCTORS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getDoctors() async {
    final response = await http.get(
      Uri.parse('$baseUrl/HdanPatients/doctors'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load doctors. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid doctor data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // GET TREATMENT TYPES
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getTreatmentTypes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/HdanPatients/treatment-types'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load treatment types. '
            'Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid treatment type data returned from API.',
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // ADD PATIENT
  // ============================================================

  static Future<Map<String, dynamic>> addPatient({
    required String name,
    String? address,
    String? phone,
    String? phone2,
    String? phone3,
    String? card,
    String? fromDr,
    String? shiftDr,
    String? managerDr,
    DateTime? timeOfIn,
    String? doctorsOfBorn,
    DateTime? timeOfBorn,
    String? type,
    int? userOfAdd,
    int? drOfAdd,
    int? hourBorn,
    String? cardOwner,
    int? age,
    String? gender,
    String? p,
    int? amountOfP,
    String? g,
    int? amountOfG,
    String? riskFactor,
    String? presnentedE,
    String? archive,
    DateTime? dateOfOut,
    String? convertedTo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/HdanPatients'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'address': address,
        'phone': phone,
        'phone2': phone2,
        'phone3': phone3,
        'card': card,
        'from_Dr': fromDr,
        'shift_Dr': shiftDr,
        'manager_Dr': managerDr,
        'time_of_in': timeOfIn?.toIso8601String(),
        'doctorsOf_born': doctorsOfBorn,
        'time_of_born': timeOfBorn?.toIso8601String(),
        'type': type,
        'userOfAdd': userOfAdd,
        'drOfAdd': drOfAdd,
        'hour_Born': hourBorn,
        'card_owner': cardOwner,
        'age': age,
        'gender': gender,
        'p_': p,
        'amount_of_p': amountOfP,
        'g_': g,
        'amount_of_g': amountOfG,
        'risk_Factor': riskFactor,
        'presnented_e': presnentedE,
        'archive': archive,
        'date_of_out': dateOfOut?.toIso8601String(),
        'converted_to': convertedTo,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to add nursery patient.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // UPDATE PATIENT
  // ============================================================

  static Future<Map<String, dynamic>> updatePatient({
    required int id,
    required String name,
    String? address,
    String? phone,
    String? phone2,
    String? phone3,
    String? card,
    String? fromDr,
    String? shiftDr,
    String? managerDr,
    DateTime? timeOfIn,
    String? doctorsOfBorn,
    DateTime? timeOfBorn,
    String? type,
    int? userOfAdd,
    int? drOfAdd,
    int? hourBorn,
    String? cardOwner,
    int? age,
    String? gender,
    String? p,
    int? amountOfP,
    String? g,
    int? amountOfG,
    String? riskFactor,
    String? presnentedE,
    String? archive,
    DateTime? dateOfOut,
    String? convertedTo,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/HdanPatients/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'address': address,
        'phone': phone,
        'phone2': phone2,
        'phone3': phone3,
        'card': card,
        'from_Dr': fromDr,
        'shift_Dr': shiftDr,
        'manager_Dr': managerDr,
        'time_of_in': timeOfIn?.toIso8601String(),
        'doctorsOf_born': doctorsOfBorn,
        'time_of_born': timeOfBorn?.toIso8601String(),
        'type': type,
        'userOfAdd': userOfAdd,
        'drOfAdd': drOfAdd,
        'hour_Born': hourBorn,
        'card_owner': cardOwner,
        'age': age,
        'gender': gender,
        'p_': p,
        'amount_of_p': amountOfP,
        'g_': g,
        'amount_of_g': amountOfG,
        'risk_Factor': riskFactor,
        'presnented_e': presnentedE,
        'archive': archive,
        'date_of_out': dateOfOut?.toIso8601String(),
        'converted_to': convertedTo,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to update nursery patient.',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  // ============================================================
  // DELETE PATIENT
  // ============================================================

  static Future<void> deletePatient(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/HdanPatients/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Failed to delete nursery patient.',
      );
    }
  }
}