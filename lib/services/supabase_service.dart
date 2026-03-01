import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Authentication Methods
  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // User Methods
  static User? get currentUser => client.auth.currentUser;

  // Database Methods (Generic example)
  static Future<List<Map<String, dynamic>>> fetchData(String table) async {
    return await client.from(table).select();
  }

  // Patient Specific Methods
  static Future<void> registerPatient({
    required String name,
    required DateTime dob,
    required String contact,
    required String email,
  }) async {
    await client.from('patients').insert({
      'name': name,
      'dob': dob.toIso8601String(),
      'contact': contact,
      'email': email,
    });
  }

  static Future<Map<String, dynamic>?> getPatientProfile(String email) async {
    final response = await client
        .from('patients')
        .select()
        .eq('email', email)
        .maybeSingle();
    return response;
  }

  // Realtime Methods (Generic example)
  static Stream<List<Map<String, dynamic>>> streamData(String table) {
    return client.from(table).stream(primaryKey: ['id']);
  }
}
