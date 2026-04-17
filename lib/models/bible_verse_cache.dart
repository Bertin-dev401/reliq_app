import 'package:hive/hive.dart';

/// BibleVerseCache model for offline caching of Bible verses
/// Stores verse data locally using Hive for quick access
class BibleVerseCache {
  final String id;
  final String book;
  final int chapter;
  final int verse;
  final String text;
  final String version;
  final DateTime cachedAt;
  final bool isBookmarked;

  BibleVerseCache({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.version,
    DateTime? cachedAt,
    this.isBookmarked = false,
  }) : cachedAt = cachedAt ?? DateTime.now();

  factory BibleVerseCache.fromJson(Map<String, dynamic> json) {
    return BibleVerseCache(
      id: json['id'] ?? '',
      book: json['book'] ?? '',
      chapter: json['chapter'] ?? 0,
      verse: json['verse'] ?? 0,
      text: json['text'] ?? '',
      version: json['version'] ?? 'KJV',
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'])
          : DateTime.now(),
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'version': version,
      'cachedAt': cachedAt.toIso8601String(),
      'isBookmarked': isBookmarked,
    };
  }
}
