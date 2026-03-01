import 'package:flutter/material.dart';
import 'admin_manage_doctors_screen.dart';
import 'admin_add_doctor_screen.dart';
import 'login_screen.dart';

import '../widgets/glass_widgets.dart';

class AdminDashboard extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  final String hospitalName;
  final String username;

  static const Color primaryColor = Color(0xFF0F766E); // Qcare teal
  static const bgColor = Color(0xFFF8FAFC);
  static const sidebarColor = Color(0xFFF1F5F9);

  const AdminDashboard({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
    required this.username,
    this.hospitalName = 'Super User',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1000;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : bgColor,
      body: isDesktop ? _buildDesktopLayout(context, isDark) : _buildMobileLayout(context, isDark),
    );
  }

  // =========================
  // DESKTOP LAYOUT (WEB STYLE)
  // =========================
  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        // SIDEBAR
        _buildSidebar(context, isDark),
        
        // MAIN CONTENT AREA
        Expanded(
          child: Column(
            children: [
              // Header Top Bar
              _buildHeader(context, isDark),
              
              // Dashboard Grid Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Overview',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // ⚡ QUICK ACTIONS SECTION
                      Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: primaryColor.withOpacity(0.8), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickActionBtn(
                              context: context,
                              icon: Icons.person_add_rounded,
                              label: 'Add Doctor',
                              isDark: isDark,
                              onTap: () => Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (_) => AdminAddDoctorScreen(hospitalName: hospitalName))
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildQuickActionBtn(
                              context: context,
                              icon: Icons.bar_chart_rounded,
                              label: 'View Reports',
                              isDark: isDark,
                              onTap: () {}, // TODO: Implement reports
                            ),
                            const SizedBox(width: 16),
                            _buildQuickActionBtn(
                              context: context,
                              icon: Icons.people_rounded,
                              label: 'Patients',
                              isDark: isDark,
                              onTap: () {}, // TODO: Implement patients
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Responsive Grid of Actions
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            children: [
                              _buildWebActionCard(
                                context: context,
                                icon: Icons.person_add_rounded,
                                title: 'Add Doctor',
                                subtitle: 'Create a new doctor account',
                                color: Colors.orange,
                                isDark: isDark,
                                width: (constraints.maxWidth - 24) / 2,
                                onTap: () => Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (_) => AdminAddDoctorScreen(hospitalName: hospitalName))
                                ),
                              ),
                              _buildWebActionCard(
                                context: context,
                                icon: Icons.medical_services_rounded,
                                title: 'Manage Doctors',
                                subtitle: 'Edit or remove existing doctors',
                                color: primaryColor,
                                isDark: isDark,
                                width: (constraints.maxWidth - 24) / 2,
                                onTap: () => Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (_) => AdminManageDoctorsScreen(hospitalName: hospitalName))
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
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
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
            // ⚡ QUICK ACTIONS (MOBILE)
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: primaryColor.withOpacity(0.8), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                   _buildQuickActionBtn(
                    context: context,
                    icon: Icons.person_add_rounded,
                    label: 'Add Doctor',
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => AdminAddDoctorScreen(hospitalName: hospitalName))
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionBtn(
                    context: context,
                    icon: Icons.bar_chart_rounded,
                    label: 'Reports',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionBtn(
                    context: context,
                    icon: Icons.people_rounded,
                    label: 'Patients',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _DashboardItem(
              icon: Icons.person_add_rounded,
              title: 'Add Doctor',
              subtitle: 'Create a new doctor',
              color: Colors.orange,
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => AdminAddDoctorScreen(hospitalName: hospitalName))
              ),
            ),
            const SizedBox(height: 12),
            _DashboardItem(
              icon: Icons.medical_services_rounded,
              title: 'Manage Doctors',
              subtitle: 'Edit or remove doctors',
              color: primaryColor,
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => AdminManageDoctorsScreen(hospitalName: hospitalName))
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // COMPONENTS
  // =========================

  Widget _buildSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : sidebarColor,
        border: Border(right: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Qcare',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryColor, letterSpacing: -1),
              ),
            ],
          ),
          const SizedBox(height: 60),
          
          // Nav Links
          _buildSidebarNavItem(Icons.dashboard_rounded, 'Overview', true, isDark),
          const SizedBox(height: 32),
          
          // Profile Details
          Text(
            'ADMIN PROFILE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white24 : Colors.blueGrey.shade300,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileInfoItem(Icons.person_outline_rounded, 'Username', username, isDark),
          _buildProfileInfoItem(Icons.local_hospital_outlined, 'Hospital Name', hospitalName, isDark),
          
          const Spacer(),
          
          // Theme Toggle Area
          GestureDetector(
            onTap: onToggleTheme,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: primaryColor, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    isDark ? 'Light Mode' : 'Dark Mode',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
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
          // User Info
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Administrator',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                hospitalName,
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.1),
            child: const Icon(Icons.admin_panel_settings_rounded, color: primaryColor),
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
          color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? primaryColor : (isDark ? Colors.white38 : Colors.blueGrey), size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15, 
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? primaryColor : (isDark ? Colors.white70 : Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return HoverItem(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 130,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.blueGrey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    onToggleTheme: onToggleTheme,
                    themeMode: themeMode,
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
