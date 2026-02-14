class User {
  final String id;
  final String email;
  final String name;
  final String? profileImage;
  final String? denomination;
  final String? bio;
  final String? location;
  final List<String> favoriteVerses;
  final List<String> prayerGoals;
  final DateTime joinedDate;
  final int streakCount;
  final bool isPremium;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    this.denomination,
    this.bio,
    this.location,
    this.favoriteVerses = const [],
    this.prayerGoals = const [],
    required this.joinedDate,
    this.streakCount = 0,
    this.isPremium = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profile_image'],
      denomination: json['denomination'],
      bio: json['bio'],
      location: json['location'],
      favoriteVerses: json['favorite_verses'] != null 
          ? List<String>.from(json['favorite_verses']) 
          : [],
      prayerGoals: json['prayer_goals'] != null 
          ? List<String>.from(json['prayer_goals']) 
          : [],
      joinedDate: json['joined_date'] != null 
          ? DateTime.parse(json['joined_date']) 
          : DateTime.now(),
      streakCount: json['streak_count'] ?? 0,
      isPremium: json['is_premium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image': profileImage,
      'denomination': denomination,
      'bio': bio,
      'location': location,
      'favorite_verses': favoriteVerses,
      'prayer_goals': prayerGoals,
      'joined_date': joinedDate.toIso8601String(),
      'streak_count': streakCount,
      'is_premium': isPremium,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    String? denomination,
    String? bio,
    String? location,
    List<String>? favoriteVerses,
    List<String>? prayerGoals,
    DateTime? joinedDate,
    int? streakCount,
    bool? isPremium,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      denomination: denomination ?? this.denomination,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      favoriteVerses: favoriteVerses ?? this.favoriteVerses,
      prayerGoals: prayerGoals ?? this.prayerGoals,
      joinedDate: joinedDate ?? this.joinedDate,
      streakCount: streakCount ?? this.streakCount,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
