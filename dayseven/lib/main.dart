// // Flutter packages
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// /// A service class for simplified interaction with SharedPreferences.
// class SharedPreferencesService {
//   /// Saves a string value to SharedPreferences.
//   static Future<void> saveString(String key, String value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(key, value);
//   }
//
//   /// Retrieves a string value from SharedPreferences.
//   static Future<String?> getString(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(key);
//   }
//
//   /// Saves a boolean value to SharedPreferences.
//   static Future<void> saveBool(String key, bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(key, value);
//   }
//
//   /// Retrieves a boolean value from SharedPreferences.
//   static Future<bool?> getBool(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(key);
//   }
//
//   /// Removes a specific key-value pair from SharedPreferences.
//   static Future<void> remove(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(key);
//   }
//
//   /// Clears all stored values from SharedPreferences.
//   static Future<void> clearAll() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
// }
//
// // Main app to demonstrate usage
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Saving data
//   await SharedPreferencesService.saveString('username', 'aung');
//   await SharedPreferencesService.saveBool('isDarkMode', true);
//
//   // Retrieving data
//   String? username = await SharedPreferencesService.getString('username');
//   bool? isDarkMode = await SharedPreferencesService.getBool('isDarkMode');
//
//   // Print output to console
//   print('Username: $username');       // Output: Username: johndoe
//   print('Is Dark Mode: $isDarkMode'); // Output: Is Dark Mode: true
//
//   runApp(MyApp(username: username ?? '', isDarkMode: isDarkMode ?? false));
// }
//
// // Minimal UI to show retrieved values
// class MyApp extends StatelessWidget {
//   final String username;
//   final bool isDarkMode;
//
//   const MyApp({super.key, required this.username, required this.isDarkMode});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SharedPreferences Demo',
//       theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Preferences')),
//         body: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Username: $username'),
//               Text('Dark Mode: $isDarkMode'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'login_page.dart'; // Importing the LoginPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that the app is properly initialized before running
  await Hive.initFlutter(); // Initializes Hive for local storage
  await Hive.openBox('users'); // Opens a box to store user data securely
  runApp(MyApp()); // Runs the main app
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Login App',
      home: LoginPage(), // Initial route is the LoginPage
    );
  }
}