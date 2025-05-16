import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // Importing Hive for local storage

class NotesPage extends StatefulWidget {
  final String username;

  NotesPage({required this.username}); // Constructor to accept the username

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController noteController = TextEditingController(); // Controller for the note input field
  final List<String> notes = []; // List to store the notes temporarily

  void _saveNote() async {
    var box = await Hive.openBox(widget.username); // Open a box named after the logged-in username
    final note = noteController.text.trim(); // Get the note content from the input

    if (note.isNotEmpty) {
      setState(() {
        notes.add(note); // Add the note to the temporary list
      });

      await box.put(DateTime.now().toString(), note); // Save the note with a timestamp as key
      noteController.clear(); // Clear the input field after saving the note
    }
  }

  void _deleteNote() {
    setState(() {
      notes.clear(); // Clears all notes from the temporary list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes for ${widget.username}'), // Show username in the app bar
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteNote, // Delete all notes on button press
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adds padding around the body content
        child: Column(
          children: [
            TextField(
              controller: noteController, // Binds the note input to the controller
              decoration: InputDecoration(
                labelText: 'Enter Note',
                border: OutlineInputBorder(), // Adds a border around the input field
              ),
            ),
            ElevatedButton(
              onPressed: _saveNote, // Trigger the save note function
              child: Text('Save Note'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length, // Show the number of notes in the list
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(notes[index]), // Show each note
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
