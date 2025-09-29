import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String workoutId; // Reference to workout document
  final int sets;
  final int reps;
  final double? weight;

  ExerciseModel({
    required this.id,
    required this.workoutId,
    required this.sets,
    required this.reps,
    this.weight,
  });

  // Create ExerciseModel from Firebase document
  factory ExerciseModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExerciseModel(
      id: doc.id,
      workoutId: data['workoutId'] ?? '',
      sets: data['sets'] ?? 0,
      reps: data['reps'] ?? 0,
      weight: data['weight']?.toDouble(),
    );
  }

  // Convert ExerciseModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'sets': sets,
      'reps': reps,
      if (weight != null) 'weight': weight,
    };
  }

  // Create a copy with updated fields
  ExerciseModel copyWith({
    String? id,
    String? workoutId,
    int? sets,
    int? reps,
    double? weight,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }

  @override
  String toString() {
    return 'ExerciseModel{id: $id, workoutId: $workoutId, sets: $sets, reps: $reps, weight: $weight}';
  }
}
