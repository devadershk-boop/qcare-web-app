import 'package:flutter/material.dart';
import 'book_appointment_screen.dart';
import 'login_screen.dart';
import 'token_status_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  static const Color primaryColor = Color(0xFF0F766E); // Qcare teal

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // 🔷 APP BAR WITH LOGOUT
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          'Patient Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // 👋 WELCOME TEXT
            const Text(
              'Welcome back 👋',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Manage your appointments and queue status with ease',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 32),

            // 📅 BOOK APPOINTMENT
            DashboardCard(
              icon: Icons.calendar_today_rounded,
              title: 'Book Appointment',
              subtitle: 'Schedule a visit with a doctor',
              accentColor: primaryColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BookAppointmentScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // 🎟️ TOKEN STATUS
            DashboardCard(
              icon: Icons.confirmation_number_rounded,
              title: 'View Token Status',
              subtitle: 'Check your queue position',
              accentColor: Colors.orange.shade600,
           onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const TokenStatusScreen(),
    ),
  );
},

            ),
          ],
        ),
      ),
    );
  }

  // 🔐 LOGOUT CONFIRMATION DIALOG
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    onToggleTheme: () {},
                    themeMode: ThemeMode.system,
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

// 🔹 DASHBOARD CARD WIDGET
class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
