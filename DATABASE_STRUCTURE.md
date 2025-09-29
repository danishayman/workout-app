# Workout App - Database Structure Documentation

## Overview
This document describes the Firebase Firestore database structure implemented for the Workout App. The database uses Cloud Firestore with three main collections: `users`, `workouts`, and `sessions`.

## Database Collections

### 1. Users Collection (`users`)
**Document ID**: `{userId}` (from Firebase Auth)

**Fields**:
- `name` (string): User's display name
- `email` (string): User's email address
- `createdAt` (timestamp): Account creation date
- `goals` (map, optional): User's fitness goals and preferences

**Example Document**:
```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "createdAt": "2024-01-15T10:30:00Z",
  "goals": {
    "targetWeight": 75,
    "weeklyWorkouts": 4,
    "primaryGoal": "muscle_gain"
  }
}
```

### 2. Workouts Collection (`workouts`)
**Document ID**: Auto-generated

**Fields**:
- `name` (string): Exercise name (e.g., "Push-ups", "Squats")
- `category` (string): Exercise category (e.g., "Chest", "Legs", "Cardio")
- `description` (string, optional): Exercise description and instructions

**Example Document**:
```json
{
  "name": "Push-ups",
  "category": "Chest",
  "description": "Classic bodyweight exercise targeting chest, shoulders, and triceps"
}
```

**Pre-seeded Categories**:
- Chest
- Back
- Legs
- Shoulders
- Arms
- Core
- Cardio
- Full Body

### 3. Sessions Collection (`sessions`)
**Document ID**: Auto-generated

**Fields**:
- `userId` (string): Reference to user document ID
- `date` (timestamp): When the workout session occurred
- `notes` (string, optional): User's notes about the session

**Subcollection**: `exercises`
- **Document ID**: Auto-generated
- **Fields**:
  - `workoutId` (string): Reference to workout document ID
  - `sets` (number): Number of sets performed
  - `reps` (number): Number of repetitions per set
  - `weight` (number, optional): Weight used (in kg or lbs)

**Example Session Document**:
```json
{
  "userId": "user123",
  "date": "2024-01-15T18:30:00Z",
  "notes": "Great workout! Felt strong today."
}
```

**Example Exercise Subcollection Document**:
```json
{
  "workoutId": "workout456",
  "sets": 3,
  "reps": 12,
  "weight": 20.5
}
```

## Service Classes

### AuthService (`lib/services/auth_service.dart`)
- Handles user authentication (email/password, Google Sign-In)
- **Automatically creates user documents** in Firestore when new users sign up
- Integrates with UserService for seamless user management

### UserService (`lib/services/user_service.dart`)
**Key Methods**:
- `createUser(UserModel user)`: Create new user document
- `getUser(String userId)`: Get user by ID
- `updateUser(String userId, Map<String, dynamic> updates)`: Update user
- `updateUserGoals(String userId, Map<String, dynamic> goals)`: Update user goals
- `getUserStream(String userId)`: Real-time user data stream

### WorkoutService (`lib/services/workout_service.dart`)
**Key Methods**:
- `createWorkout(WorkoutModel workout)`: Add new workout type
- `getAllWorkouts()`: Get all available workouts
- `getWorkoutsByCategory(String category)`: Get workouts by category
- `getCategories()`: Get all unique categories
- `searchWorkouts(String searchTerm)`: Search workouts by name
- `getWorkoutsStream()`: Real-time workouts stream
- `batchCreateWorkouts(List<WorkoutModel> workouts)`: Bulk create workouts

### SessionService (`lib/services/session_service.dart`)
**Session Methods**:
- `createSession(SessionModel session)`: Create new workout session
- `getSession(String sessionId)`: Get session by ID
- `getSessionWithExercises(String sessionId)`: Get session with exercises
- `getUserSessions(String userId)`: Get all user sessions
- `getSessionsByDateRange(String userId, DateTime start, DateTime end)`: Get sessions in date range
- `updateSession(String sessionId, Map<String, dynamic> updates)`: Update session
- `deleteSession(String sessionId)`: Delete session and all exercises

**Exercise Methods**:
- `addExerciseToSession(String sessionId, ExerciseModel exercise)`: Add exercise
- `getSessionExercises(String sessionId)`: Get all exercises in session
- `updateExercise(String sessionId, String exerciseId, Map updates)`: Update exercise
- `deleteExercise(String sessionId, String exerciseId)`: Delete exercise
- `batchAddExercisesToSession(String sessionId, List<ExerciseModel> exercises)`: Bulk add exercises

**Stream Methods** (Real-time updates):
- `getUserSessionsStream(String userId)`: Stream user sessions
- `getSessionExercisesStream(String sessionId)`: Stream session exercises
- `getSessionWithExercisesStream(String sessionId)`: Stream session with exercises

## Data Models

### UserModel (`lib/models/user_model.dart`)
```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final Map<String, dynamic>? goals;
}
```

### WorkoutModel (`lib/models/workout_model.dart`)
```dart
class WorkoutModel {
  final String id;
  final String name;
  final String category;
  final String? description;
}
```

### SessionModel (`lib/models/session_model.dart`)
```dart
class SessionModel {
  final String id;
  final String userId;
  final DateTime date;
  final String? notes;
  final List<ExerciseModel> exercises;
}
```

### ExerciseModel (`lib/models/exercise_model.dart`)
```dart
class ExerciseModel {
  final String id;
  final String workoutId;
  final int sets;
  final int reps;
  final double? weight;
}
```

## Database Initialization

### DatabaseSeeder (`lib/services/database_seeder.dart`)
- Seeds the `workouts` collection with 45+ common exercises
- Organizes exercises by categories (Chest, Back, Legs, etc.)
- Prevents duplicate seeding by checking existing data

### DatabaseInitializer (`lib/services/database_initializer.dart`)
- Called automatically when the app starts
- Initializes database seeding if needed
- Provides methods for development/testing (reset, re-initialize)

## Usage Examples

### Creating a User (Automatic)
```dart
// Users are automatically created when they sign up
final authService = AuthService();
await authService.registerWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password',
  displayName: 'John Doe',
);
// User document is automatically created in Firestore
```

### Creating a Workout Session
```dart
final sessionService = SessionService();

// 1. Create session
String sessionId = await sessionService.createSession(SessionModel(
  id: '',
  userId: 'user123',
  date: DateTime.now(),
  notes: 'Morning workout',
));

// 2. Add exercises to session
await sessionService.addExerciseToSession(sessionId, ExerciseModel(
  id: '',
  workoutId: 'pushups_workout_id',
  sets: 3,
  reps: 15,
));

await sessionService.addExerciseToSession(sessionId, ExerciseModel(
  id: '',
  workoutId: 'squats_workout_id',
  sets: 3,
  reps: 20,
  weight: 50.0,
));
```

### Getting User's Workout History
```dart
final sessionService = SessionService();

// Get all sessions with exercises
List<SessionModel> sessions = await sessionService
    .getUserSessionsWithExercises('user123');

// Get sessions from last 30 days
DateTime thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
List<SessionModel> recentSessions = await sessionService
    .getSessionsByDateRange('user123', thirtyDaysAgo, DateTime.now());
```

### Real-time Data Streaming
```dart
final sessionService = SessionService();

// Listen to user's sessions in real-time
Stream<List<SessionModel>> sessionsStream = 
    sessionService.getUserSessionsStream('user123');

sessionsStream.listen((sessions) {
  // Update UI with new session data
  print('User has ${sessions.length} sessions');
});
```

## Security Rules (Firestore)

**Important**: You'll need to set up Firestore security rules to ensure users can only access their own data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read workouts (they're public)
    match /workouts/{workoutId} {
      allow read: if true;
      allow write: if false; // Only admins should write workouts
    }
    
    // Users can only access their own sessions
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      
      // Users can access exercises in their own sessions
      match /exercises/{exerciseId} {
        allow read, write: if request.auth != null && 
          request.auth.uid == get(/databases/$(database)/documents/sessions/$(sessionId)).data.userId;
      }
    }
  }
}
```

## Next Steps

With the database structure complete, you can now:

1. **Build UI screens** to display and interact with the data
2. **Add data validation** and error handling in the UI
3. **Implement analytics** to track user progress
4. **Add offline support** using Firestore's built-in caching
5. **Create backup/export** functionality for user data
6. **Add social features** like sharing workouts or competing with friends

The backend is now fully set up and ready for frontend development!
