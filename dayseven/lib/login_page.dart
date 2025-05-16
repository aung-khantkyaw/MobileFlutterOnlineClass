import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart'; // Importing crypto to hash passwords
import 'dart:convert'; // Importing to encode the password into UTF-8
import 'notes_page.dart'; // Importing NotesPage to navigate after successful login
import 'register_page.dart'; // Importing RegisterPage to navigate for registration

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState(); // Creates the state for the login page
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController(); // Controller for the username input field
  final passwordController = TextEditingController(); // Controller for the password input field

  bool _isPasswordVisible = false; // Flag to toggle password visibility

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString(); // Hashes the password using SHA-256
  }

  void _login() async {
    var box = await Hive.openBox('users'); // Opens the Hive box to check user credentials
    final username = usernameController.text.trim(); // Getting the username from the input
    final password = hashPassword(passwordController.text.trim()); // Hashing the password

    if (box.containsKey(username) && box.get(username) == password) {
      // If the username exists in the box and the password matches
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NotesPage(username: username)),
      ); // Navigate to the Notes page if credentials are correct
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),), // Show an error if credentials are incorrect
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"), // Title of the login page
        leading: BackButton(), // Adds a back button in the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adds padding around the body content
        child: Column(
          children: [
            TextField(
              controller: usernameController, // Binds the username input to the controller
              decoration: InputDecoration(labelText: 'Username'), // Adds label for username input
            ),
            TextField(
              controller: passwordController, // Binds the password input to the controller
              obscureText: !_isPasswordVisible, // Hides the password if the flag is false
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off), // Shows/hides the password when clicked
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // Toggles the password visibility flag
                    });
                  },
                ),
              ),
            ),
            ElevatedButton(onPressed: _login, child: Text('Login')), // Button to trigger the login process
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()), // Navigate to the register page
                );
              },
              child: Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
