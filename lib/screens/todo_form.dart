import 'package:flutter/material.dart';
import 'package:genix_jot_do/data/database_helper.dart';

class AddTodoScreen extends StatefulWidget {
  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateTimeController = TextEditingController(); // Controller for due date and time
  final TextEditingController _categoryController = TextEditingController();
  String _priorityValue = 'High'; // Default priority value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add To-Do'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _todoController,
              decoration: InputDecoration(labelText: 'Enter your to-do'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _dueDateTimeController, // Use the controller for due date and time
              readOnly: true, // Make it read-only to prevent manual editing
              decoration: InputDecoration(labelText: 'Due Date & Time'),
              onTap: () async {
                DateTime? pickedDateTime = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 5),
                );

                if (pickedDateTime != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    // Combine the selected date and time
                    pickedDateTime = DateTime(
                      pickedDateTime.year,
                      pickedDateTime.month,
                      pickedDateTime.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    setState(() {
                      _dueDateTimeController.text = pickedDateTime!.toString();
                    });
                  }
                }
              },
            ),
            DropdownButtonFormField<String>(
              value: _priorityValue,
              onChanged: (value) {
                setState(() {
                  _priorityValue = value!;
                });
              },
              items: <String>['High', 'Moderate', 'Low']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ),
              )
                  .toList(),
              decoration: InputDecoration(labelText: 'Priority'),
            ),
            TextField(
              enabled: false, // Disable status field
              controller: TextEditingController(text: 'pending'), // Predefined status as pending
              decoration: InputDecoration(labelText: 'Status'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final todoTitle = _todoController.text.trim();
                final todoDescription = _descriptionController.text.trim();
                final priority = _priorityValue;
                final category = _categoryController.text.trim();

                try {
                  final dueDateTime = DateTime.parse(_dueDateTimeController.text.trim());

                  if (todoTitle.isNotEmpty) {
                    print('Inserting Todo: Title: $todoTitle, Description: $todoDescription, Due Date & Time: $dueDateTime, Priority: $priority, Category: $category');

                    // Insert the todo into the database
                    final insertedId = await dbHelper.insertTodo(
                      title: todoTitle,
                      description: todoDescription,
                      dueDate: dueDateTime,
                      priority: priority,
                      status: 'pending',
                      category: category,
                    );

                    print('Todo inserted with ID: $insertedId');

                    // Navigate back after successful insertion
                    Navigator.pop(context);
                  } else {
                    // Show error message for empty todo title
                    print('Error: Todo title is empty');
                  }
                } catch (e) {
                  // Handle parsing exception
                  print('Error while parsing input data: $e');
                }
              },
              child: Text('Save To-Do'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _todoController.dispose();
    _descriptionController.dispose();
    _dueDateTimeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
