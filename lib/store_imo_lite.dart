import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ShipDatabase {
  static Database? _database;

  // Singleton pattern to reuse the same database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    // If database is not initialized, initialize it
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create the table if it does not exist
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ships.db');

    // Open the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // Create the table
        db.execute('''
          CREATE TABLE ships(
            imo TEXT PRIMARY KEY,
            name TEXT,
            insp TEXT
          )
        ''');
      },
    );
  }

  // Insert a ship record into the database
  Future<void> insertShip(Map<String, dynamic> ship) async {
    final db = await database;

    await db.insert(
      'ships',
      ship,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all ship records from the database
  Future<List<Map<String, dynamic>>> getShips() async {
    final db = await database;
    return await db.query('ships');
  }
}
