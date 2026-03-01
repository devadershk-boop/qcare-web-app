import 'package:flutter/material.dart';
import 'doctor_appointments_screen.dart';

class DoctorCalendarScreen extends StatefulWidget {
  final String doctorName;
  const DoctorCalendarScreen({super.key, required this.doctorName});
  static const Color brandColor = Color(0xFF0F766E);
  @override
  State<DoctorCalendarScreen> createState() => _DoctorCalendarScreenState();
}

class _DoctorCalendarScreenState extends State<DoctorCalendarScreen> {
  static const Color brandColor = DoctorCalendarScreen.brandColor;

  late int _year;
  final _now = DateTime.now();

  // Show 5 year options centred on the current year
  late List<int> _years;

  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr',
    'May', 'Jun', 'Jul', 'Aug',
    'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _fullMonths = [
    'January',  'February', 'March',    'April',
    'May',      'June',     'July',     'August',
    'September','October',  'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _year = _now.year;
    _rebuildYears();
  }

  void _rebuildYears() {
    _years = List.generate(7, (i) => _year - 3 + i);
  }

  void _goToAppointments(int month) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorAppointmentsScreen(
          doctorName: widget.doctorName,
          initialYear: _year,
          initialMonth: month,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: brandColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Appointments History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ───────────────────────────────────────
              Text(
                'History Record',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Visualize your past clinical performance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white38 : Colors.blueGrey,
                ),
              ),

              const SizedBox(height: 32),

              // ── YEAR SELECTION ───────────────────────────────
              Container(
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
                      'Select Year',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: brandColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _ArrowBtn(
                          icon: Icons.keyboard_arrow_left_rounded,
                          onTap: () => setState(() {
                            _year--;
                            _rebuildYears();
                          }),
                          isDark: isDark,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: _years.map((y) {
                                final isSel = y == _year;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text('$y'),
                                    selected: isSel,
                                    selectedColor: brandColor,
                                    labelStyle: TextStyle(
                                      color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                                    onSelected: (_) => setState(() {
                                      _year = y;
                                      _rebuildYears();
                                    }),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        _ArrowBtn(
                          icon: Icons.keyboard_arrow_right_rounded,
                          onTap: () => setState(() {
                            _year++;
                            _rebuildYears();
                          }),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── MONTH SELECTION (HORIZONTAL RIBBON) ──────────────────────────
              Text(
                'Select Month',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: brandColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 125,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 12,
                  itemBuilder: (_, i) {
                    final month = i + 1;
                    final isCurrent = _year == _now.year && month == _now.month;
                    return _MonthCard(
                      shortName: _shortMonths[i],
                      fullName: _fullMonths[i],
                      isCurrent: isCurrent,
                      isDark: isDark,
                      brandColor: brandColor,
                      onTap: () => _goToAppointments(month),
                    );
                  },
                ),
              ),
              
              const Spacer(),
              
              // ── FOOTER HINT ──────────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.insights_rounded, color: brandColor, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Select a period to review analytics',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : brandColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ARROW BUTTON ─────────────────────────────────────
class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _ArrowBtn({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon,
          color: isDark ? Colors.white60 : Colors.black45, size: 26),
      splashRadius: 20,
    );
  }
}

// ── MONTH CARD (MODERN STYLE) ─────────────────────────
class _MonthCard extends StatefulWidget {
  final String shortName;
  final String fullName;
  final bool isCurrent;
  final bool isDark;
  final Color brandColor;
  final VoidCallback onTap;

  const _MonthCard({
    required this.shortName,
    required this.fullName,
    required this.isCurrent,
    required this.isDark,
    required this.brandColor,
    required this.onTap,
  });

  @override
  State<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<_MonthCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSel = widget.isCurrent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 90,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isSel 
                ? widget.brandColor 
                : (_hovered 
                    ? widget.brandColor.withOpacity(0.1) 
                    : (widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSel 
                  ? widget.brandColor 
                  : (widget.isDark ? Colors.white10 : Colors.grey.shade100),
              width: 1.5,
            ),
            boxShadow: _hovered || isSel
                ? [
                    BoxShadow(
                      color: widget.brandColor.withOpacity(isSel ? 0.3 : 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.shortName.toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isSel ? Colors.white : (widget.isDark ? Colors.white : Colors.black87),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.fullName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSel ? Colors.white70 : Colors.blueGrey,
                  letterSpacing: 0.5,
                ),
              ),
              if (isSel) ...[
                const SizedBox(height: 12),
                Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
