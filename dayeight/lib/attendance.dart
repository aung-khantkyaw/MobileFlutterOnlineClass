import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class Attendance {
  String username;
  String date;

  Attendance({required this.username, required this.date});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'date': date,
    };
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      username: json['username'],
      date: json['date'],
    );
  }
}

class SharedPreferencesService {
  static Future<void> saveAttendance(Attendance attendance) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> attendanceList = prefs.getStringList('attendance') ?? [];

    attendanceList.add(jsonEncode(attendance.toJson()));

    await prefs.setStringList('attendance', attendanceList);
  }

  static Future<List<Attendance>> getAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> attendanceList = prefs.getStringList('attendance') ?? [];

    return attendanceList.map((attendance) => Attendance.fromJson(jsonDecode(attendance))).toList();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Training Program'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AttendancePage()),
            );
          },
          child: const Text('Go to Attendance Page'),
        ),
      ),
    );
  }
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Attendance> attendanceList = [];
  List<Attendance> filteredList = [];

  Future<void> _saveAttendance() async {
    final username = usernameController.text;

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    final currentDate = DateTime.now().toString();
    final newAttendance = Attendance(username: username, date: currentDate);

    await SharedPreferencesService.saveAttendance(newAttendance);

    usernameController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved')),
    );
  }

  Future<void> _loadAttendance() async {
    final allAttendance = await SharedPreferencesService.getAttendance();
    setState(() {
      attendanceList = allAttendance;
      filteredList = attendanceList;
    });
  }

  void _searchByDate() {
    final query = searchController.text;
    if (query.isEmpty) {
      setState(() {
        filteredList = attendanceList;
      });
    } else {
      setState(() {
        filteredList = attendanceList
            .where((attendance) => attendance.date.contains(query))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveAttendance,
              child: const Text('Mark Attendance'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAttendance,
              child: const Text('Show Attendance'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Date',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => _searchByDate(),
            ),
            const SizedBox(height: 20),
            if (filteredList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final attendance = filteredList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(attendance.username),
                        subtitle: Text('Date: ${attendance.date}'),
                      ),
                    );
                  },
                ),
              )
            else
              const Text('No attendance records yet or no records match the search criteria.'),
          ],
        ),
      ),
    );
  }
}
