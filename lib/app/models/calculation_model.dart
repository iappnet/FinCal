import 'dart:convert'; // For JSON encoding/decoding

class CalculationModel {
  int? id;
  String calculationType;
  Map<String, dynamic> details; // Use a dynamic map for flexibility
  DateTime date;

  CalculationModel({
    this.id,
    required this.calculationType,
    required this.details,
    required this.date,
  });

  // Convert the object to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'calculationType': calculationType,
      'details': jsonEncode(details), // Convert the map to a JSON string
      'date': date.toIso8601String(), // Store date as ISO string
    };
  }

  // Create an object from a map retrieved from the database
  static CalculationModel fromMap(Map<String, dynamic> map) {
    return CalculationModel(
      id: map['id'] as int?,
      calculationType: map['calculationType'] as String,
      details: jsonDecode(
          map['details'] as String), // Parse the JSON string back into a map
      date:
          DateTime.parse(map['date'] as String), // Parse ISO string to DateTime
    );
  }
}
