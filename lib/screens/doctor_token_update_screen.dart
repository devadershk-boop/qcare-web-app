import 'package:flutter/material.dart';
import '../data/token_data.dart';


class DoctorTokenUpdateScreen extends StatefulWidget {
  const DoctorTokenUpdateScreen({super.key});

  @override
  State<DoctorTokenUpdateScreen> createState() =>
      _DoctorTokenUpdateScreenState();
}

class _DoctorTokenUpdateScreenState
    extends State<DoctorTokenUpdateScreen> {
  static const Color primaryColor = Color(0xFF0F766E); // Qcare teal

  // Dummy token list
  List<Map<String, String>> tokens = [
    {
      'token': 'A10',
      'patient': 'Rahul',
      'status': 'Completed',
    },
    {
      'token': 'A11',
      'patient': 'Anjali',
      'status': 'In Progress',
    },
    {
      'token': 'A12',
      'patient': 'Suresh',
      'status': 'Waiting',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          'Update Token Status',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: tokens.length,
        itemBuilder: (context, index) {
          final token = tokens[index];

          return _TokenCard(
            tokenNumber: token['token']!,
            patientName: token['patient']!,
            status: token['status']!,
           onStatusChange: (newStatus) {
  setState(() {
    tokens[index]['status'] = newStatus;

    // 🔄 Sync with patient view
    if (tokens[index]['token'] == TokenData.tokenNumber) {
      TokenData.updateStatus(newStatus);
    }
  });
},

          );
        },
      ),
    );
  }
}

// 🔹 TOKEN CARD
class _TokenCard extends StatelessWidget {
  final String tokenNumber;
  final String patientName;
  final String status;
  final Function(String) onStatusChange;

  const _TokenCard({
    required this.tokenNumber,
    required this.patientName,
    required this.status,
    required this.onStatusChange,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Token
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _statusColor(status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tokenNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _statusColor(status),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: $status',
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Status update menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: onStatusChange,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'Waiting',
                child: Text('Waiting'),
              ),
              PopupMenuItem(
                value: 'In Progress',
                child: Text('In Progress'),
              ),
              PopupMenuItem(
                value: 'Completed',
                child: Text('Completed'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
