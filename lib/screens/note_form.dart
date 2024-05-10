import 'package:flutter/material.dart';
import 'package:genix_jot_do/data/database_helper.dart';

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _saving = false; // Indicator for saving state

  TextStyle _textStyle = TextStyle(); // TextStyle for the note text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
        actions: [
          IconButton(
            onPressed: _saving
                ? null
                : () async {
              final title = _titleController.text.trim();
              final note = _noteController.text.trim();
              if (title.isNotEmpty && note.isNotEmpty) {
                setState(() {
                  _saving = true;
                });

                try {
                  await dbHelper.insertNote(
                    title: title,
                    note: note,
                    creationDate: DateTime.now(),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  print('Error saving note: $e');
                } finally {
                  setState(() {
                    _saving = false;
                  });
                }
              } else {
                // Show an error message or handle the empty title/note case
              }
            },
            icon: _saving
                ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Theme(
                data: Theme.of(context).copyWith(
                  primaryColor: Colors.green,
                  scaffoldBackgroundColor: Colors.grey[200],
                  appBarTheme: AppBarTheme(
                    color: Colors.black,
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          labelText: 'Note',
                          alignLabelWithHint: true,
                        ),
                        style: _textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       IconButton(
          //         icon: Icon(Icons.format_bold),
          //         onPressed: () {
          //           setState(() {
          //             _textStyle = _textStyle.copyWith(
          //               fontWeight: _textStyle.fontWeight == FontWeight.bold
          //                   ? FontWeight.normal
          //                   : FontWeight.bold,
          //             );
          //           });
          //         },
          //         color: _textStyle.fontWeight == FontWeight.bold
          //             ? Colors.blue
          //             : null,
          //       ),
          //       IconButton(
          //         icon: Icon(Icons.format_italic),
          //         onPressed: () {
          //           setState(() {
          //             _textStyle = _textStyle.copyWith(
          //               fontStyle: _textStyle.fontStyle == FontStyle.italic
          //                   ? FontStyle.normal
          //                   : FontStyle.italic,
          //             );
          //           });
          //         },
          //         color: _textStyle.fontStyle == FontStyle.italic
          //             ? Colors.blue
          //             : null,
          //       ),
          //       IconButton(
          //         icon: Icon(Icons.format_underline),
          //         onPressed: () {
          //           setState(() {
          //             _textStyle = _textStyle.copyWith(
          //               decoration: _textStyle.decoration ==
          //                   TextDecoration.underline
          //                   ? TextDecoration.none
          //                   : TextDecoration.underline,
          //             );
          //           });
          //         },
          //         color: _textStyle.decoration == TextDecoration.underline
          //             ? Colors.blue
          //             : null,
          //       ),
          //       IconButton(
          //         icon: Icon(Icons.format_list_bulleted),
          //         onPressed: () {
          //           // Implement bullet formatting
          //           // Example: You can insert bullet characters at the beginning of each line of text
          //           // or apply a bullet style to the text
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
