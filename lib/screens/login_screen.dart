import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'patient_home_screen.dart';
import 'doctor_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const LoginScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'Patient';

  static const Color primaryColor = Color(0xFF0F766E); // Qcare teal

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔷 HEADER (ALIGNMENT FIXED)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 36),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Stack(
                  children: [
                    // Centered content
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(height: 8),
                          Icon(
                            Icons.local_hospital,
                            size: 64,
                            color: Colors.white,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Qcare',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Smart Appointment & Token Management',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Theme toggle (aligned properly)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        splashRadius: 22,
                        icon: Icon(
                          widget.themeMode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: Colors.white,
                        ),
                        onPressed: widget.onToggleTheme,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔷 LOGIN FORM
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Text(
                      '$selectedRole Login',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.textTheme.bodyMedium!
                            .color!
                            .withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Role dropdown
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      dropdownColor:
                          isDark ? const Color(0xFF1F1F1F) : Colors.white,
                      items: const [
                        DropdownMenuItem(
                            value: 'Patient', child: Text('Patient')),
                        DropdownMenuItem(
                            value: 'Doctor', child: Text('Doctor')),
                        DropdownMenuItem(
                            value: 'Admin', child: Text('Admin')),
                      ],
                      onChanged: (value) {
                        setState(() => selectedRole = value!);
                      },
                      decoration: InputDecoration(
                        labelText: 'Login As',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF1F1F1F) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF1F1F1F) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF1F1F1F) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedRole == 'Patient') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const PatientHomeScreen()),
                            );
                          } else if (selectedRole == 'Doctor') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const DoctorDashboard()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminDashboard()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Register / Info
                    Center(
                      child: selectedRole == 'Patient'
                          ? TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const RegisterScreen()),
                                );
                              },
                              child: const Text(
                                "Don't have an account? Register",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor,
                                ),
                              ),
                            )
                          : Text(
                              selectedRole == 'Doctor'
                                  ? 'Doctor accounts are created by admin'
                                  : 'Admin access is restricted',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium!
                                    .color!
                                    .withOpacity(0.6),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
