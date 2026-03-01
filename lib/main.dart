import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kkhyyhqlsrsayainqgwj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtraHl5aHFsc3JzYXlhaW5xZ3dqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyMDU2MTYsImV4cCI6MjA4Nzc4MTYxNn0.QNb_zUjDfFy0CwaISXqIc0VW2-4JB8piaUym4WkmGX8',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hospital Queue System',
      themeMode: _themeMode,

      // 🌞 LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
        ),
      ),

      // 🌙 DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
      ),

      home: LoginScreen(
        onToggleTheme: toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}
