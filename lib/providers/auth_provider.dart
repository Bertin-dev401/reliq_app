import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as reliq;
import '../utils/firestore_utils.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  reliq.User? _currentUser;
  bool _isLoading = false;
  String? _error;

  reliq.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _auth.currentUser != null;

  Future<bool> tryAutoLogin() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return false;

    try {
      await _loadUserFromFirestore(firebaseUser.uid);
    } catch (_) {
      _currentUser = _fallbackUser(firebaseUser);
      notifyListeners();
    }
    return true;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String ethnicity,
    required String denomination,
  }) async {
    _setLoading(true);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user!;
      await firebaseUser.updateDisplayName(name);

      // The user document stores app profile fields Firebase Auth does not.
      await _db.collection('users').doc(firebaseUser.uid).set({
        'id': firebaseUser.uid,
        'name': name.trim(),
        'email': email.trim(),
        'ethnicity': ethnicity,
        'denomination': denomination,
        'profile_image': null,
        'bio': null,
        'location': null,
        'favorite_verses': <String>[],
        'prayer_goals': <String>[],
        'streak_count': 0,
        'joined_date': FieldValue.serverTimestamp(),
        'is_premium': false,
      });

      await firebaseUser.sendEmailVerification();
      await _loadUserFromFirestore(firebaseUser.uid);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleFirebaseError(e);
      _setLoading(false);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _loadUserFromFirestore(credential.user!.uid);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleFirebaseError(e);
      _setLoading(false);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleFirebaseError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(reliq.User updatedUser) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    try {
      await firebaseUser.updateDisplayName(updatedUser.name);

      // Merge keeps server-owned fields such as joined_date intact.
      await _db.collection('users').doc(firebaseUser.uid).set({
        'name': updatedUser.name,
        'profile_image': updatedUser.profileImage,
        'denomination': updatedUser.denomination,
        'bio': updatedUser.bio,
        'location': updatedUser.location,
        'favorite_verses': updatedUser.favoriteVerses,
        'prayer_goals': updatedUser.prayerGoals,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _currentUser = updatedUser;
      notifyListeners();
    } catch (_) {
      _error = 'Could not update profile.';
      notifyListeners();
    }
  }

  Future<void> _loadUserFromFirestore(String uid) async {
    final doc = await _db.collection('users').doc(uid).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Profile load timed out'),
        );

    if (doc.exists && doc.data() != null) {
      _currentUser = reliq.User.fromJson(withSnapshotId(doc));
    } else {
      _currentUser = _fallbackUser(_auth.currentUser!);
    }
    notifyListeners();
  }

  reliq.User _fallbackUser(User firebaseUser) {
    return reliq.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? 'Reliq User',
      joinedDate: DateTime.now(),
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
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
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      case 'operation-not-allowed':
        return 'Sign in method not enabled. Contact support.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
