import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'providers.dart';

// Selected workout with exercise details
class SelectedExercise {
  final WorkoutModel workout;
  int sets;
  int reps;
  double? weight;

  SelectedExercise({
    required this.workout,
    this.sets = 1,
    this.reps = 1,
    this.weight,
  });

  SelectedExercise copyWith({
    WorkoutModel? workout,
    int? sets,
    int? reps,
    double? weight,
  }) {
    return SelectedExercise(
      workout: workout ?? this.workout,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
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
