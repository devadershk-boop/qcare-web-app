import 'dart:core';

void main() {
  final now = DateTime.now();
  int h = 12; // 12:04 PM
  int m = 4;
  
  DateTime staticTime = DateTime(now.year, now.month, now.day, h, m);
  bool isLateToStart = true;
  int totalWaitFromNow = 0; // assuming doctor hasn't started
  
  DateTime calculateTime;
  if (isLateToStart) {
    calculateTime = now.add(Duration(minutes: totalWaitFromNow));
  } else {
    calculateTime = staticTime;
  }
  
  final newH = calculateTime.hour == 0 ? 12 : (calculateTime.hour > 12 ? calculateTime.hour - 12 : calculateTime.hour);
  final newM = calculateTime.minute.toString().padLeft(2, '0');
  final newAmPm = calculateTime.hour >= 12 ? 'PM' : 'AM';
  
  print("Current Time: \$now");
  print("Token 2 book time: \$staticTime");
  print("ETA Time Calculated: \$newH:\$newM \$newAmPm");
  
  // What is the 'Estimated Wait Mins' variable
  int waitFromOthers = 0;
  int activePatientRemainingTime = 0;
  int breakDuration = 0;
  print("Total wait from now computed as: \${waitFromOthers + activePatientRemainingTime + breakDuration}");
}
