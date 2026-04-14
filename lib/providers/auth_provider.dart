import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  final ApiService _api = ApiService();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize auth listener when app starts
  void initializeAuthListener() {
    _api.authStateChanges.listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _isAuthenticated = false;
      } else {
        _isAuthenticated = true;
        // Load user profile from Firestore
        try {
          final profile = await _api.getUserProfile(firebaseUser.uid);
          if (profile != null) {
            _currentUser = User(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              name: profile['name'] ?? firebaseUser.displayName ?? '',
              denomination: profile['denomination'],
              joinedDate: DateTime.parse(profile['createdAt'].toDate().toString()),
            );
          }
        } catch (e) {
          print('Error loading user profile: $e');
        }
      }
      notifyListeners();
    });
  }

  /// Try to restore session on app startup
  /// Returns true if user is already authenticated
  Future<bool> tryAutoLogin() async {
    try {
      final currentFirebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser != null) {
        _isAuthenticated = true;
        
        // Load user profile from Firestore
        final profile = await _api.getUserProfile(currentFirebaseUser.uid);
        if (profile != null) {
          _currentUser = User(
            id: currentFirebaseUser.uid,
            email: currentFirebaseUser.email ?? '',
            name: profile['name'] ?? currentFirebaseUser.displayName ?? '',
            denomination: profile['denomination'],
            joinedDate: DateTime.parse(profile['createdAt'].toDate().toString()),
          );
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error during auto login: $e');
      return false;
    }
  }

  /// Sign in with email and password
  /// Uses Firebase Authentication
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.signIn(email, password);
      
      if (result['success'] != true) {
        _error = result['message'] ?? 'Sign in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final token = result['token'] as String?;
      final userData = result['user'] as Map<String, dynamic>?;
      
      if (token == null || userData == null) {
        _error = 'Invalid response from server';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await ApiService.saveToken(token);
      await _saveUserLocally(userData);
      
      _currentUser = User(
        id: userData['uid'] ?? '',
        email: userData['email'] ?? '',
        name: userData['name'] ?? '',
        denomination: userData['denomination'],
        joinedDate: DateTime.now(),
      );
      
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email, password, and user details
  /// Uses Firebase Authentication and Firestore
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
      final result = await _api.signUp(
        name: name,
        email: email,
        password: password,
        ethnicity: ethnicity,
        denomination: denomination,
      );

      if (result['success'] != true) {
        _error = result['message'] ?? 'Sign up failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final token = result['token'] as String?;
      final userData = result['user'] as Map<String, dynamic>?;
      
      if (token == null || userData == null) {
        _error = 'Invalid response from server';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await ApiService.saveToken(token);
      await _saveUserLocally(userData);
      
      _currentUser = User(
        id: userData['uid'] ?? '',
        email: userData['email'] ?? '',
        name: userData['name'] ?? '',
        denomination: userData['denomination'],
        joinedDate: DateTime.now(),
      );
      
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset password via email
  /// Sends password reset email to user
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out current user
  /// Clears all authentication data and user session
  Future<void> signOut() async {
    try {
      await _api.signOut();
      await ApiService.clearToken();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_denomination');
      
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _error = 'Sign out failed: $e';
      notifyListeners();
    }
  }

  /// Update user profile
  /// Updates user data in Firestore
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      if (_currentUser == null) {
        _error = 'No user is currently signed in';
        return false;
      }

      await _api.updateUserProfile(_currentUser!.id, updates);
      
      // Update local user object
      _currentUser = User(
        id: _currentUser!.id,
        email: updates['email'] ?? _currentUser!.email,
        name: updates['name'] ?? _currentUser!.name,
        denomination: updates['denomination'] ?? _currentUser!.denomination,
        joinedDate: _currentUser!.joinedDate,
      );
      
      await _saveUserLocally({
        'uid': _currentUser!.id,
        'email': _currentUser!.email,
        'name': _currentUser!.name,
        'denomination': _currentUser!.denomination,
      });
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete user account permanently
  /// This is irreversible - deletes all user data
  Future<bool> deleteAccount() async {
    try {
      if (_currentUser == null) {
        _error = 'No user is currently signed in';
        return false;
      }

      await _api.deleteAccount(_currentUser!.id);
      
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Save user info locally for quick access
  /// Used to restore session on app restart
  Future<void> _saveUserLocally(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userData['uid']?.toString() ?? '');
      await prefs.setString('user_name', userData['name']?.toString() ?? '');
      await prefs.setString('user_email', userData['email']?.toString() ?? '');
      if (userData['denomination'] != null) {
        await prefs.setString('user_denomination', userData['denomination'].toString());
      }
    } catch (e) {
      print('Error saving user locally: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
