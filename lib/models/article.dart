class Article {
  final int id;
  final String title;
  final String slug;
  final String summary;
  final String? content;
  final String? thumbnailUrl;
  final String sourceName;
  final String? sourceUrl;
  final String category;
  final int viewCount;
  final bool isWeeklyHighlight;
  final int publishedAt;
  final int createdAt;
  final int updatedAt;
  bool isBookmarked;
  bool isLiked;

  Article({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    this.content,
    this.thumbnailUrl,
    required this.sourceName,
    this.sourceUrl,
    required this.category,
    required this.viewCount,
    required this.isWeeklyHighlight,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.isBookmarked = false,
    this.isLiked = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      sourceName: json['source_name'] as String? ?? 'TechFlow',
      sourceUrl: json['source_url'] as String?,
      category: json['category'] as String? ?? 'General',
      viewCount: json['view_count'] as int? ?? 0,
      isWeeklyHighlight: (json['is_weekly_highlight'] as int? ?? 0) == 1,
      publishedAt: json['published_at'] as int? ?? 0,
      createdAt: json['created_at'] as int? ?? 0,
      updatedAt: json['updated_at'] as int? ?? 0,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'summary': summary,
      'content': content,
      'thumbnail_url': thumbnailUrl,
      'source_name': sourceName,
      'source_url': sourceUrl,
      'category': category,
      'view_count': viewCount,
      'is_weekly_highlight': isWeeklyHighlight ? 1 : 0,
      'published_at': publishedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_bookmarked': isBookmarked,
      'is_liked': isLiked,
    };
  }
}
