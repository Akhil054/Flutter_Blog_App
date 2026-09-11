import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';
import '../repository/ai_repository.dart';

class SummarizeContent implements UseCase<String, SummarizeParams> {
  final AiRepository aiRepository;
  SummarizeContent(this.aiRepository);

  @override
  Future<Either<Failure, String>> call(SummarizeParams params) async {
    return await aiRepository.summarize(content: params.content);
  }
}

class SummarizeParams {
  final String content;

  SummarizeParams({required this.content});
}
