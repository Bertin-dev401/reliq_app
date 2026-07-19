import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community.dart';
import '../models/user.dart' as reliq;
import '../utils/firestore_utils.dart';

class CommunityRepository {
  final FirebaseFirestore _db;

  CommunityRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

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

  Future<void> joinCommunity(String communityId, String userId) async {
    final communityRef = _db.collection('communities').doc(communityId);
    final memberRef = communityRef.collection('members').doc(userId);

    // Batch keeps membership and count aligned when the write syncs.
    final batch = _db.batch();
    batch.set(memberRef, {
      'user_id': userId,
      'joined_at': FieldValue.serverTimestamp(),
    });
    batch.update(communityRef, {
      'member_count': FieldValue.increment(1),
    });
    await batch.commit();
  }

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
