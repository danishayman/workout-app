import '../models/workout_model.dart';
import 'workout_service.dart';

class DatabaseSeeder {
  final WorkoutService _workoutService = WorkoutService();

  // Seed the workouts collection with common exercises
  Future<void> seedWorkouts() async {
    try {
      // Check if workouts already exist
      List<WorkoutModel> existingWorkouts = await _workoutService
          .getAllWorkouts();
      if (existingWorkouts.isNotEmpty) {
        print('Workouts already exist. Skipping seeding.');
        return;
      }

      List<WorkoutModel> workouts = _getCommonWorkouts();
      await _workoutService.batchCreateWorkouts(workouts);
      print('Successfully seeded ${workouts.length} workouts.');
    } catch (e) {
      print('Error seeding workouts: $e');
      rethrow;
    }
  }

  // Get list of common workouts organized by category
  List<WorkoutModel> _getCommonWorkouts() {
    return [
      // Chest Exercises
      WorkoutModel(
        id: '', // Will be auto-generated
        name: 'Push-ups',
        category: 'Chest',
        description:
            'Classic bodyweight exercise targeting chest, shoulders, and triceps',
      ),
      WorkoutModel(
        id: '',
        name: 'Bench Press',
        category: 'Chest',
        description: 'Barbell or dumbbell press lying on a bench',
      ),
      WorkoutModel(
        id: '',
        name: 'Chest Flyes',
        category: 'Chest',
        description: 'Dumbbell flyes for chest isolation',
      ),
      WorkoutModel(
        id: '',
        name: 'Incline Push-ups',
        category: 'Chest',
        description: 'Push-ups with hands elevated on a surface',
      ),
      WorkoutModel(
        id: '',
        name: 'Dips',
        category: 'Chest',
        description: 'Bodyweight exercise using parallel bars or chair',
      ),

      // Back Exercises
      WorkoutModel(
        id: '',
        name: 'Pull-ups',
        category: 'Back',
        description: 'Bodyweight exercise using a pull-up bar',
      ),
      WorkoutModel(
        id: '',
        name: 'Rows',
        category: 'Back',
        description: 'Barbell, dumbbell, or cable rows',
      ),
      WorkoutModel(
        id: '',
        name: 'Lat Pulldowns',
        category: 'Back',
        description: 'Cable machine exercise for lats',
      ),
      WorkoutModel(
        id: '',
        name: 'Deadlifts',
        category: 'Back',
        description: 'Compound exercise lifting weight from the ground',
      ),
      WorkoutModel(
        id: '',
        name: 'Superman',
        category: 'Back',
        description: 'Bodyweight exercise lying face down',
      ),

      // Leg Exercises
      WorkoutModel(
        id: '',
        name: 'Squats',
        category: 'Legs',
        description: 'Bodyweight or weighted squats',
      ),
      WorkoutModel(
        id: '',
        name: 'Lunges',
        category: 'Legs',
        description: 'Forward, reverse, or walking lunges',
      ),
      WorkoutModel(
        id: '',
        name: 'Leg Press',
        category: 'Legs',
        description: 'Machine exercise for quadriceps and glutes',
      ),
      WorkoutModel(
        id: '',
        name: 'Calf Raises',
        category: 'Legs',
        description: 'Standing or seated calf raises',
      ),
      WorkoutModel(
        id: '',
        name: 'Wall Sit',
        category: 'Legs',
        description: 'Isometric exercise against a wall',
      ),
      WorkoutModel(
        id: '',
        name: 'Bulgarian Split Squats',
        category: 'Legs',
        description: 'Single-leg squats with rear foot elevated',
      ),

      // Shoulder Exercises
      WorkoutModel(
        id: '',
        name: 'Shoulder Press',
        category: 'Shoulders',
        description: 'Overhead press with dumbbells or barbell',
      ),
      WorkoutModel(
        id: '',
        name: 'Lateral Raises',
        category: 'Shoulders',
        description: 'Dumbbell side raises for deltoids',
      ),
      WorkoutModel(
        id: '',
        name: 'Front Raises',
        category: 'Shoulders',
        description: 'Dumbbell front raises for anterior deltoids',
      ),
      WorkoutModel(
        id: '',
        name: 'Rear Delt Flyes',
        category: 'Shoulders',
        description: 'Reverse flyes for posterior deltoids',
      ),
      WorkoutModel(
        id: '',
        name: 'Pike Push-ups',
        category: 'Shoulders',
        description: 'Bodyweight exercise in downward dog position',
      ),

      // Arm Exercises
      WorkoutModel(
        id: '',
        name: 'Bicep Curls',
        category: 'Arms',
        description: 'Dumbbell or barbell curls for biceps',
      ),
      WorkoutModel(
        id: '',
        name: 'Tricep Extensions',
        category: 'Arms',
        description: 'Overhead or lying tricep extensions',
      ),
      WorkoutModel(
        id: '',
        name: 'Hammer Curls',
        category: 'Arms',
        description: 'Neutral grip dumbbell curls',
      ),
      WorkoutModel(
        id: '',
        name: 'Tricep Dips',
        category: 'Arms',
        description: 'Bodyweight dips focusing on triceps',
      ),
      WorkoutModel(
        id: '',
        name: 'Close-Grip Push-ups',
        category: 'Arms',
        description: 'Push-ups with hands close together for triceps',
      ),

      // Core Exercises
      WorkoutModel(
        id: '',
        name: 'Plank',
        category: 'Core',
        description: 'Isometric core strengthening exercise',
      ),
      WorkoutModel(
        id: '',
        name: 'Crunches',
        category: 'Core',
        description: 'Classic abdominal exercise',
      ),
      WorkoutModel(
        id: '',
        name: 'Russian Twists',
        category: 'Core',
        description: 'Seated twisting motion for obliques',
      ),
      WorkoutModel(
        id: '',
        name: 'Mountain Climbers',
        category: 'Core',
        description: 'Dynamic plank variation',
      ),
      WorkoutModel(
        id: '',
        name: 'Bicycle Crunches',
        category: 'Core',
        description: 'Alternating knee-to-elbow crunches',
      ),
      WorkoutModel(
        id: '',
        name: 'Dead Bug',
        category: 'Core',
        description: 'Lying core exercise with opposite arm/leg movement',
      ),
      WorkoutModel(
        id: '',
        name: 'Side Plank',
        category: 'Core',
        description: 'Lateral plank for obliques',
      ),

      // Cardio Exercises
      WorkoutModel(
        id: '',
        name: 'Jumping Jacks',
        category: 'Cardio',
        description: 'Full-body jumping exercise',
      ),
      WorkoutModel(
        id: '',
        name: 'Burpees',
        category: 'Cardio',
        description: 'Full-body exercise combining squat, plank, and jump',
      ),
      WorkoutModel(
        id: '',
        name: 'High Knees',
        category: 'Cardio',
        description: 'Running in place with high knee lifts',
      ),
      WorkoutModel(
        id: '',
        name: 'Butt Kickers',
        category: 'Cardio',
        description: 'Running in place kicking heels to glutes',
      ),
      WorkoutModel(
        id: '',
        name: 'Running',
        category: 'Cardio',
        description: 'Outdoor or treadmill running',
      ),
      WorkoutModel(
        id: '',
        name: 'Jump Rope',
        category: 'Cardio',
        description: 'Jumping rope exercise',
      ),

      // Full Body Exercises
      WorkoutModel(
        id: '',
        name: 'Thrusters',
        category: 'Full Body',
        description: 'Squat to overhead press combination',
      ),
      WorkoutModel(
        id: '',
        name: 'Clean and Press',
        category: 'Full Body',
        description: 'Olympic lift variation',
      ),
      WorkoutModel(
        id: '',
        name: 'Turkish Get-ups',
        category: 'Full Body',
        description: 'Complex movement from lying to standing',
      ),
      WorkoutModel(
        id: '',
        name: 'Bear Crawl',
        category: 'Full Body',
        description: 'Quadrupedal movement pattern',
      ),
      WorkoutModel(
        id: '',
        name: 'Kettlebell Swings',
        category: 'Full Body',
        description: 'Hip-hinge movement with kettlebell',
      ),
    ];
  }

  // Method to add more workouts later
  Future<void> addCustomWorkouts(List<WorkoutModel> workouts) async {
    try {
      await _workoutService.batchCreateWorkouts(workouts);
      print('Successfully added ${workouts.length} custom workouts.');
    } catch (e) {
      print('Error adding custom workouts: $e');
      rethrow;
    }
  }

  // Method to reset workouts (delete all and re-seed)
  Future<void> resetWorkouts() async {
    try {
      // Get all existing workouts
      List<WorkoutModel> existingWorkouts = await _workoutService
          .getAllWorkouts();

      // Delete all existing workouts
      for (WorkoutModel workout in existingWorkouts) {
        await _workoutService.deleteWorkout(workout.id);
      }

      // Re-seed with common workouts
      await seedWorkouts();
      print('Successfully reset workouts database.');
    } catch (e) {
      print('Error resetting workouts: $e');
      rethrow;
    }
  }
}
