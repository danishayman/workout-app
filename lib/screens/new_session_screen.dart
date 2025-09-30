import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/session_providers.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import 'workout_selection_screen.dart';
import '../widgets/exercise_input_card.dart';

class NewSessionScreen extends ConsumerWidget {
  const NewSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(newSessionProvider);
    final sessionNotifier = ref.read(newSessionProvider.notifier);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Workout Session'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (sessionState.selectedExercises.isNotEmpty)
            TextButton(
              onPressed: sessionState.isLoading
                  ? null
                  : () => _saveSession(context, ref, currentUser?.uid),
              child: sessionState.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Workout Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _selectDate(context, ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(sessionState.date),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: sessionNotifier.updateNotes,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Add notes about your workout...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Add Exercises Section
            Row(
              children: [
                const Text(
                  'Exercises',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _navigateToWorkoutSelection(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercises'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Selected Exercises
            if (sessionState.selectedExercises.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Add Exercises" to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...sessionState.selectedExercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return ExerciseInputCard(
                  key: ValueKey('${exercise.workout.id}_$index'),
                  exercise: exercise,
                  onUpdate: (updatedExercise) =>
                      sessionNotifier.updateExercise(index, updatedExercise),
                  onRemove: () => sessionNotifier.removeExercise(index),
                );
              }),

            // Error message
            if (sessionState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Card(
                  color: Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final sessionState = ref.read(newSessionProvider);
    final sessionNotifier = ref.read(newSessionProvider.notifier);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: sessionState.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      sessionNotifier.updateDate(picked);
    }
  }

  void _navigateToWorkoutSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutSelectionScreen()),
    );
  }

  Future<void> _saveSession(
    BuildContext context,
    WidgetRef ref,
    String? userId,
  ) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save session')),
      );
      return;
    }

    final sessionNotifier = ref.read(newSessionProvider.notifier);
    final sessionState = ref.read(newSessionProvider);
    final sessionService = ref.read(sessionServiceProvider);

    try {
      sessionNotifier.setLoading(true);
      sessionNotifier.setError(null);

      // Create session
      final session = SessionModel(
        id: '',
        userId: userId,
        date: sessionState.date,
        notes: sessionState.notes.isEmpty ? null : sessionState.notes,
      );

      final sessionId = await sessionService.createSession(session);

      // Add exercises to session
      final exercises = sessionState.selectedExercises.map((selectedExercise) {
        return ExerciseModel(
          id: '',
          workoutId: selectedExercise.workout.id,
          sets: selectedExercise.sets,
          reps: selectedExercise.reps,
          weight: selectedExercise.weight,
        );
      }).toList();

      await sessionService.batchAddExercisesToSession(sessionId, exercises);

      // Reset form and navigate back
      sessionNotifier.reset();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout session saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      sessionNotifier.setError('Failed to save session: $e');
    } finally {
      sessionNotifier.setLoading(false);
    }
  }
}
