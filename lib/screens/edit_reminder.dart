import 'package:flutter/material.dart';
import 'package:genix_jot_do/data/database_helper.dart';

class EditReminderScreen extends StatefulWidget {
  final int reminderId;

  const EditReminderScreen({Key? key, required this.reminderId}) : super(key: key);

  @override
  _EditReminderScreenState createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _databaseHelper = DatabaseHelper();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    // Load reminder details using the reminderId
    final reminder = await _databaseHelper.getReminderById(widget.reminderId);
    if (reminder != null) {
      setState(() {
        _titleController.text = reminder['title'] ?? '';
        _descriptionController.text = reminder['description'] ?? '';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _databaseHelper.updateReminder(
                  id: widget.reminderId,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  dueDate: DateTime.now(), // You may set due date here
                  priority: 'low', // You may set priority here
                  status: 'pending', // You may set status here
                  notificationEnabled: true, // You may set notification enabled here
                  notificationTime: '09:00', // You may set notification time here
                );
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
