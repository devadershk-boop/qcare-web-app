import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    } else {
      return 'http://192.168.1.2:5000';
    }
  }

  // -------------------------------
  // GET DOCTORS
  // -------------------------------
  static Future<List<dynamic>> getDoctors() async {
    final response = await http
        .get(Uri.parse('$baseUrl/doctors'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  // -------------------------------
  // POST APPOINTMENT
  // -------------------------------
  static Future<Map<String, dynamic>> bookAppointment({
    required String patientName,
    required String department,
    required String doctor,
    required String date,
    required String time,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'patientName': patientName,
        'department': department,
        'doctor': doctor,
        'date': date,
        'time': time,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to book appointment');
    }
  }
}
