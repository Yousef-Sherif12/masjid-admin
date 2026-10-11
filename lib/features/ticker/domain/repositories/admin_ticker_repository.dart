import 'package:masjid_admin/features/ticker/domain/entities/admin_ticker_item.dart';

abstract class AdminTickerRepository {
  Future<List<AdminTickerItem>> getTickerMessages();
  Future<void> addTickerMessage(String text);
  Future<void> updateTickerMessage(String docId, Map<String, dynamic> data);
  Future<void> deleteTickerMessage(String docId);
  Future<void> reorderTickerMessages(List<AdminTickerItem> items);
  Stream<int> listenToHijriOffset();
  Future<void> updateHijriOffset(int newOffset);
}
