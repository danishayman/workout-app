import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_model.dart';

class SessionModel {
  final String id;
  final String userId; // Reference to user document
  final DateTime date;
  final String? notes;
  final List<ExerciseModel> exercises; // Exercises in this session
  final Duration? duration; // Total duration of the workout session
  final DateTime? startTime; // When the workout session started
  final DateTime? endTime; // When the workout session ended

  SessionModel({
    required this.id,
    required this.userId,
    required this.date,
    this.notes,
    this.exercises = const [],
    this.duration,
    this.startTime,
    this.endTime,
  });

  // Create SessionModel from Firebase document
  factory SessionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
      exercises: [], // Exercises will be loaded separately from subcollection
      duration: data['durationSeconds'] != null
          ? Duration(seconds: data['durationSeconds'])
          : null,
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert SessionModel to Map for Firebase (without exercises)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      if (notes != null) 'notes': notes,
      if (duration != null) 'durationSeconds': duration!.inSeconds,
      if (startTime != null) 'startTime': Timestamp.fromDate(startTime!),
      if (endTime != null) 'endTime': Timestamp.fromDate(endTime!),
    };
  }

  // Create a copy with updated fields
  SessionModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? notes,
    List<ExerciseModel>? exercises,
    Duration? duration,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() {
    return 'SessionModel{id: $id, userId: $userId, date: $date, notes: $notes, exercises: ${exercises.length} exercises}';
  }
}
