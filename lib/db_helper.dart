import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;
  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('absolutefit.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Создаем таблицу тренировок
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        type TEXT,
        distance TEXT,
        time TEXT,
        startTime TEXT
      )
    ''');
    // Создаем таблицу записей о еде
    await db.execute('''
      CREATE TABLE eatings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dishId INTEGER,
        weight INTEGER,
        date TEXT
      )
    ''');
    // Создаем таблицу упражнений
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        training TEXT,
        exercise TEXT
      )
    ''');
    // Создаем таблицу блюд
    await db.execute('''
      CREATE TABLE dishes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        proteins INTEGER,
        fats INTEGER,
        carbs INTEGER
      )
    ''');
    // Создаем таблицу доступных упражнений
    await db.execute('''
      CREATE TABLE available_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');
    // Создаем таблицу sets
    await db.execute('''
      CREATE TABLE sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exerciseId INTEGER,
        weight REAL,
        reps INTEGER
      )
    ''');
  }

  // Пример метода для получения всех записей из таблицы
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  // Пример метода обновления
  Future<int> update(String table, Map<String, dynamic> values,
      {required String where, required List<dynamic> whereArgs}) async {
    final db = await instance.database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }
}
