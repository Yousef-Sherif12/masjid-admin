import 'package:masjid_admin/features/messages/domain/entities/admin_message.dart';
import 'package:masjid_admin/features/messages/domain/entities/live_display_state.dart';

class MessagesState {
  final bool isLoading;
  final List<AdminMessage> messages;
  final LiveDisplayState liveDisplay;
  final String? errorMessage;

  const MessagesState({
    this.isLoading = false,
    this.messages = const [],
    this.liveDisplay = const LiveDisplayState(),
    this.errorMessage,
  });

  MessagesState copyWith({
    bool? isLoading,
    List<AdminMessage>? messages,
    LiveDisplayState? liveDisplay,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessagesState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      liveDisplay: liveDisplay ?? this.liveDisplay,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
