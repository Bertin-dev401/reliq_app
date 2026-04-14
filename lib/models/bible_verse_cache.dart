import 'package:hive/hive.dart';

part 'bible_verse_cache.g.dart';

@HiveType(typeId: 0)
class BibleVerseCache extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String book;

  @HiveField(2)
  final int chapter;

  @HiveField(3)
  final int verse;

  @HiveField(4)
  final String text;

  @HiveField(5)
  final String version;

  @HiveField(6)
  final DateTime cachedAt;

  @HiveField(7)
  final bool isBookmarked;

  BibleVerseCache({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.version,
    this.cachedAt = const Duration(),
    this.isBookmarked = false,
  }) : cachedAt = cachedAt == const Duration() ? DateTime.now() : cachedAt;

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
