import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class TokenStatusScreen extends StatefulWidget {
  final String patientName;

  const TokenStatusScreen({
    super.key,
    required this.patientName,
  });

  @override
  State<TokenStatusScreen> createState() => _TokenStatusScreenState();
}

class _TokenStatusScreenState extends State<TokenStatusScreen> {
  bool isLoading = true;
  List myAppointmentsWithQueue = [];
  String? selectedDoctorFilter;
  String selectedDateFilter = 'TODAY';
  final Set<int> notifiedTokens = {};

  @override
  void initState() {
    super.initState();
    loadStatus();
  }


  Future<void> loadStatus() async {
    setState(() => isLoading = true);

    try {
      final mine = await ApiService.getAppointments(widget.patientName);
      final waitTimesList = await ApiService.getWaitTimes();
      final Map<String, Map<String, dynamic>> deptInfoMap = {
        for (var item in waitTimesList)
          item['department_name']: {
            'avg': item['avg_time_minutes'],
            'start': item['current_consultation_start']
          }
      };

      List results = [];

      for (final appt in mine) {
        final doctor = appt['doctor'];
        final token = appt['token'];
        final status = appt['status'];
        final String dept = appt['department'] ?? '';
        final String apptDate = appt['date'] ?? '';

        final doctorQueue = await ApiService.getDoctorQueue(doctor, date: apptDate);
        final doctorStatus = await ApiService.getDoctorStatus(doctor);
        final isOnBreak = doctorStatus['onBreak'] ?? false;

        final isCompleted = status == "COMPLETED" || status == "NOT_ATTENDED";
        final isWaiting = status == "WAITING";
        
        // Accurate queue position: count how many WAITING are ahead of this one ON THE SAME DATE
        int waitingAheadCount = 0;
        int peopleAheadForWait = 0;
        if (isWaiting) {
          final myTokenVal = double.tryParse(token.toString()) ?? 0;
          
          waitingAheadCount = doctorQueue
            .where((a) => a['status'] == "WAITING" && a['date'] == apptDate && (double.tryParse((a['token_number'] ?? a['token']).toString()) ?? 0) < myTokenVal)
            .length;

          // For wait time, we only care about people in the current "Today" queue if the appt is today,
          // OR people on the same date for the future.
          peopleAheadForWait = doctorQueue
            .where((a) => 
               (a['date'] == apptDate && a['status'] == "IN_PROGRESS") || 
               (a['status'] == "WAITING" && a['date'] == apptDate && (double.tryParse((a['token_number'] ?? a['token']).toString()) ?? 0) < myTokenVal)
            ).length;
        }

        final deptInfo = deptInfoMap[dept] ?? {'avg': 2, 'start': null};
        final int avgTimeVal = deptInfo['avg'];
        final String? deptStartStr = deptInfo['start'];

        // Calculate dynamic delay if SOMEONE is in progress for this doctor
        int overdueDelay = 0;
        int activePatientRemainingTime = 0;
        final hasInProgress = doctorQueue.any((a) => a['status'] == "IN_PROGRESS");
        
        if (hasInProgress && deptStartStr != null) {
          try {
            // Ensure the string is treated as UTC
            String isoStr = deptStartStr;
            if (!isoStr.contains('Z') && !isoStr.contains('+')) {
              isoStr = "${isoStr.replaceFirst(' ', 'T')}Z";
            }
            final startedAt = DateTime.parse(isoStr).toUtc();
            final now = DateTime.now().toUtc();
            final elapsed = now.difference(startedAt).inMinutes;
            
            if (elapsed >= avgTimeVal) {
              overdueDelay = elapsed - avgTimeVal;
              activePatientRemainingTime = avgTimeVal; // they are overdue, give a standard buffer
            } else {
              activePatientRemainingTime = avgTimeVal - elapsed;
            }
          } catch (e) {
            // parsing error
          }
        }

        final now = DateTime.now();
        final isToday = apptDate == now.toIso8601String().split('T')[0];
        
        // Fix: Explicitly prevent doctorOnBreak today from poisoning future tokens' ETAs
        final breakDuration = (isOnBreak && isToday) ? 15 : 0;
        
        // waitingAheadCount exactly defines the number of people waiting to be seen before this token.
        // It does not include the IN_PROGRESS patient (whom we track separately if one exists).
        int waitFromOthers = waitingAheadCount * avgTimeVal;
        
        // The total wait relative to RIGHT NOW depends on how much time the active patient has left,
        // plus the average time of everyone else waiting in line.
        final int totalWaitFromNow = waitFromOthers + activePatientRemainingTime + breakDuration;
        
        // Because display is often "Wait Time: X mins", we show the total duration they'll be sitting.
        // It should equal the absolute ETA relative to the current time.
        final int estimatedWaitMins = totalWaitFromNow;

        // Calculate true Live ETA instead of relying solely on the static booking time configuration.
        String displayEta = appt['time'] ?? '—';
        int displayWaitTrackerMins = estimatedWaitMins;

        if (!isCompleted) {
          try {
            final components = displayEta.split(' ');
            final timeParts = components[0].split(':');
            int h = int.parse(timeParts[0]);
            int m = int.parse(timeParts[1]);
            final isPm = components[1].toUpperCase() == 'PM';
            if (isPm && h < 12) h += 12;
            if (!isPm && h == 12) h = 0;

            bool queueHasStartedToday = doctorQueue.any((a) => a['status'] == "IN_PROGRESS" || a['status'] == "COMPLETED");

            DateTime staticTime = DateTime(now.year, now.month, now.day, h, m);
            
            // The booked time slot (h:m) already includes the average spacing from previous appointments.
            // We only need to add any global overdue delay.
            int offsetDelay = overdueDelay;
            staticTime = staticTime.add(Duration(minutes: offsetDelay));

            DateTime calculateTime;
            
            bool isLateToStart = isToday && !queueHasStartedToday && now.isAfter(staticTime);
            
            if (isToday && (queueHasStartedToday || isLateToStart)) {
               // If queue is actively running today, or the doctor is late to start, ETA pushes strictly from RIGHT NOW
               calculateTime = now.add(Duration(minutes: totalWaitFromNow));
            } else {
               // If it's a future day or queue hasn't begun (and not late yet), rely on static booked time
               calculateTime = staticTime;
            }

            final newH = calculateTime.hour == 0 ? 12 : (calculateTime.hour > 12 ? calculateTime.hour - 12 : calculateTime.hour);
            final newM = calculateTime.minute.toString().padLeft(2, '0');
            final newAmPm = calculateTime.hour >= 12 ? 'PM' : 'AM';
            
            // Mark it as actively tracking if it's running live or delayed
            if (isToday && queueHasStartedToday) {
               displayEta = "$newH:$newM $newAmPm (Live)";
            } else if (isLateToStart || overdueDelay > 0) {
               displayEta = "$newH:$newM $newAmPm (Delayed)";
            } else {
               displayEta = "$newH:$newM $newAmPm";
            }
          } catch (e) {
            // Fallback to original
          }
        }

        final Map<String, dynamic> enriched = {
          ...Map<String, dynamic>.from(appt),
          "queuePosition": isCompleted ? 0 : waitingAheadCount + 1,
          "estimated": isCompleted ? "—" : "$displayWaitTrackerMins mins",
          "eta": isCompleted ? "—" : displayEta,
          "doctorOnBreak": (isOnBreak && isToday), // Only show orange border if their physical appointment is today
          "isDelayed": overdueDelay > 0,
        };

        results.add(enriched);

        if (status == "IN_PROGRESS" && !notifiedTokens.contains(token)) {
          notifiedTokens.add(token);
          if (mounted) {
            _showTurnNotification(token);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        myAppointmentsWithQueue = results;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
      }
    }
  }

  void _showTurnNotification(int token) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📣 It's your turn — please proceed"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Your Turn", style: TextStyle(color: Colors.white)),
        content: Text("Token #$token is now in progress", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.indigoAccent)),
          )
        ],
      ),
    );
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
        title: const Text("Status Dashboard", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadStatus,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.6),
            radius: 1.2,
            colors: isDark 
              ? [brandColor.withOpacity(0.05), const Color(0xFF0F172A)]
              : [brandColor.withOpacity(0.03), const Color(0xFFF1F5F9)],
          ),
        ),
        child: Column(
          children: [
            if (!isLoading && myAppointmentsWithQueue.isNotEmpty) ...[
              _buildDateFilterChips(isDark, brandColor),
              _buildDoctorFilterChips(isDark, brandColor),
            ],
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: brandColor))
                  : myAppointmentsWithQueue.isEmpty
                      ? _buildEmptyState(isDark, brandColor)
                      : _buildDashboard(isDark, brandColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorFilterChips(bool isDark, Color brandColor) {
    // Extract unique doctors
    final Set<String> doctors = {};
    for (var a in myAppointmentsWithQueue) {
      if (a['doctor'] != null) {
        doctors.add(a['doctor'].toString().toLowerCase().startsWith('dr') ? a['doctor'].toString() : "Dr. ${a['doctor']}");
      }
    }
    final doctorList = doctors.toList()..sort();

    if (doctorList.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white.withOpacity(0.5),
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            _buildFilterChip('All Doctors', null, isDark, brandColor, isDoctorLevel: true),
            const SizedBox(width: 8),
            ...doctorList.map((doc) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(doc, doc, isDark, brandColor, isDoctorLevel: true),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterChips(bool isDark, Color brandColor) {
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildDateChip('TODAY', isDark, brandColor),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildDateChip('UPCOMING', isDark, brandColor),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildDateChip('ALL', isDark, brandColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String label, bool isDark, Color brandColor) {
    final isSelected = selectedDateFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.blueGrey.shade600),
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: 0.5,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => selectedDateFilter = label);
      },
      selectedColor: brandColor,
      backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
      elevation: isSelected ? 4 : 0,
      pressElevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: isSelected ? brandColor : (isDark ? Colors.white10 : Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? matchValue, bool isDark, Color brandColor, {bool isDoctorLevel = false}) {
    final isSelected = isDoctorLevel ? selectedDoctorFilter == matchValue : selectedDateFilter == matchValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isDoctorLevel) {
            selectedDoctorFilter = matchValue;
          } else {
            selectedDateFilter = matchValue!;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? brandColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? brandColor : (isDark ? Colors.white24 : Colors.grey.shade300),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: brandColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.blueGrey),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color brandColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: brandColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_rounded, color: brandColor, size: 64),
            ),
            const SizedBox(height: 32),
            Text(
              "No Active Tokens",
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Your live appointment statuses will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(bool isDark, Color brandColor) {
    // 1. Date Filter First
    List dateFiltered = List.from(myAppointmentsWithQueue);
    if (selectedDateFilter != 'ALL') {
      final String todayStr = DateTime.now().toIso8601String().split('T')[0];
      dateFiltered = dateFiltered.where((a) {
        final String apptDate = a['date'] ?? '';
        if (selectedDateFilter == 'TODAY') {
          return apptDate == todayStr;
        } else if (selectedDateFilter == 'UPCOMING') {
          return apptDate.compareTo(todayStr) > 0;
        }
        return true;
      }).toList();
    }

    // 2. Filter based on selected doctor
    List filteredAppointments = List.from(dateFiltered);
    if (selectedDoctorFilter != null) {
      filteredAppointments = filteredAppointments.where((a) {
        final docName = a['doctor'].toString().toLowerCase().startsWith('dr') ? a['doctor'].toString() : "Dr. ${a['doctor']}";
        return docName == selectedDoctorFilter;
      }).toList();
    }

    // Separate for cleaner dashboard grouping
    final inProgress = filteredAppointments.where((a) => a['status'] == 'IN_PROGRESS').toList();
    final waiting = filteredAppointments.where((a) => a['status'] == 'WAITING').toList();
    final past = filteredAppointments.where((a) => a['status'] == 'COMPLETED' || a['status'] == 'NOT_ATTENDED').toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (inProgress.isNotEmpty) ...[
            _buildSectionHeader("LIVE NOW", Icons.sensors_rounded, isDark),
            const SizedBox(height: 20),
            ...inProgress.map((a) => _buildLiveTokenCard(a, isDark, brandColor)),
            const SizedBox(height: 56),
          ],
          
          if (waiting.isNotEmpty) ...[
            _buildSectionHeader("UPCOMING", Icons.schedule_rounded, isDark),
            const SizedBox(height: 20),
            ...waiting.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildWaitingCard(a, isDark, brandColor),
            )),
            if (past.isNotEmpty) const SizedBox(height: 32),
          ],

          if (past.isNotEmpty) ...[
            _buildSectionHeader("PAST APPOINTMENTS", Icons.history_rounded, isDark),
            const SizedBox(height: 20),
            ...past.map((a) => Opacity(
              opacity: 0.6,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildWaitingCard(a, isDark, brandColor),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildLiveTokenCard(Map<String, dynamic> a, bool isDark, Color brandColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: brandColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: brandColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "CURRENTLY IN SESSION",
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ],
                    ),
                    Text(
                      a['date'].toString().toUpperCase(),
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  a['doctor'].toString().toLowerCase().startsWith('dr') ? a['doctor'].toString() : "Dr. ${a['doctor']}",
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                Text(
                  "Booked: ${a['bookedAt'] ?? a['date']} • Scheduled: ${a['date']}",
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  "DEPARTMENT: ${a['department'].toString().toUpperCase()}",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Text(
                "YOUR TOKEN",
                style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                "#${a['token']}",
                style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, height: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingCard(Map<String, dynamic> a, bool isDark, Color brandColor) {
    final bool isDelayed = a['isDelayed'] ?? false;
    final bool isOnBreak = a['doctorOnBreak'] ?? false;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOnBreak 
            ? Colors.orange.withOpacity(0.5) 
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
          width: isOnBreak ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: brandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.medical_services_rounded, color: brandColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['doctor'].toString().toLowerCase().startsWith('dr') ? a['doctor'].toString() : "Dr. ${a['doctor']}",
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      "Booked: ${a['bookedAt'] ?? a['date']}  |  Scheduled: ${a['date']}",
                      style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Department: ${a['department']}",
                            style: const TextStyle(color: Colors.blueGrey, fontSize: 15, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (a['date'] != null && a['date'] != DateTime.now().toIso8601String().split('T')[0]) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: brandColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              a['date'],
                              style: TextStyle(color: brandColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _StatusBadge(status: a['status']),
            ],
          ),
          if (isDelayed) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "The current patient is taking longer than expected. Your ETA has been updated.",
                      style: TextStyle(
                        color: isDark ? Colors.orange.shade300 : Colors.deepOrange.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TokenInfo(label: "TOKEN #", value: "${a['token']}"),
              _TokenInfo(label: "POSITION", value: "${a['queuePosition']}"),
              _TokenInfo(
                label: "EST. WAIT", 
                value: a['estimated'], 
                color: isOnBreak ? Colors.orange : (isDelayed ? Colors.orange : null),
                showWarning: isDelayed,
              ),
              _TokenInfo(
                label: isDelayed ? "EXPECTED BY" : "EXPECTED AT", 
                value: a['eta'], 
                color: isDelayed ? Colors.orange : brandColor,
                showWarning: isDelayed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TokenInfo extends StatelessWidget {
  final String label, value;
  final Color? color;
  final bool showWarning;

  const _TokenInfo({
    required this.label, 
    required this.value, 
    this.color,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const brandColor = Color(0xFF0F766E);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showWarning) 
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.warning_amber_rounded, size: 10, color: Colors.redAccent),
              ),
            Text(
              label, 
              style: TextStyle(
                color: isDark ? Colors.white38 : brandColor.withOpacity(0.5), 
                fontSize: 11, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value, 
          style: TextStyle(
            color: color ?? (isDark ? Colors.white : Colors.black87), 
            fontSize: 18, 
            fontWeight: FontWeight.bold,
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
    String s = status.toUpperCase();
    Color color;
    if (s == "WAITING") {
      color = Colors.orange;
    } else if (s == "IN_PROGRESS") {
      color = Colors.green;
    } else if (s == "NOT_ATTENDED") {
      color = Colors.redAccent;
      s = "MISSED";
    } else {
      color = Colors.grey;
    }
    
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
          fontSize: 11, 
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

