import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final Map<String, dynamic>? goals;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.goals,
  });

  // Create UserModel from Firebase document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      goals: data['goals'] as Map<String, dynamic>?,
    );
  }

  // Convert UserModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      if (goals != null) 'goals': goals,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    Map<String, dynamic>? goals,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      goals: goals ?? this.goals,
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, createdAt: $createdAt, goals: $goals}';
  }
}
