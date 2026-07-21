// Community Repository — handles all Firestore reads/writes for communities and posts.
// Used by CommunityProvider. Screens never talk to Firestore directly.
// Firestore structure: /communities/{id}/posts/{id} and /communities/{id}/members/{id}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community.dart';
import '../models/user.dart' as reliq;
import '../utils/firestore_utils.dart';

class CommunityRepository {
  final FirebaseFirestore _db;

  CommunityRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // Real-time stream of all communities, newest first. Limit 100.
  Stream<List<Community>> watchCommunities() {
    return _db
        .collection('communities')
        .orderBy('created_date', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Community.fromJson(withDocId(doc))).toList());
  }

  // Real-time stream of latest 50 posts across ALL communities.
  // Uses collectionGroup — requires rule: match /{path=**}/posts/{id} { allow read: if isSignedIn(); }
  Stream<List<Post>> watchCommunityFeed() {
    return _db
        .collectionGroup('posts')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Post.fromJson(withDocId(doc))).toList());
  }

  // Real-time stream of posts for a specific community, newest first.
  Stream<List<Post>> watchPosts(String communityId) {
    return _db
        .collection('communities')
        .doc(communityId)
        .collection('posts')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Post.fromJson(withDocId(doc))).toList());
  }

  // Writes a new post to /communities/{id}/posts. Uses server timestamp for ordering.
  Future<void> createPost({
    required Community community,
    required reliq.User user,
    required String content,
  }) async {
    final postRef = _db.collection('communities').doc(community.id).collection('posts').doc();
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

  // Adds user to members subcollection and increments member_count atomically.
  Future<void> joinCommunity(String communityId, String userId) async {
    final communityRef = _db.collection('communities').doc(communityId);
    final batch = _db.batch();
    batch.set(communityRef.collection('members').doc(userId), {
      'user_id': userId,
      'joined_at': FieldValue.serverTimestamp(),
    });
    batch.update(communityRef, {'member_count': FieldValue.increment(1)});
    await batch.commit();
  }

  // Removes user from members and decrements member_count atomically.
  Future<void> leaveCommunity(String communityId, String userId) async {
    final communityRef = _db.collection('communities').doc(communityId);
    final batch = _db.batch();
    batch.delete(communityRef.collection('members').doc(userId));
    batch.update(communityRef, {'member_count': FieldValue.increment(-1)});
    await batch.commit();
  }

  // Real-time stream of whether the user is a member. Used for Join/Leave button.
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
