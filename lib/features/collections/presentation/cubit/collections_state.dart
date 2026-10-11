import 'package:masjid_admin/features/collections/domain/entities/collection_item.dart';

class CollectionsState {
  final bool isLoading;
  final List<CollectionItem> collections;
  final String? errorMessage;

  const CollectionsState({
    this.isLoading = false,
    this.collections = const [],
    this.errorMessage,
  });

  CollectionsState copyWith({
    bool? isLoading,
    List<CollectionItem>? collections,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CollectionsState(
      isLoading: isLoading ?? this.isLoading,
      collections: collections ?? this.collections,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
