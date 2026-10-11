import 'package:masjid_admin/features/ticker/domain/entities/admin_ticker_item.dart';

class AdminTickerState {
  final bool isLoading;
  final List<AdminTickerItem> items;
  final int hijriOffset;
  final String? errorMessage;

  const AdminTickerState({
    this.isLoading = false,
    this.items = const [],
    this.hijriOffset = 0,
    this.errorMessage,
  });

  AdminTickerState copyWith({
    bool? isLoading,
    List<AdminTickerItem>? items,
    int? hijriOffset,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminTickerState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      hijriOffset: hijriOffset ?? this.hijriOffset,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
