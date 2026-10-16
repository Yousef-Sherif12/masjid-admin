import 'package:masjid_admin/features/ticker/domain/entities/admin_ticker_item.dart';

class AdminTickerState {
  final bool isLoading;
  final List<AdminTickerItem> items;
  final int hijriOffset;
  final double dateFontSize;
  final String contentFontFamily;
  final String? errorMessage;

  const AdminTickerState({
    this.isLoading = false,
    this.items = const [],
    this.hijriOffset = 0,
    this.dateFontSize = 15.0,
    this.contentFontFamily = 'Roboto',
    this.errorMessage,
  });

  AdminTickerState copyWith({
    bool? isLoading,
    List<AdminTickerItem>? items,
    int? hijriOffset,
    double? dateFontSize,
    String? contentFontFamily,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminTickerState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      hijriOffset: hijriOffset ?? this.hijriOffset,
      dateFontSize: dateFontSize ?? this.dateFontSize,
      contentFontFamily: contentFontFamily ?? this.contentFontFamily,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
