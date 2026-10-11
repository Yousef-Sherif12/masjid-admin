import 'package:masjid_admin/features/collections/domain/entities/collection_item.dart';

class CollectionItemModel extends CollectionItem {
  const CollectionItemModel({
    required super.id,
    required super.label,
    required super.type,
    required super.active,
    required super.order,
  });

  factory CollectionItemModel.fromMap(String id, Map<String, dynamic> map) {
    return CollectionItemModel(
      id: id,
      label: (map['label'] ?? id).toString(),
      type: (map['type'] ?? 'custom').toString(),
      active: map['active'] == true,
      order: ((map['order'] ?? 0) as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'type': type,
      'active': active,
      'order': order,
    };
  }
}
