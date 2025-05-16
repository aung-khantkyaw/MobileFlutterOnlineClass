// Import the Flutter Material library and the shared_preferences package
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Entry point of the app
void main() {
  runApp(MyApp()); // Launch the app with MyApp as the root widget
}

// Root widget of the app (Stateless as it has no mutable state)
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared Preferences Demo',           // App title for switcher and browser tab
      theme: ThemeData(primarySwatch: Colors.blue), // Blue color theme
      home: SharedPreferencesDemo(),              // Load the home screen widget
    );
  }
}

// Stateful widget to demonstrate saving/loading/removing data
class SharedPreferencesDemo extends StatefulWidget {
  @override
  _SharedPreferencesDemoState createState() => _SharedPreferencesDemoState();
}

// The state class which contains the app logic and UI
class _SharedPreferencesDemoState extends State<SharedPreferencesDemo> {
  TextEditingController _controller = TextEditingController(); // Controls text input
  TextEditingController _passwordController = TextEditingController();
  List<String> _savedValue = []; // Stores the value loaded from Shared Preferences
  bool obscureText = true;

  String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Save the value from the text field
  Future<void> _saveData() async {
    if(_controller.text.isEmpty || _passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please input both username and password.')), // Feedback message
      );
    }
    else{
      SharedPreferences prefs = await SharedPreferences.getInstance(); // Access local storage
      await prefs.setString('username', _controller.text); // Save under key 'username'
      await prefs.setString('password', encryptPassword(_passwordController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data Saved!')), // Feedback message
      );
      _controller.text = "";
      _passwordController.text = "";
    }
  }

  // Load the value and update the UI
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Access storage
    setState(() {
      _savedValue = [
        prefs.getString('username') ?? "No username found",
        prefs.getString('password') ?? "No password found"
      ]; // Load value or fallback
    });
  }

  // Remove the saved value
  Future<void> _removeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Access storage
    await prefs.remove('username'); // Remove the 'username' key
    await prefs.remove('password');
    setState(() {
      _savedValue = []; // Show confirmation in UI
    });
    if(_savedValue.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data Removed!')), // Feedback message
      );
    }
  }

  // UI of the app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shared Preferences Example')), // Top app bar title
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add uniform padding around content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
          children: [
            // Input field for username
            TextField(
              controller: _controller, // Connect controller to read input
              decoration: InputDecoration(labelText: 'Enter username'), // Label
            ),
            TextField(
              obscureText: obscureText,
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off
                  ),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                )
              ),
            ),
            SizedBox(height: 20), // Add vertical space
            // Save Button
            ElevatedButton(
              onPressed: _saveData, // Call _saveData() when pressed
              child: Text('Save'),
            ),
            // Load Button
            ElevatedButton(
              onPressed: _loadData, // Call _loadData() when pressed
              child: Text('Load'),
            ),
            // Remove Button
            ElevatedButton(
              onPressed: _removeData, // Call _removeData() when pressed
              child: Text('Remove'),
            ),
            SizedBox(height: 20), // Space before showing result
            // Display the saved or loaded value
            Text(
              'Saved Value: ',
              style: TextStyle(fontSize: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _savedValue.map((value) => Text(value)).toList(),
            )
          ],
        ),
      ),
    );
  }
}