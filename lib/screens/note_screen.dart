import 'package:flutter/material.dart';
import 'package:genix_jot_do/screens/note_form.dart';
import 'package:genix_jot_do/screens/note_item.dart';
import 'package:genix_jot_do/data/database_helper.dart';
import 'dart:math';


class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context,
                  delegate: NoteSearchDelegate(
                      dbHelper.getNotes(), _openNoteItem));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> notes = snapshot.data?.toList() ?? [];
            notes.sort((a, b) => b['creation_date'].compareTo(a['creation_date']));

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final random = Random();
                final color = Color.fromARGB(
                  255,
                  random.nextInt(256),
                  random.nextInt(256),
                  random.nextInt(256),
                );
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      note['title'][0], // Get the first character of the note title
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: color, // Use random color
                  ),
                  title: Text(note['title']),
                  subtitle: Text('Created on: ${_formatCreationDate(note['creation_date'])}'),
                  onTap: () async {
                    await _openNoteItem(note);
                  },
                  onLongPress: () async {
                    await _showOptionsDialog(note);
                  },
                );
              },
            );

          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addNote();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _openNoteItem(Map<String, dynamic> note) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NoteItemScreen(
                noteTitle: note['title'],
                noteContent: note['note'],
                onUpdate: () async {
                  setState(() {});
                },
              ),
        ),
      );
      if (result != null && result) {
        // If the note was updated, call the onUpdate callback
        setState(() {});
      }
    } catch (e) {
      print('Error opening note item: $e');
    }
  }

  Future<void> _showOptionsDialog(Map<String, dynamic> note) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Note Options'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _openNoteItem(note);
              },
              child: Text('Edit Note'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _showDeleteDialog(note);
              },
              child: Text('Delete Note'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(Map<String, dynamic> note) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await dbHelper.deleteNote(note['id']);
                Navigator.pop(context);
                setState(() {});
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNote() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNoteScreen(),
        ),
      );
      setState(() {});
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  String _formatCreationDate(String creationDate) {
    // Parse the ISO 8601 string to DateTime object
    final dateTime = DateTime.parse(creationDate);

    // Format the DateTime to display only year, month, day, hour, and minute
    final formattedDate = '${dateTime.year}-${dateTime.month.toString().padLeft(
        2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute
        .toString().padLeft(2, '0')}';

    // Limit the number of characters displayed
    final maxLength = 16;
    return creationDate.length <= maxLength ? creationDate : creationDate
        .substring(0, maxLength);
  }
}

class NoteSearchDelegate extends SearchDelegate<List<Map<String, dynamic>>> {
  final Future<List<Map<String, dynamic>>> notesFuture;
  final Function(Map<String, dynamic>) onNoteTap; // Callback function

  NoteSearchDelegate(this.notesFuture, this.onNoteTap);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context,[]);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: notesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final notes = snapshot.data ?? [];
          final filteredNotes = notes.where((note) => note['title'].toLowerCase().contains(query.toLowerCase())).toList();
          return ListView.builder(
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              final note = filteredNotes[index];
              return ListTile(
                title: Text(note['title']),
                subtitle: Text('Created on: ${note['creation_date']}'),
                onTap: () async {
                  onNoteTap(note); // Call the callback function
                },
              );
            },
          );
        }
      },
    );
  }
}
