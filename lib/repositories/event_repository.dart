// Event Repository — handles all Firestore reads/writes for faith events.
// Used by EventProvider. Firestore structure: /events/{id}/attendees/{userId}
// NOTE: watchMyRsvps uses collectionGroup — needs a composite index in Firestore console.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/user.dart' as reliq;
import '../utils/firestore_utils.dart';

class EventRepository {
  final FirebaseFirestore _db;

  EventRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // Real-time stream of all events ordered by start date. Limit 100.
  Stream<List<FaithEvent>> watchEvents() {
    return _db
        .collection('events')
        .orderBy('start_date')
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FaithEvent.fromJson(withDocId(doc))).toList());
  }

  // Creates a new event. Dates stored as Firestore Timestamps for correct sorting.
  Future<void> createEvent({
    required FaithEvent event,
    required reliq.User organizer,
  }) async {
    final ref = _db.collection('events').doc();
    await ref.set({
      'id': ref.id,
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

  // Adds user to attendees subcollection and increments count atomically.
  Future<void> rsvpEvent(String eventId, String userId) async {
    final eventRef = _db.collection('events').doc(eventId);
    final batch = _db.batch();
    batch.set(eventRef.collection('attendees').doc(userId), {
      'user_id': userId,
      'created_at': FieldValue.serverTimestamp(),
    });
    batch.update(eventRef, {'attendees_count': FieldValue.increment(1)});
    await batch.commit();
  }

  // Removes user RSVP and decrements count atomically.
  Future<void> cancelRsvp(String eventId, String userId) async {
    final eventRef = _db.collection('events').doc(eventId);
    final batch = _db.batch();
    batch.delete(eventRef.collection('attendees').doc(userId));
    batch.update(eventRef, {'attendees_count': FieldValue.increment(-1)});
    await batch.commit();
  }

  // Streams event IDs the user has RSVP'd to using collectionGroup query.
  // Requires composite index: Collection group = attendees, Field = user_id.
  // Firestore will show a clickable link in debug console to create it.
  Stream<List<String>> watchMyRsvps(String userId) {
    return _db
        .collectionGroup('attendees')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.reference.parent.parent!.id).toList());
  }
}
