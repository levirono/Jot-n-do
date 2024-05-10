import 'package:flutter/material.dart';
import 'package:genix_jot_do/screens/edit_note_screen.dart';

class NoteItemScreen extends StatelessWidget {
  final String noteTitle;
  final String noteContent;
  final Function onUpdate; // Add the onUpdate callback function

  NoteItemScreen({
    required this.noteTitle,
    required this.noteContent,
    required this.onUpdate, // Define the onUpdate parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(noteTitle), // Set the specific note title as the app bar title
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await _editNote(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the top left
            children: [
              SelectableText('Title: $noteTitle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              SelectableText('Note: $noteContent', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editNote(BuildContext context) async {
    try {
      final updatedNote = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditNoteScreen(
            initialTitle: noteTitle,
            initialContent: noteContent,
            onUpdate: onUpdate, // Pass the onUpdate callback
          ),
        ),
      );
      if (updatedNote != null) {
        // If the note was updated, call the onUpdate callback
        onUpdate();
      }
    } catch (e) {
      print('Error editing note: $e');
    }
  }
}
