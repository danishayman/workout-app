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
}
