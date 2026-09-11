import '../../domain/entities/ai_suggestion.dart';

class AiSuggestionModel extends AiSuggestion {
  AiSuggestionModel({
    required super.suggestedTitle,
    required super.suggestedTopics,
    required super.summary,
  });

  factory AiSuggestionModel.fromJson(Map<String, dynamic> map) {
    return AiSuggestionModel(
      suggestedTitle: map['suggestedTitle'] as String? ?? '',
      suggestedTopics: List<String>.from((map['suggestedTopics'] ?? [])),
      summary: map['summary'] as String? ?? '',
    );
  }
}
