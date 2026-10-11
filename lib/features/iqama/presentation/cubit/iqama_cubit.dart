import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjid_admin/features/iqama/domain/repositories/iqama_repository.dart';
import 'package:masjid_admin/features/iqama/presentation/cubit/iqama_state.dart';

class IqamaCubit extends Cubit<IqamaState> {
  final IqamaRepository _repository;

  IqamaCubit(this._repository) : super(const IqamaState());

  Future<void> loadIqamaTimes() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final remote = await _repository.getIqamaTimes();
      final merged = Map<String, int>.from(state.iqamaTimes)..addAll(remote);
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, iqamaTimes: merged));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'تعذر تحميل أوقات الإقامة: $e',
          ),
        );
      }
    }
  }

  void updateLocalMinutes(String prayerKey, int minutes) {
    final clamped = minutes.clamp(1, 30);
    final updated = Map<String, int>.from(state.iqamaTimes)
      ..[prayerKey] = clamped;
    emit(state.copyWith(iqamaTimes: updated, clearError: true));
  }

  Future<void> saveIqamaTimes() async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.updateIqamaTimes(state.iqamaTimes);
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, saveSuccess: true));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: 'فشل حفظ أوقات الإقامة: $e',
          ),
        );
      }
    }
  }
}
