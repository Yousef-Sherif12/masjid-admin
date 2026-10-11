import 'package:masjid_admin/features/messages/domain/entities/admin_message.dart';
import 'package:masjid_admin/features/messages/domain/entities/live_display_state.dart';

abstract class MessagesRepository {
  Future<List<AdminMessage>> getMessages(String collection);
  Future<void> addMessage({
    required String collection,
    required String text,
    required String subText,
    required String fadl,
    required int duration,
    required double? fontSize,
  });
  Future<void> updateMessage({
    required String collection,
    required String docId,
    required String text,
    required String subText,
    required String fadl,
    required int duration,
    required double? fontSize,
  });
  Future<void> deleteMessage(String collection, String docId);
  Future<void> reorderMessages(String collection, List<AdminMessage> items);
  Future<void> toggleLiveDisplay(String collection, String docId);
  Future<void> clearLiveDisplay();
  Stream<LiveDisplayState> listenToLiveDisplay();
}
