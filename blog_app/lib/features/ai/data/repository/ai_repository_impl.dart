import 'package:fpdart/fpdart.dart';

import '../../../../error/exception.dart';
import '../../../../error/failures.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/repository/ai_repository.dart';
import '../datasources/ai_remote_data_source.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;
  AiRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> summarize({required String content}) async {
    try {
      final summary = await remoteDataSource.summarize(content: content);
      return right(summary);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, AiSuggestion>> suggestMetadata({
    required String title,
    required String content,
    required List<String> allowedTopics,
  }) async {
    try {
      final suggestion = await remoteDataSource.suggestMetadata(
        title: title,
        content: content,
        allowedTopics: allowedTopics,
      );
      return right(suggestion);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
