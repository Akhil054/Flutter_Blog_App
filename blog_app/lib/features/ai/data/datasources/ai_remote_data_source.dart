import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../error/exception.dart';
import '../models/ai_suggestion_model.dart';

abstract interface class AiRemoteDataSource {
  Future<String> summarize({required String content});

  Future<AiSuggestionModel> suggestMetadata({
    required String title,
    required String content,
    required List<String> allowedTopics,
  });
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final SupabaseClient supabaseClient;
  AiRemoteDataSourceImpl({required this.supabaseClient});

  Future<Map<String, dynamic>> _invoke(Map<String, dynamic> body) async {
    final res = await supabaseClient.functions.invoke('ai-assist', body: body);
    if (res.status != 200) {
      throw ServerException(res.data.toString());
    }
    return Map<String, dynamic>.from(res.data);
  }

  @override
  Future<String> summarize({required String content}) async {
    try {
      final data = await _invoke({'action': 'summarize', 'content': content});
      return data['summary'] as String? ?? '';
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AiSuggestionModel> suggestMetadata({
    required String title,
    required String content,
    required List<String> allowedTopics,
  }) async {
    try {
      final data = await _invoke({
        'action': 'suggest_metadata',
        'title': title,
        'content': content,
        'allowedTopics': allowedTopics,
      });
      return AiSuggestionModel.fromJson(data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
