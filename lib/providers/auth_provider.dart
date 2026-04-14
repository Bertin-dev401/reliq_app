import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as reliq;

class AuthProvider with ChangeNotifier {
  // Firebase Auth instance — handles all authentication operations
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance — stores extra user data that Firebase Auth
  // doesn't store by itself (name, denomination, ethnicity)
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  reliq.User? _currentUser;
  bool _isLoading = false;
  String? _error;

  reliq.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Firebase Auth persists the session automatically across app restarts.
  // currentUser is non-null if the user is already signed in — no token
  // management needed, Firebase handles it all internally.
  bool get isAuthenticated => _auth.currentUser != null;

  // Called from splash_screen.dart on app start.
  // Firebase already knows if the user is logged in — we just load
  // their profile data from Firestore to populate the UI.
  Future<bool> tryAutoLogin() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return false;

    try {
      await _loadUserFromFirestore(firebaseUser.uid);
      return true;
    } catch (_) {
      // Firestore fetch failed but user is still authenticated —
      // build a minimal user object from Firebase Auth data
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

  // Creates a new Firebase Auth account with email + password.
  // Then saves the extra profile data (name, ethnicity, denomination)
  // to Firestore under /users/{uid} since Firebase Auth only stores
  // email and password — nothing else.
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
      // Step 1 — create the Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // Step 2 — update the display name in Firebase Auth
      await credential.user!.updateDisplayName(name);

      // Step 3 — save full profile to Firestore
      // This is the user's document that the app reads everywhere
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

      // Step 4 — send email verification
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

  // Signs in with Firebase Auth using email + password.
  // Firebase validates the credentials on their servers — the password
  // never touches your device storage.
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

  // Sends a real password reset email via Firebase.
  // The user gets a link in their inbox — no OTP needed,
  // Firebase handles the entire reset flow.
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

  // Signs out from Firebase — clears the session on the device.
  // Next app open, currentUser will be null and user goes to welcome screen.
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Updates the user's profile both in Firebase Auth and Firestore
  Future<void> updateProfile(reliq.User updatedUser) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _auth.currentUser!.updateDisplayName(updatedUser.name);
      await _db.collection('users').doc(uid).update(updatedUser.toJson());

      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _error = 'Could not update profile.';
      notifyListeners();
    }
  }

  // Reads the user's full profile from Firestore.
  // Called after sign in and on auto login.
  Future<void> _loadUserFromFirestore(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      _currentUser = reliq.User.fromJson({
        ...doc.data()!,
        'id': uid,
      });
    } else {
      // Document doesn't exist yet — use Firebase Auth data
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

  // Converts Firebase error codes into readable messages for the user.
  // Firebase returns specific error codes so we can give precise feedback.
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
        return 'Incorrect email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
