import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'providers.dart';

// Individual set data
class ExerciseSet {
  final int reps;
  final double? weight;
  final bool completed;

  ExerciseSet({required this.reps, this.weight, this.completed = false});

  ExerciseSet copyWith({int? reps, double? weight, bool? completed}) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      completed: completed ?? this.completed,
    );
  }
}

// Selected workout with exercise details
class SelectedExercise {
  final WorkoutModel workout;
  final List<ExerciseSet> exerciseSets;
  final String? notes;
  final bool isExpanded;

  SelectedExercise({
    required this.workout,
    List<ExerciseSet>? exerciseSets,
    this.notes,
    this.isExpanded = false,
  }) : exerciseSets = exerciseSets ?? [ExerciseSet(reps: 8, weight: 0)];

  // Legacy getters for compatibility
  int get sets => exerciseSets.length;
  int get reps => exerciseSets.isNotEmpty ? exerciseSets.first.reps : 0;
  double? get weight =>
      exerciseSets.isNotEmpty ? exerciseSets.first.weight : null;

  SelectedExercise copyWith({
    WorkoutModel? workout,
    List<ExerciseSet>? exerciseSets,
    String? notes,
    bool? isExpanded,
  }) {
    return SelectedExercise(
      workout: workout ?? this.workout,
      exerciseSets: exerciseSets ?? this.exerciseSets,
      notes: notes ?? this.notes,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  // Add a new set based on the previous set
  SelectedExercise addSet() {
    final lastSet = exerciseSets.isNotEmpty
        ? exerciseSets.last
        : ExerciseSet(reps: 8, weight: 0);
    final newSet = ExerciseSet(reps: lastSet.reps, weight: lastSet.weight);
    return copyWith(exerciseSets: [...exerciseSets, newSet]);
  }

  // Update a specific set
  SelectedExercise updateSet(int index, ExerciseSet updatedSet) {
    final updatedSets = List<ExerciseSet>.from(exerciseSets);
    if (index < updatedSets.length) {
      updatedSets[index] = updatedSet;
    }
    return copyWith(exerciseSets: updatedSets);
  }

  // Remove a set
  SelectedExercise removeSet(int index) {
    if (exerciseSets.length <= 1) return this; // Keep at least one set
    final updatedSets = List<ExerciseSet>.from(exerciseSets);
    updatedSets.removeAt(index);
    return copyWith(exerciseSets: updatedSets);
  }
}

// New session state
class NewSessionState {
  final DateTime date;
  final String notes;
  final List<SelectedExercise> selectedExercises;
  final bool isLoading;
  final String? error;

  NewSessionState({
    required this.date,
    this.notes = '',
    this.selectedExercises = const [],
    this.isLoading = false,
    this.error,
  });

  NewSessionState copyWith({
    DateTime? date,
    String? notes,
    List<SelectedExercise>? selectedExercises,
    bool? isLoading,
    String? error,
  }) {
    return NewSessionState(
      date: date ?? this.date,
      notes: notes ?? this.notes,
      selectedExercises: selectedExercises ?? this.selectedExercises,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// New session notifier
class NewSessionNotifier extends StateNotifier<NewSessionState> {
  NewSessionNotifier() : super(NewSessionState(date: DateTime.now()));

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void addSelectedWorkouts(List<WorkoutModel> workouts) {
    final newExercises = workouts
        .map((workout) => SelectedExercise(workout: workout))
        .toList();
    final updatedExercises = [...state.selectedExercises, ...newExercises];
    state = state.copyWith(selectedExercises: updatedExercises);
  }

  void removeExercise(int index) {
    final updatedExercises = List<SelectedExercise>.from(
      state.selectedExercises,
    );
    updatedExercises.removeAt(index);
    state = state.copyWith(selectedExercises: updatedExercises);
  }

  void updateExercise(int index, SelectedExercise exercise) {
    final updatedExercises = List<SelectedExercise>.from(
      state.selectedExercises,
    );
    updatedExercises[index] = exercise;
    state = state.copyWith(selectedExercises: updatedExercises);
  }

  void toggleExerciseExpansion(int index) {
    final updatedExercises = List<SelectedExercise>.from(
      state.selectedExercises,
    );
    updatedExercises[index] = updatedExercises[index].copyWith(
      isExpanded: !updatedExercises[index].isExpanded,
    );
    state = state.copyWith(selectedExercises: updatedExercises);
  }

  void addSetToExercise(int exerciseIndex) {
    final updatedExercises = List<SelectedExercise>.from(
      state.selectedExercises,
    );
    updatedExercises[exerciseIndex] = updatedExercises[exerciseIndex].addSet();
    state = state.copyWith(selectedExercises: updatedExercises);
  }

  void updateExerciseSet(
    int exerciseIndex,
    int setIndex,
    ExerciseSet updatedSet,
  ) {
    final updatedExercises = List<SelectedExercise>.from(
      state.selectedExercises,
    );
    updatedExercises[exerciseIndex] = updatedExercises[exerciseIndex].updateSet(
      setIndex,
      updatedSet,
    );
    state = state.copyWith(selectedExercises: updatedExercises);
  }

  void updateExerciseNotes(int exerciseIndex, String notes) {
    final updatedExercises = List<SelectedExercise>.from(
      state.selectedExercises,
    );
    updatedExercises[exerciseIndex] = updatedExercises[exerciseIndex].copyWith(
      notes: notes,
    );
    state = state.copyWith(selectedExercises: updatedExercises);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = NewSessionState(date: DateTime.now());
  }
}

// New session provider
final newSessionProvider =
    StateNotifierProvider<NewSessionNotifier, NewSessionState>((ref) {
      return NewSessionNotifier();
    });

// Selected workouts for workout selection screen
final selectedWorkoutsProvider = StateProvider<Set<String>>((ref) => {});

// Workout search query provider
final workoutSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered workouts provider
final filteredWorkoutsProvider = Provider<AsyncValue<List<WorkoutModel>>>((
  ref,
) {
  final workoutsAsync = ref.watch(workoutsProvider);
  final searchQuery = ref.watch(workoutSearchQueryProvider).toLowerCase();

  return workoutsAsync.when(
    data: (workouts) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(workouts);
      }
      final filtered = workouts.where((workout) {
        return workout.name.toLowerCase().contains(searchQuery) ||
            workout.category.toLowerCase().contains(searchQuery);
      }).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
