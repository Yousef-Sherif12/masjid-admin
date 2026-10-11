import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjid_admin/features/messages/domain/entities/admin_message.dart';
import 'package:masjid_admin/features/messages/domain/entities/live_display_state.dart';
import 'package:masjid_admin/features/messages/domain/repositories/messages_repository.dart';
import 'package:masjid_admin/features/messages/presentation/cubit/messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final MessagesRepository _repository;
  final String collectionKey;
  StreamSubscription<LiveDisplayState>? _liveSubscription;

  MessagesCubit(this._repository, {required this.collectionKey})
      : super(const MessagesState());

  Future<void> init() async {
    _liveSubscription?.cancel();
    _liveSubscription = _repository.listenToLiveDisplay().listen((liveState) {
      if (!isClosed) {
        emit(state.copyWith(liveDisplay: liveState));
      }
    });
    await loadMessages();
  }

  Future<void> loadMessages() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final msgs = await _repository.getMessages(collectionKey);
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, messages: msgs));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'تعذر تحميل النصوص: $e',
          ),
        );
      }
    }
  }

  Future<void> addMessage({
    required String text,
    required String subText,
    required String fadl,
    required int duration,
    required double? fontSize,
  }) async {
    try {
      await _repository.addMessage(
        collection: collectionKey,
        text: text,
        subText: subText,
        fadl: fadl,
        duration: duration,
        fontSize: fontSize,
      );
      await loadMessages();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل إضافة النص: $e'));
      }
    }
  }

  Future<void> updateMessage({
    required String docId,
    required String text,
    required String subText,
    required String fadl,
    required int duration,
    required double? fontSize,
  }) async {
    try {
      await _repository.updateMessage(
        collection: collectionKey,
        docId: docId,
        text: text,
        subText: subText,
        fadl: fadl,
        duration: duration,
        fontSize: fontSize,
      );
      await loadMessages();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل تعديل النص: $e'));
      }
    }
  }

  Future<void> deleteMessage(String docId) async {
    try {
      await _repository.deleteMessage(collectionKey, docId);
      await loadMessages();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل حذف النص: $e'));
      }
    }
  }

  Future<void> reorderMessages(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final list = List<AdminMessage>.from(state.messages);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    emit(state.copyWith(messages: list, clearError: true));
    try {
      await _repository.reorderMessages(collectionKey, list);
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل حفظ ترتيب النصوص: $e'));
      }
    }
  }

  Future<void> toggleLiveDisplay(String docId) async {
    try {
      await _repository.toggleLiveDisplay(collectionKey, docId);
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل تبديل البث المباشر: $e'));
      }
    }
  }

  Future<void> stopLiveDisplay() async {
    try {
      await _repository.clearLiveDisplay();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل إيقاف البث المباشر: $e'));
      }
    }
  }

  @override
  Future<void> close() {
    _liveSubscription?.cancel();
    return super.close();
  }
}
