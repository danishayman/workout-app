import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (result.user != null) {
        await _createUserDocument(result.user!, displayName);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available
      if (!await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut(); // Clear any cached data
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Verify we have the required tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw 'Failed to obtain Google authentication tokens. Please try again.';
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      UserCredential result = await _auth.signInWithCredential(credential);

      // Create user document if it's a new user
      if (result.user != null && result.additionalUserInfo?.isNewUser == true) {
        await _createUserDocument(result.user!);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw 'An account already exists with this email using a different sign-in method.';
        case 'invalid-credential':
          throw 'The Google sign-in credentials are invalid. Please try again.';
        case 'operation-not-allowed':
          throw 'Google sign-in is not enabled. Please contact support.';
        case 'user-disabled':
          throw 'This user account has been disabled.';
        default:
          throw _handleAuthException(e);
      }
    } catch (e) {
      // Log the actual error for debugging
      print('Google Sign-In Error: $e');

      if (e.toString().contains('PlatformException')) {
        throw 'Google Sign-In configuration error. Please check your setup.';
      } else if (e.toString().contains('network')) {
        throw 'Network error. Please check your internet connection.';
      } else {
        throw 'An unexpected error occurred during Google sign-in: ${e.toString()}';
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw 'Error signing out. Please try again.';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, [String? displayName]) async {
    try {
      // Check if user document already exists
      bool userExists = await _userService.userExists(user.uid);
      if (userExists) return;

      // Create user model
      UserModel userModel = UserModel(
        id: user.uid,
        name: displayName ?? user.displayName ?? 'User',
        email: user.email ?? '',
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _userService.createUser(userModel);
    } catch (e) {
      // Log error but don't throw - user authentication was successful
      print('Error creating user document: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
