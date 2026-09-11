part of 'ai_assist_cubit.dart';

@immutable
sealed class AiAssistState {}

final class AiAssistInitial extends AiAssistState {}

final class AiAssistLoading extends AiAssistState {}

final class AiAssistFailure extends AiAssistState {
  final String error;

  AiAssistFailure(this.error);
}

final class AiSummaryReady extends AiAssistState {
  final String summary;

  AiSummaryReady(this.summary);
}

final class AiSuggestionReady extends AiAssistState {
  final AiSuggestion suggestion;

  AiSuggestionReady(this.suggestion);
}
