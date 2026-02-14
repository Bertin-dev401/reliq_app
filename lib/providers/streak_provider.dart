import 'package:flutter/material.dart';

/// Provider for managing daily spiritual streaks and routines
/// 
/// Responsibilities:
/// - Track daily spiritual activities
/// - Maintain streak counts
/// - Manage routine completion
/// - Provide motivation and encouragement
class StreakProvider with ChangeNotifier {
  int _currentStreak = 0;
  List<DateTime> _completedDates = [];
  bool _todayCompleted = false;
  Map<String, bool> _todayActivities = {
    'daily_verse': false,
    'prayer': false,
    'testimony': false,
  };
  String? _error;

  // Getters
  int get currentStreak => _currentStreak;
  List<DateTime> get completedDates => _completedDates;
  bool get todayCompleted => _todayCompleted;
  Map<String, bool> get todayActivities => _todayActivities;
  String? get error => _error;

  /// Calculate total activities completed today
  int get activitiesCompletedToday {
    return _todayActivities.values.where((completed) => completed).length;
  }

  /// Calculate total activities available
  int get totalActivities => _todayActivities.length;

  /// Check if all activities are completed
  bool get allActivitiesCompleted {
    return _todayActivities.values.every((completed) => completed);
  }

  /// Load streak data from local storage
  /// TODO: Implement with SharedPreferences or Hive
  Future<void> loadStreak() async {
    try {
      // TODO: Load from local storage
      // Example:
      // final prefs = await SharedPreferences.getInstance();
      // _currentStreak = prefs.getInt('current_streak') ?? 0;
      // final datesJson = prefs.getString('completed_dates');
      // if (datesJson != null) {
      //   _completedDates = (jsonDecode(datesJson) as List)
      //       .map((date) => DateTime.parse(date))
      //       .toList();
      // }
      
      // Mock data for demonstration
      _currentStreak = 5;
      _completedDates = List.generate(
        5,
        (index) => DateTime.now().subtract(Duration(days: index)),
      );
      
      // Check if today is already completed
      _checkTodayStatus();
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Check if user has completed activities today
  void _checkTodayStatus() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    _todayCompleted = _completedDates.any((date) {
      final completedDate = DateTime(date.year, date.month, date.day);
      return completedDate.isAtSameMomentAs(todayDate);
    });
  }

  /// Mark a specific activity as completed
  Future<void> completeActivity(String activityKey) async {
    try {
      if (_todayActivities.containsKey(activityKey)) {
        _todayActivities[activityKey] = true;
        
        // Check if all activities are now completed
        if (allActivitiesCompleted && !_todayCompleted) {
          await completeToday();
        }
        
        // TODO: Save to local storage
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Mark today as completed and update streak
  Future<void> completeToday() async {
    try {
      if (!_todayCompleted) {
        _todayCompleted = true;
        _currentStreak++;
        _completedDates.add(DateTime.now());
        
        // TODO: Save to local storage
        // Example:
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setInt('current_streak', _currentStreak);
        // await prefs.setString('completed_dates', 
        //     jsonEncode(_completedDates.map((d) => d.toIso8601String()).toList()));
        
        // TODO: Optionally sync with backend
        // await ApiService.updateStreak(_currentStreak);
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Reset streak (usually happens when user misses a day)
  Future<void> resetStreak() async {
    try {
      _currentStreak = 0;
      _todayCompleted = false;
      _completedDates.clear();
      _todayActivities.updateAll((key, value) => false);
      
      // TODO: Save to local storage
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Check and update streak status
  /// Call this when app opens to check if streak should be reset
  Future<void> checkStreakStatus() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (_completedDates.isEmpty) {
        return;
      }
      
      final lastCompleted = _completedDates.last;
      final lastCompletedDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );
      
      final daysDifference = today.difference(lastCompletedDate).inDays;
      
      // If more than 1 day has passed, reset streak
      if (daysDifference > 1) {
        await resetStreak();
      }
      // If it's a new day, reset today's activities
      else if (daysDifference == 1) {
        _todayCompleted = false;
        _todayActivities.updateAll((key, value) => false);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Get encouragement message based on streak
  String getEncouragementMessage() {
    if (_currentStreak == 0) {
      return "Start your spiritual journey today! 🌱";
    } else if (_currentStreak < 7) {
      return "Great start! Keep going! 💪";
    } else if (_currentStreak < 30) {
      return "You're on fire! ${_currentStreak} days strong! 🔥";
    } else if (_currentStreak < 100) {
      return "Amazing dedication! ${_currentStreak} days! 🌟";
    } else {
      return "Legendary streak! ${_currentStreak} days! 👑";
    }
  }

  /// Get activity name
  String getActivityName(String key) {
    switch (key) {
      case 'daily_verse':
        return 'Read Daily Verse';
      case 'prayer':
        return 'Pray for 5 minutes';
      case 'testimony':
        return 'Share a testimony';
      default:
        return 'Activity';
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
