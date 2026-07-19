import '../utils/firestore_utils.dart';

class ChatThread {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime updatedAt;

  ChatThread({
    required this.id,
    required this.participants,
    this.participantNames = const {},
    this.lastMessage = '',
    required this.updatedAt,
  });

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    final rawNames = json['participant_names'] as Map? ?? {};
    return ChatThread(
      id: json['id'] ?? '',
      participants: json['participants'] != null
          ? List<String>.from(json['participants'])
          : [],
      participantNames: rawNames.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      lastMessage: json['last_message'] ?? '',
      updatedAt: readFirestoreDate(json['updated_at']),
    );
  }

  String otherName(String currentUserId) {
    final otherId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return participantNames[otherId] ?? 'Reliq user';
  }
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      chatId: json['chat_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      text: json['text'] ?? '',
      createdAt: readFirestoreDate(json['created_at']),
    );
  }
}
