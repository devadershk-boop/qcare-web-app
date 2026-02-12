class TokenData {
  static String tokenNumber = 'A12';
  static String patientName = 'Suresh';
  static String status = 'Waiting';
  static int queuePosition = 3;
  static String estimatedTime = '15 mins';

  static void updateStatus(String newStatus) {
    status = newStatus;

    if (newStatus == 'In Progress') {
      queuePosition = 1;
      estimatedTime = '5 mins';
    } else if (newStatus == 'Completed') {
      queuePosition = 0;
      estimatedTime = 'Done';
    }
  }
}
