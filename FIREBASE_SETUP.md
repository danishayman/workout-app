# 🔥 Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Project name: `workout-tracker` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click **"Create project"**

## Step 2: Enable Authentication

1. In your Firebase project dashboard, click **"Authentication"**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable these providers:
   - ✅ **Email/Password** - Toggle ON
   - ✅ **Google** - Toggle ON, set support email

## Step 3: Add Android App

1. In Firebase Console, click the **Android icon** (⚙️)
2. **Android package name**: `com.example.workout_app`
3. **App nickname**: `Workout App`
4. **Debug signing certificate SHA-1**: Leave blank for now
5. Click **"Register app"**
6. **Download** `google-services.json`
7. Place the file in: `android/app/google-services.json`

## Step 4: Configure Firebase Options

After adding your Android app, Firebase will show you configuration values. Copy them to `lib/firebase_options.dart`:

```dart
// Replace the placeholder values in firebase_options.dart with:

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',        // From Firebase Console
  appId: 'YOUR_ANDROID_APP_ID',          // From Firebase Console  
  messagingSenderId: 'YOUR_SENDER_ID',   // From Firebase Console
  projectId: 'your-project-id',          // Your Firebase project ID
  storageBucket: 'your-project-id.appspot.com',
);
```

You'll find these values in the Firebase Console when you register your Android app.

## Step 5: Test the App

Once you've completed the above steps:

```bash
flutter run
```

## 🚨 Important Notes

- **Package Name**: Make sure to use `com.example.workout_app` when registering your Android app
- **google-services.json**: This file MUST be placed in `android/app/` directory
- **Configuration**: Replace ALL placeholder values in `firebase_options.dart`

## ✅ What's Already Configured

- ✅ Firebase dependencies added to pubspec.yaml
- ✅ Android Gradle configuration updated
- ✅ Authentication service created
- ✅ UI screens built
- ✅ Auth state management implemented

## 🔍 Troubleshooting

If you get Firebase errors when running the app:
1. Double-check that `google-services.json` is in the correct location
2. Verify all values in `firebase_options.dart` are correct
3. Make sure Authentication is enabled in Firebase Console
4. Clean and rebuild: `flutter clean && flutter pub get && flutter run`

## 📱 Testing Authentication

Once setup is complete, you can test:
1. **Email/Password Sign Up** - Create new account
2. **Email/Password Sign In** - Login with created account  
3. **Google Sign In** - Use Google account
4. **Password Reset** - Test forgot password feature
5. **Sign Out** - Test logout functionality

---

After completing these steps, your authentication system will be fully functional! 🎉
