// ─────────────────────────────────────────────────────────────────────────────
// EVENT REPOSITORY — lib/repositories/event_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// WHAT THIS FILE DOES:
//   All Firestore read/write operations for faith events live here.
//   Handles creating events, RSVP management, and real-time event streaming.
//
// FIRESTORE STRUCTURE:
//   /events/{eventId}
//     - id, title, description, location, start_date, end_date,
//       denomination, organizer_id, organizer_name, attendees_count,
//       is_online, meeting_link, is_live, tags, created_at
//     /attendees/{userId}
//       - user_id, created_at
//
// IMPORTANT — INDEXES NEEDED:
//   The watchEvents() query uses orderBy('start_date') — Firestore will
//   ask you to create a composite index the first time this runs.
//   Click the link in the error message in your debug console to create it.
//
//   watchMyRsvps() uses collectionGroup('attendees') with a where clause —
//   this also requires a composite index. Same process — click the link.
//
// FIRESTORE RULES REQUIRED:
//   - /events: read if signed in, create if organizer_id matches auth
//   - /events/{id}/attendees: read/write if userId matches auth
//   - collectionGroup('attendees'): read if userId matches auth
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/user.dart' as reliq;
import '../utils/firestore_utils.dart';

class EventRepository {
  final FirebaseFirestore _db;

  EventRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // Streams all upcoming events ordered by start date (soonest first).
  // Limited to 100 — add denomination/date filtering here later
  // when the events collection grows large enough to need it.
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

  // Creates a new event document in Firestore.
  // Dates are stored as Firestore Timestamps (not strings) so they
  // sort correctly and work with Firestore date queries.
  // FieldValue.serverTimestamp() for created_at uses server time —
  // not the device clock which could be wrong.
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
      // Store as Timestamp not DateTime string — Firestore sorts these correctly
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

  // Adds the user to the event's attendees subcollection AND
  // increments attendees_count atomically in one batch.
  // Using userId as the document ID means a user can only RSVP once —
  // trying to set the same document twice just overwrites it (idempotent).
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

  // Removes the user's RSVP and decrements the count atomically.
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

  // Returns a stream of event IDs the user has RSVP'd to.
  // Uses collectionGroup to query the 'attendees' subcollection across
  // all events at once — much more efficient than querying each event separately.
  //
  // NOTE: Requires a composite index in Firestore for:
  //   Collection group: attendees | Field: user_id (ascending)
  //   Firestore will show a clickable link in the debug console to create it.
  //
  // NOTE: Also requires a Firestore rule:
  //   match /events/{id}/attendees/{userId} { allow read: if isSignedIn() && request.auth.uid == userId; }
  Stream<List<String>> watchMyRsvps(String userId) {
    return _db
        .collectionGroup('attendees')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        // Extract the parent event document ID from each attendee document reference
        .map((snap) => snap.docs
            .map((doc) => doc.reference.parent.parent!.id)
            .toList());
  }
}
