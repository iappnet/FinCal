import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/calculation_model.dart';
import 'dart:convert'; // Required for JSON encoding/decoding

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calculations.db');

    return await openDatabase(
      path,
      version: 2, // Increment version for schema changes
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE calculations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          calculationType TEXT,
          details TEXT, -- Store details as JSON
          date TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE calculations ADD COLUMN details TEXT');
        }
      },
    );
  }

  Future<int> insertCalculation(CalculationModel calculation) async {
    final db = await database;
    return await db.insert(
      'calculations',
      {
        ...calculation.toMap(),
        'details': jsonEncode(calculation.details), // Save as JSON
      },
    );
  }

  Future<List<CalculationModel>> fetchCalculations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('calculations');
    return maps.map((map) {
      return CalculationModel(
        id: map['id'],
        calculationType: map['calculationType'],
        details: jsonDecode(map['details']), // Decode JSON
        date: DateTime.parse(map['date']),
      );
    }).toList();
  }

  Future<void> deleteCalculation(int id) async {
    final db = await database;
    await db.delete(
      'calculations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
