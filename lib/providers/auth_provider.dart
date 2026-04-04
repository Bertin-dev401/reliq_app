import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

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

  // Called once when the app starts (from main.dart).
  // Checks if a token is already saved — if yes, the user is still
  // logged in and we skip the welcome/signin screens entirely.
  Future<bool> tryAutoLogin() async {
    final token = await ApiService.getToken();
    if (token == null) return false;

    try {
      // Token exists — load the saved user data from local storage
      // so we don't need a network call just to restore the session.
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');
      final userDenomination = prefs.getString('user_denomination');

      if (userId == null || userEmail == null) return false;

      _currentUser = User(
        id: userId,
        email: userEmail,
        name: userName ?? '',
        denomination: userDenomination,
        joinedDate: DateTime.now(),
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Signs the user in via POST /auth/signin.
  // Falls back to local credential check if no backend is available yet.
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Skip network entirely until backend is ready
    if (!ApiService.backendReady) {
      return await _localSignIn(email, password);
    }

    try {
      final data = await _api.signIn(email, password);
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;
      if (token == null || userData == null) {
        _error = 'Invalid response from server.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      await ApiService.saveToken(token);
      await _saveUserLocally(userData);
      _currentUser = User.fromJson(userData);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      return await _localSignIn(email, password);
    }
  }

  // Checks the email + hashed password stored locally during signup.
  Future<bool> _localSignIn(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('local_email') ?? '';
      final storedPass = prefs.getString('local_password') ?? '';

      if (email.trim().toLowerCase() != storedEmail.toLowerCase() ||
          password != storedPass) {
        _error = 'Incorrect email or password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Credentials match — restore the user session
      final userId = prefs.getString('user_id') ?? 'local_user';
      final userName = prefs.getString('user_name') ?? '';
      final userDenomination = prefs.getString('user_denomination');

      // Issue a local token so tryAutoLogin works on next app open
      await ApiService.saveToken('local_token_$userId');

      _currentUser = User(
        id: userId,
        email: email,
        name: userName,
        denomination: userDenomination,
        joinedDate: DateTime.now(),
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Signs up via POST /auth/signup.
  // Falls back to local storage if no backend is available yet.
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

    // Skip network entirely until backend is ready
    if (!ApiService.backendReady) {
      return await _localSignUp(
        name: name,
        email: email,
        password: password,
        denomination: denomination,
      );
    }

    try {
      final data = await _api.signUp(
        name: name,
        email: email,
        password: password,
        ethnicity: ethnicity,
        denomination: denomination,
      );
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;
      if (token == null || userData == null) {
        _error = 'Invalid response from server.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      await ApiService.saveToken(token);
      await _saveUserLocally(userData);
      _currentUser = User.fromJson(userData);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      return await _localSignUp(
        name: name,
        email: email,
        password: password,
        denomination: denomination,
      );
    }
  }

  Future<bool> _localSignUp({
    required String name,
    required String email,
    required String password,
    required String denomination,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = 'local_${DateTime.now().millisecondsSinceEpoch}';

      // Store credentials for local sign in validation
      await prefs.setString('local_email', email.trim().toLowerCase());
      await prefs.setString('local_password', password);

      await prefs.setString('user_id', userId);
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_denomination', denomination);

      // Issue a local token
      await ApiService.saveToken('local_token_$userId');

      _currentUser = User(
        id: userId,
        email: email,
        name: name,
        denomination: denomination,
        joinedDate: DateTime.now(),
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Could not create account. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sends a password reset email via POST /auth/reset-password.
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

  // Verifies the OTP code sent to the user's email.
  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.verifyOtp(email, otp);
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

  // Clears the token, user data, and resets state.
  Future<void> signOut() async {
    await ApiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_denomination');
    await prefs.remove('local_email');
    await prefs.remove('local_password');
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    _currentUser = updatedUser;
    await _saveUserLocally(updatedUser.toJson());
    notifyListeners();
  }

  // Saves minimal user info locally so tryAutoLogin() can restore
  // the session without a network call on every app open.
  Future<void> _saveUserLocally(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userData['id']?.toString() ?? '');
    await prefs.setString('user_name', userData['name']?.toString() ?? '');
    await prefs.setString('user_email', userData['email']?.toString() ?? '');
    if (userData['denomination'] != null) {
      await prefs.setString('user_denomination', userData['denomination'].toString());
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
