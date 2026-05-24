class AiTool {
  final int id;
  final String name;
  final String category;
  final String pricingType;
  final String pricingDetail;
  final String speedRating;
  final String contextWindow;
  final double efficiencyScore;
  final String description;
  final String evaluation;
  final String howToUse;
  final bool isFreePrioritized;
  final String? websiteUrl;

  AiTool({
    required this.id,
    required this.name,
    required this.category,
    required this.pricingType,
    required this.pricingDetail,
    required this.speedRating,
    required this.contextWindow,
    required this.efficiencyScore,
    required this.description,
    required this.evaluation,
    required this.howToUse,
    required this.isFreePrioritized,
    this.websiteUrl,
  });

  factory AiTool.fromJson(Map<String, dynamic> json) {
    return AiTool(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      pricingType: json['pricing_type'] as String,
      pricingDetail: json['pricing_detail'] as String,
      speedRating: json['speed_rating'] as String,
      contextWindow: json['context_window'] as String,
      efficiencyScore: (json['efficiency_score'] as num).toDouble(),
      description: json['description'] as String,
      evaluation: json['evaluation'] as String,
      howToUse: json['how_to_use'] as String? ?? '',
      isFreePrioritized: json['is_free_prioritized'] == true || json['is_free_prioritized'] == 1,
      websiteUrl: json['website_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'pricing_type': pricingType,
      'pricing_detail': pricingDetail,
      'speed_rating': speedRating,
      'context_window': contextWindow,
      'efficiency_score': efficiencyScore,
      'description': description,
      'evaluation': evaluation,
      'how_to_use': howToUse,
      'is_free_prioritized': isFreePrioritized,
      'website_url': websiteUrl,
    };
  }
}
