import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';
import '../utils/firestore_utils.dart';

class ChatRepository {
  final FirebaseFirestore _db;

  ChatRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  String directChatId(String firstUserId, String secondUserId) {
    final ids = [firstUserId, secondUserId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<List<ChatThread>> watchChats(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snap) {
          final chats = snap.docs.map((doc) {
            return ChatThread.fromJson(withDocId(doc));
          }).toList();
          chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return chats;
        });
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('created_at')
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              return ChatMessage.fromJson(withDocId(doc));
            }).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required List<String> participants,
    required Map<String, String> participantNames,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final chatRef = _db.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    final batch = _db.batch();
    batch.set(
      chatRef,
      {
        'id': chatId,
        'participants': participants,
        'participant_names': participantNames,
        'last_message': trimmed,
        'updated_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(messageRef, {
      'id': messageRef.id,
      'chat_id': chatId,
      'sender_id': senderId,
      'text': trimmed,
      'created_at': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
