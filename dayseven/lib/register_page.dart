import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart'; // Importing crypto to hash passwords
import 'dart:convert'; // Importing to encode the password into UTF-8

import 'login_page.dart'; // Importing LoginPage to navigate after successful registration

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState(); // Creates the state for the register page
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController(); // Controller for the username input field
  final passwordController = TextEditingController(); // Controller for the password input field
  final confirmPasswordController = TextEditingController(); // Controller for confirming the password

  bool _isPasswordVisible = false; // Flag to toggle password visibility
  bool _isConfirmPasswordVisible = false; // Flag to toggle confirm password visibility

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString(); // Hashes the password using SHA-256
  }

  List<String> validatePassword(String password) {
    List<String> errors = [];

    if (password.length < 8) {
      errors.add('Password must be at least 8 characters long.');
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('Must contain at least one uppercase letter.');
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('Must contain at least one lowercase letter.');
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      errors.add('Must contain at least one number.');
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      errors.add('Must contain at least one special character (!@#\$&*~).');
    }

    return errors;
  }

  Future<bool> _checkPasswordAndShowErrors(
      String username,
      String password,
      String confirmPassword,
      ) async {
    List<String> errors = validatePassword(password);

    if (password == username) {
      _showSnackBar('Password and username must not be the same.');
      return false;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match.');
      return false;
    }

    if (errors.isNotEmpty) {
      _showSnackBar(errors.join('\n'));
      return false;
    }

    return true;
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _register() async {
    var box = await Hive.openBox('users'); // Opens the Hive box to store user data
    final username = usernameController.text.trim(); // Getting the username from the input
    final password = passwordController.text.trim(); // Getting the password from the input
    final confirmPassword = confirmPasswordController.text.trim(); // Getting the confirmed password from the input

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Please fill all fields.');
      return;
    }

    if (box.containsKey(username)) {
      _showSnackBar('Username already exists.');
      return;
    }

    final isPasswordValid = await _checkPasswordAndShowErrors(
      username,
      password,
      confirmPassword,
    );

    if (!isPasswordValid) return;

    final hashedPassword = hashPassword(password); // Hashing the password
    await box.put(username, hashedPassword); // Store the username and hashed password in the box

    _showSnackBar('Registered successfully!', color: Colors.green);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to the login page after successful registration
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"), // Title of the register page
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
            TextField(
              controller: confirmPasswordController, // Binds the confirm password input to the controller
              obscureText: !_isConfirmPasswordVisible, // Hides the password if the flag is false
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off), // Shows/hides the confirm password when clicked
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible; // Toggles the confirm password visibility flag
                    });
                  },
                ),
              ),
            ),
            ElevatedButton(onPressed: _register, child: Text('Register')), // Button to trigger the registration process
          ],
        ),
      ),
    );
  }
}