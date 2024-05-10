// import 'package:flutter/material.dart';
// import 'package:genix_jot_do/data/database_helper.dart';
//
// class AddReminderScreen extends StatefulWidget {
//   const AddReminderScreen({Key? key}) : super(key: key);
//
//   @override
//   _AddReminderScreenState createState() => _AddReminderScreenState();
// }
//
// class _AddReminderScreenState extends State<AddReminderScreen> {
//   late TextEditingController _titleController;
//   late TextEditingController _descriptionController;
//   late DatabaseHelper _databaseHelper;
//
//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController();
//     _descriptionController = TextEditingController();
//     _databaseHelper = DatabaseHelper();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Reminder'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(labelText: 'Title'),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(labelText: 'Description'),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () async {
//                 await _databaseHelper.insertReminder(
//                   title: _titleController.text,
//                   description: _descriptionController.text,
//                   dueDate: DateTime.now(), // You may set due date here
//                   priority: 'low', // You may set priority here
//                   status: 'pending', // You may set status here
//                   notificationEnabled: true, // You may set notification enabled here
//                   notificationTime: '09:00', // You may set notification time here
//                 );
//                 Navigator.pop(context);
//               },
//               child: Text('Add Reminder'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
}

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DatabaseHelper {
//   static Database? _database;
//   static final _dbName = 'notes_todos.db';
//   static final _tableNotes = 'notes';
//   static final _tableTodos = 'todos';
//   static final _tableReminders = 'reminders';
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//
//     _database = await initDatabase();
//     return _database!;
//   }
//
//   Future<Database> initDatabase() async {
//     final path = join(await getDatabasesPath(), _dbName);
//     return openDatabase(path, version: 1, onCreate: _createTables);
//   }
//
//   Future<void> _createTables(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE $_tableNotes(
//         id INTEGER PRIMARY KEY,
//         title TEXT,
//         note TEXT,
//         creation_date TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE $_tableTodos(
//         id INTEGER PRIMARY KEY,
//         title TEXT,
//         description TEXT,
//         due_date TEXT,
//         priority TEXT,
//         status TEXT,
//         category TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE $_tableReminders(
//         id INTEGER PRIMARY KEY,
//         title TEXT,
//         description TEXT,
//         due_date TEXT,
//         priority TEXT,
//         status TEXT,
//         notification_enabled INTEGER,
//         notification_time TEXT
//       )
//     ''');
//   }
//
//   Future<int> insertNote({
//     required String title,
//     required String note,
//     required DateTime creationDate,
//   }) async {
//     final db = await database;
//     return db.insert(_tableNotes, {
//       'title': title,
//       'note': note,
//       'creation_date': creationDate.toIso8601String(),
//     });
//   }
//
//   Future<int> insertTodo({
//     required String title,
//     required String description,
//     required DateTime dueDate,
//     required String priority,
//     required String status,
//     required String category,
//   }) async {
//     final db = await database;
//     return db.insert(
//       _tableTodos,
//       {
//         'title': title,
//         'description': description,
//         'due_date': dueDate.toIso8601String(),
//         'priority': priority,
//         'status': status,
//         'category': category,
//       },
//     );
//   }
//
//   Future<int> insertReminder({
//     required String title,
//     required String description,
//     required DateTime dueDate,
//     required String priority,
//     required String status,
//     required bool notificationEnabled,
//     required String notificationTime,
//   }) async {
//     final db = await database;
//     return db.insert(
//       _tableReminders,
//       {
//         'title': title,
//         'description': description,
//         'due_date': dueDate.toIso8601String(),
//         'priority': priority,
//         'status': status,
//         'notification_enabled': notificationEnabled ? 1 : 0,
//         'notification_time': notificationTime,
//       },
//     );
//   }
//
//   Future<int> updateNote({
//     required String oldTitle,
//     required String newTitle,
//     required String newContent,
//   }) async {
//     final db = await database;
//     return db.update(
//       _tableNotes,
//       {'title': newTitle, 'note': newContent},
//       where: 'title = ?',
//       whereArgs: [oldTitle],
//     );
//   }
//
//   Future<int> updateTodoStatus({
//     required int id,
//     required String status,
//   }) async {
//     final db = await database;
//     return db.update(_tableTodos, {'status': status}, where: 'id = ?', whereArgs: [id]);
//   }
//
//   Future<int> updateReminder({
//     required int id,
//     required String title,
//     required String description,
//     required DateTime dueDate,
//     required String priority,
//     required String status,
//     required bool notificationEnabled,
//     required String notificationTime,
//   }) async {
//     final db = await database;
//     return db.update(
//       _tableReminders,
//       {
//         'title': title,
//         'description': description,
//         'due_date': dueDate.toIso8601String(),
//         'priority': priority,
//         'status': status,
//         'notification_enabled': notificationEnabled ? 1 : 0,
//         'notification_time': notificationTime,
//       },
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future<int> updateReminderStatus({
//     required int id,
//     required String status,
//   }) async {
//     final db = await database;
//     return db.update(_tableReminders, {'status': status}, where: 'id = ?', whereArgs: [id]);
//   }
//
//   Future<Map<String, dynamic>?> getReminderById(int id) async {
//     final db = await database;
//     final List<Map<String, dynamic>> reminders = await db.query(
//       _tableReminders,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     return reminders.isNotEmpty ? reminders.first : null;
//   }
//
//   Future<List<Map<String, dynamic>>> getOverdueTodos() async {
//     final db = await database;
//     final now = DateTime.now();
//     return db.query(
//       _tableTodos,
//       where: 'status = ? AND due_date < ?',
//       whereArgs: ['pending', now.toIso8601String()],
//     );
//   }
//
//   Future<List<Map<String, dynamic>>> getNotes() async {
//     final db = await database;
//     return db.query(_tableNotes);
//   }
//
//   Future<List<Map<String, dynamic>>> getRecentNotes() async {
//     final db = await database;
//     return db.query(
//       _tableNotes,
//       orderBy: 'creation_date DESC', // Order by creation_date in descending order
//       limit: 4, // Limit the result to the 4 most recent notes
//     );
//   }
//
//   Future<List<Map<String, dynamic>>> getRecentTodos() async {
//     final db = await database;
//     return db.query(
//       _tableTodos,
//       orderBy: 'due_date DESC', // Order by due_date in descending order
//       limit: 4, // Limit the result to the 4 most recent todos
//     );
//   }
//
//   Future<List<Map<String, dynamic>>> getTodos() async {
//     final db = await database;
//     return db.query(_tableTodos);
//   }
//
//   Future<List<Map<String, dynamic>>> getReminders() async {
//     final db = await database;
//     return db.query(_tableReminders);
//   }
//
//   Future<int> deleteNote(int id) async {
//     final db = await database;
//     return db.delete(_tableNotes, where: 'id = ?', whereArgs: [id]);
//   }
//
//   Future<int> deleteTodo(int id) async {
//     final db = await database;
//     return db.delete(_tableTodos, where: 'id = ?', whereArgs: [id]);
//   }
//
//   Future<int> deleteReminder(int id) async {
//     final db = await database;
//     return db.delete(_tableReminders, where: 'id = ?', whereArgs: [id]);
//   }
// }

