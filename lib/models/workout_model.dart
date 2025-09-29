import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  final String id;
  final String name;
  final String category;
  final String? description;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
  });

  // Create WorkoutModel from Firebase document
  factory WorkoutModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'],
    );
  }

  // Convert WorkoutModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      if (description != null) 'description': description,
    };
  }

  // Create a copy with updated fields
  WorkoutModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'WorkoutModel{id: $id, name: $name, category: $category, description: $description}';
  }
}
