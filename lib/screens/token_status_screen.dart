import 'package:flutter/material.dart';
import '../data/token_data.dart';


class TokenStatusScreen extends StatelessWidget {
  const TokenStatusScreen({super.key});

  static const Color primaryColor = Color(0xFF0F766E); // Qcare teal

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

final tokenNumber = TokenData.tokenNumber;
final queuePosition = TokenData.queuePosition;
final estimatedTime = TokenData.estimatedTime;
final status = TokenData.status;


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          'Token Status',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🎫 TOKEN CARD
            _InfoCard(
              icon: Icons.confirmation_number_rounded,
              title: 'Your Token',
              value: tokenNumber,
              accentColor: primaryColor,
            ),

            const SizedBox(height: 18),

            // 📍 QUEUE POSITION
            _InfoCard(
              icon: Icons.people_alt_rounded,
              title: 'Queue Position',
              value: '$queuePosition',
              accentColor: Colors.orange.shade600,
            ),

            const SizedBox(height: 18),

            // ⏱️ WAITING TIME
            _InfoCard(
              icon: Icons.timer_rounded,
              title: 'Estimated Waiting Time',
              value: estimatedTime,
              accentColor: Colors.purple.shade600,
            ),

            const SizedBox(height: 30),

            // 🔄 STATUS CHIP
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.hourglass_top_rounded,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Status: Waiting',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 🔄 REFRESH BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Status refreshed'),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Refresh Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 REUSABLE INFO CARD
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
