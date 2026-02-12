class DoctorData {
  // Shared doctor list (acts like database)
  static List<Map<String, String>> doctors = [
    {
      'name': 'Dr. Arun',
      'department': 'Cardiology',
    },
    {
      'name': 'Dr. Meera',
      'department': 'Neurology',
    },
  ];

  static void addDoctor({
    required String name,
    required String department,
  }) {
    doctors.add({
      'name': name,
      'department': department,
    });
  }

  static List<String> getDepartments() {
    return doctors
        .map((doc) => doc['department']!)
        .toSet()
        .toList();
  }

  static List<String> getDoctorsByDepartment(String department) {
    return doctors
        .where((doc) => doc['department'] == department)
        .map((doc) => doc['name']!)
        .toList();
  }
}
