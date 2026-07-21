// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY REPOSITORY — lib/repositories/community_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// WHAT THIS FILE DOES:
//   All Firestore read/write operations for communities and posts live here.
//   Screens and providers never talk to Firestore directly — they go through
//   this repository. This keeps Firestore logic in one place and makes it
//   easy to test or swap out later.
//
// FIRESTORE STRUCTURE:
//   /communities/{communityId}
//     - name, description, denomination, member_count, created_date
//     /members/{userId}
//       - user_id, joined_at
//     /posts/{postId}
//       - id, community_id, user_id, user_name, content, likes_count,
//         comments_count, created_at
//
// STREAMS vs FUTURES:
//   Methods prefixed with "watch" return Streams — they stay open and push
//   updates in real time whenever Firestore data changes. No manual refresh needed.
//   Methods prefixed with "create/join/leave" are one-shot Futures.
//
// FIRESTORE RULES REQUIRED:
//   - /communities: read if signed in, write if owner
//   - /communities/{id}/posts: read if signed in, write if userId matches auth
//   - /communities/{id}/members: read/write if userId matches auth
//   - collectionGroup('posts'): read if signed in (for watchCommunityFeed)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community.dart';
import '../models/user.dart' as reliq;
import '../utils/firestore_utils.dart';

class CommunityRepository {
  final FirebaseFirestore _db;

  // Accepts an optional FirebaseFirestore instance for testing.
  // In production, uses FirebaseFirestore.instance (the default singleton).
  CommunityRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // Streams all communities ordered by newest first.
  // Limited to 100 to avoid reading the entire collection on load.
  // The stream stays open — any new community added in Firestore
  // will automatically appear in the UI without a manual refresh.
  Stream<List<Community>> watchCommunities() {
    return _db
        .collection('communities')
        .orderBy('created_date', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              return Community.fromJson(withDocId(doc));
            }).toList());
  }

  // Streams the latest 50 posts across ALL communities.
  // Used on the home screen community feed preview.
  // Uses collectionGroup which queries the 'posts' subcollection
  // under every community document at once.
  // NOTE: Requires a collectionGroup rule in firestore.rules:
  //   match /{path=**}/posts/{postId} { allow read: if isSignedIn(); }
  Stream<List<Post>> watchCommunityFeed() {
    return _db
        .collectionGroup('posts')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              return Post.fromJson(withDocId(doc));
            }).toList());
  }

  // Streams posts for a specific community, newest first.
  // Called when the user opens a community detail screen.
  // Limited to 50 — add pagination later when communities grow.
  Stream<List<Post>> watchPosts(String communityId) {
    return _db
        .collection('communities')
        .doc(communityId)
        .collection('posts')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              return Post.fromJson(withDocId(doc));
            }).toList());
  }

  // Creates a new post inside a community's posts subcollection.
  // Uses .doc() with no argument to let Firestore auto-generate the ID.
  // FieldValue.serverTimestamp() uses the server clock — not the device clock.
  // This prevents posts appearing out of order on devices with wrong time settings.
  Future<void> createPost({
    required Community community,
    required reliq.User user,
    required String content,
  }) async {
    final postRef = _db
        .collection('communities')
        .doc(community.id)
        .collection('posts')
        .doc();

    await postRef.set({
      'id': postRef.id,
      'community_id': community.id,
      'community_name': community.name,
      'community_denomination': community.denomination,
      'user_id': user.id,
      'user_name': user.name,
      'user_image': user.profileImage,
      'content': content,
      'images': <String>[],
      'video_url': null,
      'likes_count': 0,
      'comments_count': 0,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Adds the user to the community's members subcollection AND
  // increments the member_count on the community document in one atomic batch.
  // Using a batch ensures both writes succeed or both fail together —
  // prevents a situation where the member is added but the count isn't updated.
  Future<void> joinCommunity(String communityId, String userId) async {
    final communityRef = _db.collection('communities').doc(communityId);
    final memberRef = communityRef.collection('members').doc(userId);

    final batch = _db.batch();
    batch.set(memberRef, {
      'user_id': userId,
      'joined_at': FieldValue.serverTimestamp(),
    });
    batch.update(communityRef, {
      // FieldValue.increment is atomic — safe even if multiple users
      // join at the exact same millisecond
      'member_count': FieldValue.increment(1),
    });
    await batch.commit();
  }

  // Removes the user from members and decrements member_count atomically.
  // Same batch pattern as joinCommunity for consistency.
  Future<void> leaveCommunity(String communityId, String userId) async {
    final communityRef = _db.collection('communities').doc(communityId);
    final memberRef = communityRef.collection('members').doc(userId);

    final batch = _db.batch();
    batch.delete(memberRef);
    batch.update(communityRef, {
      'member_count': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  // Returns a real-time stream of whether the user is a member.
  // Used in community_detail_screen.dart to show Join/Leave button.
  // doc().snapshots() fires immediately with current state, then again
  // whenever the membership document is created or deleted.
  Stream<bool> watchMembership(String communityId, String userId) {
    return _db
        .collection('communities')
        .doc(communityId)
        .collection('members')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
