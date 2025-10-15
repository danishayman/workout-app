import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class VideoUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload a video file to Firebase Storage
  /// Returns the download URL of the uploaded video
  Future<String> uploadExerciseVideo({
    required File videoFile,
    required String exerciseId,
    required String exerciseName,
    Function(double)? onProgress,
  }) async {
    try {
      // Create a unique filename
      final String fileName =
          '${exerciseId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String path = 'exercise_videos/$exerciseId/$fileName';

      // Create reference to Firebase Storage
      final Reference ref = _storage.ref().child(path);

      // Upload file with metadata
      final UploadTask uploadTask = ref.putFile(
        videoFile,
        SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'exerciseId': exerciseId,
            'exerciseName': exerciseName,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  /// Upload video and update workout document in Firestore
  Future<void> uploadAndUpdateWorkout({
    required File videoFile,
    required String workoutId,
    required String workoutName,
    Function(double)? onProgress,
  }) async {
    try {
      // Upload video to Firebase Storage
      final String videoUrl = await uploadExerciseVideo(
        videoFile: videoFile,
        exerciseId: workoutId,
        exerciseName: workoutName,
        onProgress: onProgress,
      );

      // Update workout document with video URL
      await _firestore.collection('workouts').doc(workoutId).update({
        'videoUrl': videoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Video uploaded and workout updated successfully');
    } catch (e) {
      throw Exception('Failed to upload and update workout: $e');
    }
  }

  /// Pick a video file from device
  Future<File?> pickVideoFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to pick video file: $e');
    }
  }

  /// Delete a video from Firebase Storage
  Future<void> deleteExerciseVideo(String videoUrl) async {
    try {
      final Reference ref = _storage.refFromURL(videoUrl);
      await ref.delete();
      print('Video deleted successfully');
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }

  /// Get video metadata
  Future<FullMetadata> getVideoMetadata(String videoUrl) async {
    try {
      final Reference ref = _storage.refFromURL(videoUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get video metadata: $e');
    }
  }
}
