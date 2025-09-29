import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/services.dart';
import '../models/models.dart';

// Service providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userServiceProvider = Provider<UserService>((ref) => UserService());
final workoutServiceProvider = Provider<WorkoutService>(
  (ref) => WorkoutService(),
);
final sessionServiceProvider = Provider<SessionService>(
  (ref) => SessionService(),
);

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Workouts provider
final workoutsProvider = FutureProvider<List<WorkoutModel>>((ref) async {
  final workoutService = ref.watch(workoutServiceProvider);
  return await workoutService.getAllWorkouts();
});

// Workout categories provider
final workoutCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final workoutService = ref.watch(workoutServiceProvider);
  return await workoutService.getCategories();
});

// User sessions provider
final userSessionsProvider = FutureProvider.family<List<SessionModel>, String>((
  ref,
  userId,
) async {
  final sessionService = ref.watch(sessionServiceProvider);
  return await sessionService.getUserSessions(userId);
});

// User sessions stream provider
final userSessionsStreamProvider =
    StreamProvider.family<List<SessionModel>, String>((ref, userId) {
      final sessionService = ref.watch(sessionServiceProvider);
      return sessionService.getUserSessionsStream(userId);
    });
