import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_providers.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class WorkoutSelectionScreen extends ConsumerWidget {
  const WorkoutSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredWorkoutsAsync = ref.watch(filteredWorkoutsProvider);
    final selectedWorkoutIds = ref.watch(selectedWorkoutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercises'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (selectedWorkoutIds.isNotEmpty)
            TextButton(
              onPressed: () => _addSelectedWorkouts(context, ref),
              child: Text('Add (${selectedWorkoutIds.length})'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (query) =>
                  ref.read(workoutSearchQueryProvider.notifier).state = query,
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Workouts List
          Expanded(
            child: filteredWorkoutsAsync.when(
              data: (workouts) => _buildWorkoutsList(
                context,
                ref,
                workouts,
                selectedWorkoutIds,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading workouts: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(workoutsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsList(
    BuildContext context,
    WidgetRef ref,
    List<WorkoutModel> workouts,
    Set<String> selectedWorkoutIds,
  ) {
    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Group workouts by category
    final groupedWorkouts = <String, List<WorkoutModel>>{};
    for (final workout in workouts) {
      groupedWorkouts.putIfAbsent(workout.category, () => []).add(workout);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedWorkouts.keys.length,
      itemBuilder: (context, index) {
        final category = groupedWorkouts.keys.elementAt(index);
        final categoryWorkouts = groupedWorkouts[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),

            // Category Workouts
            ...categoryWorkouts.map(
              (workout) => _buildWorkoutTile(
                context,
                ref,
                workout,
                selectedWorkoutIds.contains(workout.id),
              ),
            ),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildWorkoutTile(
    BuildContext context,
    WidgetRef ref,
    WorkoutModel workout,
    bool isSelected,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (selected) =>
            _toggleWorkoutSelection(ref, workout.id, selected ?? false),
        title: Text(
          workout.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: workout.description != null
            ? Text(
                workout.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        secondary: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getCategoryColor(workout.category).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getCategoryColor(workout.category).withOpacity(0.5),
            ),
          ),
          child: Text(
            workout.category,
            style: TextStyle(
              fontSize: 12,
              color: _getCategoryColor(workout.category),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _toggleWorkoutSelection(WidgetRef ref, String workoutId, bool selected) {
    final selectedIds = ref.read(selectedWorkoutsProvider.notifier);
    final currentSelection = ref.read(selectedWorkoutsProvider);

    if (selected) {
      selectedIds.state = {...currentSelection, workoutId};
    } else {
      selectedIds.state = currentSelection
          .where((id) => id != workoutId)
          .toSet();
    }
  }

  void _addSelectedWorkouts(BuildContext context, WidgetRef ref) {
    final selectedWorkoutIds = ref.read(selectedWorkoutsProvider);
    final workoutsAsync = ref.read(workoutsProvider);

    workoutsAsync.when(
      data: (allWorkouts) {
        final selectedWorkouts = allWorkouts
            .where((workout) => selectedWorkoutIds.contains(workout.id))
            .toList();

        if (selectedWorkouts.isNotEmpty) {
          // Add selected workouts to session
          ref
              .read(newSessionProvider.notifier)
              .addSelectedWorkouts(selectedWorkouts);

          // Clear selection
          ref.read(selectedWorkoutsProvider.notifier).state = {};

          // Navigate back
          Navigator.pop(context);
        }
      },
      loading: () {},
      error: (error, stack) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return Colors.red;
      case 'back':
        return Colors.blue;
      case 'legs':
        return Colors.green;
      case 'shoulders':
        return Colors.orange;
      case 'arms':
        return Colors.purple;
      case 'core':
        return Colors.yellow;
      case 'cardio':
        return Colors.pink;
      case 'full body':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
