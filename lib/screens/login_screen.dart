import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'patient_home_screen.dart';
import 'doctor_dashboard.dart';
import 'admin_dashboard.dart';
import '../data/doctor_data.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';

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
  bool _passwordVisible = false;
  bool _isLoading = false;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final hospitalNameController = TextEditingController();

  static const Color primaryTeal = Color(0xFF0F766E);

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    hospitalNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: isMobile ? _buildMobileLayout(isDark) : _buildDesktopLayout(isDark),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        // LEFT PANEL: Branding (Rectangular Split)
        Expanded(
          flex: 4,
          child: Container(
            color: primaryTeal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // Centered branding
                children: [
                  // App Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      size: 80, // Larger logo for better presence
                      color: primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Qcare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Premium Hospital Queue & Appointment System for Modern Healthcare.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for theme toggle at bottom area
                  GestureDetector(
                    onTap: widget.onToggleTheme,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDark ? 'LIGHT MODE' : 'DARK MODE',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // RIGHT PANEL: Form
        Expanded(
          flex: 6,
          child: Container(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 1400 ? MediaQuery.of(context).size.width * 0.1 : 60,
              vertical: 40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: _buildLoginForm(isDark),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        // TOP PANEL: Branding (Compact Rectangle)
        Container(
          width: double.infinity,
          height: 220, // Slightly taller for better centering
          color: primaryTeal,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.local_hospital_rounded, color: primaryTeal, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Qcare',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                  onPressed: widget.onToggleTheme,
                ),
              ),
            ],
          ),
        ),
        // BOTTOM PANEL: Form
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: _buildLoginForm(isDark, isMobile: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isDark, {bool isMobile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sign In',
          style: TextStyle(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 30),
        
        // Custom Segmented Role Selector
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: ['Patient', 'Doctor', 'Admin'].map((role) {
              final isSelected = selectedRole == role;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedRole = role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryTeal : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      role,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : (isDark ? Colors.white38 : Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 30),

        _professionalTextField(
          controller: usernameController,
          label: 'Username',
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        if (selectedRole == 'Admin') ...[
          _professionalTextField(
            controller: hospitalNameController,
            label: 'Hospital Name',
            isDark: isDark,
          ),
          const SizedBox(height: 20),
        ],
        _professionalTextField(
          controller: emailController,
          label: 'E-mail Address',
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _professionalTextField(
          controller: passwordController,
          label: 'Password',
          isDark: isDark,
          obscure: !_passwordVisible,
          suffix: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: 20,
              color: isDark ? Colors.white38 : Colors.blueGrey.shade300,
            ),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
        ),

        const SizedBox(height: 40),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
              ),
            ),
            if (selectedRole == 'Patient') ...[
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryTeal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal),
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ],
    );
  }

  Widget _professionalTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white38 : Colors.blueGrey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Enter your ${label.toLowerCase()}',
            hintStyle: TextStyle(color: isDark ? Colors.white10 : Colors.blueGrey.shade200, fontSize: 13),
            suffixIcon: suffix,
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.blueGrey.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.blueGrey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    if (selectedRole == 'Patient') {
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your email and password")),
        );
        return;
      }
    } else {
      if (username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your username")),
        );
        return;
      }
    }

    if (selectedRole == 'Doctor') {
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your email and password")),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // 1. Sign in with Supabase
        await SupabaseService.signIn(email, password);

        // 2. Fetch Doctor Info from Backend
        final doctor = await ApiService.getDoctorProfileByEmail(email);

        if (doctor != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorDashboard(
                  doctorName: doctor['name']!,
                  onToggleTheme: widget.onToggleTheme,
                  themeMode: widget.themeMode,
                ),
              ),
            );
          }
        } else {
          throw Exception("Doctor profile not found in database.");
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = "Login Failed: ${e.toString()}";
          
          if (e.toString().contains("Failed to fetch") || e.toString().contains("ClientException")) {
            errorMessage = "Connection Failed: Unable to reach Supabase. If you are in India, please try using a VPN or an alternative DNS (like Google DNS or Cloudflare), as some ISPs are currently blocking Supabase.";
          } else if (e.toString().contains("Invalid login credentials")) {
            errorMessage = "Invalid email or password. Please try again.";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (selectedRole == 'Patient') {
      setState(() => _isLoading = true);
      try {
        // 1. Sign in with Supabase Auth
        await SupabaseService.signIn(email, password);

        // 2. Fetch Patient Name from database
        final profile = await SupabaseService.getPatientProfile(email);
        final patientName = profile != null ? profile['name'] : email.split('@')[0];

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PatientHomeScreen(
                patientName: patientName,
                onToggleTheme: widget.onToggleTheme,
                themeMode: widget.themeMode,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = "Login Failed: ${e.toString()}";
          
          if (e.toString().contains("Failed to fetch") || e.toString().contains("ClientException")) {
            errorMessage = "Connection Failed: Unable to reach Supabase. If you are in India, please try using a VPN or an alternative DNS (like Google DNS or Cloudflare), as some ISPs are currently blocking Supabase.";
          } else if (e.toString().contains("Invalid login credentials")) {
            errorMessage = "Invalid email or password. Please try again.";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Admin Logic
      if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your admin password")),
        );
        return;
      }
      if (hospitalNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the Hospital Name")),
        );
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        await ApiService.adminLogin(
          username, 
          hospitalNameController.text.trim(), 
          password,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(
                hospitalName: hospitalNameController.text.trim(),
                username: username,
                onToggleTheme: widget.onToggleTheme,
                themeMode: widget.themeMode,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Admin Login Failed: ${e.toString().replaceAll('Exception: ', '')}"),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
