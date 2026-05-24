class GitHubRepo {
  final int id;
  final String repoName;
  final String owner;
  final String? description;
  final String? language;
  final int starsCount;
  final int forksCount;
  final int starsToday;
  final String repoUrl;
  final String rankPeriod;
  final int fetchedAt;
  bool isBookmarked;

  GitHubRepo({
    required this.id,
    required this.repoName,
    required this.owner,
    this.description,
    this.language,
    required this.starsCount,
    required this.forksCount,
    required this.starsToday,
    required this.repoUrl,
    required this.rankPeriod,
    required this.fetchedAt,
    this.isBookmarked = false,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      id: json['id'] as int,
      repoName: json['repo_name'] as String,
      owner: json['owner'] as String,
      description: json['description'] as String?,
      language: json['language'] as String?,
      starsCount: json['stars_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      starsToday: json['stars_today'] as int? ?? 0,
      repoUrl: json['repo_url'] as String,
      rankPeriod: json['rank_period'] as String? ?? 'daily',
      fetchedAt: json['fetched_at'] as int? ?? 0,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repo_name': repoName,
      'owner': owner,
      'description': description,
      'language': language,
      'stars_count': starsCount,
      'forks_count': forksCount,
      'stars_today': starsToday,
      'repo_url': repoUrl,
      'rank_period': rankPeriod,
      'fetched_at': fetchedAt,
      'is_bookmarked': isBookmarked,
    };
  }
}
