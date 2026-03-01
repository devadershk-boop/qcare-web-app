import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import 'book_appointment_screen.dart';
import 'login_screen.dart';
import 'token_status_screen.dart';
import 'my_appointments_screen.dart';
import '../services/api_service.dart';

class PatientHomeScreen extends StatefulWidget {
  final String patientName;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  static const brandColor = Color(0xFF0F766E);
  static const bgColor = Color(0xFFF8FAFC);
  static const sidebarColor = Color(0xFFF1F5F9);

  const PatientHomeScreen({
    super.key,
    required this.patientName,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  Map<String, dynamic>? patientProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getPatientProfile(widget.patientName);
      if (mounted) {
        setState(() {
          patientProfile = profile;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1000;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : PatientHomeScreen.bgColor,
      body: isDesktop ? _buildDesktopLayout(context, isDark) : _buildMobileLayout(context, isDark),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        _buildSidebar(context, isDark),
        Expanded(
          child: Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Overview',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 32),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            children: [
                              _buildWebActionCard(
                                context: context,
                                icon: Icons.calendar_today_rounded,
                                title: 'Book Appointment',
                                subtitle: 'Schedule a visit with a doctor',
                                color: PatientHomeScreen.brandColor,
                                isDark: isDark,
                                width: (constraints.maxWidth - 24) / 2,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookAppointmentScreen(patientName: widget.patientName))),
                              ),
                              _buildWebActionCard(
                                context: context,
                                icon: Icons.confirmation_number_rounded,
                                title: 'View Token Status',
                                subtitle: 'Check your queue position',
                                color: Colors.orange.shade600,
                                isDark: isDark,
                                width: (constraints.maxWidth - 24) / 2,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TokenStatusScreen(patientName: widget.patientName))),
                              ),
                              _buildWebActionCard(
                                context: context,
                                icon: Icons.history_rounded,
                                title: 'My Appointments',
                                subtitle: 'Review your personal history',
                                color: Colors.indigoAccent,
                                isDark: isDark,
                                width: (constraints.maxWidth - 24) / 2,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyAppointmentsScreen(patientName: widget.patientName))),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qcare Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: PatientHomeScreen.brandColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _DashboardItem(
              icon: Icons.calendar_today_rounded,
              title: 'Book Appointment',
              subtitle: 'Schedule a visit with a doctor',
              color: PatientHomeScreen.brandColor,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookAppointmentScreen(patientName: widget.patientName))),
            ),
            const SizedBox(height: 16),
            _DashboardItem(
              icon: Icons.confirmation_number_rounded,
              title: 'View Token Status',
              subtitle: 'Check your queue position',
              color: Colors.orange.shade600,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TokenStatusScreen(patientName: widget.patientName))),
            ),
            const SizedBox(height: 16),
            _DashboardItem(
              icon: Icons.history_rounded,
              title: 'My Appointments',
              subtitle: 'Review your personal history',
              color: Colors.indigoAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyAppointmentsScreen(patientName: widget.patientName))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : PatientHomeScreen.sidebarColor,
        border: Border(right: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: PatientHomeScreen.brandColor, shape: BoxShape.circle),
                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Qcare',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: PatientHomeScreen.brandColor, letterSpacing: -1),
              ),
            ],
          ),
          const SizedBox(height: 60),
          _buildSidebarNavItem(Icons.dashboard_rounded, 'Overview', true, isDark),
          const SizedBox(height: 32),
          Text(
            'REGISTRATION PROFILE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white24 : Colors.blueGrey.shade300,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileInfoItem(Icons.person_outline_rounded, 'User Name', widget.patientName, isDark),
          _buildProfileInfoItem(Icons.email_outlined, 'Email', patientProfile?['email'] ?? 'Not provided', isDark),
          _buildProfileInfoItem(Icons.cake_outlined, 'DOB', patientProfile?['dob'] != null ? patientProfile!['dob'].toString().split('T')[0] : 'Not provided', isDark),
          _buildProfileInfoItem(Icons.phone_outlined, 'Contact', patientProfile?['contact'] ?? 'Not provided', isDark),
          const Spacer(),
          GestureDetector(
            onTap: widget.onToggleTheme,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : PatientHomeScreen.brandColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: PatientHomeScreen.brandColor, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    isDark ? 'Light Mode' : 'Dark Mode',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PatientHomeScreen.brandColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.patientName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const Text(
                'Verified Patient',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: PatientHomeScreen.brandColor.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, color: PatientHomeScreen.brandColor),
          ),
          const SizedBox(width: 24),
          const VerticalDivider(width: 1, indent: 20, endIndent: 20),
          const SizedBox(width: 24),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(IconData icon, String label, bool isActive, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? PatientHomeScreen.brandColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? PatientHomeScreen.brandColor : (isDark ? Colors.white38 : Colors.blueGrey), size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15, 
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? PatientHomeScreen.brandColor : (isDark ? Colors.white70 : Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required double width,
    required VoidCallback onTap,
  }) {
    return HoverItem(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.blueGrey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white38 : Colors.blueGrey.shade400),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.blueGrey.shade300,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.blueGrey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PatientHomeScreen.brandColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    onToggleTheme: widget.onToggleTheme,
                    themeMode: widget.themeMode,
                  ),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardItem extends StatelessWidget {
    final IconData icon;
    final String title;
    final String subtitle;
    final Color color;
    final VoidCallback onTap;
  
    const _DashboardItem({
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.color,
      required this.onTap,
    });
  
    @override
    Widget build(BuildContext context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
  
      return HoverItem(
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.blueGrey, size: 14),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
