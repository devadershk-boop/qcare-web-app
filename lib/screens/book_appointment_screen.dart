import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends State<BookAppointmentScreen> {
  bool isLoading = true;

  List<dynamic> doctors = [];
  List<String> departments = [];
  List<String> doctorsByDept = [];

  String? selectedDepartment;
  String? selectedDoctor;
  String? selectedTimeSlot;
  DateTime? selectedDate;

  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      final data = await ApiService.getDoctors();

      final deptSet = <String>{};
      for (var d in data) {
        deptSet.add(d['department'].toString());
      }

      setState(() {
        doctors = data;
        departments = deptSet.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load doctors from server'),
        ),
      );
    }
  }

  void updateDoctors(String department) {
    final list = doctors
        .where((d) => d['department'] == department)
        .map<String>((d) => d['name'].toString())
        .toList();

    setState(() {
      doctorsByDept = list;
      selectedDoctor = null;
    });
  }

  Widget dropdown({
    required String label,
    required List<String> items,
    required String? selected,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: const SizedBox(),
        hint: Text(label),
        value: items.contains(selected) ? selected : null,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          onChanged(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color(0xFF0F766E),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 🏥 Department
                  dropdown(
                    label: 'Select Department',
                    items: departments,
                    selected: selectedDepartment,
                    onChanged: (value) {
                      setState(() {
                        selectedDepartment = value;
                      });
                      updateDoctors(value);
                    },
                  ),

                  const SizedBox(height: 20),

                  // 👨‍⚕️ Doctor
                  dropdown(
                    label: 'Select Doctor',
                    items: doctorsByDept,
                    selected: selectedDoctor,
                    onChanged: (value) {
                      setState(() {
                        selectedDoctor = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // 📅 Date Picker
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 30)),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Select Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedDate == null
                            ? 'Choose a date'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ⏰ Time Slot
                  dropdown(
                    label: 'Select Time Slot',
                    items: timeSlots,
                    selected: selectedTimeSlot,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeSlot = value;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  // ✅ CONFIRM BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                      ),
                      onPressed: () async {
                        if (selectedDepartment == null ||
                            selectedDoctor == null ||
                            selectedDate == null ||
                            selectedTimeSlot == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please complete all fields'),
                            ),
                          );
                          return;
                        }

                        try {
                          final response =
                              await ApiService.bookAppointment(
                            patientName: 'Patient',
                            department: selectedDepartment!,
                            doctor: selectedDoctor!,
                            date:
                                '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
                            time: selectedTimeSlot!,
                          );

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text(
                                  'Appointment Confirmed'),
                              content: Text(
                                'Your token number is ${response['token']}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to book appointment'),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Confirm Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
