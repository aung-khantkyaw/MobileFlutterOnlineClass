// Import core Flutter UI package
import 'package:flutter/material.dart';
// Import the sqflite package for SQLite database
import 'package:sqflite/sqflite.dart';
// Import path package to correctly build file paths for the database
import 'package:path/path.dart';

// Entry point of the app
void main() => runApp(MyApp());

// Root widget of the app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local DB Demo', // App title
      home: NotesPage(),      // Home screen widget
    );
  }
}

// A StatefulWidget to handle dynamic UI updates
class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

// State class that manages UI and database logic
class _NotesPageState extends State<NotesPage> {
  late Database database; // SQLite Database instance (late initialization)
  List<Map<String, dynamic>> notes = []; // List to hold note entries from the DB
  final TextEditingController controller = TextEditingController(); // Controller for input text field
  int? _editingNoteId;

  // Initializes the SQLite database
  Future<void> initDB() async {
    // Opens or creates the database at a specified path
    database = await openDatabase(
      join(await getDatabasesPath(), 'notes.db'), // Path: app's DB directory + file name
      onCreate: (db, version) {
        // Called when the database is created for the first time
        return db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)',
          // Creates a table 'notes' with an auto-incrementing id and a text field
        );
      },
      version: 1, // DB version
    );

    // Load existing notes into the app after database is ready
    fetchNotes();
  }

  // Function to insert a new note into the database
  Future<void> insertNote(String content) async {
    await database.insert(
      'notes', // Table name
      {'content': content}, // Map with column names and values
    );
    fetchNotes(); // Refresh notes list after insertion
  }

  // Retrieves all notes from the database
  Future<void> fetchNotes() async {
    final List<Map<String, dynamic>> maps = await database.query('notes');
    // Updates the local notes list and UI
    setState(() {
      notes = maps;
    });
  }

  Future<Map<String, dynamic>?> fetchNoteById(int id) async {
    final List<Map<String, dynamic>> result = await database.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> updateNote(int id, String content) async {
    await database.update(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
        {'content': content}
    );
    fetchNotes();
  }

  // Deletes a note by its ID
  Future<void> deleteNote(int id) async {
    await database.delete(
      'notes',              // Table name
      where: 'id = ?',      // Condition to match the note by ID
      whereArgs: [id],      // Arguments for the condition
    );
    fetchNotes();           // Refresh notes list after deletion
  }

  // Called once when the widget is inserted into the widget tree
  @override
  void initState() {
    super.initState();
    initDB(); // Initialize the database when the screen loads
  }

  // Builds the UI for the NotesPage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Notes')), // App bar with title
      body: Column(
        children: [
          // Input field and send button
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: controller, // Link the controller to get text input
              decoration: InputDecoration(
                labelText: 'Enter note', // Hint text in the input box
                suffixIcon: IconButton(
                  icon: Icon(Icons.send), // Icon at the end of input field
                  onPressed: () {
                    // When the send icon is pressed
                    if (controller.text.isNotEmpty) {
                      if (_editingNoteId == null) {
                        insertNote(controller.text);
                      } else {
                        updateNote(_editingNoteId!, controller.text);
                        _editingNoteId = null;
                      }
                      controller.clear(); // Clear the input field after saving
                    }
                  },
                ),
              ),
            ),
          ),
          // Display the list of notes
          Expanded(
            child: ListView.builder(
              itemCount: notes.length, // Number of notes to show
              itemBuilder: (context, index) {
                final note = notes[index]; // Get current note
                return ListTile(
                  title: Text(note['content']), // Display note text
                  trailing:Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final noteToEdit = await fetchNoteById(note['id']);
                          if (noteToEdit != null) {
                            controller.text = noteToEdit['content'];
                            _editingNoteId = note['id'];
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete), // Delete icon
                        onPressed: () => deleteNote(note['id']), // Delete this note
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
