import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Create a new user document
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(user.toMap());
    } catch (e) {
      throw 'Failed to create user: ${e.toString()}';
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user: ${e.toString()}';
    }
  }

  // Update user document
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(updates);
    } catch (e) {
      throw 'Failed to update user: ${e.toString()}';
    }
  }

  // Update user goals
  Future<void> updateUserGoals(
    String userId,
    Map<String, dynamic> goals,
  ) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'goals': goals,
      });
    } catch (e) {
      throw 'Failed to update user goals: ${e.toString()}';
    }
  }

  // Delete user document
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw 'Failed to delete user: ${e.toString()}';
    }
  }

  // Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      throw 'Failed to check if user exists: ${e.toString()}';
    }
  }

  // Stream user data (real-time updates)
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection(_collection).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    });
  }

  // Get all users (admin function)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get all users: ${e.toString()}';
    }
  }

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String searchTerm) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation that searches for exact matches
      // For production, consider using Algolia or similar service

      QuerySnapshot nameQuery = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      QuerySnapshot emailQuery = await _firestore
          .collection(_collection)
          .where('email', isGreaterThanOrEqualTo: searchTerm)
          .where('email', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      Set<UserModel> users = {};

      for (var doc in nameQuery.docs) {
        users.add(UserModel.fromDocument(doc));
      }

      for (var doc in emailQuery.docs) {
        users.add(UserModel.fromDocument(doc));
      }

      return users.toList();
    } catch (e) {
      throw 'Failed to search users: ${e.toString()}';
    }
  }
}
