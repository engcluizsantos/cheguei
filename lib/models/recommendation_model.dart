class RecommendationModel {
  final String type;
  final String emoji;
  final String description;
  final double score;
  final bool recommended;

  const RecommendationModel({
    required this.type,
    required this.emoji,
    required this.description,
    required this.score,
    required this.recommended,
  });

  RecommendationModel copyWith({
    String? type,
    String? emoji,
    String? description,
    double? score,
    bool? recommended,
  }) {
    return RecommendationModel(
      type: type ?? this.type,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      score: score ?? this.score,
      recommended: recommended ?? this.recommended,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'emoji': emoji,
      'description': description,
      'score': score,
      'recommended': recommended,
    };
  }

  factory RecommendationModel.fromMap(Map<dynamic, dynamic> map) {
    return RecommendationModel(
      type: map['type'] ?? '',
      emoji: map['emoji'] ?? '',
      description: map['description'] ?? '',
      score: (map['score'] ?? 0).toDouble(),
      recommended: map['recommended'] ?? false,
    );
  }
}