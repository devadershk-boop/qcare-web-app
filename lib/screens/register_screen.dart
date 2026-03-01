import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Sign up user in Supabase Auth
      await SupabaseService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. Insert patient details into 'patients' table
      // Note: In a real app, you'd probably link these by UID.
      // For now, we'll just insert as requested.
      await SupabaseService.registerPatient(
        name: _nameController.text.trim(),
        dob: DateTime.parse(_dobController.text.trim().split('/').reversed.join('-')), // Quick & dirty date parse
        contact: _contactController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const brandColor = Color(0xFF0F766E);
    
    // Background color based on theme
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    // Card color
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo / Header Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: brandColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 40,
                      color: brandColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    "Join Qcare",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Register for your patient account",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          controller: _dobController,
                          label: 'Date of Birth',
                          hint: 'DD/MM/YYYY',
                          icon: Icons.calendar_today_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          controller: _contactController,
                          label: 'Contact Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 32),

                        // Register Button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F766E), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F766E).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Back to Login Link
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black87,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 15,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: brandColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? hint,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    final fillColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black45),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2),
        ),
      ),
    );
  }
}
