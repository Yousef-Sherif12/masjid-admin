class CollectionItem {
  final String id;
  final String label;
  final String type;
  final bool active;
  final int order;

  const CollectionItem({
    required this.id,
    required this.label,
    required this.type,
    required this.active,
    required this.order,
  });

  bool get isBuiltIn => const {
        'quran_messages',
        'hadith_messages',
        'thaqil',
        'prayer_from_quran',
      }.contains(id);

  CollectionItem copyWith({
    String? id,
    String? label,
    String? type,
    bool? active,
    int? order,
  }) {
    return CollectionItem(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      active: active ?? this.active,
      order: order ?? this.order,
    );
  }
}
