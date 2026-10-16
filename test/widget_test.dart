import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_admin/features/collections/domain/entities/collection_item.dart';
import 'package:masjid_admin/features/collections/domain/repositories/collections_repository.dart';
import 'package:masjid_admin/features/collections/presentation/cubit/collections_cubit.dart';
import 'package:masjid_admin/features/iqama/domain/repositories/iqama_repository.dart';
import 'package:masjid_admin/features/iqama/presentation/cubit/iqama_cubit.dart';
import 'package:masjid_admin/features/messages/domain/entities/admin_message.dart';
import 'package:masjid_admin/features/messages/domain/entities/live_display_state.dart';
import 'package:masjid_admin/features/messages/domain/repositories/messages_repository.dart';
import 'package:masjid_admin/features/messages/presentation/cubit/messages_cubit.dart';
import 'package:masjid_admin/features/ticker/domain/entities/admin_ticker_item.dart';
import 'package:masjid_admin/features/ticker/domain/repositories/admin_ticker_repository.dart';
import 'package:masjid_admin/features/ticker/presentation/cubit/admin_ticker_cubit.dart';

class FakeCollectionsRepository implements CollectionsRepository {
  List<CollectionItem> items = const [
    CollectionItem(
      id: 'quran_messages',
      label: 'القرآن الكريم',
      type: 'quran',
      active: true,
      order: 0,
    ),
    CollectionItem(
      id: 'hadith_messages',
      label: 'الأحاديث النبوية',
      type: 'hadith',
      active: true,
      order: 1,
    ),
  ];

  @override
  Future<void> ensureDefaultCollectionsExist() async {}

  @override
  Future<List<CollectionItem>> getCollections() async => items;

  @override
  Future<void> addCollection({
    required String key,
    required String label,
  }) async {
    items = [
      ...items,
      CollectionItem(
        id: key,
        label: label,
        type: key,
        active: true,
        order: items.length,
      ),
    ];
  }

  @override
  Future<void> updateCollectionLabel({
    required String key,
    required String newLabel,
  }) async {
    items = items
        .map((e) => e.id == key ? e.copyWith(label: newLabel) : e)
        .toList();
  }

  @override
  Future<void> deleteCollection(String key) async {
    items = items.where((e) => e.id != key).toList();
  }

  @override
  Future<bool> toggleCollection(String key, bool active) async {
    items = items
        .map((e) => e.id == key ? e.copyWith(active: active) : e)
        .toList();
    return true;
  }

  @override
  Future<void> reorderCollections(List<CollectionItem> reordered) async {
    items = reordered;
  }
}

class FakeMessagesRepository implements MessagesRepository {
  List<AdminMessage> messages = const [
    AdminMessage(
      id: 'm1',
      text: 'سبحان الله وبحمده',
      subText: 'البخاري',
      type: 'hadith',
      duration: 30,
      fontSize: 40,
      order: 0,
    ),
  ];
  LiveDisplayState liveState = const LiveDisplayState();

  @override
  Future<List<AdminMessage>> getMessages(String collection) async => messages;

  @override
  Stream<LiveDisplayState> listenToLiveDisplay() => Stream.value(liveState);

  @override
  Future<void> addMessage({
    required String collection,
    required String text,
    required String subText,
    required String fadl,
    required int duration,
    required double? fontSize,
  }) async {
    messages = [
      ...messages,
      AdminMessage(
        id: 'm2',
        text: text,
        subText: subText,
        fadl: fadl,
        type: collection,
        duration: duration,
        fontSize: fontSize,
        order: messages.length,
      ),
    ];
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
  }) async {}

  @override
  Future<void> deleteMessage(String collection, String docId) async {
    messages = messages.where((m) => m.id != docId).toList();
  }

  @override
  Future<void> reorderMessages(
    String collection,
    List<AdminMessage> items,
  ) async {
    messages = items;
  }

  @override
  Future<void> toggleLiveDisplay(String collection, String docId) async {
    liveState = LiveDisplayState(
      active: true,
      collection: collection,
      docId: docId,
    );
  }

  @override
  Future<void> clearLiveDisplay() async {
    liveState = const LiveDisplayState();
  }
}

class FakeIqamaRepository implements IqamaRepository {
  Map<String, int> times = {'الفجر': 20, 'الظهر': 15};

  @override
  Future<Map<String, int>> getIqamaTimes() async => times;

  @override
  Future<void> updateIqamaTimes(Map<String, int> newTimes) async {
    times = Map<String, int>.from(newTimes);
  }
}

class FakeAdminTickerRepository implements AdminTickerRepository {
  List<AdminTickerItem> items = const [
    AdminTickerItem(id: 't1', text: 'مرحباً بكم', active: true, order: 0),
  ];
  int hijriOffset = 0;

  @override
  Future<List<AdminTickerItem>> getTickerMessages() async => items;

  @override
  Stream<int> listenToHijriOffset() => Stream.value(hijriOffset);

  @override
  Future<void> addTickerMessage(String text) async {
    items = [
      ...items,
      AdminTickerItem(
        id: 't2',
        text: text,
        active: true,
        order: items.length,
      ),
    ];
  }

  @override
  Future<void> updateTickerMessage(
    String docId,
    Map<String, dynamic> data,
  ) async {}

  @override
  Future<void> deleteTickerMessage(String docId) async {
    items = items.where((e) => e.id != docId).toList();
  }

  @override
  Future<void> reorderTickerMessages(List<AdminTickerItem> reordered) async {
    items = reordered;
  }

  @override
  Future<void> updateHijriOffset(int newOffset) async {
    hijriOffset = newOffset;
  }

  double dateFontSize = 15.0;
  String contentFontFamily = 'Roboto';

  @override
  Stream<double> listenToDateFontSize() => Stream.value(dateFontSize);

  @override
  Future<void> updateDateFontSize(double newSize) async {
    dateFontSize = newSize;
  }

  @override
  Stream<String> listenToContentFontFamily() => Stream.value(contentFontFamily);

  @override
  Future<void> updateContentFontFamily(String newFamily) async {
    contentFontFamily = newFamily;
  }
}

void main() {
  test('CollectionsCubit loads and reorders collections cleanly', () async {
    final repo = FakeCollectionsRepository();
    final cubit = CollectionsCubit(repo);
    await cubit.loadCollections();

    expect(cubit.state.collections.length, 2);
    await cubit.reorderCollections(0, 2);
    expect(cubit.state.collections.first.id, 'hadith_messages');
    await cubit.close();
  });

  test('MessagesCubit loads messages and adds new message cleanly', () async {
    final repo = FakeMessagesRepository();
    final cubit = MessagesCubit(repo, collectionKey: 'hadith_messages');
    await cubit.init();

    expect(cubit.state.messages.length, 1);
    await cubit.addMessage(
      text: 'إنما الأعمال بالنيات',
      subText: 'متفق عليه',
      fadl: '',
      duration: 20,
      fontSize: 38,
    );
    expect(cubit.state.messages.length, 2);
    await cubit.close();
  });

  test('IqamaCubit loads, updates minutes, and saves iqama times cleanly',
      () async {
    final repo = FakeIqamaRepository();
    final cubit = IqamaCubit(repo);
    await cubit.loadIqamaTimes();

    expect(cubit.state.iqamaTimes['الفجر'], 20);
    cubit.updateLocalMinutes('الفجر', 25);
    await cubit.saveIqamaTimes();
    expect(cubit.state.saveSuccess, isTrue);
    expect(repo.times['الفجر'], 25);
    await cubit.close();
  });

  test('AdminTickerCubit loads ticker messages and updates hijri offset',
      () async {
    final repo = FakeAdminTickerRepository();
    final cubit = AdminTickerCubit(repo);
    await cubit.init();

    expect(cubit.state.items.length, 1);
    await cubit.updateHijriOffset(1);
    expect(repo.hijriOffset, 1);
    await cubit.close();
  });
}
