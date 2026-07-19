import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bible.dart';
import '../services/bible_service.dart';

class BibleProvider with ChangeNotifier {
  List<BibleVerse> _bookmarkedVerses = [];
  DailyVerse? _dailyVerse;
  List<BibleVerse> _currentChapter = [];
  bool _isLoading = false;
  String? _error;

  List<BibleVerse> get bookmarkedVerses => _bookmarkedVerses;
  DailyVerse? get dailyVerse => _dailyVerse;
  List<BibleVerse> get currentChapter => _currentChapter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // A pool of well-known verses. The daily verse is picked by taking
  // today's day-of-year and using it as an index into this list.
  // This means it rotates daily without any backend needed.
  static const List<String> _dailyVerseRefs = [
    'john+3:16', 'psalm+23:1', 'philippians+4:13', 'romans+8:28',
    'jeremiah+29:11', 'proverbs+3:5', 'isaiah+40:31', 'matthew+6:33',
    'psalm+46:1', 'john+14:6', 'romans+5:8', 'ephesians+2:8',
    'hebrews+11:1', 'james+1:2', '1+corinthians+13:4', 'psalm+119:105',
    'matthew+11:28', 'john+10:10', 'romans+12:2', 'galatians+5:22',
    'psalm+27:1', 'isaiah+41:10', 'john+16:33', 'proverbs+31:25',
    'psalm+91:1', 'matthew+5:16', 'colossians+3:23', 'joshua+1:9',
    'psalm+34:8', 'john+15:13', 'romans+8:38', 'ephesians+3:20',
  ];

  // Loads the daily verse from bible-api.com.
  // First checks if today's verse is already cached in SharedPreferences
  // to avoid unnecessary network calls.
  Future<void> loadDailyVerse() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      final cachedKey = prefs.getString('daily_verse_date');
      final cachedVerse = prefs.getString('daily_verse_data');

      // Use cached verse if it's from today
      if (cachedKey == todayKey && cachedVerse != null) {
        final json = jsonDecode(cachedVerse);
        _dailyVerse = _parseDailyVerse(json);
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Pick verse reference based on day of year
      final dayOfYear = int.parse(
        today.difference(DateTime(today.year, 1, 1)).inDays.toString(),
      );
      final ref = _dailyVerseRefs[dayOfYear % _dailyVerseRefs.length];

      final data = await getVerse(ref);

      // Cache it so we don't call the API again today
      await prefs.setString('daily_verse_date', todayKey);
      await prefs.setString('daily_verse_data', jsonEncode(data));
      await prefs.setString('daily_verse_latest', jsonEncode(data));

      _dailyVerse = _parseDailyVerse(data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final latestVerse = prefs.getString('daily_verse_latest');
      if (latestVerse != null) {
        _dailyVerse = _parseDailyVerse(jsonDecode(latestVerse));
        _error = null;
      } else {
        _error = 'Could not load daily verse. Check your connection.';
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetches a full chapter from bible-api.com.
  // Reference format: "john+3" or "genesis+1"
  Future<void> loadChapter(String bookAndChapter) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'bible_chapter_$bookAndChapter';
      final data = await getVerse(bookAndChapter);
      await prefs.setString(cacheKey, jsonEncode(data));
      final verses = data['verses'] as List? ?? [];
      _currentChapter = verses.map((v) {
        return BibleVerse(
          id: '${v['book_id']}_${v['chapter']}_${v['verse']}',
          book: v['book_name'] ?? '',
          chapter: v['chapter'] ?? 0,
          verse: v['verse'] ?? 0,
          text: (v['text'] as String? ?? '').trim(),
        );
      }).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'bible_chapter_$bookAndChapter';
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        final data = jsonDecode(cached);
        final verses = data['verses'] as List? ?? [];
        _currentChapter = verses.map((v) {
          return BibleVerse(
            id: '${v['book_id']}_${v['chapter']}_${v['verse']}',
            book: v['book_name'] ?? '',
            chapter: v['chapter'] ?? 0,
            verse: v['verse'] ?? 0,
            text: (v['text'] as String? ?? '').trim(),
          );
        }).toList();
        _error = null;
      } else {
        _error = 'Could not load chapter. Check your connection.';
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // Loads bookmarks from SharedPreferences
  Future<void> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('bookmarked_verses');
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _bookmarkedVerses = list.map((v) => BibleVerse.fromJson(v)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> toggleBookmark(BibleVerse verse) async {
    final index = _bookmarkedVerses.indexWhere((v) => v.id == verse.id);
    if (index != -1) {
      _bookmarkedVerses.removeAt(index);
    } else {
      _bookmarkedVerses.add(verse);
    }
    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'bookmarked_verses',
      jsonEncode(_bookmarkedVerses.map((v) => v.toJson()).toList()),
    );
    notifyListeners();
  }

  bool isBookmarked(String verseId) =>
      _bookmarkedVerses.any((v) => v.id == verseId);

  DailyVerse _parseDailyVerse(Map data) {
    final verses = data['verses'] as List? ?? [];
    final text = verses.isNotEmpty
        ? (verses.first['text'] as String? ?? '').trim()
        : data['text'] as String? ?? '';
    final reference = data['reference'] as String? ?? '';

    return DailyVerse(
      id: reference,
      verse: BibleVerse(
        id: reference,
        book: reference.split(' ').first,
        chapter: 0,
        verse: 0,
        text: text,
        reference: reference,
      ),
      reflection: '',
      date: DateTime.now(),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
