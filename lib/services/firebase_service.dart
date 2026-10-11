// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirebaseService {
//   static final _db = FirebaseFirestore.instance;

//   static Future<void> initCollectionsConfig() async {
//     final defaults = [
//       {
//         'id': 'quran_messages',
//         'label': 'رسائل قرآنية',
//         'type': 'quran',
//         'active': true,
//         'order': 0,
//       },
//       {
//         'id': 'hadith_messages',
//         'label': 'رسائل نبوية',
//         'type': 'hadith',
//         'active': true,
//         'order': 1,
//       },
//       {
//         'id': 'thaqil',
//         'label': 'ثقل موازينك',
//         'type': 'thaqil',
//         'active': true,
//         'order': 2,
//       },
//       {
//         'id': 'prayer_from_quran',
//         'label': 'أدعية',
//         'type': 'prayer',
//         'active': true,
//         'order': 3,
//       },
//     ];

//     for (final col in defaults) {
//       final id = col['id'] as String;
//       final doc = await _db.collection('collections_config').doc(id).get();
//       if (!doc.exists) {
//         await _db.collection('collections_config').doc(id).set(col);
//       }
//     }
//   }

//   // ===================== رفع الـ Version =====================
//   static Future<void> bumpMessagesVersion() async {
//     final doc = await _db.collection('settings').doc('versions').get();
//     final current = (doc.data()?['messages_version'] ?? 1) as int;
//     await _db.collection('settings').doc('versions').update({
//       'messages_version': current + 1,
//     });
//   }

//   static Future<void> bumpIqamaVersion() async {
//     final doc = await _db.collection('settings').doc('versions').get();
//     final current = (doc.data()?['iqama_version'] ?? 1) as int;
//     await _db.collection('settings').doc('versions').update({
//       'iqama_version': current + 1,
//     });
//   }

//   // ===================== النصوص =====================
//   static Future<List<Map<String, dynamic>>> getMessages(
//     String collection,
//   ) async {
//     final snapshot = await _db.collection(collection).orderBy('order').get();
//     return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
//   }

//   static Future<void> addMessage(
//     String collection,
//     Map<String, dynamic> data,
//   ) async {
//     final snapshot = await _db
//         .collection(collection)
//         .orderBy('order', descending: true)
//         .limit(1)
//         .get();
//     final lastOrder = snapshot.docs.isEmpty
//         ? 0
//         : (snapshot.docs.first.data()['order'] ?? 0) as int;

//     await _db.collection(collection).add({...data, 'order': lastOrder + 1});
//     await bumpMessagesVersion();
//   }

//   static Future<void> updateMessage(
//     String collection,
//     String docId,
//     Map<String, dynamic> data,
//   ) async {
//     await _db.collection(collection).doc(docId).update(data);
//     await bumpMessagesVersion();
//   }

//   static Future<void> deleteMessage(String collection, String docId) async {
//     await _db.collection(collection).doc(docId).delete();
//     await bumpMessagesVersion();
//   }

//   static Future<void> reorderMessages(
//     String collection,
//     List<Map<String, dynamic>> items,
//   ) async {
//     final batch = _db.batch();
//     for (int i = 0; i < items.length; i++) {
//       final ref = _db.collection(collection).doc(items[i]['id']);
//       batch.update(ref, {'order': i});
//     }
//     await batch.commit();
//     await bumpMessagesVersion();
//   }

//   // ===================== الإقامة =====================
//   static Future<Map<String, dynamic>> getIqamaTimes() async {
//     final doc = await _db.collection('settings').doc('iqama_times').get();
//     return doc.data() ?? {};
//   }

//   static Future<void> updateIqamaTimes(Map<String, dynamic> data) async {
//     await _db.collection('settings').doc('iqama_times').set(data);
//     await bumpIqamaVersion();
//   }

//   // ===================== Live Display =====================
//   static Future<void> setLiveDisplay(String collection, String docId) async {
//     final current = await _db.collection('settings').doc('live_display').get();
//     final isActive = current.data()?['active'] == true;
//     final currentDocId = current.data()?['docId'] ?? '';

//     // ✅ نفس النص → وقّف
//     if (isActive && currentDocId == docId) {
//       await clearLiveDisplay();
//       return;
//     }

//     // ✅ نص تاني أو مفيش حاجة → اعرضه
//     await _db.collection('settings').doc('live_display').set({
//       'collection': collection,
//       'docId': docId,
//       'active': true,
//     });
//   }

//   static Future<void> clearLiveDisplay() async {
//     await _db.collection('settings').doc('live_display').set({
//       'collection': '',
//       'docId': '',
//       'active': false,
//     });
//   }

//   // ✅ Stream للـ live display
//   static Stream<DocumentSnapshot> getLiveDisplayStream() {
//     return _db.collection('settings').doc('live_display').snapshots();
//   }

//   // ===================== Collections Config =====================
//   static Future<List<Map<String, dynamic>>> getCollectionsConfig() async {
//     final snapshot = await _db
//         .collection('collections_config')
//         .orderBy('order')
//         .get();
//     return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
//   }

//   static Future<void> addCollection({
//     required String key,
//     required String label,
//   }) async {
//     final snapshot = await _db
//         .collection('collections_config')
//         .orderBy('order', descending: true)
//         .limit(1)
//         .get();
//     final lastOrder = snapshot.docs.isEmpty
//         ? 0
//         : (snapshot.docs.first.data()['order'] ?? 0) as int;

//     await _db.collection('collections_config').doc(key).set({
//       'label': label,
//       'type': 'custom',
//       'active': true,
//       'order': lastOrder + 1,
//     });
//   }

//   static Future<bool> toggleCollection(String key, bool active) async {
//     if (!active) {
//       final snapshot = await _db
//           .collection('collections_config')
//           .where('active', isEqualTo: true)
//           .get();
//       if (snapshot.docs.length <= 1) return false;
//     }
//     await _db.collection('collections_config').doc(key).update({
//       'active': active,
//     });
//     await bumpMessagesVersion();
//     return true;
//   }

//   static Future<void> reorderCollections(
//     List<Map<String, dynamic>> items,
//   ) async {
//     final batch = _db.batch();
//     for (int i = 0; i < items.length; i++) {
//       final ref = _db.collection('collections_config').doc(items[i]['id']);
//       batch.update(ref, {'order': i});
//     }
//     await batch.commit();
//     await bumpMessagesVersion();
//   }

//   static Stream<QuerySnapshot> listenToCollectionsConfig() {
//     return _db.collection('collections_config').orderBy('order').snapshots();
//   }

//   static Future<void> bumpTickerVersion() async {
//     final doc = await _db.collection('settings').doc('versions').get();

//     final current = (doc.data()?['ticker_version'] ?? 1) as int;

//     await _db.collection('settings').doc('versions').update({
//       'ticker_version': current + 1,
//     });
//   }
//   static Future<List<Map<String, dynamic>>> getTickerMessages() async {
//   final snapshot = await _db
//       .collection('ticker_messages')
//       .orderBy('order')
//       .get();

//   return snapshot.docs
//       .map((doc) => {
//             'id': doc.id,
//             ...doc.data(),
//           })
//       .toList();
// }
// static Future<void> addTickerMessage(String text) async {
//   final snapshot = await _db
//       .collection('ticker_messages')
//       .orderBy('order', descending: true)
//       .limit(1)
//       .get();

//   final lastOrder = snapshot.docs.isEmpty
//       ? 0
//       : (snapshot.docs.first.data()['order'] ?? 0) as int;

//   await _db.collection('ticker_messages').add({
//     'text': text,
//     'active': true,
//     'order': lastOrder + 1,
//   });

//   await bumpTickerVersion();
// }
// static Future<void> updateTickerMessage(
//   String docId,
//   Map<String, dynamic> data,
// ) async {
//   await _db
//       .collection('ticker_messages')
//       .doc(docId)
//       .update(data);

//   await bumpTickerVersion();
// }
// static Future<void> deleteTickerMessage(String docId) async {
//   await _db
//       .collection('ticker_messages')
//       .doc(docId)
//       .delete();

//   await bumpTickerVersion();
// }
// static Future<void> reorderTickerMessages(
//   List<Map<String, dynamic>> items,
// ) async {
//   final batch = _db.batch();

//   for (int i = 0; i < items.length; i++) {
//     final ref = _db
//         .collection('ticker_messages')
//         .doc(items[i]['id']);

//     batch.update(ref, {
//       'order': i,
//     });
//   }

//   await batch.commit();

//   await bumpTickerVersion();
// }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  // ===================== Init =====================
  static Future<void> initCollectionsConfig() async {
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
        'type': 'prayer',
        'active': true,
        'order': 3,
      },
    ];
    for (final col in defaults) {
      final id = col['id'] as String;
      final doc = await _db.collection('collections_config').doc(id).get();
      if (!doc.exists) {
        await _db.collection('collections_config').doc(id).set(col);
      }
    }
  }

  // ===================== Versions =====================
  static Future<void> bumpMessagesVersion() async {
    final doc = await _db.collection('settings').doc('versions').get();
    final current = (doc.data()?['messages_version'] ?? 1) as int;
    await _db.collection('settings').doc('versions').update({
      'messages_version': current + 1,
    });
  }

  static Future<void> bumpIqamaVersion() async {
    final doc = await _db.collection('settings').doc('versions').get();
    final current = (doc.data()?['iqama_version'] ?? 1) as int;
    await _db.collection('settings').doc('versions').update({
      'iqama_version': current + 1,
    });
  }

  static Future<void> bumpTickerVersion() async {
    final doc = await _db.collection('settings').doc('versions').get();
    final current = (doc.data()?['ticker_version'] ?? 1) as int;
    await _db.collection('settings').doc('versions').update({
      'ticker_version': current + 1,
    });
  }

  // ===================== النصوص =====================
  static Future<List<Map<String, dynamic>>> getMessages(
    String collection,
  ) async {
    final snapshot = await _db.collection(collection).orderBy('order').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Future<void> addMessage(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final snapshot = await _db
        .collection(collection)
        .orderBy('order', descending: true)
        .limit(1)
        .get();
    final lastOrder = snapshot.docs.isEmpty
        ? 0
        : (snapshot.docs.first.data()['order'] ?? 0) as int;
    await _db.collection(collection).add({...data, 'order': lastOrder + 1});
    await bumpMessagesVersion();
  }

  static Future<void> updateMessage(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(collection).doc(docId).update(data);
    await bumpMessagesVersion();
  }

  static Future<void> deleteMessage(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
    await bumpMessagesVersion();
  }

  static Future<void> reorderMessages(
    String collection,
    List<Map<String, dynamic>> items,
  ) async {
    final batch = _db.batch();
    for (int i = 0; i < items.length; i++) {
      batch.update(_db.collection(collection).doc(items[i]['id']), {
        'order': i,
      });
    }
    await batch.commit();
    await bumpMessagesVersion();
  }

  // ===================== الإقامة =====================
  static Future<Map<String, dynamic>> getIqamaTimes() async {
    final doc = await _db.collection('settings').doc('iqama_times').get();
    return doc.data() ?? {};
  }

  static Future<void> updateIqamaTimes(Map<String, dynamic> data) async {
    await _db.collection('settings').doc('iqama_times').set(data);
    await bumpIqamaVersion();
  }

  // ===================== Live Display =====================
  static Future<void> setLiveDisplay(String collection, String docId) async {
    final current = await _db.collection('settings').doc('live_display').get();
    final isActive = current.data()?['active'] == true;
    final currentDocId = current.data()?['docId'] ?? '';
    if (isActive && currentDocId == docId) {
      await clearLiveDisplay();
      return;
    }
    await _db.collection('settings').doc('live_display').set({
      'collection': collection,
      'docId': docId,
      'active': true,
    });
  }

  static Future<void> clearLiveDisplay() async {
    await _db.collection('settings').doc('live_display').set({
      'collection': '',
      'docId': '',
      'active': false,
    });
  }

  static Stream<DocumentSnapshot> getLiveDisplayStream() {
    return _db.collection('settings').doc('live_display').snapshots();
  }

  // ===================== Collections Config =====================
  static Future<List<Map<String, dynamic>>> getCollectionsConfig() async {
    final snapshot = await _db
        .collection('collections_config')
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Future<void> addCollection({
    required String key,
    required String label,
  }) async {
    final snapshot = await _db
        .collection('collections_config')
        .orderBy('order', descending: true)
        .limit(1)
        .get();
    final lastOrder = snapshot.docs.isEmpty
        ? 0
        : (snapshot.docs.first.data()['order'] ?? 0) as int;
    await _db.collection('collections_config').doc(key).set({
      'label': label,
      'type': 'custom',
      'active': true,
      'order': lastOrder + 1,
    });
  }

  static Future<bool> toggleCollection(String key, bool active) async {
    if (!active) {
      final snapshot = await _db
          .collection('collections_config')
          .where('active', isEqualTo: true)
          .get();
      if (snapshot.docs.length <= 1) return false;
    }
    await _db.collection('collections_config').doc(key).update({
      'active': active,
    });
    await bumpMessagesVersion();
    return true;
  }

  static Future<void> reorderCollections(
    List<Map<String, dynamic>> items,
  ) async {
    final batch = _db.batch();
    for (int i = 0; i < items.length; i++) {
      batch.update(_db.collection('collections_config').doc(items[i]['id']), {
        'order': i,
      });
    }
    await batch.commit();
    await bumpMessagesVersion();
  }

  static Stream<QuerySnapshot> listenToCollectionsConfig() {
    return _db.collection('collections_config').orderBy('order').snapshots();
  }

  // ===================== Ticker =====================
  static Future<List<Map<String, dynamic>>> getTickerMessages() async {
    final snapshot = await _db
        .collection('ticker_messages')
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Future<void> addTickerMessage(String text) async {
    final snapshot = await _db
        .collection('ticker_messages')
        .orderBy('order', descending: true)
        .limit(1)
        .get();
    final lastOrder = snapshot.docs.isEmpty
        ? 0
        : (snapshot.docs.first.data()['order'] ?? 0) as int;
    await _db.collection('ticker_messages').add({
      'text': text,
      'active': true,
      'order': lastOrder + 1,
    });
    await bumpTickerVersion();
  }

  static Future<void> updateTickerMessage(
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('ticker_messages').doc(docId).update(data);
    await bumpTickerVersion();
  }

  static Future<void> deleteTickerMessage(String docId) async {
    await _db.collection('ticker_messages').doc(docId).delete();
    await bumpTickerVersion();
  }

  static Future<void> reorderTickerMessages(
    List<Map<String, dynamic>> items,
  ) async {
    final batch = _db.batch();
    for (int i = 0; i < items.length; i++) {
      batch.update(_db.collection('ticker_messages').doc(items[i]['id']), {
        'order': i,
      });
    }
    await batch.commit();
    await bumpTickerVersion();
  }

  // ===================== Hijri Offset =====================
  static Future<int> getHijriOffset() async {
    final doc = await _db.collection('settings').doc('display_settings').get();
    return (doc.data()?['hijri_offset'] ?? 0) as int;
  }

static Future<void> updateHijriOffset(int newOffset) async {
  final batch = FirebaseFirestore.instance.batch();
  
  // 1. تحديث الفارق الهجري
  final displayRef = FirebaseFirestore.instance.collection('settings').doc('display_settings');
  batch.update(displayRef, {'hijri_offset': newOffset});
  
  // 2. ترفيع الفيرجن لكي يشعر به التطبيق الأساسي فوراً
  final versionRef = FirebaseFirestore.instance.collection('settings').doc('versions');
  batch.update(versionRef, {
    'hijri_version': FieldValue.increment(1), // يزود الفيرجن بمقدار 1 تلقائياً
  });
  
  await batch.commit();
}

  static Stream<int> listenToHijriOffset() {
    return _db
        .collection('settings')
        .doc('display_settings')
        .snapshots()
        .map((doc) => (doc.data()?['hijri_offset'] ?? 0) as int);
  }
}
