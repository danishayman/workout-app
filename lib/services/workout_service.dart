import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'workouts';

  // Create a new workout
  Future<String> createWorkout(WorkoutModel workout) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(workout.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create workout: ${e.toString()}';
    }
  }

  // Get workout by ID
  Future<WorkoutModel?> getWorkout(String workoutId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(workoutId)
          .get();

      if (doc.exists) {
        return WorkoutModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get workout: ${e.toString()}';
    }
  }

  // Get all workouts
  Future<List<WorkoutModel>> getAllWorkouts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('category')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => WorkoutModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get all workouts: ${e.toString()}';
    }
  }

  // Get workouts by category
  Future<List<WorkoutModel>> getWorkoutsByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => WorkoutModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get workouts by category: ${e.toString()}';
    }
  }

  // Get all unique categories
  Future<List<String>> getCategories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .get();

      Set<String> categories = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        categories.add(data['category'] ?? '');
      }

      List<String> sortedCategories = categories.toList();
      sortedCategories.sort();
      return sortedCategories;
    } catch (e) {
      throw 'Failed to get categories: ${e.toString()}';
    }
  }

  // Update workout
  Future<void> updateWorkout(
    String workoutId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection(_collection).doc(workoutId).update(updates);
    } catch (e) {
      throw 'Failed to update workout: ${e.toString()}';
    }
  }

  // Delete workout
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _firestore.collection(_collection).doc(workoutId).delete();
    } catch (e) {
      throw 'Failed to delete workout: ${e.toString()}';
    }
  }

  // Search workouts by name
  Future<List<WorkoutModel>> searchWorkouts(String searchTerm) async {
    try {
      String searchTermLower = searchTerm.toLowerCase();

      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: searchTermLower)
          .where('name', isLessThanOrEqualTo: '$searchTermLower\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => WorkoutModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to search workouts: ${e.toString()}';
    }
  }

  // Stream all workouts (real-time updates)
  Stream<List<WorkoutModel>> getWorkoutsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('category')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WorkoutModel.fromDocument(doc))
              .toList();
        });
  }

  // Stream workouts by category (real-time updates)
  Stream<List<WorkoutModel>> getWorkoutsByCategoryStream(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WorkoutModel.fromDocument(doc))
              .toList();
        });
  }

  // Batch create workouts (useful for seeding)
  Future<void> batchCreateWorkouts(List<WorkoutModel> workouts) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (WorkoutModel workout in workouts) {
        DocumentReference docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, workout.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to batch create workouts: ${e.toString()}';
    }
  }

  // Check if workout exists
  Future<bool> workoutExists(String workoutId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(workoutId)
          .get();
      return doc.exists;
    } catch (e) {
      throw 'Failed to check if workout exists: ${e.toString()}';
    }
  }
}
