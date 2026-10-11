import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:masjid_admin/core/utils/version_bumper.dart';
import 'package:masjid_admin/features/ticker/data/models/admin_ticker_item_model.dart';
import 'package:masjid_admin/features/ticker/domain/entities/admin_ticker_item.dart';
import 'package:masjid_admin/features/ticker/domain/repositories/admin_ticker_repository.dart';

class AdminTickerRepositoryImpl implements AdminTickerRepository {
  final FirebaseFirestore _db;
  final VersionBumper _versionBumper;

  AdminTickerRepositoryImpl({
    FirebaseFirestore? firestore,
    VersionBumper? versionBumper,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _versionBumper = versionBumper ?? VersionBumper();

  CollectionReference<Map<String, dynamic>> get _colRef =>
      _db.collection('ticker_messages');

  @override
  Future<List<AdminTickerItem>> getTickerMessages() async {
    final snapshot = await _colRef.orderBy('order').get();
    return snapshot.docs
        .map((doc) => AdminTickerItemModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> addTickerMessage(String text) async {
    final snapshot =
        await _colRef.orderBy('order', descending: true).limit(1).get();
    final lastOrder = snapshot.docs.isEmpty
        ? 0
        : ((snapshot.docs.first.data()['order'] ?? 0) as num).toInt();

    await _colRef.add({
      'text': text,
      'active': true,
      'order': lastOrder + 1,
    });
    await _versionBumper.bumpTickerVersion();
  }

  @override
  Future<void> updateTickerMessage(
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _colRef.doc(docId).set(data, SetOptions(merge: true));
    await _versionBumper.bumpTickerVersion();
  }

  @override
  Future<void> deleteTickerMessage(String docId) async {
    await _colRef.doc(docId).delete();
    await _versionBumper.bumpTickerVersion();
  }

  @override
  Future<void> reorderTickerMessages(List<AdminTickerItem> items) async {
    final batch = _db.batch();
    for (int i = 0; i < items.length; i++) {
      batch.set(
        _colRef.doc(items[i].id),
        {'order': i},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
    await _versionBumper.bumpTickerVersion();
  }

  @override
  Stream<int> listenToHijriOffset() {
    return _db
        .collection('settings')
        .doc('display_settings')
        .snapshots()
        .map((doc) => ((doc.data()?['hijri_offset'] ?? 0) as num).toInt());
  }

  @override
  Future<void> updateHijriOffset(int newOffset) async {
    final batch = _db.batch();

    final displayRef = _db.collection('settings').doc('display_settings');
    batch.set(
      displayRef,
      {'hijri_offset': newOffset},
      SetOptions(merge: true),
    );

    final versionRef = _db.collection('settings').doc('versions');
    batch.set(
      versionRef,
      {'hijri_version': FieldValue.increment(1)},
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
