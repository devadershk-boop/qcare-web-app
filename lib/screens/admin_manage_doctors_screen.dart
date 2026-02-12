import 'package:flutter/material.dart';
import '../data/doctor_data.dart';

class AdminManageDoctorsScreen extends StatefulWidget {
  const AdminManageDoctorsScreen({super.key});

  @override
  State<AdminManageDoctorsScreen> createState() =>
      _AdminManageDoctorsScreenState();
}

class _AdminManageDoctorsScreenState
    extends State<AdminManageDoctorsScreen> {
  static const Color primaryColor = Color(0xFF0F766E); // Qcare teal

  final TextEditingController nameController =
      TextEditingController();
  final TextEditingController emailController =
      TextEditingController();

  String selectedDepartment = 'Cardiology';

  final List<String> departments = [
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
  ];

  void _addDoctor() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
        ),
      );
      return;
    }

    DoctorData.addDoctor(
      name: nameController.text,
      department: selectedDepartment,
    );

    nameController.clear();
    emailController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Doctor added successfully'),
      ),
    );

    setState(() {});
  }

  void _confirmDeleteDoctor(int index) {
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
            onPressed: () {
              DoctorData.doctors.removeAt(index);
              Navigator.pop(context);
              setState(() {});
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
            // ➕ ADD DOCTOR
            const Text(
              'Add New Doctor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Doctor Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedDepartment,
              items: departments
                  .map(
                    (dept) => DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Department',
                prefixIcon: Icon(Icons.local_hospital),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _addDoctor,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Doctor',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 📋 DOCTOR LIST
            const Text(
              'Doctor List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            DoctorData.doctors.isEmpty
                ? const Text(
                    'No doctors added yet',
                    style: TextStyle(color: Colors.grey),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: DoctorData.doctors.length,
                    itemBuilder: (context, index) {
                      final doctor =
                          DoctorData.doctors[index];

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
                                    doctor['department']!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
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
