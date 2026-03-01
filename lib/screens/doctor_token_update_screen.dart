import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DoctorTokenUpdateScreen extends StatefulWidget {
  final String doctorName;

  const DoctorTokenUpdateScreen({
    super.key,
    required this.doctorName,
  });

  static const Color brandColor = Color(0xFF0F766E);
  static const Color bgColor = Color(0xFFF8FAFC);

  @override
  State<DoctorTokenUpdateScreen> createState() =>
      _DoctorTokenUpdateScreenState();
}

class _DoctorTokenUpdateScreenState
    extends State<DoctorTokenUpdateScreen> {

  bool isLoading = true;
  List appointments = [];
  String selectedFilter = 'PENDING';

  String get displayDoctorName {
    if (widget.doctorName.toLowerCase().startsWith("dr")) {
      return widget.doctorName;
    }
    return "Dr. ${widget.doctorName}";
  }

  List get filteredAppointments {
    if (selectedFilter == 'ALL') return appointments;
    if (selectedFilter == 'PENDING') return appointments.where((a) => a['status'] == 'WAITING' || a['status'] == 'IN_PROGRESS').toList();
    if (selectedFilter == 'COMPLETED') return appointments.where((a) => a['status'] == 'COMPLETED').toList();
    if (selectedFilter == 'NOT_ATTENDED') return appointments.where((a) => a['status'] == 'NOT_ATTENDED').toList();
    return appointments;
  }

  Timer? autoTimer;

  @override
  void initState() {
    super.initState();
    loadQueue();

    autoTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadQueue(),
    );
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    super.dispose();
  }

  Future<void> loadQueue() async {
    try {
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      final data = await ApiService.getDoctorQueue(widget.doctorName, date: todayStr, filter: 'ALL');
      data.sort((a, b) => a['token'].compareTo(b['token']));

      if (!mounted) return;

      setState(() {
        appointments = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> callNextPatient() async {
    try {
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final result = await ApiService.callNext(widget.doctorName, date: todayStr);
      if (!mounted) return;

      final next = result['next'];

      if (next == null) {
        _showNoPatientsDialog();
        return;
      }

      final token = next['token'];
      final patient = next['patientName'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Now calling Token #$token — $patient"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      loadQueue();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to call next patient. Check connection."),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showNoPatientsDialog() {
    const brandColor = DoctorTokenUpdateScreen.brandColor;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 26),
            SizedBox(width: 10),
            Text("Queue Empty", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "All patients have been attended to.\nNo more patients are waiting.",
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> updateStatus(int appointmentId, String status) async {
    try {
      await ApiService.updateAppointmentStatus(appointmentId, status);
      loadQueue();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status: $e"),
          backgroundColor: Colors.redAccent,
        )
      );
    }
  }

  Widget _buildFilterChips(bool isDark, Color brandColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: ['PENDING', 'COMPLETED', 'NOT_ATTENDED', 'ALL'].map((filterStr) {
          final isSelected = selectedFilter == filterStr;
          String label = filterStr.replaceAll('_', ' ');
          if (filterStr == 'NOT_ATTENDED') label = 'MISSED';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.blueGrey),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: brandColor,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? brandColor : (isDark ? Colors.white24 : Colors.grey.shade300),
                ),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  setState(() => selectedFilter = filterStr);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = DoctorTokenUpdateScreen.brandColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : DoctorTokenUpdateScreen.bgColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: brandColor,
        title: Text("Queue — $displayDoctorName", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadQueue,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: brandColor,
        elevation: 4,
        onPressed: callNextPatient,
        icon: const Icon(Icons.campaign, color: Colors.white),
        label: const Text("Call Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: brandColor))
          : Column(
              children: [
                _buildFilterChips(isDark, brandColor),
                Expanded(
                  child: filteredAppointments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: brandColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.people_outline_rounded,
                                  color: isDark ? Colors.white : brandColor,
                                  size: 52,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "No Patients Found",
                                style: TextStyle(
                                  color: isDark ? Colors.white : brandColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "No patients match this filter.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredAppointments.length,
                          itemBuilder: (_, i) {
                            final a = filteredAppointments[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _TokenCard(
                                appointmentId: a['id'],
                                tokenNumber: "#${a['token']}",
                                patientName: a['patientName'],
                                status: a['status'],
                                onUpdateStatus: updateStatus,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  final int appointmentId;
  final String tokenNumber;
  final String patientName;
  final String status;
  final Function(int, String) onUpdateStatus;

  const _TokenCard({
    required this.appointmentId,
    required this.tokenNumber,
    required this.patientName,
    required this.status,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = status.toUpperCase();
    final isActive = s == "IN_PROGRESS";
    final isNotAttended = s == "NOT_ATTENDED";
    final color = isActive ? Colors.green : (s == "WAITING" ? DoctorTokenUpdateScreen.brandColor : (isNotAttended ? Colors.redAccent : Colors.grey));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isActive ? Colors.green.withOpacity(0.5) : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      tokenNumber,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.blueGrey),
                  onSelected: (val) => onUpdateStatus(appointmentId, val),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'WAITING', child: Text("Set to Waiting")),
                    const PopupMenuItem(value: 'IN_PROGRESS', child: Text("Set to In Progress")),
                    const PopupMenuItem(value: 'COMPLETED', child: Text("Set to Completed")),
                    const PopupMenuItem(value: 'NOT_ATTENDED', child: Text("Set to Not Attended")),
                  ],
                ),
              ],
            ),
            if (s != 'COMPLETED' && s != 'NOT_ATTENDED') ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (s == 'WAITING')
                    Expanded(
                      child: _ActionButton(
                        label: "Start Session",
                        icon: Icons.play_arrow_rounded,
                        color: Colors.green,
                        onTap: () => onUpdateStatus(appointmentId, "IN_PROGRESS"),
                      ),
                    ),
                  if (s == 'IN_PROGRESS') ...[
                    Expanded(
                      child: _ActionButton(
                        label: "Not Attended",
                        icon: Icons.person_off_rounded,
                        color: Colors.redAccent,
                        onTap: () => onUpdateStatus(appointmentId, "NOT_ATTENDED"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: "Mark Completed",
                        icon: Icons.check_circle_rounded,
                        color: Colors.indigo,
                        onTap: () => onUpdateStatus(appointmentId, "COMPLETED"),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
