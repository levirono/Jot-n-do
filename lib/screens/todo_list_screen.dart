import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genix_jot_do/screens/todo_item.dart';
import 'package:genix_jot_do/screens/todo_form.dart';
import 'package:genix_jot_do/data/database_helper.dart';
import 'package:timezone/timezone.dart' as tz;

class TodosScreen extends StatefulWidget {
  @override
  _TodosScreenState createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final dbHelper = DatabaseHelper();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _configureLocalNotificationCallback();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _configureLocalNotificationCallback() {
    // Configure callback for handling notification actions
    FlutterLocalNotificationsPlugin().initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
      ),
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          // Handle action button press
          if (payload.startsWith('completed:')) {
            final todoId = int.parse(payload.split(':')[1]);
            // Update todo status as completed
            await dbHelper.updateTodoStatus(id: todoId, status: 'completed');
            // Refresh UI
            setState(() {});
          }
        }
      },
    );
  }

  void _scheduleNotification(
      String title, String body, DateTime scheduledDate, int id) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      autoCancel: true,
      styleInformation: BigTextStyleInformation(''),
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, // Unique id for notification
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'completed:$id', // Pass the todo id as payload
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('To-Dos'),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getTodos(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
    } else {
    final todos = snapshot.data ?? [];

    if (todos.isEmpty) {
    return Center(child: Text('No to-dos available.'));
    }

    // Group todos by their due date
    final groupedTodos = groupTodosByDate(todos);

    // Build the ListView with grouped todos
    return ListView.builder(
    itemCount: groupedTodos.length,
    itemBuilder: (context, index) {
    final group = groupedTodos[index];

    // Display previous days' tasks at the bottom of the list
    if (!group['isToday'] && !group['isFuture']) {
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
    group['title'],
    style: TextStyle(
    fontWeight: FontWeight.bold, fontSize: 18),
    ),
    ),
    ...group['todos'].map<Widget>((todo) {
    _scheduleNotification(
    todo['title'], 'Due Date: ${todo['due_date']}',
    DateTime.parse(todo['due_date']), todo['id']);
    return TodoItemTile(
    todo: todo,
    onUpdate: () {
    // Trigger rebuild of TodosScreen
    setState(() {});
    },
    );
    }).toList(),
    ],
    );
    }

    // Display today's tasks separately under "Today"
    if (group['isToday']) {
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
    'Today',
    style: TextStyle(
    fontWeight: FontWeight.bold, fontSize: 18),
    ),
    ),
    ...group['todos'].map<Widget>((todo) {
    _scheduleNotification(
    todo['title'], 'Due Date: ${todo['due_date']}',
    DateTime.parse(todo['due_date']), todo['id']);
    return TodoItemTile(
    todo: todo,
    onUpdate: () {
    // Trigger rebuild of TodosScreen
    setState(() {});
    },
    );
    }).toList(),
    ],
    );
    }

    // Display yesterday's tasks separately under "Yesterday"
    if (group['isYesterday']) {
    return Column(
    crossAxisAlignment: CrossAxisAlignment
        .start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Yesterday',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ...group['todos'].map<Widget>((todo) {
          _scheduleNotification(
              todo['title'], 'Due Date: ${todo['due_date']}',
              DateTime.parse(todo['due_date']), todo['id']);
          return TodoItemTile(
            todo: todo,
            onUpdate: () {
              // Trigger rebuild of TodosScreen
              setState(() {});
            },
          );
        }).toList(),
      ],
    );
    }

    return SizedBox(); // Return an empty SizedBox for future days
    },
    );
    }
    },
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTodoScreen()),
          );

          setState(() {}); // Refresh the UI after adding a todo
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Function to group todos by due date
  List<Map<String, dynamic>> groupTodosByDate(
      List<Map<String, dynamic>> todos) {
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));
    final groupedTodos = <Map<String, dynamic>>[];
    List<Map<String, dynamic>> todayTodos = [];
    List<Map<String, dynamic>> yesterdayTodos = [];
    List<Map<String, dynamic>> pastTodos = [];

    // Group todos by date
    todos.forEach((todo) {
      final dueDate = DateTime.parse(todo['due_date']);
      final formattedDate = dueDate.toLocal().toString().split(' ')[0];

      // Check if the todo's due date is today
      final isToday = dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day;

      // Check if the todo's due date is yesterday
      final isYesterday = dueDate.year == yesterday.year &&
          dueDate.month == yesterday.month &&
          dueDate.day == yesterday.day;

      // Check if the todo's due date is in the past
      final isPast = dueDate.isBefore(today);

      if (isToday) {
        todayTodos.add(todo);
      } else if (isYesterday) {
        yesterdayTodos.add(todo);
      } else if (isPast) {
        pastTodos.add(todo);
      } else {
        // Find the group index for the todo
        var groupIndex =
        groupedTodos.indexWhere((group) => group['title'] == formattedDate);

        if (groupIndex == -1) {
          // If group not found, add a new group
          groupIndex = groupedTodos.length;
          groupedTodos.add({
            'title': formattedDate,
            'todos': <Map<String, dynamic>>[],
            'isToday': false,
            'isYesterday': false,
            'isFuture': false,
          });
        }

        // Add the todo to the corresponding group
        groupedTodos[groupIndex]['todos'].add(todo);
      }
    });

    if (todayTodos.isNotEmpty) {
      groupedTodos.insert(
        0,
        {
          'title': 'Today',
          'todos': todayTodos,
          'isToday': true,
          'isYesterday': false,
          'isFuture': false,
        },
      );
    }

    if (yesterdayTodos.isNotEmpty) {
      groupedTodos.insert(
        0,
        {
          'title': 'Yesterday',
          'todos': yesterdayTodos,
          'isToday': false,
          'isYesterday': true,
          'isFuture': false,
        },
      );
    }

    if (pastTodos.isNotEmpty) {
      groupedTodos.add(
        {
          'title': 'Previous Days',
          'todos': pastTodos,
          'isToday': false,
          'isYesterday': false,
          'isFuture': false,
        },
      );
    }

    return groupedTodos;
  }
}

class TodoItemTile extends StatelessWidget {
  final Map<String, dynamic> todo;
  final VoidCallback onUpdate;

  const TodoItemTile({required this.todo, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.parse(todo['due_date']);
    return ListTile(
      title: Text(todo['title']),
      subtitle: Text('Due Date: ${dueDate.toLocal()}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TodoItemScreen(
              todoTitle: todo['title'],
              todoDescription: todo['description'],
              dueDate: dueDate,
              priority: todo['priority'],
              status: todo['status'],
              category: todo['category'],
            ),
          ),
        );
      },
      leading: Checkbox(
        value: todo['status'] == 'completed',
        onChanged: (value) async {
          // Update status only if the todo is not completed
          if (value != null && todo['status'] != 'completed') {
            // Update the status in the database
            await DatabaseHelper().updateTodoStatus(
              id: todo['id'],
              status: value ? 'completed' : 'pending',
            );

            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Todo status updated.')));

            // Notify TodosScreen about the update
            onUpdate();
          }
        },
      ),
      trailing: dueDate.isBefore(DateTime.now())
          ? Icon(Icons.warning, color: Colors.red)
          : null,
    );
  }
}
