class IqamaState {
  final bool isLoading;
  final bool isSaving;
  final Map<String, int> iqamaTimes;
  final String? errorMessage;
  final bool saveSuccess;

  const IqamaState({
    this.isLoading = false,
    this.isSaving = false,
    this.iqamaTimes = const {
      'الفجر': 20,
      'الظهر': 15,
      'العصر': 15,
      'المغرب': 10,
      'العشاء': 15,
    },
    this.errorMessage,
    this.saveSuccess = false,
  });

  IqamaState copyWith({
    bool? isLoading,
    bool? isSaving,
    Map<String, int>? iqamaTimes,
    String? errorMessage,
    bool? saveSuccess,
    bool clearError = false,
  }) {
    return IqamaState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      iqamaTimes: iqamaTimes ?? this.iqamaTimes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      saveSuccess: saveSuccess ?? false,
    );
  }
}
