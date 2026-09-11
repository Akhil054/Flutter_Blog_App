import 'package:fpdart/fpdart.dart';

import '../../../../error/failures.dart';
import '../entities/ai_suggestion.dart';

abstract interface class AiRepository {
  Future<Either<Failure, String>> summarize({required String content});

  Future<Either<Failure, AiSuggestion>> suggestMetadata({
    required String title,
    required String content,
    required List<String> allowedTopics,
  });
}
