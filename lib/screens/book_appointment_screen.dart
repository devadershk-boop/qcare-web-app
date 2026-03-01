import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../services/api_service.dart';
import 'appointment_success_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String patientName;

  const BookAppointmentScreen({
    super.key,
    required this.patientName,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  // 🚀 STATE MANAGEMENT USING VALUENOTIFIER
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<bool> _isSubmitting = ValueNotifier(false);
  
  final ValueNotifier<List<dynamic>> _allDoctors = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> _waitTimesData = ValueNotifier([]);
  
  final ValueNotifier<List<String>> _hospitals = ValueNotifier([]);
  final ValueNotifier<List<String>> _departments = ValueNotifier([]);
  final ValueNotifier<List<String>> _filteredDoctors = ValueNotifier([]);

  final ValueNotifier<String?> _selectedHospital = ValueNotifier(null);
  final ValueNotifier<String?> _selectedDepartment = ValueNotifier(null);
  final ValueNotifier<String?> _selectedDoctor = ValueNotifier(null);
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(null);



  @override
  void initState() {
    super.initState();
    fetchInitialData();

    super.initState();
    fetchInitialData();

    // Listener for cascading filters
    _selectedHospital.addListener(_filterByHospital);
    _selectedDepartment.addListener(_filterByDepartment);
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _isSubmitting.dispose();
    _allDoctors.dispose();
    _waitTimesData.dispose();
    _hospitals.dispose();
    _departments.dispose();
    _filteredDoctors.dispose();
    _selectedHospital.dispose();
    _selectedDepartment.dispose();
    _selectedDoctor.dispose();
    _selectedDate.dispose();
    super.dispose();
  }

  Future<void> fetchInitialData() async {
    try {
      final data = await ApiService.getDoctors();
      final waitData = await ApiService.getWaitTimes();
      
      _allDoctors.value = data;
      _waitTimesData.value = waitData;

      // Extract unique hospitals strictly tied to Doctors array
      final hospitalSet = <String>{};
      for (var d in data) {
        if (d['hospital_name'] != null && d['hospital_name'].toString().isNotEmpty) {
          hospitalSet.add(d['hospital_name'].toString());
        }
      }
      
      _hospitals.value = hospitalSet.toList();
      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  void _filterByHospital() {
    final hosp = _selectedHospital.value;
    
    if (hosp == null) {
      _departments.value = [];
      _filteredDoctors.value = [];
    } else {
      // Find departments natively belonging to doctors in this hospital
      final deptSet = <String>{};
      for (var d in _allDoctors.value) {
        if (d['hospital_name'] == hosp && d['department_name'] != null) {
          deptSet.add(d['department_name'].toString());
        }
      }
      _departments.value = deptSet.toList();
    }
    
    _selectedDepartment.value = null;
    _selectedDoctor.value = null;
  }

  void _filterByDepartment() {
    final dept = _selectedDepartment.value;
    final hosp = _selectedHospital.value;
    
    if (dept == null || hosp == null) {
      _filteredDoctors.value = [];
    } else {
      _filteredDoctors.value = _allDoctors.value
          .where((d) => d['department_name'] == dept && d['hospital_name'] == hosp)
          .map<String>((d) => "Dr. ${d['name']}")
          .toList();
    }
    _selectedDoctor.value = null;
  }

  String formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF0F766E);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Book Appointment', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
        backgroundColor: brandColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, loading, _) {
          if (loading) return const Center(child: CircularProgressIndicator(color: brandColor));
          
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: brandColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.calendar_month_rounded, color: brandColor, size: 28),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Schedule Your Visit",
                                      style: TextStyle(
                                        fontSize: 28, 
                                        fontWeight: FontWeight.w900, 
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    Text(
                                      "Fill in the details below to book your appointment",
                                      style: TextStyle(
                                        color: isDark ? Colors.white38 : Colors.blueGrey, 
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Divider(height: 1),
                          ),

                          // 🏥 Hospital Selection
                          _buildLabel("Select Hospital", brandColor, isDark),
                          ValueListenableBuilder<List<String>>(
                            valueListenable: _hospitals,
                            builder: (context, hospitals, _) {
                              return ValueListenableBuilder<String?>(
                                valueListenable: _selectedHospital,
                                builder: (context, selected, _) {
                                  return _buildDropdown(
                                    hint: "Choose Hospital",
                                    value: selected,
                                    items: hospitals,
                                    onChanged: (val) => _selectedHospital.value = val,
                                    enabled: hospitals.isNotEmpty,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // 📂 Department Selection
                          _buildLabel("Select Department", brandColor, isDark),
                          ValueListenableBuilder<List<String>>(
                            valueListenable: _departments,
                            builder: (context, depts, _) {
                              return ValueListenableBuilder<String?>(
                                valueListenable: _selectedDepartment,
                                builder: (context, selected, _) {
                                  return _buildDropdown(
                                    hint: _selectedHospital.value == null ? "Select hospital first" : "Choose Department",
                                    value: selected,
                                    items: depts,
                                    onChanged: (val) => _selectedDepartment.value = val,
                                    enabled: _selectedHospital.value != null && depts.isNotEmpty,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // 👨‍⚕️ Doctor Selection
                          _buildLabel("Select Doctor", brandColor, isDark),
                          ValueListenableBuilder<List<String>>(
                            valueListenable: _filteredDoctors,
                            builder: (context, doctors, _) {
                              return ValueListenableBuilder<String?>(
                                valueListenable: _selectedDoctor,
                                builder: (context, selected, _) {
                                  return _buildDropdown(
                                    hint: _selectedDepartment.value == null ? "Select department first" : "Choose Doctor",
                                    value: selected,
                                    items: doctors,
                                    onChanged: (val) => _selectedDoctor.value = val,
                                    enabled: _selectedDepartment.value != null && doctors.isNotEmpty,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // 📅 Date Selection (Horizontal Scrollable)
                          _buildLabel("Select Date", brandColor, isDark),
                          ValueListenableBuilder<DateTime?>(
                            valueListenable: _selectedDate,
                            builder: (context, selected, _) {
                              return SizedBox(
                                height: 100,
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
                                    itemCount: 30,
                                    itemBuilder: (context, index) {
                                      final date = DateTime.now().add(Duration(days: index));
                                      final isSelected = selected != null &&
                                          date.day == selected.day &&
                                          date.month == selected.month &&
                                          date.year == selected.year;
                                      final dayName = index == 0
                                          ? "Today"
                                          : index == 1
                                              ? "Tmrrw"
                                              : _getDayName(date.weekday);

                                      return Padding(
                                        padding: const EdgeInsets.only(right: 14),
                                        child: GestureDetector(
                                          onTap: () => _selectedDate.value = date,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: 75,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? brandColor
                                                  : (isDark
                                                      ? Colors.white.withOpacity(0.05)
                                                      : const Color(0xFFF1F5F9)),
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(
                                                color: isSelected
                                                    ? brandColor
                                                    : (isDark
                                                        ? Colors.white.withOpacity(0.1)
                                                        : Colors.blueGrey.shade100.withOpacity(0.5)),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  dayName.toUpperCase(),
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white.withOpacity(0.7)
                                                        : (isDark ? Colors.white38 : Colors.blueGrey),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  date.day.toString(),
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : (isDark ? Colors.white : const Color(0xFF1E293B)),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _getMonthName(date.month),
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white.withOpacity(0.7)
                                                        : (isDark ? Colors.white38 : Colors.blueGrey),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),


                          const SizedBox(height: 48),

                          // 🚀 Submit Button
                          _BookButton(
                            onPressed: _bookAppointment,
                            isSubmitting: _isSubmitting,
                            brandColor: brandColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text, Color brandColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white : brandColor, 
          fontWeight: FontWeight.bold, 
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const brandColor = Color(0xFF0F766E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(enabled ? 0.1 : 0.05) : brandColor.withOpacity(enabled ? 0.05 : 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(enabled ? 0.2 : 0.1) : brandColor.withOpacity(enabled ? 0.2 : 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 14)),
          value: items.contains(value) ? value : null,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white70 : brandColor),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    if (_selectedDepartment.value == null ||
        _selectedDoctor.value == null ||
        _selectedDate.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields to continue')),
      );
      return;
    }

    _isSubmitting.value = true;
    try {
      final strippedDoctor = _selectedDoctor.value!.replaceFirst("Dr. ", "");
      final res = await ApiService.bookAppointment(
        patientName: widget.patientName,
        department: _selectedDepartment.value!,
        doctor: strippedDoctor,
        date: formatDate(_selectedDate.value!),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AppointmentSuccessScreen(
            token: res['token'].toString(),
            doctor: _selectedDoctor.value!,
            department: _selectedDepartment.value!,
            date: formatDate(_selectedDate.value!),
            time: res['expectedTime']?.toString() ?? 'TBD',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    } finally {
      _isSubmitting.value = false;
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return "Mon";
      case 2: return "Tue";
      case 3: return "Wed";
      case 4: return "Thu";
      case 5: return "Fri";
      case 6: return "Sat";
      case 7: return "Sun";
      default: return "";
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return "Jan";
      case 2: return "Feb";
      case 3: return "Mar";
      case 4: return "Apr";
      case 5: return "May";
      case 6: return "Jun";
      case 7: return "Jul";
      case 8: return "Aug";
      case 9: return "Sep";
      case 10: return "Oct";
      case 11: return "Nov";
      case 12: return "Dec";
      default: return "";
    }
  }
}

class _BookButton extends StatefulWidget {
  final VoidCallback onPressed;
  final ValueNotifier<bool> isSubmitting;
  final Color brandColor;

  const _BookButton({required this.onPressed, required this.isSubmitting, required this.brandColor});

  @override
  State<_BookButton> createState() => _BookButtonState();
}

class _BookButtonState extends State<_BookButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isSubmitting,
      builder: (context, busy, _) {
        return GestureDetector(
          onTapDown: busy ? null : (_) => setState(() => _isPressed = true),
          onTapUp: busy ? null : (_) => setState(() => _isPressed = false),
          onTapCancel: busy ? null : () => setState(() => _isPressed = false),
          onTap: busy ? null : widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isPressed 
                  ? [widget.brandColor.withOpacity(0.8), widget.brandColor]
                  : [widget.brandColor.withOpacity(0.9), widget.brandColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: _isPressed ? [] : [
                BoxShadow(
                  color: widget.brandColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Confirm Booking",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        );
      },
    );
  }
}

