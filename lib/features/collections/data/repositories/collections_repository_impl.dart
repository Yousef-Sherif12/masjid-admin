import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:masjid_admin/core/utils/version_bumper.dart';
import 'package:masjid_admin/features/collections/data/models/collection_item_model.dart';
import 'package:masjid_admin/features/collections/domain/entities/collection_item.dart';
import 'package:masjid_admin/features/collections/domain/repositories/collections_repository.dart';

class CollectionsRepositoryImpl implements CollectionsRepository {
  final FirebaseFirestore _db;
  final VersionBumper _versionBumper;

  CollectionsRepositoryImpl({
    FirebaseFirestore? firestore,
    VersionBumper? versionBumper,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _versionBumper = versionBumper ?? VersionBumper();

  CollectionReference<Map<String, dynamic>> get _colRef =>
      _db.collection('collections_config');

  @override
  Future<void> ensureDefaultCollectionsExist() async {
    final defaults = [
      {
        'id': 'quran_messages',
        'label': 'رسائل قرآنية',
        'type': 'quran',
        'active': true,
        'order': 0,
      },
      {
        'id': 'hadith_messages',
        'label': 'رسائل نبوية',
        'type': 'hadith',
        'active': true,
        'order': 1,
      },
      {
        'id': 'thaqil',
        'label': 'ثقل موازينك',
        'type': 'thaqil',
        'active': true,
        'order': 2,
      },
      {
        'id': 'prayer_from_quran',
        'label': 'أدعية',
        'type': 'Prayer_From_Quran',
        'active': true,
        'order': 3,
      },
    ];

    final snapshot = await _colRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final col in defaults) {
      final id = col['id'] as String;
      batch.set(_colRef.doc(id), col, SetOptions(merge: true));
    }
    await batch.commit();
  }

  @override
  Future<List<CollectionItem>> getCollections() async {
    final snapshot = await _colRef.orderBy('order').get();
    return snapshot.docs
        .map((doc) => CollectionItemModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> addCollection({
    required String key,
    required String label,
  }) async {
    final snapshot =
        await _colRef.orderBy('order', descending: true).limit(1).get();
    final lastOrder = snapshot.docs.isEmpty
        ? 0
        : ((snapshot.docs.first.data()['order'] ?? 0) as num).toInt();

    await _colRef.doc(key).set(
      {
        'id': key,
        'label': label,
        'type': 'custom',
        'active': true,
        'order': lastOrder + 1,
      },
      SetOptions(merge: true),
    );
    await _versionBumper.bumpMessagesVersion();
  }

  @override
  Future<void> updateCollectionLabel({
    required String key,
    required String newLabel,
  }) async {
    await _colRef.doc(key).set(
      {'label': newLabel},
      SetOptions(merge: true),
    );
    await _versionBumper.bumpMessagesVersion();
  }

  @override
  Future<void> deleteCollection(String key) async {
    await _colRef.doc(key).delete();
    await _versionBumper.bumpMessagesVersion();
  }

  @override
  Future<bool> toggleCollection(String key, bool active) async {
    if (!active) {
      final snapshot = await _colRef.where('active', isEqualTo: true).get();
      if (snapshot.docs.length <= 1) return false;
    }

    await _colRef.doc(key).set(
      {'active': active},
      SetOptions(merge: true),
    );
    await _versionBumper.bumpMessagesVersion();
    return true;
  }

  @override
  Future<void> reorderCollections(List<CollectionItem> items) async {
    final batch = _db.batch();
    for (int i = 0; i < items.length; i++) {
      batch.set(
        _colRef.doc(items[i].id),
        {'order': i},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
    await _versionBumper.bumpMessagesVersion();
  }
}
