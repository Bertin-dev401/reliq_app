// ─────────────────────────────────────────────────────────────────────────────
// FIRESTORE UTILITIES — lib/utils/firestore_utils.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// WHAT THIS FILE DOES:
//   Small helper functions used across all repositories when reading
//   Firestore documents. Centralizes common patterns so they're not
//   duplicated in every repository file.
//
// WHY THESE ARE NEEDED:
//   Firestore stores dates as Timestamp objects, not Dart DateTime objects.
//   Every model's fromJson() needs to handle this conversion.
//   Without these helpers, you'd write the same null-check and type-check
//   logic in every single model file.
//
//   Firestore document IDs are not included in doc.data() — they live
//   separately in doc.id. withDocId() and withSnapshotId() merge them
//   so models can be constructed from a single map.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

// Safely converts a Firestore field value to a Dart DateTime.
// Handles three cases that appear in real Firestore data:
//   1. Timestamp — the normal case when data was written with serverTimestamp()
//   2. DateTime — when data was written directly as a DateTime (less common)
//   3. String — when data was written as an ISO 8601 string (legacy or manual)
//   4. null or anything else — returns fallback or DateTime.now()
//
// Usage in a model's fromJson():
//   createdAt: readFirestoreDate(json['created_at']),
DateTime readFirestoreDate(dynamic value, {DateTime? fallback}) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
  return fallback ?? DateTime.now();
}

// Merges a Firestore query document's data with its document ID.
// Firestore's doc.data() does NOT include the document ID — it's separate.
// Models need the ID to identify documents (e.g. for updates or navigation).
//
// Used with query snapshots (collection reads):
//   snap.docs.map((doc) => MyModel.fromJson(withDocId(doc)))
Map<String, dynamic> withDocId(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) {
  return {
    ...doc.data(),
    'id': doc.id, // inject the Firestore document ID into the data map
  };
}

// Same as withDocId but for single document snapshots (get() calls).
// The difference is the type — DocumentSnapshot vs QueryDocumentSnapshot.
// Also handles the case where doc.data() is null (document doesn't exist).
//
// Used with single document reads:
//   final doc = await db.collection('users').doc(uid).get();
//   final user = User.fromJson(withSnapshotId(doc));
Map<String, dynamic> withSnapshotId(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  return {
    ...(doc.data() ?? {}), // safe spread — empty map if document doesn't exist
    'id': doc.id,
  };
}
