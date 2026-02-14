/// Application-wide constants
/// 
/// This file contains all constant values used throughout the app.
/// Update these values to customize the app for your needs.

class AppConstants {
  // ==================== App Info ====================
  static const String appName = 'FaithConnect';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Grow your faith together';

  // ==================== API ====================
  /// Backend API base URL - UPDATE THIS
  static const String apiBaseUrl = 'https://your-api-domain.com/api/v1';
  
  /// API timeout duration
  static const Duration apiTimeout = Duration(seconds: 30);

  // ==================== Denominations ====================
  static const List<String> denominations = [
    'All',
    'Catholic',
    'Protestant',
    'Anglican',
    'Mormon',
    'Orthodox',
    'Baptist',
    'Methodist',
    'Presbyterian',
    'Lutheran',
    'Pentecostal',
    'Other',
  ];

  // ==================== Product Categories ====================
  static const List<String> productCategories = [
    'All',
    'Jewelry',
    'Books',
    'Home Decor',
    'Clothing',
    'Art',
    'Accessories',
    'Other',
  ];

  // ==================== Currency ====================
  static const String defaultCurrency = 'RWF';
  static const String currencySymbol = 'RWF';

  // ==================== Pagination ====================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ==================== Streak ====================
  /// Activities required to maintain streak
  static const List<String> streakActivities = [
    'daily_verse',
    'prayer',
    'testimony',
  ];

  static const Map<String, String> streakActivityNames = {
    'daily_verse': 'Read Daily Verse',
    'prayer': 'Pray for 5 minutes',
    'testimony': 'Share a testimony',
  };

  // ==================== Bible ====================
  /// Available Bible translations
  static const List<String> bibleTranslations = [
    'KJV',  // King James Version
    'NIV',  // New International Version
    'ESV',  // English Standard Version
    'NKJV', // New King James Version
    'NLT',  // New Living Translation
  ];

  /// Books of the Bible
  static const List<String> oldTestamentBooks = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
    'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
    '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles',
    'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
    'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah',
    'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel',
    'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk',
    'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
  ];

  static const List<String> newTestamentBooks = [
    'Matthew', 'Mark', 'Luke', 'John', 'Acts',
    'Romans', '1 Corinthians', '2 Corinthians', 'Galatians',
    'Ephesians', 'Philippians', 'Colossians',
    '1 Thessalonians', '2 Thessalonians',
    '1 Timothy', '2 Timothy', 'Titus', 'Philemon',
    'Hebrews', 'James', '1 Peter', '2 Peter',
    '1 John', '2 John', '3 John', 'Jude', 'Revelation',
  ];

  // ==================== Quiz ====================
  /// Quiz difficulty levels
  static const List<String> quizDifficulties = [
    'Easy',
    'Medium',
    'Hard',
  ];

  /// Quiz categories
  static const List<String> quizCategories = [
    'Old Testament',
    'New Testament',
    'Life of Jesus',
    'Prophets',
    'Miracles',
    'Parables',
    'General Knowledge',
  ];

  // ==================== Events ====================
  /// Event types
  static const List<String> eventTypes = [
    'Worship Service',
    'Bible Study',
    'Prayer Meeting',
    'Youth Gathering',
    'Community Outreach',
    'Conference',
    'Workshop',
    'Other',
  ];

  // ==================== Storage Keys ====================
  /// SharedPreferences keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyCurrentStreak = 'current_streak';
  static const String keyCompletedDates = 'completed_dates';
  static const String keyDarkMode = 'dark_mode';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyLanguage = 'language';

  // ==================== External Links ====================
  static const String privacyPolicyUrl = 'https://faithconnect.rw/privacy';
  static const String termsOfServiceUrl = 'https://faithconnect.rw/terms';
  static const String supportEmail = 'support@faithconnect.rw';
  static const String instagramUrl = 'https://instagram.com/faithconnect';
  static const String facebookUrl = 'https://facebook.com/faithconnect';
  static const String twitterUrl = 'https://twitter.com/faithconnect';

  // ==================== Features Flags ====================
  /// Enable/disable features
  static const bool enablePremiumFeatures = false;
  static const bool enableLiveStreaming = true;
  static const bool enableDonations = true;
  static const bool enableMarketplace = true;
  static const bool enableChat = true;

  // ==================== Image Placeholders ====================
  static const String placeholderProfileImage = 'https://via.placeholder.com/150';
  static const String placeholderCoverImage = 'https://via.placeholder.com/800x400';
  static const String placeholderProductImage = 'https://via.placeholder.com/400';

  // ==================== Validation ====================
  /// Email validation regex
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Password minimum length
  static const int minPasswordLength = 6;

  /// Maximum file upload size (in bytes)
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB

  // ==================== Animation Durations ====================
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // ==================== Messages ====================
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String successMessage = 'Success!';
}
