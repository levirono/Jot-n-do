import 'package:flutter/material.dart';

class TodoItemScreen extends StatelessWidget {
  final String todoTitle;
  final String todoDescription;
  final DateTime dueDate;
  final String priority;
  final String status;
  final String category;

  TodoItemScreen({
    required this.todoTitle,
    required this.todoDescription,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(todoTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              // Handle the edit action as needed
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: $todoDescription', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Due Date: ${dueDate.toLocal()}', style: TextStyle(fontSize: 16)), // Removed due time
            SizedBox(height: 10),
            Text('Priority: $priority', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Status: $status', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Category: $category', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
