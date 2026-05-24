class CuratedPrompt {
  final int id;
  final String title;
  final String targetModel;
  final String category;
  final String description;
  final String promptText;
  int copyCount;
  int likesCount;
  final int createdAt;
  bool isBookmarked;
  bool isLiked;

  CuratedPrompt({
    required this.id,
    required this.title,
    required this.targetModel,
    required this.category,
    required this.description,
    required this.promptText,
    required this.copyCount,
    required this.likesCount,
    required this.createdAt,
    this.isBookmarked = false,
    this.isLiked = false,
  });

  factory CuratedPrompt.fromJson(Map<String, dynamic> json) {
    return CuratedPrompt(
      id: json['id'] as int,
      title: json['title'] as String,
      targetModel: json['target_model'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      promptText: json['prompt_text'] as String,
      copyCount: json['copy_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: json['created_at'] as int? ?? 0,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'target_model': targetModel,
      'category': category,
      'description': description,
      'prompt_text': promptText,
      'copy_count': copyCount,
      'likes_count': likesCount,
      'created_at': createdAt,
      'is_bookmarked': isBookmarked,
      'is_liked': isLiked,
    };
  }
}
