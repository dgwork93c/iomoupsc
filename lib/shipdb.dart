import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ShipDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ships.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTable(db);
      },
      onOpen: (db) async {
        // Ensure table exists every time the database opens
        await _createTable(db);
      },
    );
  }

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ships (
        imo TEXT ,
        name TEXT ,
        insp TEXT 
      )
    ''');
  }

  Future<void> insertShip(Map<String, dynamic> ship) async {
    final db = await database;
    await db.insert(
      'ships',
      ship,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getShips() async {
    final db = await database;
    return await db.query('ships');
  }

  Future<int> getRowCount() async {
    final db = await database;
    await _createTable(db); // Ensure table exists before querying
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ships'));
    return count ?? 0;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('ships');
  }
}
