import 'dart:core';

void main() {
  String deptStartStr = "2026-03-03T06:18:48.000Z";
  String isoStr = "${deptStartStr.replaceFirst(' ', 'T')}Z";
  
  final startedAt = DateTime.parse(deptStartStr).toUtc();
  final now = DateTime.now().toUtc();
  
  print("Started At: \$startedAt");
  print("Now: \$now");
  print("Elapsed Mins: \${now.difference(startedAt).inMinutes}");
}
