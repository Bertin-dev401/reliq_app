class Community {
  final String id;
  final String name;
  final String description;
  final String? coverImage;
  final String denomination;
  final int memberCount;
  final DateTime createdDate;
  final bool isPrivate;
  final List<String> moderators;

  Community({
    required this.id,
    required this.name,
    required this.description,
    this.coverImage,
    required this.denomination,
    this.memberCount = 0,
    required this.createdDate,
    this.isPrivate = false,
    this.moderators = const [],
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['cover_image'],
      denomination: json['denomination'] ?? '',
      memberCount: json['member_count'] ?? 0,
      createdDate: json['created_date'] != null 
          ? DateTime.parse(json['created_date']) 
          : DateTime.now(),
      isPrivate: json['is_private'] ?? false,
      moderators: json['moderators'] != null 
          ? List<String>.from(json['moderators']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_image': coverImage,
      'denomination': denomination,
      'member_count': memberCount,
      'created_date': createdDate.toIso8601String(),
      'is_private': isPrivate,
      'moderators': moderators,
    };
  }
}

class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final String communityId;
  final String content;
  final List<String> images;
  final String? videoUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final bool isLiked;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.communityId,
    required this.content,
    this.images = const [],
    this.videoUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userImage: json['user_image'],
      communityId: json['community_id'] ?? '',
      content: json['content'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      videoUrl: json['video_url'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'community_id': communityId,
      'content': content,
      'images': images,
      'video_url': videoUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'is_liked': isLiked,
    };
  }
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userImage;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      postId: json['post_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userImage: json['user_image'],
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
