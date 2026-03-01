import 'package:flutter/material.dart';
import '../data/doctor_data.dart';
import '../services/api_service.dart';

class AdminManageDoctorsScreen extends StatefulWidget {
  final String hospitalName;

  const AdminManageDoctorsScreen({super.key, required this.hospitalName});

  @override
  State<AdminManageDoctorsScreen> createState() =>
      _AdminManageDoctorsScreenState();
}

class _AdminManageDoctorsScreenState
    extends State<AdminManageDoctorsScreen> {
  static const Color primaryColor = Color(0xFF0F766E); // Qcare teal
  
  List<dynamic> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final fetchedDoctors = await ApiService.getDoctors();
      setState(() {
        doctors = fetchedDoctors;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching doctors: $e')),
      );
    }
  }

  final List<String> departments = [
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
  ];



  void _editDoctor(int index) {
    final doctor = doctors[index];
    final TextEditingController editNameController =
        TextEditingController(text: doctor['name']);
    final TextEditingController editSpecializationController =
        TextEditingController(text: doctor['specialization'] ?? '');
    String editSelectedDepartment = doctor['department_name'] ?? 'Cardiology';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Doctor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editNameController,
                  decoration: const InputDecoration(labelText: 'Doctor Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: editSpecializationController,
                  decoration: const InputDecoration(labelText: 'Specialization'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(
                      text: editSelectedDepartment),
                  onChanged: (value) {
                    editSelectedDepartment = value;
                  },
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                try {
                  await ApiService.updateDoctor(
                    doctor['doctor_id'],
                    name: editNameController.text,
                    department: editSelectedDepartment,
                    specialization: editSpecializationController.text,
                    hospitalName: widget.hospitalName,
                  );
                  Navigator.pop(context);
                  _fetchDoctors();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update failed: $e')),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDoctor(int index) {
    final doctor = doctors[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: const Text(
          'Are you sure you want to delete this doctor?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () async {
              try {
                await ApiService.deleteDoctor(doctor['doctor_id']);
                Navigator.pop(context);
                _fetchDoctors();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete failed: $e')),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

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
          'Manage Doctors',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📋 DOCTOR LIST
            const Text(
              'Doctor List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : doctors.isEmpty
                    ? const Text(
                        'No doctors added yet',
                        style: TextStyle(color: Colors.grey),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];

                          return Container(
                        margin:
                            const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius:
                              BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),
                              blurRadius: 8,
                              offset:
                                  const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_rounded,
                              size: 36,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor['name']!,
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${doctor['department_name']} | ${doctor['specialization'] ?? 'General'}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: primaryColor,
                              ),
                              onPressed: () {
                                _editDoctor(index);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_rounded,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _confirmDeleteDoctor(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
