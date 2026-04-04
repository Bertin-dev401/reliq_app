import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  int get currentStreak => _currentStreak;
  List<DateTime> get completedDates => _completedDates;
  bool get todayCompleted => _todayCompleted;
  Map<String, bool> get todayActivities => Map.unmodifiable(_todayActivities);
  String? get error => _error;
  int get activitiesCompletedToday =>
      _todayActivities.values.where((v) => v).length;
  int get totalActivities => _todayActivities.length;
  bool get allActivitiesCompleted =>
      _todayActivities.values.every((v) => v);

  // Loads streak data from SharedPreferences on app start.
  // Also checks if the user missed a day and resets the streak if so.
  Future<void> loadStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentStreak = prefs.getInt('streak_count') ?? 0;

      final datesRaw = prefs.getString('streak_dates');
      if (datesRaw != null) {
        _completedDates = (jsonDecode(datesRaw) as List)
            .map((d) => DateTime.parse(d as String))
            .toList();
      }

      // Load today's activity completion state
      final activitiesRaw = prefs.getString('today_activities');
      final savedDate = prefs.getString('activities_date');
      final todayStr = _dateKey(DateTime.now());

      if (activitiesRaw != null && savedDate == todayStr) {
        // Same day — restore activity state
        final map = jsonDecode(activitiesRaw) as Map<String, dynamic>;
        _todayActivities = map.map((k, v) => MapEntry(k, v as bool));
      } else {
        // New day — reset activities
        _todayActivities.updateAll((_, __) => false);
        await prefs.setString('activities_date', todayStr);
      }

      await checkStreakStatus();
      _checkTodayStatus();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Checks if the streak should be reset because the user missed a day.
  Future<void> checkStreakStatus() async {
    if (_completedDates.isEmpty) return;
    final now = DateTime.now();
    final today = _dateOnly(now);
    final last = _dateOnly(_completedDates.last);
    final diff = today.difference(last).inDays;
    if (diff > 1) {
      // Missed at least one day — reset streak
      await _resetStreak();
    } else if (diff == 1) {
      // New day — reset today's activities but keep streak
      _todayCompleted = false;
      _todayActivities.updateAll((_, __) => false);
      notifyListeners();
    }
  }

  Future<void> completeActivity(String key) async {
    if (!_todayActivities.containsKey(key)) return;
    _todayActivities[key] = true;
    await _saveActivities();
    if (allActivitiesCompleted && !_todayCompleted) {
      await completeToday();
    }
    notifyListeners();
  }

  Future<void> completeToday() async {
    if (_todayCompleted) return;
    _todayCompleted = true;
    _currentStreak++;
    _completedDates.add(DateTime.now());
    await _persist();
    notifyListeners();
  }

  void _checkTodayStatus() {
    final today = _dateOnly(DateTime.now());
    _todayCompleted = _completedDates.any(
      (d) => _dateOnly(d) == today,
    );
  }

  Future<void> _resetStreak() async {
    _currentStreak = 0;
    _todayCompleted = false;
    _completedDates.clear();
    _todayActivities.updateAll((_, __) => false);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak_count', _currentStreak);
    await prefs.setString(
      'streak_dates',
      jsonEncode(_completedDates.map((d) => d.toIso8601String()).toList()),
    );
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('today_activities', jsonEncode(_todayActivities));
    await prefs.setString('activities_date', _dateKey(DateTime.now()));
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String getEncouragementMessage() {
    if (_currentStreak == 0) return 'Start your spiritual journey today! 🌱';
    if (_currentStreak < 7) return 'Great start! Keep going! 💪';
    if (_currentStreak < 30) return "You're on fire! $_currentStreak days strong! 🔥";
    if (_currentStreak < 100) return 'Amazing dedication! $_currentStreak days! 🌟';
    return 'Legendary streak! $_currentStreak days! 👑';
  }

  String getActivityName(String key) {
    switch (key) {
      case 'daily_verse': return 'Read Daily Verse';
      case 'prayer':      return 'Pray for 5 minutes';
      case 'testimony':   return 'Share a testimony';
      default:            return 'Activity';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
