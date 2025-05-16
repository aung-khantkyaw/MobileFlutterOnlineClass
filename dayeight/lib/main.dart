import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance.dart';

void main() {
  runApp(const MyApp());
}

class User {
  String username;
  String phone;
  String date;

  User({required this.username, required this.phone, required this.date});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'phone': phone,
      'date': date,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      phone: json['phone'],
      date: json['date'],
    );
  }
}

class SharedPreferencesService {
  static Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersList = prefs.getStringList('users') ?? [];

    usersList.add(jsonEncode(user.toJson()));

    await prefs.setStringList('users', usersList);
  }

  static Future<List<User>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersList = prefs.getStringList('users') ?? [];

    return usersList.map((user) => User.fromJson(jsonDecode(user))).toList();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Info Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  List<User> users = [];

  Future<void> _saveUser() async {
    final username = usernameController.text;
    final phone = phoneController.text;

    if (username.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final currentDate = DateTime.now().toString();
    final newUser = User(username: username, phone: phone, date: currentDate);

    await SharedPreferencesService.saveUserData(newUser);

    usernameController.clear();
    phoneController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration Successful.')),
    );
  }

  Future<void> _loadUsers() async {
    final allUsers = await SharedPreferencesService.getUserData();
    setState(() {
      users = allUsers;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Training Program'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendancePage()),
                );
              },
              child: Text('Go to Attendance Page'),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _saveUser,
                  child: const Text('Save'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _loadUsers,
                  child: const Text('Show All Users'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (users.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(user.username),
                        subtitle: Text('Phone: ${user.phone}\nDate: ${user.date}'),
                      ),
                    );
                  },
                ),
              )
            else
              const Text('No users registered yet.'),
          ],
        ),
      ),
    );
  }
}
