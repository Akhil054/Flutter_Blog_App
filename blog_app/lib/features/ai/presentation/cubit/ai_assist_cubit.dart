import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ai_suggestion.dart';
import '../../domain/usecases/suggest_metadata.dart';
import '../../domain/usecases/summarize_content.dart';

part 'ai_assist_state.dart';

class AiAssistCubit extends Cubit<AiAssistState> {
  final SummarizeContent _summarizeContent;
  final SuggestMetadata _suggestMetadata;

  AiAssistCubit({
    required SummarizeContent summarizeContent,
    required SuggestMetadata suggestMetadata,
  })  : _summarizeContent = summarizeContent,
        _suggestMetadata = suggestMetadata,
        super(AiAssistInitial());

  Future<void> summarize(String content) async {
    emit(AiAssistLoading());
    final res = await _summarizeContent(SummarizeParams(content: content));
    res.fold(
      (failure) => emit(AiAssistFailure(failure.message)),
      (summary) => emit(AiSummaryReady(summary)),
    );
  }

  Future<void> suggestMetadata({
    required String title,
    required String content,
    required List<String> allowedTopics,
  }) async {
    emit(AiAssistLoading());
    final res = await _suggestMetadata(SuggestMetadataParams(
      title: title,
      content: content,
      allowedTopics: allowedTopics,
    ));
    res.fold(
      (failure) => emit(AiAssistFailure(failure.message)),
      (suggestion) => emit(AiSuggestionReady(suggestion)),
    );
  }

  void reset() => emit(AiAssistInitial());
}
