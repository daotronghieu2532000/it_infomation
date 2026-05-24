class DevWorkflow {
  final int id;
  final String title;
  final String description;
  final String toolCategory;
  final String contentMarkdown;
  final String authorName;
  int likesCount;
  int copyCount;
  final int createdAt;
  final int updatedAt;
  bool isLiked;
  bool isBookmarked;

  DevWorkflow({
    required this.id,
    required this.title,
    required this.description,
    required this.toolCategory,
    required this.contentMarkdown,
    required this.authorName,
    required this.likesCount,
    required this.copyCount,
    required this.createdAt,
    required this.updatedAt,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  factory DevWorkflow.fromJson(Map<String, dynamic> json) {
    return DevWorkflow(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      toolCategory: json['tool_category'] ?? '',
      contentMarkdown: json['content_markdown'] ?? '',
      authorName: json['author_name'] ?? 'Admin',
      likesCount: json['likes_count'] is int ? json['likes_count'] : int.parse(json['likes_count'].toString()),
      copyCount: json['copy_count'] is int ? json['copy_count'] : int.parse(json['copy_count'].toString()),
      createdAt: json['created_at'] is int ? json['created_at'] : int.parse(json['created_at'].toString()),
      updatedAt: json['updated_at'] is int ? json['updated_at'] : int.parse(json['updated_at'].toString()),
      isLiked: json['is_liked'] == true || json['is_liked'] == 1 || json['is_liked'] == '1',
      isBookmarked: json['is_bookmarked'] == true || json['is_bookmarked'] == 1 || json['is_bookmarked'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tool_category': toolCategory,
      'content_markdown': contentMarkdown,
      'author_name': authorName,
      'likes_count': likesCount,
      'copy_count': copyCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_liked': isLiked,
      'is_bookmarked': isBookmarked,
    };
  }
}
