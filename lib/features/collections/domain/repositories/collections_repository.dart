import 'package:masjid_admin/features/collections/domain/entities/collection_item.dart';

abstract class CollectionsRepository {
  Future<void> ensureDefaultCollectionsExist();
  Future<List<CollectionItem>> getCollections();
  Future<void> addCollection({required String key, required String label});
  Future<void> updateCollectionLabel({
    required String key,
    required String newLabel,
  });
  Future<void> deleteCollection(String key);
  Future<bool> toggleCollection(String key, bool active);
  Future<void> reorderCollections(List<CollectionItem> items);
}
