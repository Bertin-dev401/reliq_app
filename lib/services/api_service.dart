import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

/// API Service - Firebase wrapper
/// This service provides a clean interface for all API calls
/// All calls are now delegated to Firebase Authentication and Firestore
class ApiService {
  static const String _tokenKey = 'firebase_token';
  static const String _userKey = 'user_profile';

  final _auth = FirebaseService.auth;
  final _firestore = FirestoreService();

  // ── Token helpers ──────────────────────────────────────────
  // FirebaseAuth handles tokens automatically via ID tokens
  // These methods maintain compatibility with the old interface

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── Authentication ────────────────────────────────────────
  
  /// Sign up with email and password
  /// Creates Firebase Auth user and Firestore user document
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String ethnicity,
    required String denomination,
  }) async {
    try {
      developer.log('SignUp: Creating user account for $email');

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      developer.log('SignUp: Firebase user created: ${user.uid}');

      // Create user profile in Firestore
      await _firestore.createUserDocument(
        userId: user.uid,
        email: email,
        name: name,
        denomination: denomination,
        ethnicity: ethnicity,
        theme: 'white',
      );

      developer.log('SignUp: User document created in Firestore');

      // Get ID token for API communication
      final idToken = await user.getIdToken();

      // Save credentials locally
      await saveToken(idToken ?? '');

      return {
        'success': true,
        'token': idToken,
        'user': {
          'uid': user.uid,
          'email': user.email,
          'name': name,
          'ethnicity': ethnicity,
          'denomination': denomination,
        },
      };
    } on FirebaseAuthException catch (e) {
      developer.log('SignUp Error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      developer.log('SignUp Error: $e');
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      developer.log('SignIn: Attempting login for $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Login failed');
      }

      developer.log('SignIn: User logged in: ${user.uid}');

      // Get ID token
      final idToken = await user.getIdToken();

      // Save token
      await saveToken(idToken ?? '');

      // Fetch user profile from Firestore
      final userProfile = await _firestore.getUserProfile(user.uid);

      return {
        'success': true,
        'token': idToken,
        'user': {
          'uid': user.uid,
          'email': user.email,
          ...?userProfile,
        },
      };
    } on FirebaseAuthException catch (e) {
      developer.log('SignIn Error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      developer.log('SignIn Error: $e');
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      developer.log('SignOut: Signing out user');
      await _auth.signOut();
      await clearToken();
      developer.log('SignOut: User signed out successfully');
    } catch (e) {
      developer.log('SignOut Error: $e');
      throw Exception('Sign out failed: $e');
    }
  }

  /// Reset password via email
  Future<void> resetPassword(String email) async {
    try {
      developer.log('ResetPassword: Sending reset email to $email');
      await _auth.sendPasswordResetEmail(email: email);
      developer.log('ResetPassword: Email sent successfully');
    } on FirebaseAuthException catch (e) {
      developer.log('ResetPassword Error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      developer.log('ResetPassword Error: $e');
      throw Exception('Password reset failed: $e');
    }
  }

  /// Update user profile (delegates to Firestore)
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.updateUserProfile(userId, data);
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  /// Get user profile (delegates to Firestore)
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      return await _firestore.getUserProfile(userId);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // ── Current User Info ──────────────────────────────────────

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Helper Methods ────────────────────────────────────────

  /// Handle Firebase Auth exceptions and convert to user-friendly messages
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email address not found. Please sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters with uppercase, lowercase, and numbers.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  /// Handle general errors
  String _handleError(Exception e) {
    developer.log('Error: $e');
    return 'An error occurred. Please try again.';
  }
}

/// Legacy compatibility - Maintains old interface for gradual migration
@Deprecated('Use ApiService directly instead')
class LegacyApiService {
  static final ApiService _instance = ApiService();

  static ApiService get instance => _instance;
}
