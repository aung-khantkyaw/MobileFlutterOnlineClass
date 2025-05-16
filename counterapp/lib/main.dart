import 'dart:ffi';

import 'package:flutter/material.dart';

void main() => runApp(StudentAttendanceApp());

class StudentAttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Attendance',
      home: StudentAttendancePage(),
    );
  }
}

class StudentAttendancePage extends StatefulWidget {
  @override
  _StudentAttendancePageState createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  final List<String> students = ['Alice', 'Bob', 'Charlie'];
  final Map<String, bool> attendance = {};
  int count = 0;

  @override
  void initState() {
    super.initState();
    for (var student in students) {
      attendance[student] = false; // default to not present
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Attendance'),
      ),
      body: ListView(
        children:
        <Widget>[
          Text('Number of Students: $count / ${students.length}'),
          ...students.map((student) {
            return SwitchListTile(
              title: Text(student),
              value: attendance[student]!,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true && attendance[student] == false) {
                    count++;
                  } else if (value == false && attendance[student] == true) {
                    count--;
                  }
                  attendance[student] = value ?? false;
                });
              },
            );
          }).toList(),
        ],
      )
    );
  }
}
