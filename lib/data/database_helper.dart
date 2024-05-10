import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final _dbName = 'notes_todos.db';
  static final _tableNotes = 'notes';
  static final _tableTodos = 'todos';
  static final _tableSettings = 'settings';

  static final StreamController<void> _dbChangesStreamController =
  StreamController<void>.broadcast();

  Stream<void> get dbChangesStream => _dbChangesStreamController.stream;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableNotes(
        id INTEGER PRIMARY KEY,
        title TEXT,
        note TEXT,
        creation_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableTodos(
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        due_date TEXT,
        priority TEXT,
        status TEXT,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableSettings(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
  }

  Future<int> insertNote({
    required String title,
    required String note,
    required DateTime creationDate,
  }) async {
    final truncatedCreationDate = DateTime(
      creationDate.year,
      creationDate.month,
      creationDate.day,
      creationDate.hour,
      creationDate.minute,
    );

    final db = await database;
    final result = await db.insert(_tableNotes, {
      'title': title,
      'note': note,
      'creation_date': truncatedCreationDate.toIso8601String(),
    });
    _dbChangesStreamController.add(null);
    return result;
  }

  Future<int> insertTodo({
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
    required String status,
    required String category,
  }) async {
    final truncatedDueDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueDate.hour,
      dueDate.minute,
    );

    final db = await database;
    final result = await db.insert(
      _tableTodos,
      {
        'title': title,
        'description': description,
        'due_date': truncatedDueDate.toIso8601String(),
        'priority': priority,
        'status': status,
        'category': category,
      },
    );
    _dbChangesStreamController.add(null);
    return result;
  }

  Future<int> updateNote({
    required String oldTitle,
    required String newTitle,
    required String newContent,
  }) async {
    final db = await database;
    final result = await db.update(
      _tableNotes,
      {'title': newTitle, 'note': newContent},
      where: 'title = ?',
      whereArgs: [oldTitle],
    );
    _dbChangesStreamController.add(null);
    return result;
  }

  Future<void> updateTodoStatus({
    required int id,
    required String status,
  }) async {
    final db = await database;
    await db.update(_tableTodos, {'status': status}, where: 'id = ?', whereArgs: [id]);
    _dbChangesStreamController.add(null);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    final result =
    await db.delete(_tableNotes, where: 'id = ?', whereArgs: [id]);
    _dbChangesStreamController.add(null);
    return result;
  }

  Future<List<Map<String, dynamic>>> getOverdueTodos() async {
    final db = await database;
    final now = DateTime.now();
    return db.query(
      _tableTodos,
      where: 'status = ? AND due_date < ?',
      whereArgs: ['pending', now.toIso8601String()],
    );
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return db.query(_tableNotes);
  }

  Future<List<Map<String, dynamic>>> getRecentNotes() async {
    final db = await database;
    return db.query(
      _tableNotes,
      orderBy: 'creation_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTodosForToday() async {
    final db = await database;
    final today = DateTime.now();
    final formattedDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return db.query(
      _tableTodos,
      where: 'due_date LIKE ?',
      whereArgs: ['$formattedDate%'],
      orderBy: 'due_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    final db = await database;
    return db.query(_tableTodos);
  }

  Future<void> updateUserName(String name) async {
    final db = await database;
    final data = await db.query(_tableSettings);
    if (data.isEmpty) {
      await db.insert(_tableSettings, {'name': name});
    } else {
      await db.update(_tableSettings, {'name': name}, where: 'id = ?', whereArgs: [data.first['id']]);
    }
    _dbChangesStreamController.add(null);
  }

  Future<String> getUserName() async {
    final db = await database;
    final data = await db.query(_tableSettings);
    return data.isEmpty ? '' : data.first['name'] as String;
  }
}
