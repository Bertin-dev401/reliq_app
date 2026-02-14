/// Bible-related data models
/// 
/// This file contains all models related to Bible content,
/// including verses, daily devotionals, and reading plans

/// Model representing a single Bible verse
class BibleVerse {
  final String id;
  final String book;
  final int chapter;
  final int verse;
  final String text;
  final String translation;
  final bool isBookmarked;
  final bool isHighlighted;

  BibleVerse({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    this.translation = 'KJV',
    this.isBookmarked = false,
    this.isHighlighted = false,
  });

  /// Create BibleVerse from JSON
  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      id: json['id'] ?? '',
      book: json['book'] ?? '',
      chapter: json['chapter'] ?? 1,
      verse: json['verse'] ?? 1,
      text: json['text'] ?? '',
      translation: json['translation'] ?? 'KJV',
      isBookmarked: json['is_bookmarked'] ?? false,
      isHighlighted: json['is_highlighted'] ?? false,
    );
  }

  /// Convert BibleVerse to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'translation': translation,
      'is_bookmarked': isBookmarked,
      'is_highlighted': isHighlighted,
    };
  }

  /// Get formatted verse reference (e.g., "John 3:16")
  String get reference => '$book $chapter:$verse';

  /// Create a copy with updated fields
  BibleVerse copyWith({
    String? id,
    String? book,
    int? chapter,
    int? verse,
    String? text,
    String? translation,
    bool? isBookmarked,
    bool? isHighlighted,
  }) {
    return BibleVerse(
      id: id ?? this.id,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}

/// Model representing the daily verse with reflection
class DailyVerse {
  final String id;
  final BibleVerse verse;
  final String reflection;
  final DateTime date;

  DailyVerse({
    required this.id,
    required this.verse,
    required this.reflection,
    required this.date,
  });

  /// Create DailyVerse from JSON
  factory DailyVerse.fromJson(Map<String, dynamic> json) {
    return DailyVerse(
      id: json['id'] ?? '',
      verse: BibleVerse.fromJson(json['verse'] ?? {}),
      reflection: json['reflection'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
    );
  }

  /// Convert DailyVerse to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verse': verse.toJson(),
      'reflection': reflection,
      'date': date.toIso8601String(),
    };
  }

  /// Get formatted date string
  String get formattedDate {
    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}

/// Model representing a Bible reading plan
class ReadingPlan {
  final String id;
  final String name;
  final String description;
  final int durationDays;
  final List<String> verseReferences;
  final DateTime? startDate;
  final int currentDay;

  ReadingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.verseReferences,
    this.startDate,
    this.currentDay = 0,
  });

  /// Create ReadingPlan from JSON
  factory ReadingPlan.fromJson(Map<String, dynamic> json) {
    return ReadingPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      verseReferences: json['verse_references'] != null
          ? List<String>.from(json['verse_references'])
          : [],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      currentDay: json['current_day'] ?? 0,
    );
  }

  /// Convert ReadingPlan to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration_days': durationDays,
      'verse_references': verseReferences,
      'start_date': startDate?.toIso8601String(),
      'current_day': currentDay,
    };
  }

  /// Calculate progress percentage
  double get progress {
    if (durationDays == 0) return 0.0;
    return (currentDay / durationDays) * 100;
  }

  /// Check if plan is completed
  bool get isCompleted => currentDay >= durationDays;
}
