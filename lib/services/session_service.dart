import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import '../models/exercise_model.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sessions';
  final String _exercisesSubcollection = 'exercises';

  // Create a new session
  Future<String> createSession(SessionModel session) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(session.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create session: ${e.toString()}';
    }
  }

  // Get session by ID (without exercises)
  Future<SessionModel?> getSession(String sessionId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(sessionId)
          .get();

      if (doc.exists) {
        return SessionModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get session: ${e.toString()}';
    }
  }

  // Get session with exercises
  Future<SessionModel?> getSessionWithExercises(String sessionId) async {
    try {
      SessionModel? session = await getSession(sessionId);
      if (session == null) return null;

      List<ExerciseModel> exercises = await getSessionExercises(sessionId);
      return session.copyWith(exercises: exercises);
    } catch (e) {
      throw 'Failed to get session with exercises: ${e.toString()}';
    }
  }

  // Get all sessions for a user
  Future<List<SessionModel>> getUserSessions(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SessionModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get user sessions: ${e.toString()}';
    }
  }

  // Get user sessions with exercises
  Future<List<SessionModel>> getUserSessionsWithExercises(String userId) async {
    try {
      List<SessionModel> sessions = await getUserSessions(userId);
      List<SessionModel> sessionsWithExercises = [];

      for (SessionModel session in sessions) {
        List<ExerciseModel> exercises = await getSessionExercises(session.id);
        sessionsWithExercises.add(session.copyWith(exercises: exercises));
      }

      return sessionsWithExercises;
    } catch (e) {
      throw 'Failed to get user sessions with exercises: ${e.toString()}';
    }
  }

  // Get sessions by date range
  Future<List<SessionModel>> getSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SessionModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get sessions by date range: ${e.toString()}';
    }
  }

  // Update session
  Future<void> updateSession(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update(updates);
    } catch (e) {
      throw 'Failed to update session: ${e.toString()}';
    }
  }

  // Delete session (and all its exercises)
  Future<void> deleteSession(String sessionId) async {
    try {
      WriteBatch batch = _firestore.batch();

      // Delete all exercises in the session
      QuerySnapshot exercisesSnapshot = await _firestore
          .collection(_collection)
          .doc(sessionId)
          .collection(_exercisesSubcollection)
          .get();

      for (DocumentSnapshot exerciseDoc in exercisesSnapshot.docs) {
        batch.delete(exerciseDoc.reference);
      }

      // Delete the session
      batch.delete(_firestore.collection(_collection).doc(sessionId));

      await batch.commit();
    } catch (e) {
      throw 'Failed to delete session: ${e.toString()}';
    }
  }

  // EXERCISE OPERATIONS

  // Add exercise to session
  Future<String> addExerciseToSession(
    String sessionId,
    ExerciseModel exercise,
  ) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .doc(sessionId)
          .collection(_exercisesSubcollection)
          .add(exercise.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add exercise to session: ${e.toString()}';
    }
  }

  // Get all exercises for a session
  Future<List<ExerciseModel>> getSessionExercises(String sessionId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .doc(sessionId)
          .collection(_exercisesSubcollection)
          .get();

      return querySnapshot.docs
          .map((doc) => ExerciseModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get session exercises: ${e.toString()}';
    }
  }

  // Update exercise in session
  Future<void> updateExercise(
    String sessionId,
    String exerciseId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .collection(_exercisesSubcollection)
          .doc(exerciseId)
          .update(updates);
    } catch (e) {
      throw 'Failed to update exercise: ${e.toString()}';
    }
  }

  // Delete exercise from session
  Future<void> deleteExercise(String sessionId, String exerciseId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(sessionId)
          .collection(_exercisesSubcollection)
          .doc(exerciseId)
          .delete();
    } catch (e) {
      throw 'Failed to delete exercise: ${e.toString()}';
    }
  }

  // Batch add exercises to session
  Future<void> batchAddExercisesToSession(
    String sessionId,
    List<ExerciseModel> exercises,
  ) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (ExerciseModel exercise in exercises) {
        DocumentReference docRef = _firestore
            .collection(_collection)
            .doc(sessionId)
            .collection(_exercisesSubcollection)
            .doc();
        batch.set(docRef, exercise.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to batch add exercises to session: ${e.toString()}';
    }
  }

  // STREAM OPERATIONS (Real-time updates)

  // Stream user sessions
  Stream<List<SessionModel>> getUserSessionsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SessionModel.fromDocument(doc))
              .toList();
        });
  }

  // Stream session exercises
  Stream<List<ExerciseModel>> getSessionExercisesStream(String sessionId) {
    return _firestore
        .collection(_collection)
        .doc(sessionId)
        .collection(_exercisesSubcollection)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ExerciseModel.fromDocument(doc))
              .toList();
        });
  }

  // Stream session with exercises
  Stream<SessionModel?> getSessionWithExercisesStream(String sessionId) {
    return _firestore
        .collection(_collection)
        .doc(sessionId)
        .snapshots()
        .asyncMap((sessionDoc) async {
          if (!sessionDoc.exists) return null;

          SessionModel session = SessionModel.fromDocument(sessionDoc);
          List<ExerciseModel> exercises = await getSessionExercises(sessionId);

          return session.copyWith(exercises: exercises);
        });
  }

  // UTILITY METHODS

  // Check if session exists
  Future<bool> sessionExists(String sessionId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(sessionId)
          .get();
      return doc.exists;
    } catch (e) {
      throw 'Failed to check if session exists: ${e.toString()}';
    }
  }

  // Get session count for user
  Future<int> getUserSessionCount(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw 'Failed to get user session count: ${e.toString()}';
    }
  }

  // Get latest session for user
  Future<SessionModel?> getLatestUserSession(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return SessionModel.fromDocument(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw 'Failed to get latest user session: ${e.toString()}';
    }
  }

  // Get weekly statistics for user
  Future<WeeklyStats> getWeeklyStats(String userId) async {
    try {
      // Calculate the start of the current week (Monday)
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startOfWeek = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      // Calculate the end of the week (Sunday)
      DateTime endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );

      // Get sessions for this week
      List<SessionModel> sessions = await getSessionsByDateRange(
        userId,
        startOfWeek,
        endOfWeek,
      );

      // Calculate stats
      int workoutCount = sessions.length;
      Duration totalDuration = Duration.zero;
      double totalVolume = 0;

      for (SessionModel session in sessions) {
        // Add duration if available
        if (session.duration != null) {
          totalDuration += session.duration!;
        }

        // Get exercises for this session and calculate volume
        List<ExerciseModel> exercises = await getSessionExercises(session.id);
        for (ExerciseModel exercise in exercises) {
          if (exercise.weight != null) {
            totalVolume += (exercise.weight! * exercise.sets * exercise.reps);
          }
        }
      }

      // Get previous week stats for comparison
      DateTime prevWeekStart = startOfWeek.subtract(const Duration(days: 7));
      DateTime prevWeekEnd = startOfWeek.subtract(const Duration(seconds: 1));

      List<SessionModel> prevWeekSessions = await getSessionsByDateRange(
        userId,
        prevWeekStart,
        prevWeekEnd,
      );

      int prevWorkoutCount = prevWeekSessions.length;
      Duration prevTotalDuration = Duration.zero;
      double prevTotalVolume = 0;

      for (SessionModel session in prevWeekSessions) {
        if (session.duration != null) {
          prevTotalDuration += session.duration!;
        }
        List<ExerciseModel> exercises = await getSessionExercises(session.id);
        for (ExerciseModel exercise in exercises) {
          if (exercise.weight != null) {
            prevTotalVolume +=
                (exercise.weight! * exercise.sets * exercise.reps);
          }
        }
      }

      return WeeklyStats(
        workoutCount: workoutCount,
        totalDuration: totalDuration,
        totalVolume: totalVolume,
        previousWorkoutCount: prevWorkoutCount,
        previousDuration: prevTotalDuration,
        previousVolume: prevTotalVolume,
      );
    } catch (e) {
      throw 'Failed to get weekly stats: ${e.toString()}';
    }
  }
}

// Weekly stats model
class WeeklyStats {
  final int workoutCount;
  final Duration totalDuration;
  final double totalVolume;
  final int previousWorkoutCount;
  final Duration previousDuration;
  final double previousVolume;

  WeeklyStats({
    required this.workoutCount,
    required this.totalDuration,
    required this.totalVolume,
    required this.previousWorkoutCount,
    required this.previousDuration,
    required this.previousVolume,
  });

  // Calculate changes from previous week
  int get workoutChange => workoutCount - previousWorkoutCount;
  Duration get durationChange => totalDuration - previousDuration;
  double get volumeChange => totalVolume - previousVolume;

  // Format duration as "Xh Ym"
  String get formattedDuration {
    int hours = totalDuration.inHours;
    int minutes = totalDuration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Format previous duration as "Xh Ym"
  String get formattedPreviousDuration {
    int hours = previousDuration.inHours;
    int minutes = previousDuration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Format duration change
  String get formattedDurationChange {
    Duration change = durationChange;
    int hours = change.inHours;
    int minutes = change.inMinutes.remainder(60);

    String prefix = change.isNegative ? '' : '';
    if (hours != 0) {
      return '$prefix${hours}h ${minutes.abs()}m';
    } else {
      return '$prefix${minutes}m';
    }
  }

  // Format volume as "X XXX kg"
  String get formattedVolume {
    if (totalVolume >= 1000) {
      // Format with space as thousands separator
      String volumeStr = totalVolume.toInt().toString();
      String formatted = '';
      int count = 0;
      for (int i = volumeStr.length - 1; i >= 0; i--) {
        if (count == 3) {
          formatted = ' $formatted';
          count = 0;
        }
        formatted = volumeStr[i] + formatted;
        count++;
      }
      return '${formatted}kg';
    }
    return '${totalVolume.toInt()}kg';
  }

  // Format volume change
  String get formattedVolumeChange {
    double change = volumeChange;
    if (change >= 1000) {
      String volumeStr = change.abs().toInt().toString();
      String formatted = '';
      int count = 0;
      for (int i = volumeStr.length - 1; i >= 0; i--) {
        if (count == 3) {
          formatted = ' $formatted';
          count = 0;
        }
        formatted = volumeStr[i] + formatted;
        count++;
      }
      return '${formatted} kg';
    }
    return '${change.toInt()} kg';
  }
}
