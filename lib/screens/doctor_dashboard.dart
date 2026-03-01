import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/glass_widgets.dart';
import 'doctor_token_update_screen.dart';
import 'doctor_calendar_screen.dart';
import 'login_screen.dart';

class DoctorDashboard extends StatefulWidget {
  final String doctorName;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  static const brandColor = Color(0xFF0F766E);
  static const bgColor = Color(0xFFF8FAFC);
  static const sidebarColor = Color(0xFFF1F5F9);

  const DoctorDashboard({
    super.key,
    required this.doctorName,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  bool isOnBreak = false;
  bool isStatusLoading = true;
  bool isStatusUpdating = false;
  Map<String, dynamic>? doctorProfile;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await ApiService.getDoctorStatus(widget.doctorName);
      final profile = await ApiService.getDoctorProfile(widget.doctorName);
      if (mounted) {
        setState(() {
          isOnBreak = status['onBreak'] ?? false;
          doctorProfile = profile;
          isStatusLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isStatusLoading = false);
    }
  }

  Future<void> _toggleBreak(bool newValue) async {
    if (isStatusUpdating) return;

    final oldStatus = isOnBreak;
    setState(() {
      isOnBreak = newValue;
      isStatusUpdating = true;
    });

    try {
      await ApiService.toggleDoctorBreak(widget.doctorName, newValue);
    } catch (e) {
      if (mounted) {
        setState(() => isOnBreak = oldStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update status: $e"),
            backgroundColor: Colors.redAccent,
          )
        );
      }
    } finally {
      if (mounted) setState(() => isStatusUpdating = false);
    }
  }

  String get normalizedDoctorName {
    if (widget.doctorName.toLowerCase().startsWith("dr")) {
      return widget.doctorName;
    }
    return "Dr. ${widget.doctorName}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1000;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : DoctorDashboard.bgColor,
      body: isDesktop ? _buildDesktopLayout(context, isDark) : _buildMobileLayout(context, isDark),
    );
  }

  // =========================
  // DESKTOP LAYOUT (WEB STYLE)
  // =========================
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Doctor Overview',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              letterSpacing: -1,
                            ),
                          ),
                          _buildBreakToggle(isDark),
                        ],
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
                                icon: Icons.confirmation_number_rounded,
                                title: 'Update Token Status',
                                subtitle: 'Manage the live patient queue',
                                color: DoctorDashboard.brandColor,
                                isDark: isDark,
                                width: (constraints.maxWidth - 24) / 2,
                                onTap: () => Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (_) => DoctorTokenUpdateScreen(doctorName: widget.doctorName)
                                  )
                                ),
                              ),
                              _buildWebActionCard(
                                context: context,
                                icon: Icons.history_rounded,
                                title: 'Appointments History',
                                subtitle: 'View completed & upcoming appointments',
                                color: const Color(0xFF7C3AED),
                                isDark: isDark,
                                width: (constraints.maxWidth - 24) / 2,
                                onTap: () => Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (_) => DoctorCalendarScreen(doctorName: widget.doctorName)
                                  )
                                ),
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

  // =========================
  // MOBILE LAYOUT
  // =========================
  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : DoctorDashboard.bgColor,
      appBar: AppBar(
        title: const Text('Doctor Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: DoctorDashboard.brandColor,
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
            _buildBreakToggle(isDark, fullWidth: true),
            const SizedBox(height: 20),
            _DashboardItem(
              icon: Icons.confirmation_number_rounded,
              title: 'Update Token Status',
              subtitle: 'Manage the live patient queue',
              color: DoctorDashboard.brandColor,
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => DoctorTokenUpdateScreen(doctorName: widget.doctorName)
                )
              ),
            ),
            const SizedBox(height: 16),
            _DashboardItem(
              icon: Icons.history_rounded,
              title: 'Appointments History',
              subtitle: 'View completed & upcoming appointments',
              color: const Color(0xFF7C3AED),
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => DoctorCalendarScreen(doctorName: widget.doctorName)
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakToggle(bool isDark, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isOnBreak ? Colors.orange.withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isOnBreak ? Colors.orange.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isOnBreak ? Icons.coffee_rounded : Icons.work_off_outlined, color: isOnBreak ? Colors.orange : Colors.blueGrey, size: 20),
              const SizedBox(width: 12),
              Text(
                isOnBreak ? 'ON BREAK' : 'ACTIVE SESSION',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isOnBreak ? Colors.orange : Colors.blueGrey, letterSpacing: 0.5),
              ),
            ],
          ),
          if (fullWidth) const Spacer(),
          Switch.adaptive(
            value: isOnBreak,
            onChanged: isStatusUpdating ? null : (v) => _toggleBreak(v),
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : DoctorDashboard.sidebarColor,
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
                decoration: const BoxDecoration(color: DoctorDashboard.brandColor, shape: BoxShape.circle),
                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Qcare',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: DoctorDashboard.brandColor, letterSpacing: -1),
              ),
            ],
          ),
          const SizedBox(height: 60),
          _buildSidebarNavItem(Icons.dashboard_rounded, 'Overview', true, isDark),
          const SizedBox(height: 32),
          Text(
            'DOCTOR PROFILE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white24 : Colors.blueGrey.shade300,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileInfoItem(Icons.person_outline_rounded, 'Doctor Name', normalizedDoctorName, isDark),
          _buildProfileInfoItem(Icons.domain_rounded, 'Department', doctorProfile?['department_name'] ?? 'General', isDark),
          _buildProfileInfoItem(Icons.medical_services_outlined, 'Specialization', doctorProfile?['specialization'] ?? 'Not specified', isDark),
          _buildProfileInfoItem(Icons.email_outlined, 'Email ID', doctorProfile?['email'] ?? 'Not specified', isDark),
          const Spacer(),
          GestureDetector(
            onTap: widget.onToggleTheme,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : DoctorDashboard.brandColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: DoctorDashboard.brandColor, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    isDark ? 'Light Mode' : 'Dark Mode',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: DoctorDashboard.brandColor),
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
                normalizedDoctorName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              Text(
                doctorProfile?['designation'] ?? 'Senior Consultant',
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: DoctorDashboard.brandColor.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, color: DoctorDashboard.brandColor),
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
          color: isActive ? DoctorDashboard.brandColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? DoctorDashboard.brandColor : (isDark ? Colors.white38 : Colors.blueGrey), size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15, 
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? DoctorDashboard.brandColor : (isDark ? Colors.white70 : Colors.blueGrey),
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
              backgroundColor: DoctorDashboard.brandColor,
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
