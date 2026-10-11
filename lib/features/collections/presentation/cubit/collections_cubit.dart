import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjid_admin/features/collections/domain/entities/collection_item.dart';
import 'package:masjid_admin/features/collections/domain/repositories/collections_repository.dart';
import 'package:masjid_admin/features/collections/presentation/cubit/collections_state.dart';

class CollectionsCubit extends Cubit<CollectionsState> {
  final CollectionsRepository _repository;

  CollectionsCubit(this._repository) : super(const CollectionsState());

  Future<void> loadCollections() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repository.ensureDefaultCollectionsExist();
      final items = await _repository.getCollections();
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, collections: items));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'تعذر تحميل المجموعات: $e',
          ),
        );
      }
    }
  }

  Future<void> addCollection({
    required String key,
    required String label,
  }) async {
    try {
      await _repository.addCollection(key: key, label: label);
      await loadCollections();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل إضافة المجموعة: $e'));
      }
    }
  }

  Future<void> updateCollectionLabel({
    required String key,
    required String newLabel,
  }) async {
    try {
      await _repository.updateCollectionLabel(key: key, newLabel: newLabel);
      await loadCollections();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل تعديل اسم المجموعة: $e'));
      }
    }
  }

  Future<void> deleteCollection(String key) async {
    try {
      await _repository.deleteCollection(key);
      await loadCollections();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل حذف المجموعة: $e'));
      }
    }
  }

  Future<bool> toggleCollection(String key, bool active) async {
    try {
      final success = await _repository.toggleCollection(key, active);
      if (success) {
        await loadCollections();
      }
      return success;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل تحديث حالة المجموعة: $e'));
      }
      return false;
    }
  }

  Future<void> reorderCollections(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final list = List<CollectionItem>.from(state.collections);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    emit(state.copyWith(collections: list, clearError: true));
    try {
      await _repository.reorderCollections(list);
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل حفظ ترتيب المجموعات: $e'));
      }
    }
  }
}
