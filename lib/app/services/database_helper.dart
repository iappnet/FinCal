import 'package:fincals/app/controllers/history_controller.dart';
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
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final results = await db.query('calculations');
          for (var row in results) {
            if (row['details'] != null) {
              final details =
                  row['details'] as String; // Explicitly cast to String
              final decodedDetails = jsonDecode(details);

              if (decodedDetails is! Map<String, dynamic>) {
                // Convert to a valid map or set default
                final updatedDetails = {
                  'defaultKey': decodedDetails.toString()
                };
                await db.update(
                  'calculations',
                  {'details': jsonEncode(updatedDetails)},
                  where: 'id = ?',
                  whereArgs: [row['id']],
                );
              }
            }
          }
        }
      },
    );
  }

  Future<int> insertCalculation(CalculationModel calculation) async {
    final db = await database;

    int id = await db.insert(
      'calculations',
      {
        ...calculation.toMap(),
        'details': jsonEncode(calculation.details), // Save as JSON
      },
    );
    HistoryController().fetchCalculations(); // Trigger real-time update
    return id;
  }

  Future<List<CalculationModel>> fetchSalaryCalculations() async {
    final db = await database;
    try {
      // Query only for salary calculation rows
      final List<Map<String, dynamic>> maps = await db.query(
        'calculations',
        where: 'calculationType = ?', // Filter by type
        whereArgs: ['Salary Calculation'], // Specify the type
      );

      // Return an empty list if no data is present
      if (maps.isEmpty) {
        return [];
      }
      // Map the result to CalculationModel instances
      return maps.map((map) {
        try {
          final detailsDecoded = map['details'] != null
              ? jsonDecode(map['details'] as String) // Decode JSON
              : {};

          // Ensure it's a valid map, or replace it with an empty map
          if (detailsDecoded is! Map<String, dynamic>) {
            throw Exception('Invalid details format');
          }

          return CalculationModel(
            id: map['id'] as int,
            calculationType: map['calculationType'] as String,
            details: detailsDecoded, // Use the decoded map
            date: DateTime.parse(map['date']),
          );
        } catch (e) {
          print("Invalid details for row ID ${map['id']}: ${map['details']}");

          // Sanitize the details to a default valid map
          final sanitizedDetails = {'defaultKey': map['details'].toString()};
          return CalculationModel(
            id: map['id'] as int,
            calculationType: map['calculationType'] as String,
            details: sanitizedDetails, // Use sanitized details
            date: DateTime.parse(map['date']),
          );
        }
      }).toList();
    } catch (e) {
      print("Error fetching salary calculations: $e");
      return [];
    }
  }

  Future<List<CalculationModel>> fetchCalculations() async {
    final db = await database;
    try {
      // Query the database
      final List<Map<String, dynamic>> maps = await db.query('calculations');

      // Return an empty list if no data is present
      if (maps.isEmpty) {
        return [];
      }

      // Map the result to CalculationModel instances
      return maps.map((map) {
        final detailsDecoded = map['details'] != null
            ? jsonDecode(map['details'] as String) // Decode JSON
            : {}; // Default to an empty map if details are null

        // Ensure the decoded details are a valid map
        if (detailsDecoded is! Map<String, dynamic>) {
          // Handle invalid format gracefully
          final sanitizedDetails = {
            'defaultKey': map['details']?.toString() ?? ''
          };
          return CalculationModel(
            id: map['id'] as int,
            calculationType: map['calculationType'] as String,
            details: sanitizedDetails,
            date: DateTime.parse(map['date']),
          );
        }

        // Return the valid calculation model
        return CalculationModel(
          id: map['id'] as int,
          calculationType: map['calculationType'] as String,
          details: detailsDecoded,
          date: DateTime.parse(map['date']),
        );
      }).toList();
    } catch (e) {
      // Log and return an empty list in case of errors
      print("Error fetching calculations: $e");
      return [];
    }
  }

  Future<void> deleteCalculation(int id) async {
    final db = await database;
    await db.delete(
      'calculations',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Notify the controller
    HistoryController().fetchCalculations();
  }

  // Save or update income
  Future<void> saveIncome(double monthlyIncome, double additionalIncome) async {
    final db = await database;
    await db.delete('calculations',
        where: 'calculationType = ?', whereArgs: ['income']);
    await db.insert('calculations', {
      'calculationType': 'income',
      'details': jsonEncode({
        'monthlyIncome': monthlyIncome,
        'additionalIncome': additionalIncome
      }),
      'date': DateTime.now().toIso8601String(),
    });
    // Notify the controller to refresh calculations
    HistoryController().fetchCalculations();
  }

  // Fetch income
  Future<Map<String, dynamic>?> fetchIncome() async {
    final db = await database;
    final result = await db.query(
      'calculations',
      where: 'calculationType = ?',
      whereArgs: ['income'],
    );

    if (result.isNotEmpty) {
      return jsonDecode(result.first['details'] as String);
    }

    return null;
  }

  // Save fixed expenses
  Future<void> saveFixedExpenses(List<Map<String, dynamic>> expenses) async {
    final db = await database;

    await db.delete('calculations',
        where: 'calculationType = ?', whereArgs: ['fixed_expenses']);

    await db.insert('calculations', {
      'calculationType': 'fixed_expenses',
      'details': jsonEncode(expenses),
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Fetch fixed expenses
  Future<List<Map<String, dynamic>>> fetchFixedExpenses() async {
    final db = await database;
    final result = await db.query(
      'calculations',
      where: 'calculationType = ?',
      whereArgs: ['fixed_expenses'],
    );

    if (result.isNotEmpty) {
      return List<Map<String, dynamic>>.from(
          jsonDecode(result.first['details'] as String));
    }

    return [];
  }

  // Save recurring expenses
  Future<void> saveRecurringExpenses(
      List<Map<String, dynamic>> expenses) async {
    final db = await database;

    await db.delete('calculations',
        where: 'calculationType = ?', whereArgs: ['recurring_expenses']);

    await db.insert('calculations', {
      'calculationType': 'recurring_expenses',
      'details': jsonEncode(expenses),
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Fetch recurring expenses
  Future<List<Map<String, dynamic>>> fetchRecurringExpenses() async {
    final db = await database;
    final result = await db.query(
      'calculations',
      where: 'calculationType = ?',
      whereArgs: ['recurring_expenses'],
    );

    if (result.isNotEmpty) {
      return List<Map<String, dynamic>>.from(
          jsonDecode(result.first['details'] as String));
    }

    return [];
  }

  // Save savings
  Future<void> saveSavings(double emergencySavings, double investments) async {
    final db = await database;

    await db.delete('calculations',
        where: 'calculationType = ?', whereArgs: ['savings']);

    await db.insert('calculations', {
      'calculationType': 'savings',
      'details': jsonEncode(
          {'emergencySavings': emergencySavings, 'investments': investments}),
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Fetch savings
  Future<Map<String, dynamic>?> fetchSavings() async {
    final db = await database;
    final result = await db.query(
      'calculations',
      where: 'calculationType = ?',
      whereArgs: ['savings'],
    );

    if (result.isNotEmpty) {
      return jsonDecode(result.first['details'] as String);
    }

    return null;
  }
}
