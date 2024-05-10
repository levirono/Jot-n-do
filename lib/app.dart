import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genix_jot_do/data/database_helper.dart';
import 'screens/note_screen.dart';
import 'screens/todo_list_screen.dart';
import 'widgets/settings.dart';
import 'package:genix_jot_do/screens/note_form.dart';
import 'package:genix_jot_do/screens/todo_form.dart';
import 'package:genix_jot_do/screens/note_item.dart';
import 'package:genix_jot_do/screens/splash_screen.dart';
import 'dart:math';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'genix',
      theme: ThemeData(
        primaryColor: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          color: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.grey,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {

        '/':(context) =>SplashScreen(),
        '/home': (context) => MyHomePage(),
        '/notes': (context) => NotesScreen(),
        '/todos': (context) => TodosScreen(),
        '/quicknote':(context)=>AddNoteScreen(),
        '/quicktodo':(context)=>AddTodoScreen(),
        // '/reminders':(context)=>RemindersScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription _dbChangesSubscription;

  @override
  void initState() {
    super.initState();
    _listenToDbChanges();
  }

  @override
  void dispose() {
    _dbChangesSubscription.cancel();
    super.dispose();
  }

  void _listenToDbChanges() {
    _dbChangesSubscription = DatabaseHelper().dbChangesStream.listen((_) {
      // Update the UI when database changes occur
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: Future.wait([_getGreeting(), _getUserName()]),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return CircularProgressIndicator();
    } else if (snapshot.hasError) {
    return Text('Error: ${snapshot.error}');
    } else {
    final List<String> data = snapshot.data ?? ['', ''];
    final greeting = data[0] ?? '';
    final userName = data[1] ?? '';
    return WillPopScope(
    onWillPop: () async {
    // Restart the app when navigating back to the homepage
    Navigator.pushReplacementNamed(context, '/');
    return true;
    },
    child: Scaffold(
    appBar: AppBar(
    title: Text('GENIX Jot n Do'),
    leading: Builder(
    builder: (context) => IconButton(
    icon: Icon(Icons.menu),
    onPressed: () {
    Scaffold.of(context).openDrawer();
    },
    ),
    ),
    ),
    drawer: SettingsMenu(),
    body: SingleChildScrollView(
    child: Padding(
    padding: EdgeInsets.all(20.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    '$greeting, $userName',
    style: TextStyle(fontSize: 30.0),
    ),
    SizedBox(height: 20.0),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      SizedBox(
        width: 150.0,
        height: 150.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0), // Adjust as desired
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/quicknote');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sticky_note_2, size: 100.0, color: Colors.yellow[700]),
                Text('Quick Note'),
              ],
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(10.0),
            ),
          ),
        ),
      ),

      SizedBox(
        width: 150.0,
        height: 150.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0), // Adjust as desired
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/quicktodo');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_task, size: 100.0, color: Colors.red[300]),
                Text('Quick Todos'),
              ],
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(10.0),
            ),
          ),
        ),
      ),

    ],
    ),
    SizedBox(height: 20.0),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      SizedBox(
        width: 150.0,
        height: 150.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0), // Adjust as desired
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notes');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note, size: 100.0, color: Colors.cyan[700]),
                Text('My Notes'),
              ],
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(10.0),
            ),
          ),
        ),
      ),
      SizedBox(
        width: 150.0,
        height: 150.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0), // Adjust as desired
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/todos');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.playlist_add_check, size: 100.0, color: Colors.blue[700]),
                Text('Todos'),
              ],
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(10.0),
            ),
          ),
        ),
      ),

    ],
    ),
    SizedBox(height: 20.0),
    Column(
    children: [
    Text(
    'Recent Notes',
    style: TextStyle(
    fontSize: 18.0, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 10.0),
    Container(
    height: 300.0, // Set your desired height
    child: FutureBuilder<List<Map<String, dynamic>>>(
    future: DatabaseHelper().getRecentNotes(),
    builder: (context, snapshot) {
    if (snapshot.connectionState ==
    ConnectionState.waiting) {
    return Center(
    child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
    return Center(
    child: Text('Error: ${snapshot.error}'));
    } else {
    final recentNotes = snapshot.data ?? [];
    return ListView.builder(
      itemCount: recentNotes.length,
      itemBuilder: (context, index) {
        final note = recentNotes[index];
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
          subtitle: Text('Created on: ${note['creation_date']}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteItemScreen(
                  noteTitle: note['title'],
                  noteContent: note['note'],
                  onUpdate: () {
                    // Refresh the UI if needed
                  },

                ),
    ),
    );
    },
    );
    },
    );
    }
    },
    ),
    ),
    ],
    ),
      SizedBox(height: 20.0),
      Column(
        children: [
          Text(
            'Todays tasks',
            style: TextStyle(
                fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.0),
          Container(
              height: 300.0, // Set your desired height
              child:FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().getTodosForToday(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final todayTodos = snapshot.data ?? [];
                    if (todayTodos.isEmpty) {
                      return Center(child: Text('No todos for today.'));
                    }
                    return ListView.builder(
                      itemCount: todayTodos.length,
                      itemBuilder: (context, index) {
                        final todo = todayTodos[index];
                        return ListTile(
                          title: Text(todo['title']),
                          subtitle: Text('Due Date: ${todo['due_date']}'),
                          onTap: () {
                            // Navigate to TodoItemScreen with todo details
                            // Implement this if needed
                          },
                        );
                      },
                    );
                  }
                },
              )

          ),
        ],
      ),
    ],
    ),
    ),
    ),
    ),
    );
    }
    },
    );
  }

  Future<String> _getGreeting() async {
    final currentTime = DateTime.now();
    final hour = currentTime.hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Future<String> _getUserName() async {
    // Fetch the user's name from the database
    final user = await DatabaseHelper().getUserName();
    return user ?? ''; // Return user's name or an empty string if not available
  }
}
