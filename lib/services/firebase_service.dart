import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';

/// Firebase initialization and configuration service
/// Handles all Firebase setup and provides centralized access to Firebase services
class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

  /// Initialize Firebase
  /// Call this in main() before running the app
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
      
      // Enable offline persistence for Firestore
      await firestore.enableNetwork();
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print('✅ Firestore offline persistence enabled');
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// Get current authenticated user
  static User? get currentUser => auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get user ID (throws if not authenticated)
  static String get userId {
    if (currentUser == null) {
      throw Exception('User is not authenticated');
    }
    return currentUser!.uid;
  }

  /// Sign out user
  static Future<void> signOut() async {
    try {
      await auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out failed: $e');
      rethrow;
    }
  }

  /// Delete user account and data
  static Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Delete user document from Firestore
      await firestore.collection('users').doc(user.uid).delete();
      print('✅ User data deleted from Firestore');

      // Delete user from Firebase Auth
      await user.delete();
      print('✅ User account deleted from Firebase Auth');
    } catch (e) {
      print('❌ Account deletion failed: $e');
      rethrow;
    }
  }

  /// Get user profile document reference
  static DocumentReference<Map<String, dynamic>> userDoc() {
    return firestore.collection('users').doc(userId);
  }

  /// Get collection reference
  static CollectionReference<Map<String, dynamic>> collection(String name) {
    return firestore.collection(name);
  }

  /// Batch write operation
  static WriteBatch batch() {
    return firestore.batch();
  }

  /// Get storage reference for user files
  static Reference userStorageRef() {
    return storage.ref('users/$userId');
  }

  /// Get storage reference for a specific folder
  static Reference storageRef(String path) {
    return storage.ref(path);
  }
}

/// Firestore Database Service
/// Provides centralized methods for all database operations
class FirestoreService {
  final _firestore = FirebaseService.firestore;

  // ==================== USERS ====================

  /// Create user document in Firestore
  Future<void> createUserDocument({
    required String userId,
    required String email,
    required String name,
    required String denomination,
    required String ethnicity,
    required String theme,
    String? profileImage,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'email': email,
        'name': name,
        'denomination': denomination,
        'ethnicity': ethnicity,
        'userTheme': theme,
        'profileImage': profileImage,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'streak': 0,
        'streakLastDate': null,
        'phone': null,
        'location': null,
        'bio': null,
      });
      print('✅ User document created for $userId');
    } catch (e) {
      print('❌ Error creating user document: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(data);
      print('✅ User profile updated');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  /// Delete user profile and all related data
  Future<void> deleteUserProfile(String userId) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
      print('✅ User profile deleted');
    } catch (e) {
      print('❌ Error deleting user profile: $e');
      rethrow;
    }
  }

  // ==================== BIBLE VERSES ====================

  /// Cache Bible verse to Firestore (for syncing across devices)
  Future<void> saveBibleBookmark({
    required String userId,
    required String book,
    required int chapter,
    required int verse,
    required String text,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bibleBookmarks')
          .add({
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'text': text,
        'savedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Bible verse bookmarked');
    } catch (e) {
      print('❌ Error bookmarking verse: $e');
      rethrow;
    }
  }

  /// Get user's bookmarked verses
  Future<List<Map<String, dynamic>>> getBibleBookmarks(String userId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bibleBookmarks')
          .orderBy('savedAt', descending: true)
          .get();
      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Error fetching bookmarks: $e');
      rethrow;
    }
  }

  // ==================== COMMUNITY POSTS ====================

  /// Create community post
  Future<String> createCommunityPost({
    required String userId,
    required String title,
    required String content,
    required String category,
    List<String>? imageUrls,
  }) async {
    try {
      final docRef = await _firestore.collection('communityPosts').add({
        'userId': userId,
        'title': title,
        'content': content,
        'category': category,
        'imageUrls': imageUrls ?? [],
        'likes': 0,
        'comments': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Community post created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating community post: $e');
      rethrow;
    }
  }

  /// Get community posts (paginated)
  Future<List<Map<String, dynamic>>> getCommunityPosts({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('communityPosts')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      print('❌ Error fetching community posts: $e');
      rethrow;
    }
  }

  /// Add comment to community post
  Future<void> addCommentToPost({
    required String postId,
    required String userId,
    required String comment,
  }) async {
    try {
      await _firestore
          .collection('communityPosts')
          .doc(postId)
          .collection('comments')
          .add({
        'userId': userId,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Increment comment count
      await _firestore.collection('communityPosts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });

      print('✅ Comment added to post');
    } catch (e) {
      print('❌ Error adding comment: $e');
      rethrow;
    }
  }

  // ==================== MARKETPLACE ====================

  /// Create marketplace listing
  Future<String> createMarketplaceListing({
    required String userId,
    required String productName,
    required String description,
    required int priceRwf,
    required String category,
    required List<String> imageUrls,
    String? location,
  }) async {
    try {
      final docRef = await _firestore.collection('marketplaceListings').add({
        'userId': userId,
        'productName': productName,
        'description': description,
        'priceRwf': priceRwf,
        'category': category,
        'imageUrls': imageUrls,
        'location': location,
        'available': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Marketplace listing created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating marketplace listing: $e');
      rethrow;
    }
  }

  /// Get marketplace listings
  Future<List<Map<String, dynamic>>> getMarketplaceListings({
    String? category,
    int limit = 30,
  }) async {
    try {
      Query query = _firestore
          .collection('marketplaceListings')
          .where('available', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      print('❌ Error fetching marketplace listings: $e');
      rethrow;
    }
  }

  // ==================== EVENTS ====================

  /// Create event
  Future<String> createEvent({
    required String userId,
    required String eventName,
    required String description,
    required DateTime eventDate,
    required String location,
    required int maxAttendees,
    String? imageUrl,
  }) async {
    try {
      final docRef = await _firestore.collection('events').add({
        'userId': userId,
        'eventName': eventName,
        'description': description,
        'eventDate': eventDate,
        'location': location,
        'maxAttendees': maxAttendees,
        'imageUrl': imageUrl,
        'attendees': 1, // Creator is first attendee
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Event created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating event: $e');
      rethrow;
    }
  }

  /// Get upcoming events
  Future<List<Map<String, dynamic>>> getUpcomingEvents({int limit = 20}) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('events')
          .where('eventDate', isGreaterThanOrEqualTo: now)
          .orderBy('eventDate')
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('❌ Error fetching events: $e');
      rethrow;
    }
  }

  // ==================== QUIZ ====================

  /// Get quiz by ID
  Future<Map<String, dynamic>?> getQuiz(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();
      return doc.data();
    } catch (e) {
      print('❌ Error fetching quiz: $e');
      rethrow;
    }
  }

  /// Save quiz result
  Future<void> saveQuizResult({
    required String userId,
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizResults')
          .add({
        'quizId': quizId,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': (score / totalQuestions * 100).toStringAsFixed(1),
        'completedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Quiz result saved');
    } catch (e) {
      print('❌ Error saving quiz result: $e');
      rethrow;
    }
  }

  // ==================== DONATIONS ====================

  /// Create donation record
  Future<String> createDonation({
    required String userId,
    required int amountRwf,
    required String cause,
    required String paymentMethod,
  }) async {
    try {
      final docRef = await _firestore.collection('donations').add({
        'userId': userId,
        'amountRwf': amountRwf,
        'cause': cause,
        'paymentMethod': paymentMethod,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Donation recorded: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error recording donation: $e');
      rethrow;
    }
  }

  /// Get user's donation history
  Future<List<Map<String, dynamic>>> getUserDonations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('donations')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('❌ Error fetching donations: $e');
      rethrow;
    }
  }

  // ==================== STREAKS ====================

  /// Update user streak
  Future<void> updateStreak(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final lastDate = userDoc['streakLastDate'] as Timestamp?;
      final currentStreak = userDoc['streak'] as int? ?? 0;

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      int newStreak = currentStreak;

      if (lastDate != null) {
        final lastDateOnly = DateTime(
          lastDate.toDate().year,
          lastDate.toDate().month,
          lastDate.toDate().day,
        );
        final yesterdayOnly =
            DateTime(yesterday.year, yesterday.month, yesterday.day);

        if (lastDateOnly == yesterdayOnly) {
          // Continue streak
          newStreak = currentStreak + 1;
        } else if (lastDateOnly !=
            DateTime(today.year, today.month, today.day)) {
          // Streak broken
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      await _firestore.collection('users').doc(userId).update({
        'streak': newStreak,
        'streakLastDate': FieldValue.serverTimestamp(),
      });

      print('✅ Streak updated: $newStreak');
    } catch (e) {
      print('❌ Error updating streak: $e');
      rethrow;
    }
  }
}
