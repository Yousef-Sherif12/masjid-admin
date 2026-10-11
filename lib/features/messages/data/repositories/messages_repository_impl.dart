import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:masjid_admin/core/utils/version_bumper.dart';
import 'package:masjid_admin/features/messages/data/models/admin_message_model.dart';
import 'package:masjid_admin/features/messages/domain/entities/admin_message.dart';
import 'package:masjid_admin/features/messages/domain/entities/live_display_state.dart';
import 'package:masjid_admin/features/messages/domain/repositories/messages_repository.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final FirebaseFirestore _db;
  final VersionBumper _versionBumper;

  MessagesRepositoryImpl({
    FirebaseFirestore? firestore,
    VersionBumper? versionBumper,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _versionBumper = versionBumper ?? VersionBumper();

  String _resolveType(String collection) {
    const types = {
      'quran_messages': 'quran',
      'hadith_messages': 'hadith',
      'thaqil': 'thaqil',
      'prayer_from_quran': 'Prayer_From_Quran',
      'adhkar_salah': 'adhkar_salah',
      'adhkar_sabah': 'adhkar_sabah',
      'adhkar_masa': 'adhkar_masa',
    };
    return types[collection] ?? collection;
  }

  @override
  Future<List<AdminMessage>> getMessages(String collection) async {
    final snapshot = await _db.collection(collection).orderBy('order').get();
    return snapshot.docs
        .map((doc) => AdminMessageModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> addMessage({
    required String collection,
    required String text,
    required String subText,
    required String fadl,
    required int duration,
    required double? fontSize,
  }) async {
    final colRef = _db.collection(collection);
    final snapshot =
        await colRef.orderBy('order', descending: true).limit(1).get();
    final lastOrder = snapshot.docs.isEmpty
        ? 0
        : ((snapshot.docs.first.data()['order'] ?? 0) as num).toInt();

    await colRef.add({
      'text': text,
      'subText': subText,
      'fadl': fadl,
      'duration': duration,
      'type': _resolveType(collection),
      'fontSize': fontSize,
      'order': lastOrder + 1,
    });
    await _versionBumper.bumpMessagesVersion();
  }

  @override
  Future<void> updateMessage({
    required String collection,
    required String docId,
    required String text,
    required String subText,
    required String fadl,
    required int duration,
    required double? fontSize,
  }) async {
    await _db.collection(collection).doc(docId).set(
      {
        'text': text,
        'subText': subText,
        'fadl': fadl,
        'duration': duration,
        'type': _resolveType(collection),
        'fontSize': fontSize,
      },
      SetOptions(merge: true),
    );
    await _versionBumper.bumpMessagesVersion();
  }

  @override
  Future<void> deleteMessage(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
    await _versionBumper.bumpMessagesVersion();
  }

  @override
  Future<void> reorderMessages(
    String collection,
    List<AdminMessage> items,
  ) async {
    final batch = _db.batch();
    final colRef = _db.collection(collection);
    for (int i = 0; i < items.length; i++) {
      batch.set(
        colRef.doc(items[i].id),
        {'order': i},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
    await _versionBumper.bumpMessagesVersion();
  }

  @override
  Future<void> toggleLiveDisplay(String collection, String docId) async {
    final liveRef = _db.collection('settings').doc('live_display');
    final current = await liveRef.get();
    final data = current.data();
    final isActive = data?['active'] == true;
    final currentDocId = (data?['docId'] ?? '').toString();

    if (isActive && currentDocId == docId) {
      await clearLiveDisplay();
      return;
    }

    await liveRef.set({
      'collection': collection,
      'docId': docId,
      'active': true,
    });
  }

  @override
  Future<void> clearLiveDisplay() async {
    await _db.collection('settings').doc('live_display').set({
      'collection': '',
      'docId': '',
      'active': false,
    });
  }

  @override
  Stream<LiveDisplayState> listenToLiveDisplay() {
    return _db
        .collection('settings')
        .doc('live_display')
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null || data['active'] != true) {
        return const LiveDisplayState();
      }
      return LiveDisplayState(
        active: true,
        collection: (data['collection'] ?? '').toString(),
        docId: (data['docId'] ?? '').toString(),
      );
    });
  }
}
