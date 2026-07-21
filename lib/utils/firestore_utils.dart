// Firestore Utilities — shared helpers used by all repositories.
// readFirestoreDate converts Firestore Timestamps to Dart DateTime safely.
// withDocId / withSnapshotId inject the Firestore document ID into the data map since doc.data() doesn't include it.

import 'package:cloud_firestore/cloud_firestore.dart';

// Safely converts Timestamp, DateTime, or String to DateTime. Falls back to now().
DateTime readFirestoreDate(dynamic value, {DateTime? fallback}) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
  return fallback ?? DateTime.now();
}

// Merges query document data with its Firestore ID. Used in collection reads.
Map<String, dynamic> withDocId(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  return {...doc.data(), 'id': doc.id};
}

// Merges single document data with its Firestore ID. Used in get() calls.
Map<String, dynamic> withSnapshotId(DocumentSnapshot<Map<String, dynamic>> doc) {
  return {...(doc.data() ?? {}), 'id': doc.id};
}
