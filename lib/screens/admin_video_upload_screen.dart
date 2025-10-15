import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';
import '../services/video_upload_service.dart';

class AdminVideoUploadScreen extends StatefulWidget {
  const AdminVideoUploadScreen({super.key});

  @override
  State<AdminVideoUploadScreen> createState() => _AdminVideoUploadScreenState();
}

class _AdminVideoUploadScreenState extends State<AdminVideoUploadScreen> {
  final VideoUploadService _uploadService = VideoUploadService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedWorkoutId;
  File? _selectedVideoFile;
  List<WorkoutModel> _workouts = [];
  bool _isLoadingWorkouts = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    try {
      final querySnapshot = await _firestore.collection('workouts').get();
      setState(() {
        _workouts = querySnapshot.docs
            .map((doc) => WorkoutModel.fromDocument(doc))
            .toList();
        _isLoadingWorkouts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWorkouts = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load workouts: $e')));
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final videoFile = await _uploadService.pickVideoFile();
      if (videoFile != null) {
        setState(() {
          _selectedVideoFile = videoFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick video: $e')));
      }
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedWorkoutId == null || _selectedVideoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a workout and a video file'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final workout = _workouts.firstWhere((w) => w.id == _selectedWorkoutId);

      await _uploadService.uploadAndUpdateWorkout(
        videoFile: _selectedVideoFile!,
        workoutId: workout.id,
        workoutName: workout.name,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reset state
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _selectedVideoFile = null;
        _selectedWorkoutId = null;
      });

      // Reload workouts to reflect changes
      _loadWorkouts();
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text('Upload Exercise Videos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingWorkouts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Upload Instructions',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '1. Select an exercise from the dropdown\n'
                          '2. Choose a video file (MP4 recommended)\n'
                          '3. Upload to Firebase Storage\n'
                          '4. Video URL will be saved to Firestore',
                          style: TextStyle(color: Colors.white70, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Select Exercise
                  const Text(
                    'Select Exercise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedWorkoutId,
                        hint: const Text(
                          'Choose an exercise...',
                          style: TextStyle(color: Colors.white54),
                        ),
                        dropdownColor: Colors.grey[850],
                        style: const TextStyle(color: Colors.white),
                        items: _workouts.map((workout) {
                          return DropdownMenuItem<String>(
                            value: workout.id,
                            child: Row(
                              children: [
                                Expanded(child: Text(workout.name)),
                                if (workout.videoUrl != null)
                                  const Icon(
                                    Icons.video_library,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWorkoutId = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Video File Selection
                  const Text(
                    'Select Video File',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _isUploading ? null : _pickVideo,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedVideoFile != null
                              ? Colors.green
                              : Colors.grey[700]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedVideoFile != null
                                ? Icons.video_file
                                : Icons.cloud_upload,
                            size: 48,
                            color: _selectedVideoFile != null
                                ? Colors.green
                                : Colors.grey[600],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedVideoFile != null
                                ? _selectedVideoFile!.path.split('/').last
                                : 'Tap to select video file',
                            style: TextStyle(
                              color: _selectedVideoFile != null
                                  ? Colors.white
                                  : Colors.grey[500],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_selectedVideoFile != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'File size: ${(_selectedVideoFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Upload Progress
                  if (_isUploading) ...[
                    const Text(
                      'Upload Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _uploadProgress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_uploadProgress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadVideo,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload),
                      label: Text(
                        _isUploading ? 'Uploading...' : 'Upload Video',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Existing Videos List
                  const Text(
                    'Exercises with Videos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._workouts
                      .where((w) => w.videoUrl != null)
                      .map((workout) => _buildVideoListItem(workout)),

                  if (_workouts.where((w) => w.videoUrl != null).isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'No videos uploaded yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildVideoListItem(WorkoutModel workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.video_library, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workout.category,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteVideo(workout),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVideo(WorkoutModel workout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Video',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete the video for ${workout.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && workout.videoUrl != null) {
      try {
        await _uploadService.deleteExerciseVideo(workout.videoUrl!);
        await _firestore.collection('workouts').doc(workout.id).update({
          'videoUrl': FieldValue.delete(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _loadWorkouts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete video: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
