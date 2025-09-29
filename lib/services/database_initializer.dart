import 'database_seeder.dart';

class DatabaseInitializer {
  static final DatabaseSeeder _seeder = DatabaseSeeder();
  static bool _initialized = false;

  // Initialize the database (call this once when the app starts)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('Initializing database...');

      // Seed workouts collection
      await _seeder.seedWorkouts();

      _initialized = true;
      print('Database initialization completed.');
    } catch (e) {
      print('Database initialization failed: $e');
      // Don't throw - app should still work even if seeding fails
    }
  }

  // Force re-initialization (useful for development/testing)
  static Future<void> forceReinitialize() async {
    _initialized = false;
    await initialize();
  }

  // Reset and re-seed database (useful for development/testing)
  static Future<void> resetDatabase() async {
    try {
      print('Resetting database...');
      await _seeder.resetWorkouts();
      print('Database reset completed.');
    } catch (e) {
      print('Database reset failed: $e');
      rethrow;
    }
  }
}
