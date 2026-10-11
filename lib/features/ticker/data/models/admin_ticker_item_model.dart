import 'package:masjid_admin/features/ticker/domain/entities/admin_ticker_item.dart';

class AdminTickerItemModel extends AdminTickerItem {
  const AdminTickerItemModel({
    required super.id,
    required super.text,
    required super.active,
    required super.order,
  });

  factory AdminTickerItemModel.fromMap(String id, Map<String, dynamic> map) {
    return AdminTickerItemModel(
      id: id,
      text: (map['text'] ?? '').toString(),
      active: map['active'] ?? true,
      order: ((map['order'] ?? 0) as num).toInt(),
    );
  }
}
