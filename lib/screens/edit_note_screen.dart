import 'package:flutter/material.dart';
import 'package:genix_jot_do/data/database_helper.dart';

class EditNoteScreen extends StatefulWidget {
  final String initialTitle;
  final String initialContent;
  final Function onUpdate;

  EditNoteScreen({
    required this.initialTitle,
    required this.initialContent,
    required this.onUpdate,
  });

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final dbHelper = DatabaseHelper();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _saving = false;
  late TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _textStyle = TextStyle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
        actions: [
          IconButton(
            onPressed: _saving
                ? null
                : () async {
              final title = _titleController.text.trim();
              final content = _contentController.text.trim();
              if (title.isNotEmpty && content.isNotEmpty) {
                setState(() {
                  _saving = true;
                });

                try {
                  await dbHelper.updateNote(
                    oldTitle: widget.initialTitle,
                    newTitle: title,
                    newContent: content,
                  );
                  widget.onUpdate();
                  Navigator.pop(context);
                } catch (e) {
                  print('Error updating note: $e');
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    controller: _contentController,
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.format_bold),
                    onPressed: () {
                      setState(() {
                        _textStyle = _textStyle.copyWith(
                          fontWeight: _textStyle.fontWeight == FontWeight.bold
                              ? FontWeight.normal
                              : FontWeight.bold,
                        );
                      });
                    },
                    color: _textStyle.fontWeight == FontWeight.bold
                        ? Colors.blue
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.format_italic),
                    onPressed: () {
                      setState(() {
                        _textStyle = _textStyle.copyWith(
                          fontStyle: _textStyle.fontStyle == FontStyle.italic
                              ? FontStyle.normal
                              : FontStyle.italic,
                        );
                      });
                    },
                    color: _textStyle.fontStyle == FontStyle.italic
                        ? Colors.blue
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.format_underline),
                    onPressed: () {
                      setState(() {
                        _textStyle = _textStyle.copyWith(
                          decoration: _textStyle.decoration ==
                              TextDecoration.underline
                              ? TextDecoration.none
                              : TextDecoration.underline,
                        );
                      });
                    },
                    color: _textStyle.decoration == TextDecoration.underline
                        ? Colors.blue
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.format_list_bulleted),
                    onPressed: () {
                      // Implement bullet formatting
                      // Example: You can insert bullet characters at the beginning of each line of text
                      // or apply a bullet style to the text
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
