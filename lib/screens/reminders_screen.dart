// import 'package:flutter/material.dart';
// import 'package:genix_jot_do/data/database_helper.dart';
// import 'package:genix_jot_do/screens/add_reminder.dart';
// import 'package:genix_jot_do/screens/edit_reminder.dart';
//
// class RemindersScreen extends StatefulWidget {
//   const RemindersScreen({Key? key}) : super(key: key);
//
//   @override
//   _RemindersScreenState createState() => _RemindersScreenState();
// }
//
// class _RemindersScreenState extends State<RemindersScreen> {
//   late DatabaseHelper _databaseHelper;
//   List<Map<String, dynamic>> _reminders = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _databaseHelper = DatabaseHelper();
//     _loadReminders();
//   }
//
//   Future<void> _loadReminders() async {
//     List<Map<String, dynamic>> reminders = await _databaseHelper.getReminders();
//     setState(() {
//       _reminders = reminders;
//     });
//   }
//
//   Future<void> _showAddReminderDialog(BuildContext context) async {
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AddReminderScreen();
//       },
//     );
//     await _loadReminders(); // Reload reminders after adding a new one
//   }
//
//   Future<void> _showEditReminderDialog(
//       BuildContext context, Map<String, dynamic> reminder) async {
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return EditReminderScreen(reminderId: reminder['id']);
//       },
//     );
//     await _loadReminders(); // Reload reminders after editing one
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Reminders'),
//       ),
//       body: _reminders.isEmpty
//           ? Center(
//         child: Text('No reminders'),
//       )
//           : ListView.builder(
//         itemCount: _reminders.length,
//         itemBuilder: (context, index) {
//           final reminder = _reminders[index];
//           return ListTile(
//             title: Text(reminder['title']),
//             subtitle: Text(
//               'Due Date: ${DateTime.parse(reminder['due_date']).toString()}',
//             ),
//             onTap: () {
//               _showEditReminderDialog(context, reminder);
//             },
//             onLongPress: () {
//               _showEditReminderDialog(context, reminder);
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showAddReminderDialog(context);
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
