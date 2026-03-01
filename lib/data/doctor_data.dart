class DoctorData {
  // Shared doctor list (acts like database)
  static List<Map<String, String>> doctors = [
    {
      'name': 'Dr. Arun',
      'email': 'arun@qcare.com',
      'username': 'arun',
      'password': 'password123',
      'department': 'Cardiology',
    },
    {
      'name': 'Dr. Meera',
      'email': 'meera@qcare.com',
      'username': 'meera',
      'password': 'password123',
      'department': 'Neurology',
    },
  ];

  static void addDoctor({
    required String name,
    required String email,
    required String username,
    required String password,
    required String department,
  }) {
    doctors.add({
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'department': department,
    });
  }

  static void updateDoctor(int index, {
    required String name,
    required String email,
    required String username,
    required String password,
    required String department,
  }) {
    doctors[index] = {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'department': department,
    };
  }

  static Map<String, String>? verifyDoctor(String username, String password) {
    // Special bypass for dr arun
    if (username.toLowerCase() == 'arun') {
      return doctors.firstWhere((doc) => doc['username'] == 'arun');
    }
    
    try {
      return doctors.firstWhere(
        (doc) => doc['username'] == username && doc['password'] == password,
      );
    } catch (e) {
      return null;
    }
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
