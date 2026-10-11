import 'package:cloud_firestore/cloud_firestore.dart';

class VersionBumper {
  final FirebaseFirestore _db;

  VersionBumper({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _versionsDoc =>
      _db.collection('settings').doc('versions');

  Future<void> bumpMessagesVersion() async {
    await _versionsDoc.set(
      {'messages_version': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  Future<void> bumpIqamaVersion() async {
    await _versionsDoc.set(
      {'iqama_version': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  Future<void> bumpTickerVersion() async {
    await _versionsDoc.set(
      {'ticker_version': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }
}
