import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjid_admin/features/ticker/domain/entities/admin_ticker_item.dart';
import 'package:masjid_admin/features/ticker/domain/repositories/admin_ticker_repository.dart';
import 'package:masjid_admin/features/ticker/presentation/cubit/admin_ticker_state.dart';

class AdminTickerCubit extends Cubit<AdminTickerState> {
  final AdminTickerRepository _repository;
  StreamSubscription<int>? _hijriSubscription;

  AdminTickerCubit(this._repository) : super(const AdminTickerState());

  Future<void> init() async {
    _hijriSubscription?.cancel();
    _hijriSubscription = _repository.listenToHijriOffset().listen((offset) {
      if (!isClosed) {
        emit(state.copyWith(hijriOffset: offset));
      }
    });
    await loadTickerMessages();
  }

  Future<void> loadTickerMessages() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final list = await _repository.getTickerMessages();
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, items: list));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'تعذر تحميل رسائل الشريط: $e',
          ),
        );
      }
    }
  }

  Future<void> addMessage(String text) async {
    try {
      await _repository.addTickerMessage(text);
      await loadTickerMessages();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل إضافة الرسالة: $e'));
      }
    }
  }

  Future<void> updateText(String docId, String text) async {
    try {
      await _repository.updateTickerMessage(docId, {'text': text});
      await loadTickerMessages();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل تعديل الرسالة: $e'));
      }
    }
  }

  Future<void> toggleActive(String docId, bool active) async {
    try {
      await _repository.updateTickerMessage(docId, {'active': active});
      await loadTickerMessages();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل تحديث حالة الرسالة: $e'));
      }
    }
  }

  Future<void> deleteMessage(String docId) async {
    try {
      await _repository.deleteTickerMessage(docId);
      await loadTickerMessages();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل حذف الرسالة: $e'));
      }
    }
  }

  Future<void> reorderMessages(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final list = List<AdminTickerItem>.from(state.items);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    emit(state.copyWith(items: list, clearError: true));
    try {
      await _repository.reorderTickerMessages(list);
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل حفظ ترتيب الرسائل: $e'));
      }
    }
  }

  Future<void> updateHijriOffset(int newOffset) async {
    try {
      await _repository.updateHijriOffset(newOffset);
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'فشل تحديث التاريخ الهجري: $e'));
      }
    }
  }

  @override
  Future<void> close() {
    _hijriSubscription?.cancel();
    return super.close();
  }
}
