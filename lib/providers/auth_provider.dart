// ─────────────────────────────────────────────────────────────────────────────
// AUTH PROVIDER — lib/providers/auth_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// OVERVIEW FOR THE DEVELOPER WORKING ON AUTH:
//
// This file manages all authentication state for the Reliq app.
// It uses Firebase Auth for credentials and Firestore for user profile data.
//
// FIREBASE AUTH handles:
//   - Email/password sign up and sign in
//   - Session persistence (user stays logged in across app restarts)
//   - Password reset emails
//   - Email verification
//
// FIRESTORE handles:
//   - Extra user data Firebase Auth doesn't store:
//     name, denomination, ethnicity, streak_count, is_premium
//   - Collection path: /users/{uid}
//   - Document structure:
//     {
//       "id": "firebase_uid",
//       "name": "Full Name",
//       "email": "user@email.com",
//       "ethnicity": "East African",
//       "denomination": "Catholic",
//       "streak_count": 0,
//       "joined_date": Timestamp,
//       "is_premium": false
//     }
//
// FLOW:
//   1. App starts → splash_screen calls tryAutoLogin()
//   2. If Firebase has a session → load user from Firestore → go to /main
//   3. If no session → go to /welcome → user signs in or signs up
//   4. On sign up → create Firebase Auth account → save profile to Firestore
//   5. On sign in → Firebase validates credentials → load profile from Firestore
//
// ERRORS:
//   All Firebase errors are caught and converted to readable strings
//   via _handleFirebaseError(). Add new error codes there if needed.
//
// TODO FOR AUTH DEVELOPER:
//   [ ] Add Google Sign-In (use firebase_auth + google_sign_in packages)
//   [ ] Add phone number auth if needed for Rwanda market
//   [ ] Add email verification check before allowing access to /main
//       (currently sends verification email but doesn't enforce it)
//   [ ] Add token refresh handling for long sessions
//   [ ] Consider adding biometric auth (local_auth package) for returning users
//
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as reliq;

class AuthProvider with ChangeNotifier {
  // Firebase Auth instance — do not create multiple instances,
  // always use FirebaseAuth.instance (singleton pattern)
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance — same singleton pattern
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  reliq.User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // ── Public getters ──────────────────────────────────────────────────────────

  // The current signed-in user's profile data (from Firestore)
  // Will be null if not signed in or if Firestore hasn't loaded yet
  reliq.User? get currentUser => _currentUser;

  // True while any async auth operation is in progress
  // Use this to show loading spinners in the UI
  bool get isLoading => _isLoading;

  // Last error message — shown in the UI as a red banner
  // Always call clearError() when the user dismisses it
  String? get error => _error;

  // Firebase Auth automatically persists the session — this just checks
  // if Firebase has a current user without any network call
  bool get isAuthenticated => _auth.currentUser != null;

  // ── tryAutoLogin ────────────────────────────────────────────────────────────
  // Called ONCE from splash_screen.dart when the app starts.
  // Returns true if the user is already logged in (session exists).
  // Returns false if the user needs to sign in.
  //
  // NOTE: This does NOT make a network call to validate the session —
  // Firebase handles session validation internally and refreshes tokens
  // automatically. We only call Firestore to get the user's profile data.
  Future<bool> tryAutoLogin() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return false;

    try {
      await _loadUserFromFirestore(firebaseUser.uid);
      return true;
    } catch (_) {
      // Firestore fetch failed (offline?) but user IS authenticated —
      // build a minimal user object from Firebase Auth data so the app
      // still works without a network connection
      _currentUser = reliq.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? '',
        joinedDate: DateTime.now(),
      );
      notifyListeners();
      return true;
    }
  }

  // ── signUp ──────────────────────────────────────────────────────────────────
  // Creates a new account. Called from signup_screen.dart.
  //
  // Steps:
  //   1. createUserWithEmailAndPassword → creates Firebase Auth account
  //   2. updateDisplayName → sets name in Firebase Auth (used as fallback)
  //   3. Firestore set → saves full profile to /users/{uid}
  //   4. sendEmailVerification → sends verification email (not enforced yet)
  //
  // If step 1 fails (e.g. email already in use) → returns false with error
  // If step 3 fails (Firestore not enabled) → returns false with error
  //   FIX: Make sure Firestore is enabled in Firebase console
  //        and security rules allow writes to /users/{uid}
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String ethnicity,
    required String denomination,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1 — Firebase Auth account creation
      // Throws FirebaseAuthException if email is taken or password is weak
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // Step 2 — Set display name in Firebase Auth
      // This is used as a fallback if Firestore is unavailable
      await credential.user!.updateDisplayName(name);

      // Step 3 — Save full profile to Firestore
      // IMPORTANT: Firestore must be enabled in Firebase console
      // Security rules must allow: allow write: if request.auth.uid == uid;
      await _db.collection('users').doc(uid).set({
        'id': uid,
        'name': name,
        'email': email.trim(),
        'ethnicity': ethnicity,
        'denomination': denomination,
        'streak_count': 0,
        'joined_date': FieldValue.serverTimestamp(),
        'is_premium': false,
      });

      // Step 4 — Send verification email
      // TODO: Enforce email verification before allowing /main access
      await credential.user!.sendEmailVerification();

      _currentUser = reliq.User(
        id: uid,
        email: email,
        name: name,
        denomination: denomination,
        joinedDate: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // Firebase Auth specific errors — see _handleFirebaseError below
      _error = _handleFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Catch-all for Firestore errors or unexpected issues
      // If this triggers, check: Firestore enabled? Security rules correct?
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── signIn ──────────────────────────────────────────────────────────────────
  // Signs in an existing user. Called from signin_screen.dart.
  //
  // Steps:
  //   1. signInWithEmailAndPassword → Firebase validates credentials
  //   2. _loadUserFromFirestore → loads profile data for the UI
  //
  // Common errors:
  //   'invalid-credential' → wrong email or password
  //   'user-not-found'     → no account with this email
  //   'too-many-requests'  → account temporarily locked after many failures
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _loadUserFromFirestore(credential.user!.uid);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── resetPassword ───────────────────────────────────────────────────────────
  // Sends a password reset link to the user's email.
  // Firebase handles the entire reset flow — no OTP or custom backend needed.
  // Called from forgot_password_screen.dart.
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── signOut ─────────────────────────────────────────────────────────────────
  // Signs out the user. Called from profile_screen.dart settings.
  // After this, isAuthenticated returns false and currentUser is null.
  // The app navigates to /welcome.
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // ── updateProfile ───────────────────────────────────────────────────────────
  // Updates user profile in both Firebase Auth and Firestore.
  // Called from edit_profile_screen.dart.
  //
  // NOTE: Only updates fields that exist in the User model.
  // To add new fields, update the User model and toJson() method first.
  Future<void> updateProfile(reliq.User updatedUser) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      // Update display name in Firebase Auth (used as fallback)
      await _auth.currentUser!.updateDisplayName(updatedUser.name);

      // Update full profile in Firestore
      await _db.collection('users').doc(uid).update(updatedUser.toJson());

      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _error = 'Could not update profile.';
      notifyListeners();
    }
  }

  // ── _loadUserFromFirestore ──────────────────────────────────────────────────
  // Private helper — loads user profile from Firestore after auth.
  // If the document doesn't exist (e.g. user signed up before Firestore
  // was enabled), falls back to Firebase Auth data.
  Future<void> _loadUserFromFirestore(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      _currentUser = reliq.User.fromJson({
        ...doc.data()!,
        'id': uid,
      });
    } else {
      // Fallback — Firestore document missing
      // This can happen if the user was created before Firestore was set up
      // TODO: Create the missing document here if needed
      final firebaseUser = _auth.currentUser!;
      _currentUser = reliq.User(
        id: uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? '',
        joinedDate: DateTime.now(),
      );
    }
    notifyListeners();
  }

  // ── _handleFirebaseError ────────────────────────────────────────────────────
  // Converts Firebase error codes to user-friendly messages.
  // Add new cases here as you encounter new error codes.
  // Full list: https://firebase.google.com/docs/auth/admin/errors
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'invalid-credential':
        // This is the most common error — covers both wrong email and password
        // Firebase merged these into one code for security (prevents enumeration)
        return 'Incorrect email or password.';
      case 'requires-recent-login':
        // Triggered when trying to update email/password without recent sign in
        // TODO: Prompt user to re-authenticate before sensitive operations
        return 'Please sign in again to continue.';
      case 'operation-not-allowed':
        // Email/password auth is disabled in Firebase console
        // FIX: Go to Firebase console → Authentication → Sign-in method → Enable Email/Password
        return 'Sign in method not enabled. Contact support.';
      default:
        // Log unknown error codes during development
        // ignore: avoid_print
        print('[AuthProvider] Unhandled Firebase error code: ${e.code}');
        return 'Authentication failed. Please try again.';
    }
  }

  // ── clearError ──────────────────────────────────────────────────────────────
  // Call this when the user dismisses an error banner in the UI
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
