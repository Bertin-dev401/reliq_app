import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/user.dart' as reliq;
import '../utils/firestore_utils.dart';

class EventRepository {
  final FirebaseFirestore _db;

  EventRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<FaithEvent>> watchEvents() {
    return _db
        .collection('events')
        .orderBy('start_date')
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              return FaithEvent.fromJson(withDocId(doc));
            }).toList());
  }

  Future<void> createEvent({
    required FaithEvent event,
    required reliq.User organizer,
  }) async {
    final eventRef = _db.collection('events').doc();
    await eventRef.set({
      'id': eventRef.id,
      'title': event.title,
      'description': event.description,
      'cover_image': event.coverImage,
      'location': event.location,
      'start_date': Timestamp.fromDate(event.startDate),
      'end_date': Timestamp.fromDate(event.endDate),
      'denomination': event.denomination,
      'organizer_id': organizer.id,
      'organizer_name': organizer.name,
      'attendees_count': 0,
      'is_online': event.isOnline,
      'meeting_link': event.meetingLink,
      'is_live': false,
      'tags': event.tags,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rsvpEvent(String eventId, String userId) async {
    final eventRef = _db.collection('events').doc(eventId);
    final attendeeRef = eventRef.collection('attendees').doc(userId);

    final batch = _db.batch();
    batch.set(attendeeRef, {
      'user_id': userId,
      'created_at': FieldValue.serverTimestamp(),
    });
    batch.update(eventRef, {
      'attendees_count': FieldValue.increment(1),
    });
    await batch.commit();
  }

  Future<void> cancelRsvp(String eventId, String userId) async {
    final eventRef = _db.collection('events').doc(eventId);
    final attendeeRef = eventRef.collection('attendees').doc(userId);

    final batch = _db.batch();
    batch.delete(attendeeRef);
    batch.update(eventRef, {
      'attendees_count': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  Stream<List<String>> watchMyRsvps(String userId) {
    return _db
        .collectionGroup('attendees')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.reference.parent.parent!.id).toList());
  }
}
