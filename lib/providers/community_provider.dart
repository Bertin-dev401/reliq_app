import 'dart:async';
import 'package:flutter/material.dart';
import '../models/community.dart';
import '../models/user.dart' as reliq;
import '../repositories/community_repository.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityRepository _repo;

  CommunityProvider({CommunityRepository? repository})
      : _repo = repository ?? CommunityRepository();

  List<Community> _communities = [];
  List<Post> _feedPosts = [];
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<Community>>? _communitiesSub;
  StreamSubscription<List<Post>>? _feedSub;
  StreamSubscription<List<Post>>? _postsSub;

  List<Community> get communities => _communities;
  List<Post> get feedPosts => _feedPosts;
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCommunities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _communitiesSub?.cancel();
    _communitiesSub = _repo.watchCommunities().listen(
      (communities) {
        _communities = communities;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Could not load communities.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadFeedPosts() async {
    await _feedSub?.cancel();
    _feedSub = _repo.watchCommunityFeed().listen(
      (posts) {
        _feedPosts = posts;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Could not load community posts.';
        notifyListeners();
      },
    );
  }

  Future<void> loadPosts(String communityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _postsSub?.cancel();
    _postsSub = _repo.watchPosts(communityId).listen(
      (posts) {
        _posts = posts;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Could not load posts.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> createPost({
    required Community community,
    required reliq.User user,
    required String content,
  }) async {
    try {
      await _repo.createPost(
        community: community,
        user: user,
        content: content,
      );
      return true;
    } catch (_) {
      _error = 'Could not create post. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> joinCommunity(String communityId, String userId) async {
    try {
      await _repo.joinCommunity(communityId, userId);
    } catch (_) {
      _error = 'Could not join community.';
      notifyListeners();
    }
  }

  Future<void> leaveCommunity(String communityId, String userId) async {
    try {
      await _repo.leaveCommunity(communityId, userId);
    } catch (_) {
      _error = 'Could not leave community.';
      notifyListeners();
    }
  }

  Stream<bool> watchMembership(String communityId, String userId) {
    return _repo.watchMembership(communityId, userId);
  }

  Community? findCommunity(String communityId) {
    for (final community in _communities) {
      if (community.id == communityId) return community;
    }
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _communitiesSub?.cancel();
    _feedSub?.cancel();
    _postsSub?.cancel();
    super.dispose();
  }
}
