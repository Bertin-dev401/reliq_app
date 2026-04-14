import 'package:hive_flutter/hive_flutter.dart';
import '../models/bible_verse_cache.dart';

/// Service for caching Bible verses locally for offline access
class BibleCacheService {
  static const String _boxName = 'bible_verses';
  static const String _bookmarksBoxName = 'bible_bookmarks';
  
  late Box<BibleVerseCache> _verseBox;
  late Box<String> _bookmarksBox;
  bool _isInitialized = false;

  /// Initialize the Hive boxes
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _verseBox = await Hive.openBox<BibleVerseCache>(_boxName);
      _bookmarksBox = await Hive.openBox<String>(_bookmarksBoxName);
      _isInitialized = true;
    } catch (e) {
      print('Error initializing Bible cache: $e');
      rethrow;
    }
  }

  /// Cache a single verse
  Future<void> cacheVerse(BibleVerseCache verse) async {
    if (!_isInitialized) await initialize();
    await _verseBox.put(verse.id, verse);
  }

  /// Cache multiple verses
  Future<void> cacheVerses(List<BibleVerseCache> verses) async {
    if (!_isInitialized) await initialize();
    
    final Map<String, BibleVerseCache> data = {};
    for (var verse in verses) {
      data[verse.id] = verse;
    }
    await _verseBox.putAll(data);
  }

  /// Get a verse by ID
  Future<BibleVerseCache?> getVerse(String id) async {
    if (!_isInitialized) await initialize();
    return _verseBox.get(id);
  }

  /// Get verses by book name
  Future<List<BibleVerseCache>> getVersesByBook(String book) async {
    if (!_isInitialized) await initialize();
    
    final verses = _verseBox.values
        .where((verse) => verse.book.toLowerCase() == book.toLowerCase())
        .toList();
    return verses;
  }

  /// Get verses by book and chapter
  Future<List<BibleVerseCache>> getVersesByChapter(String book, int chapter) async {
    if (!_isInitialized) await initialize();
    
    final verses = _verseBox.values
        .where((verse) =>
            verse.book.toLowerCase() == book.toLowerCase() &&
            verse.chapter == chapter)
        .toList();
    return verses;
  }

  /// Bookmark a verse
  Future<void> bookmarkVerse(String verseId) async {
    if (!_isInitialized) await initialize();
    
    final verse = _verseBox.get(verseId);
    if (verse != null) {
      final updatedVerse = BibleVerseCache(
        id: verse.id,
        book: verse.book,
        chapter: verse.chapter,
        verse: verse.verse,
        text: verse.text,
        version: verse.version,
        cachedAt: verse.cachedAt,
        isBookmarked: true,
      );
      await _verseBox.put(verseId, updatedVerse);
      await _bookmarksBox.put(verseId, verseId);
    }
  }

  /// Remove bookmark from a verse
  Future<void> removeBookmark(String verseId) async {
    if (!_isInitialized) await initialize();
    
    final verse = _verseBox.get(verseId);
    if (verse != null) {
      final updatedVerse = BibleVerseCache(
        id: verse.id,
        book: verse.book,
        chapter: verse.chapter,
        verse: verse.verse,
        text: verse.text,
        version: verse.version,
        cachedAt: verse.cachedAt,
        isBookmarked: false,
      );
      await _verseBox.put(verseId, updatedVerse);
      await _bookmarksBox.delete(verseId);
    }
  }

  /// Get all bookmarked verses
  Future<List<BibleVerseCache>> getBookmarkedVerses() async {
    if (!_isInitialized) await initialize();
    
    final bookmarkedIds = _bookmarksBox.values.toList();
    final bookmarked = <BibleVerseCache>[];
    
    for (String id in bookmarkedIds) {
      final verse = _verseBox.get(id);
      if (verse != null) {
        bookmarked.add(verse);
      }
    }
    
    return bookmarked;
  }

  /// Check if verse is bookmarked
  Future<bool> isVerseBookmarked(String verseId) async {
    if (!_isInitialized) await initialize();
    return _bookmarksBox.containsKey(verseId);
  }

  /// Search verses by text
  Future<List<BibleVerseCache>> searchVerses(String query) async {
    if (!_isInitialized) await initialize();
    
    final lowerQuery = query.toLowerCase();
    final verses = _verseBox.values
        .where((verse) =>
            verse.text.toLowerCase().contains(lowerQuery) ||
            verse.book.toLowerCase().contains(lowerQuery))
        .toList();
    
    return verses;
  }

  /// Clear all cached verses
  Future<void> clearCache() async {
    if (!_isInitialized) await initialize();
    await _verseBox.clear();
  }

  /// Clear bookmarks
  Future<void> clearBookmarks() async {
    if (!_isInitialized) await initialize();
    await _bookmarksBox.clear();
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    if (!_isInitialized) await initialize();
    
    final bookmarkedCount = _bookmarksBox.length;
    final totalVerses = _verseBox.length;
    
    return {
      'totalVerses': totalVerses,
      'bookmarkedVerses': bookmarkedCount,
      'oldestCachedAt': _verseBox.values.isEmpty
          ? null
          : _verseBox.values
              .reduce((a, b) => a.cachedAt.isBefore(b.cachedAt) ? a : b)
              .cachedAt,
      'newestCachedAt': _verseBox.values.isEmpty
          ? null
          : _verseBox.values
              .reduce((a, b) => a.cachedAt.isAfter(b.cachedAt) ? a : b)
              .cachedAt,
    };
  }
}
