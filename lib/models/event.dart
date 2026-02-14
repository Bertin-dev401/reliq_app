class FaithEvent {
  final String id;
  final String title;
  final String description;
  final String? coverImage;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String denomination;
  final String organizerId;
  final String organizerName;
  final int attendeesCount;
  final bool isOnline;
  final String? meetingLink;
  final bool isLive;
  final List<String> tags;

  FaithEvent({
    required this.id,
    required this.title,
    required this.description,
    this.coverImage,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.denomination,
    required this.organizerId,
    required this.organizerName,
    this.attendeesCount = 0,
    this.isOnline = false,
    this.meetingLink,
    this.isLive = false,
    this.tags = const [],
  });

  factory FaithEvent.fromJson(Map<String, dynamic> json) {
    return FaithEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['cover_image'],
      location: json['location'] ?? '',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : DateTime.now(),
      denomination: json['denomination'] ?? '',
      organizerId: json['organizer_id'] ?? '',
      organizerName: json['organizer_name'] ?? '',
      attendeesCount: json['attendees_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
      meetingLink: json['meeting_link'],
      isLive: json['is_live'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_image': coverImage,
      'location': location,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'denomination': denomination,
      'organizer_id': organizerId,
      'organizer_name': organizerName,
      'attendees_count': attendeesCount,
      'is_online': isOnline,
      'meeting_link': meetingLink,
      'is_live': isLive,
      'tags': tags,
    };
  }
}
