// Chat Models — data classes for the messaging feature.
// ChatThread maps to /chats/{chatId}, ChatMessage maps to /chats/{chatId}/messages/{messageId}.
// Used by ChatRepository and chat screens.

import '../utils/firestore_utils.dart';

// Represents a conversation between two users.
class ChatThread {
  final String id;
  final List<String> participants;
  // Map of userId → display name. Stored on the chat to avoid extra user profile reads.
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
      participants: json['participants'] != null ? List<String>.from(json['participants']) : [],
      participantNames: rawNames.map((k, v) => MapEntry(k.toString(), v.toString())),
      lastMessage: json['last_message'] ?? '',
      updatedAt: readFirestoreDate(json['updated_at']),
    );
  }

  // Returns the other participant's display name for the chat list screen.
  String otherName(String currentUserId) {
    final otherId = participants.firstWhere((id) => id != currentUserId, orElse: () => currentUserId);
    return participantNames[otherId] ?? 'Reliq user';
  }
}

// Represents a single message inside a conversation.
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId; // Firebase Auth UID — used to determine bubble alignment
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
