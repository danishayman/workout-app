import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/session_providers.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/exercise_accordion_card.dart';
import 'workout_selection_screen.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  Timer? _timer;
  Duration _duration = Duration.zero;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration = Duration(seconds: _duration.inSeconds + 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  double _calculateTotalVolume(List<SelectedExercise> exercises) {
    double totalVolume = 0;
    for (final exercise in exercises) {
      for (final set in exercise.exerciseSets) {
        if (set.weight != null && set.completed) {
          totalVolume += (set.weight! * set.reps);
        }
      }
    }
    return totalVolume;
  }

  int _calculateTotalSets(List<SelectedExercise> exercises) {
    return exercises.fold(
      0,
      (total, exercise) =>
          total + exercise.exerciseSets.where((set) => set.completed).length,
    );
  }

  Future<void> _finishWorkout() async {
    final currentUser = ref.read(currentUserProvider);
    final sessionState = ref.read(newSessionProvider);
    final sessionNotifier = ref.read(newSessionProvider.notifier);
    final sessionService = ref.read(sessionServiceProvider);

    if (currentUser?.uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save session')),
      );
      return;
    }

    if (sessionState.selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some exercises before finishing')),
      );
      return;
    }

    try {
      sessionNotifier.setLoading(true);
      sessionNotifier.setError(null);

      // Create session with timing data
      final session = SessionModel(
        id: '',
        userId: currentUser!.uid,
        date: _startTime ?? DateTime.now(),
        notes: sessionState.notes.isEmpty ? null : sessionState.notes,
        duration: _duration,
        startTime: _startTime,
        endTime: DateTime.now(),
      );

      final sessionId = await sessionService.createSession(session);

      // Add exercises to session - create one ExerciseModel per completed set
      final List<ExerciseModel> exercises = [];
      for (final selectedExercise in sessionState.selectedExercises) {
        for (final exerciseSet in selectedExercise.exerciseSets) {
          if (exerciseSet.completed) {
            exercises.add(
              ExerciseModel(
                id: '',
                workoutId: selectedExercise.workout.id,
                sets: 1, // Each model represents one completed set
                reps: exerciseSet.reps,
                weight: exerciseSet.weight,
              ),
            );
          }
        }
      }

      await sessionService.batchAddExercisesToSession(sessionId, exercises);

      // Reset form and navigate back
      sessionNotifier.reset();
      _timer?.cancel();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout completed! Great job!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      sessionNotifier.setError('Failed to save session: $e');
    } finally {
      sessionNotifier.setLoading(false);
    }
  }

  void _navigateToWorkoutSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(newSessionProvider);
    final totalVolume = _calculateTotalVolume(sessionState.selectedExercises);
    final totalSets = _calculateTotalSets(sessionState.selectedExercises);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.expand_more, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Icon(Icons.timer, color: Colors.white),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: sessionState.isLoading ? null : _finishWorkout,
            child: sessionState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue,
                    ),
                  )
                : const Text(
                    'Finish',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Row(
              children: [
                // Duration
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Duration',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Volume
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Volume',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalVolume.toInt()} kg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sets
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Sets',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalSets.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Exercise List or Empty State
          Expanded(
            child: sessionState.selectedExercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises added yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add exercises to start your workout',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sessionState.selectedExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = sessionState.selectedExercises[index];
                      final sessionNotifier = ref.read(
                        newSessionProvider.notifier,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExerciseAccordionCard(
                          exercise: exercise,
                          exerciseIndex: index,
                          onUpdateExercise: sessionNotifier.updateExercise,
                          onToggleExpansion:
                              sessionNotifier.toggleExerciseExpansion,
                          onAddSet: sessionNotifier.addSetToExercise,
                          onUpdateSet: sessionNotifier.updateExerciseSet,
                          onUpdateNotes: sessionNotifier.updateExerciseNotes,
                          onRemove: () => sessionNotifier.removeExercise(index),
                        ),
                      );
                    },
                  ),
          ),

          // Error message
          if (sessionState.error != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sessionState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Add Exercises Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _navigateToWorkoutSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Add Exercises',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // More Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement more options (notes, rest timer, etc.)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('More options coming soon!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'More',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
