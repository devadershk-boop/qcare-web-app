import 'package:flutter/material.dart';

class AppointmentSuccessScreen extends StatelessWidget {
  final String token;
  final String doctor;
  final String department;
  final String date;
  final String time;

  const AppointmentSuccessScreen({
    super.key,
    required this.token,
    required this.doctor,
    required this.department,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF0F766E);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Column(
        children: [
          // FULL-WIDTH HEADER
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: brandColor,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Appointment Booked Successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your digital token is ready. Present it at the reception.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // TOKEN SECTION
                      Column(
                        children: [
                          Text(
                            "YOUR TOKEN NUMBER",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                              color: isDark ? Colors.white38 : Colors.blueGrey.shade400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            decoration: BoxDecoration(
                              color: brandColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: brandColor.withOpacity(0.15), width: 2),
                            ),
                            child: Text(
                              token,
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                color: brandColor,
                                letterSpacing: -4,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Booking ID: APP-${token}QX-2026",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white24 : Colors.blueGrey.shade200,
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(height: 1),
                      ),

                      // DETAILS GRID
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _detailItem("Attending Doctor", doctor, Icons.person_rounded, isDark),
                                const SizedBox(height: 20),
                                _detailItem("Date", date, Icons.calendar_today_rounded, isDark),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            child: Column(
                              children: [
                                _detailItem("Medical Department", department, Icons.medical_services_rounded, isDark),
                                const SizedBox(height: 20),
                                _detailItem("Approved Time Slot", time, Icons.access_time_filled_rounded, isDark),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "Please note: Your expected waiting time might fluctuate based on active delays or previous patient consultation times.",
                                style: TextStyle(
                                  color: isDark ? Colors.orange.shade300 : Colors.deepOrange.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: 260,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          ),
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          child: const Text(
                            "Done",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value, IconData icon, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: const Color(0xFF0F766E)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white24 : Colors.blueGrey.shade300,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
