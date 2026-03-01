import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

void main() async {
  print('--- Supabase Connectivity Test ---');
  
  const url = 'https://kkhyyhqlsrsayainqgwj.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtraHl5aHFsc3JzYXlhaW5xZ3dqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyMDU2MTYsImV4cCI6MjA4Nzc4MTYxNn0.QNb_zUjDfFy0CwaISXqIc0VW2-4JB8piaUym4WkmGX8';

  print('Attempting to initialize Supabase with:');
  print('URL: $url');
  
  try {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    
    final client = Supabase.instance.client;
    
    print('Initialization successful.');
    print('Testing basic network reachability to the health endpoint (5s timeout)...');
    
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse('$url/rest/v1/'))
        .timeout(const Duration(seconds: 5));
    final response = await request.close()
        .timeout(const Duration(seconds: 5));
    
    if (response.statusCode == 200 || response.statusCode == 401) { // 401 is expected if no key is sent, but means server is alive
      print('✅ Supabase server is REACHABLE (HTTP ${response.statusCode})');
    } else {
      print('❌ Supabase server returned unexpected status: ${response.statusCode}');
    }

    print('Attempting to check if project is active by listing a public table (5s timeout)...');
    try {
      // Just a dummy query to see if the project is awake
       await client.from('doctors').select().limit(1)
           .timeout(const Duration(seconds: 5));
       print('✅ Project is ACTIVE and responding to queries.');
    } catch (e) {
      if (e.toString().contains('503') || e.toString().contains('paused')) {
        print('⚠️ PROJECT APPEARS TO BE PAUSED or UNREACHABLE (503 Service Unavailable).');
      } else if (e is TimeoutException) {
        print('❌ Connection TIMED OUT. The server might be down or your network is blocked.');
      } else {
        print('ℹ️ Query failed (expected if RLS is on or table doesn\'t exist): ${e.toString()}');
        print('✅ Server responded, so project is NOT paused.');
      }
    }

  } catch (e) {
    print('❌ FATAL ERROR during test: $e');
    if (e.toString().contains('Failed host lookup')) {
      print('💡 This usually means you have no internet connection or the URL is wrong.');
    } else if (e.toString().contains('Connection refused')) {
      print('💡 The server is rejecting connections. Check if Supabase services are down.');
    }
  } finally {
    print('--- Test Complete ---');
    exit(0);
  }
}
