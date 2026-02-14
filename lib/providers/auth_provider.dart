import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock user data
      _currentUser = User(
        id: '1',
        email: email,
        name: 'John Doe',
        denomination: 'Catholic',
        joinedDate: DateTime.now(),
        streakCount: 5,
      );
      
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = User(
        id: '1',
        email: email,
        name: name,
        joinedDate: DateTime.now(),
      );
      
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile(User updatedUser) async {
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<void> updateStreak(int newStreak) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(streakCount: newStreak);
      notifyListeners();
    }
  }
}
