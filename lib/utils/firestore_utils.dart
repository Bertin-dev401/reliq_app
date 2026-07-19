import 'package:cloud_firestore/cloud_firestore.dart';

DateTime readFirestoreDate(dynamic value, {DateTime? fallback}) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
  return fallback ?? DateTime.now();
}

Map<String, dynamic> withDocId(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) {
  return {
    ...doc.data(),
    'id': doc.id,
  };
}

Map<String, dynamic> withSnapshotId(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  return {
    ...(doc.data() ?? {}),
    'id': doc.id,
  };
}
