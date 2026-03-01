import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/doctor_data.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

class AdminAddDoctorScreen extends StatefulWidget {
  final String hospitalName;

  const AdminAddDoctorScreen({super.key, required this.hospitalName});

  @override
  State<AdminAddDoctorScreen> createState() => _AdminAddDoctorScreenState();
}

class _AdminAddDoctorScreenState extends State<AdminAddDoctorScreen> {
  static const Color primaryColor = Color(0xFF0F766E);
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _addDoctor() async {
    if (nameController.text.isEmpty ||
        specializationController.text.isEmpty ||
        departmentController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create Supabase Auth Account
      try {
        await SupabaseService.signUp(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      } on AuthException catch (ae) {
        // If user already exists, we can still proceed to save the SQL profile
        if (ae.code != 'user_already_exists') {
          rethrow;
        }
        debugPrint('Note: Auth user already exists, proceeding to SQL setup.');
      }

      // 2. Save Doctor Profile to SQL
      await ApiService.addDoctor(
        name: nameController.text,
        department: departmentController.text,
        specialization: specializationController.text,
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        hospitalName: widget.hospitalName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor profile configured successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          'Add New Doctor',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Doctor Credentials',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: specializationController,
                  label: 'Specialization (e.g. Surgeon)',
                  icon: Icons.star_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: departmentController,
                  label: 'Department',
                  icon: Icons.local_hospital_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: emailController,
                  label: 'Email Address',
                  icon: Icons.email_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: usernameController,
                  label: 'Username',
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _addDoctor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Doctor Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.grey.shade50,
      ),
    );
  }
}
