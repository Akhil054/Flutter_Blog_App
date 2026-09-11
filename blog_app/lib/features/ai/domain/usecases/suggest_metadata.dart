import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';
import '../entities/ai_suggestion.dart';
import '../repository/ai_repository.dart';

class SuggestMetadata implements UseCase<AiSuggestion, SuggestMetadataParams> {
  final AiRepository aiRepository;
  SuggestMetadata(this.aiRepository);

  @override
  Future<Either<Failure, AiSuggestion>> call(SuggestMetadataParams params) async {
    return await aiRepository.suggestMetadata(
      title: params.title,
      content: params.content,
      allowedTopics: params.allowedTopics,
    );
  }
}

class SuggestMetadataParams {
  final String title;
  final String content;
  final List<String> allowedTopics;

  SuggestMetadataParams({
    required this.title,
    required this.content,
    required this.allowedTopics,
  });
}
