import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final String patientName;

  const MyAppointmentsScreen({
    super.key,
    required this.patientName,
  });

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> appointments = [];
  String selectedFilter = 'UPCOMING';

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  List<Map<String, dynamic>> get filteredAppointments {
    if (selectedFilter == 'ALL') return appointments;
    
    return appointments.where((a) {
      final status = a['status'] ?? "WAITING";
      switch (selectedFilter) {
        case 'UPCOMING':
          return status == 'WAITING';
        case 'PRESENT':
          return status == 'IN_PROGRESS';
        case 'PAST':
          return status == 'COMPLETED' || status == 'NOT_ATTENDED';
        default:
          return true;
      }
    }).toList();
  }

  Future<void> loadAppointments() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getAppointments(widget.patientName);
      if (!mounted) return;
      setState(() {
        appointments = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF0F766E);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: brandColor,
        title: const Text("My Appointments", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadAppointments,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: brandColor))
          : Column(
              children: [
                _buildFilterChips(isDark, brandColor),
                Expanded(
                  child: filteredAppointments.isEmpty
                      ? Center(
                          child: Text(
                            "No $selectedFilter appointments", 
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.blueGrey, 
                              fontWeight: FontWeight.w700, 
                              fontSize: 16
                            )
                          )
                        )
                      : Scrollbar(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 800),
                                child: Column(
                                  children: List.generate(filteredAppointments.length, (i) {
                                    final a = filteredAppointments[i];
                                    final status = a['status'] ?? "WAITING";

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                    blurRadius: 40,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "TOKEN #${a['token']}",
                                            style: const TextStyle(
                                              color: brandColor,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Appointment ID: APP-${a['token']}04",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white24 : Colors.blueGrey.shade200,
                                            ),
                                          ),
                                        ],
                                      ),
                                      _StatusBadge(status: status),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Divider(height: 1),
                                  ),
                                  _InfoRow(icon: Icons.person_outline_rounded, label: "Doctor", value: a['doctor'].toString().toLowerCase().startsWith('dr') ? a['doctor'].toString() : "Dr. ${a['doctor']}"),
                                  const SizedBox(height: 18),
                                  _InfoRow(icon: Icons.medical_services_outlined, label: "Department", value: a['department']),
                                  const SizedBox(height: 18),
                                  _InfoRow(icon: Icons.calendar_today_outlined, label: "Appointment Date", value: a['date']),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(child: _InfoRow(icon: Icons.history_rounded, label: "Booked On", value: a['bookedAt'] ?? a['date'])),
                                      Expanded(child: _InfoRow(icon: Icons.access_time_outlined, label: "Time", value: a['time'])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildFilterChips(bool isDark, Color brandColor) {
    final filters = ['UPCOMING', 'PRESENT', 'PAST', 'ALL'];
    
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white 
                      : (isDark ? Colors.white70 : Colors.blueGrey.shade600),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => selectedFilter = filter);
                },
                selectedColor: brandColor,
                backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                elevation: isSelected ? 4 : 0,
                pressElevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: isSelected 
                      ? brandColor 
                      : (isDark ? Colors.white10 : Colors.grey.shade200),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const brandColor = Color(0xFF0F766E);

    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white54 : brandColor.withOpacity(0.6)),
        const SizedBox(width: 14),
        Text(
          "$label: ", 
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black45, 
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87, 
              fontSize: 15, 
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    final color = s == "WAITING" ? Colors.orange : s == "IN_PROGRESS" ? Colors.green : (s == "COMPLETED" ? Colors.grey : Colors.indigo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        s, 
        style: TextStyle(
          color: color, 
          fontSize: 10, 
          fontWeight: FontWeight.w900, 
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

