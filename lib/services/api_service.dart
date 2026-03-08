import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {

  // =========================
  // BASE URL
  // =========================
  // =========================
  // BASE URL
  // =========================
  // TIP: You can pass your actual Vercel backend URL during build using:
  // flutter build web --release --dart-define=BASE_URL=https://your-real-backend.vercel.app
  static String get baseUrl {
    const String? definedUrl = String.fromEnvironment('BASE_URL');
    if (definedUrl != null && definedUrl.isNotEmpty) {
      return definedUrl;
    }

    if (kReleaseMode) {
      // Current production backend on Render
      return 'https://qcare-web-app.onrender.com'; 
    } else if (kIsWeb) {
      return 'http://localhost:5000';
    } else {
      return 'http://10.0.2.2:5000'; // Android Emulator default
    }
  }

  // =========================
  // GET DOCTORS
  // =========================
  static Future<List<dynamic>> getDoctors() async {
    final res = await http.get(Uri.parse('$baseUrl/doctors'));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  // =========================
  // BOOK APPOINTMENT
  // =========================
  static Future<Map<String, dynamic>> bookAppointment({
    required String patientName,
    required String department,
    required String doctor,
    required String date,
  }) async {

    final res = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "patientName": patientName,
        "department": department,
        "doctor": doctor,
        "date": date,
      }),
    );

    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Booking failed');
    }
  }

  // =========================
  // GET APPOINTMENTS BY PATIENT
  // =========================
  static Future<List<dynamic>> getAppointments(
      String patientName) async {

    final safe =
        Uri.encodeComponent(patientName);

    final res = await http.get(
      Uri.parse('$baseUrl/appointments/patient/$safe'),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  // =========================
  // GET ALL APPOINTMENTS
  // =========================
  static Future<List<dynamic>> getAllAppointments() async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments'),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load queue');
    }
  }

  // =========================
  // GET DOCTOR QUEUE
  // =========================
  static Future<List<dynamic>> getDoctorQueue(
      String doctor, {String? date, String? filter}) async {

    final safe = Uri.encodeComponent(doctor);
    
    String url = '$baseUrl/appointments/doctor/$safe';
    List<String> queryParams = [];
    
    if (date != null) queryParams.add('date=$date');
    if (filter != null) queryParams.add('filter=$filter');
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed doctor queue');
    }
  }

  // =========================
  // GET DEPARTMENT WAIT TIMES
  // =========================
  static Future<List<dynamic>> getWaitTimes() async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/status/waittimes'),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load wait times');
    }
  }

  // =========================
  // UPDATE APPOINTMENT STATUS
  // =========================
  static Future<void> updateAppointmentStatus(int appointmentId, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/appointments/$appointmentId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status: ${response.body}');
    }
  }

  // =========================
  // CALL NEXT PATIENT
  // =========================
  static Future<Map<String, dynamic>> callNext(
      String doctor, {String? date}) async {

    final safe = Uri.encodeComponent(doctor);
    final url = date != null 
        ? '$baseUrl/appointments/call-next/$safe?date=$date'
        : '$baseUrl/appointments/call-next/$safe';

    final res = await http.post(Uri.parse(url));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('No waiting patients');
    }
  }

  // =========================
  // FETCH ALL DOCTOR APPOINTMENTS (history)
  // =========================
  static Future<List<dynamic>> fetchDoctorAllAppointments(
    String doctor, {
    int? year,
    int? month,
    String? date,
  }) async {
    final safe = Uri.encodeComponent(doctor);
    final params = <String, String>{};
    if (date != null) {
      params['date'] = date;
    } else {
      if (year != null) params['year'] = year.toString();
      if (month != null) params['month'] = month.toString();
    }

    final uri = Uri.parse('$baseUrl/appointments/doctor/$safe/all')
        .replace(queryParameters: params.isEmpty ? null : params);

    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load appointments history');
    }
  }

  // =========================
  // DOCTOR STATUS (Breaks, etc.)
  // =========================
  static Future<Map<String, dynamic>> getDoctorStatus(String doctor) async {
    final safe = Uri.encodeComponent(doctor);
    final res = await http.get(Uri.parse('$baseUrl/doctors/status/$safe'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      return {'onBreak': false};
    }
  }

  static Future<void> toggleDoctorBreak(String doctor, bool onBreak) async {
    final safe = Uri.encodeComponent(doctor);
    final res = await http.post(
      Uri.parse('$baseUrl/doctors/status/$safe/break'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"onBreak": onBreak}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to toggle break');
    }
  }

  // =========================
  // GET DOCTOR PROFILE
  // =========================
  static Future<Map<String, dynamic>> getDoctorProfile(String doctorName) async {
    final safe = Uri.encodeComponent(doctorName);
    final res = await http.get(Uri.parse('$baseUrl/doctors/profile/$safe'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load doctor profile');
    }
  }

  // =========================
  // GET PATIENT PROFILE
  // =========================
  static Future<Map<String, dynamic>> getPatientProfile(String patientName) async {
    final safe = Uri.encodeComponent(patientName);
    final res = await http.get(Uri.parse('$baseUrl/patients/profile/$safe'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load patient profile');
    }
  }

  // =========================
  // ADMIN LOGIN
  // =========================
  static Future<Map<String, dynamic>> adminLogin(
      String username, String hospitalName, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admins/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "hospital_name": hospitalName,
        "password": password,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      try {
        final error = jsonDecode(res.body);
        throw Exception(error['error'] ?? 'Admin login failed');
      } catch (_) {
        throw Exception('Admin login failed with status ${res.statusCode}');
      }
    }
  }

  // =========================
  // ADD DOCTOR
  // =========================
  static Future<void> addDoctor({
    required String name,
    required String department,
    required String username,
    required String email,
    required String password,
    required String hospitalName,
    String specialization = 'General Physician',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/doctors'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "department": department,
        "specialization": specialization,
        "username": username,
        "email": email,
        "password": password,
        "hospital_name": hospitalName,
      }),
    );

    if (res.statusCode != 201) {
      try {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['details'] ?? 'Failed to add doctor');
      } catch (e) {
        throw Exception('Server error (${res.statusCode}): ${res.body.isNotEmpty ? res.body : "No response body"}');
      }
    }
  }

  // =========================
  // UPDATE DOCTOR
  // =========================
  static Future<void> updateDoctor(int doctorId, {
    required String name,
    required String department,
    required String specialization,
    required String hospitalName,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/doctors/$doctorId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "department": department,
        "specialization": specialization,
        "hospital_name": hospitalName,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update doctor');
    }
  }

  // =========================
  // DELETE DOCTOR
  // =========================
  static Future<void> deleteDoctor(int doctorId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/doctors/$doctorId'),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to delete doctor');
    }
  }
  // =========================
  // GET DOCTOR PROFILE BY EMAIL
  // =========================
  static Future<Map<String, dynamic>?> getDoctorProfileByEmail(String email) async {
    final list = await getDoctors();
    try {
      return list.firstWhere((doc) => doc['email'] == email);
    } catch (e) {
      return null;
    }
  }
}
