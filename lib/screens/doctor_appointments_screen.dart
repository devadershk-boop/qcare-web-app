import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../services/api_service.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  final String doctorName;
  final int initialYear;
  final int initialMonth;

  const DoctorAppointmentsScreen({
    super.key,
    required this.doctorName,
    required this.initialYear,
    required this.initialMonth,
  });

  static const Color brandColor = Color(0xFF0F766E);

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  static const Color brandColor = DoctorAppointmentsScreen.brandColor;

  final _monthNames = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  late int selectedYear;
  late int selectedMonth;
  int? selectedDay;      // null = show all days in month

  bool isLoading = true;
  List<dynamic> _allForMonth = [];
  List<dynamic> all = [];
  String? error;

  @override
  void initState() {
    super.initState();
    selectedYear  = widget.initialYear;
    selectedMonth = widget.initialMonth;
    _load();
  }

  Future<void> _load() async {
    setState(() { isLoading = true; error = null; });
    try {
      final data = await ApiService.fetchDoctorAllAppointments(
        widget.doctorName,
        year: selectedYear,
        month: selectedMonth,
      );
      if (!mounted) return;
      setState(() {
        _allForMonth = data;
        _applyDayFilter();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('DoctorAppointmentsScreen error: $e');
      if (!mounted) return;
      setState(() {
        error = 'Could not reach server.\n$e';
        isLoading = false;
      });
    }
  }

  void _applyDayFilter() {
    all = selectedDay == null
        ? _allForMonth
        : _allForMonth.where((a) {
            final d = a['date'] as String?;
            if (d == null) return false;
            return int.tryParse(d.split('-').last) == selectedDay;
          }).toList();
  }

  List<dynamic> get scheduled => all;

  int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalDays = _daysInMonth(selectedYear, selectedMonth);
    final monthLabel = '${_monthNames[selectedMonth - 1]} $selectedYear';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: brandColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          monthLabel,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── DAY SELECTOR ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FILTER BY DAY',
                      style: TextStyle(
                        color: brandColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 42,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: totalDays + 1,
                          itemBuilder: (_, i) {
                            final day = i == 0 ? null : i;
                            final sel = selectedDay == day;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  day == null ? 'All Days' : '$day',
                                  style: TextStyle(
                                    color: sel
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                selected: sel,
                                selectedColor: brandColor,
                                backgroundColor: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade100,
                                onSelected: (_) {
                                  setState(() {
                                    selectedDay = day;
                                    _applyDayFilter();
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── RESULTS ──────────────────────────────────────
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: brandColor))
                  : error != null
                      ? _errorState()
                      : ListView(
                          padding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 30),
                          children: [
                            _SectionHeader(
                              label: 'Scheduled Appointments',
                              count: scheduled.length,
                              color: brandColor,
                              isDark: isDark,
                            ),
                            if (scheduled.isEmpty)
                              _emptySection(
                                  'No appointments found',
                                  Icons.event_available_rounded,
                                  isDark)
                            else
                              ...scheduled.map((a) => _AppointmentCard(
                                    appt: a, isDark: isDark)),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: Colors.white54, size: 52),
            const SizedBox(height: 16),
            const Text('Could not load appointments.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );

  Widget _emptySection(String msg, IconData icon, bool isDark) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon,
                color: isDark ? Colors.white38 : Colors.black26, size: 22),
            const SizedBox(width: 10),
            Text(msg,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                )),
          ],
        ),
      );
}

// ── SECTION HEADER ──────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isDark;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              )),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                )),
          ),
        ],
      ),
    );
  }
}

// ── APPOINTMENT CARD ──────────────────────────
class _AppointmentCard extends StatelessWidget {
  final dynamic appt;
  final bool isDark;

  const _AppointmentCard({required this.appt, required this.isDark});

  Color _statusColor(String s) {
    final status = s.toUpperCase();
    if (status == 'WAITING') return Colors.orange;
    if (status == 'IN_PROGRESS') return Colors.green;
    if (status == 'COMPLETED') return Colors.grey;
    return DoctorAppointmentsScreen.brandColor;
  }

  String _statusLabel(String s) => s.isEmpty ? "Scheduled" : s;

  @override
  Widget build(BuildContext context) {
    final status = appt['status'] as String? ?? '';
    final color  = _statusColor(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Token badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '#${appt['token']}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appt['patientName'] ?? '—',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 13,
                          color: isDark ? Colors.white38 : Colors.blueGrey),
                      const SizedBox(width: 6),
                      Text(appt['date'] ?? '—',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white38 : Colors.blueGrey,
                          )),
                      const SizedBox(width: 14),
                      Icon(Icons.access_time_rounded,
                          size: 13,
                          color: isDark ? Colors.white38 : Colors.blueGrey),
                      const SizedBox(width: 6),
                      Text(appt['time'] ?? '—',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white38 : Colors.blueGrey,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            // Status pill
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                _statusLabel(status).toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
