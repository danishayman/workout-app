import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? videoUrl;
  final String? thumbnailUrl;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.videoUrl,
    this.thumbnailUrl,
  });

  // Create WorkoutModel from Firebase document
  factory WorkoutModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'],
      videoUrl: data['videoUrl'],
      thumbnailUrl: data['thumbnailUrl'],
    );
  }

  // Convert WorkoutModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      if (description != null) 'description': description,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
  }

  // Create a copy with updated fields
  WorkoutModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  @override
  String toString() {
    return 'WorkoutModel{id: $id, name: $name, category: $category, description: $description}';
  }
}
