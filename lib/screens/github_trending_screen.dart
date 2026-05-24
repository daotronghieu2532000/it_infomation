import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../models/github_repo.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/shimmer_loader.dart';
import 'settings_screen.dart';

class GitHubTrendingScreen extends StatelessWidget {
  const GitHubTrendingScreen({super.key});

  // Map ngôn ngữ lập trình sang màu sắc tương ứng (Aesthetic color indicator)
  Color _getLanguageColor(String? language) {
    if (language == null) return Colors.grey;
    switch (language.toLowerCase()) {
      case 'dart':
        return const Color(0xFF00B4AB);
      case 'python':
        return const Color(0xFF3572A5);
      case 'javascript':
      case 'js':
        return const Color(0xFFF1E05A);
      case 'typescript':
      case 'ts':
        return const Color(0xFF3178C6);
      case 'go':
        return const Color(0xFF00ADD8);
      case 'rust':
        return const Color(0xFFDEA584);
      case 'c++':
        return const Color(0xFFF34B7D);
      case 'html':
        return const Color(0xFFE34C26);
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final languages = ['All', 'Dart', 'Python', 'JavaScript', 'TypeScript', 'Go', 'Rust', 'C++'];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadTrendingRepos(),
          color: const Color(0xFF06B6D4),
          backgroundColor: const Color(0xFF161F30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('GITHUB XU HƯỚNG', 'GITHUB TRENDING'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('Bảng xếp hạng dự án open-source bùng nổ', 'Trending open-source projects ranking'),
                          style: const TextStyle(fontSize: 11, color: Colors.white54),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        // Manual GitHub Sync button
                        provider.isSyncingGitHub
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06B6D4)),
                              )
                            : IconButton(
                                icon: const Icon(Icons.sync_rounded, color: Color(0xFF06B6D4), size: 22),
                                onPressed: () {
                                  provider.triggerSyncGitHub().then((res) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(res['message'] ?? context.tr('Đồng bộ GitHub hoàn tất!', 'GitHub sync completed!')),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  });
                                },
                              ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter Controls (Period & Language)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Period Selector (Daily / Weekly)
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161F30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.8),
                        ),
                        child: DropdownButton<String>(
                          value: provider.selectedRepoPeriod,
                          dropdownColor: const Color(0xFF161F30),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                          underline: const SizedBox(),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          items: [
                            DropdownMenuItem(value: 'daily', child: Text(context.tr('HÀNG NGÀY', 'DAILY'))),
                            DropdownMenuItem(value: 'weekly', child: Text(context.tr('HÀNG TUẦN', 'WEEKLY'))),
                          ],
                          onChanged: (val) {
                            if (val != null) provider.setRepoFilters(period: val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Language Selector
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161F30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.8),
                        ),
                        child: DropdownButton<String>(
                          value: provider.selectedRepoLanguage.isEmpty ? 'All' : provider.selectedRepoLanguage,
                          dropdownColor: const Color(0xFF161F30),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                          underline: const SizedBox(),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          items: languages.map((lang) {
                            return DropdownMenuItem(value: lang, child: Text((lang == 'All' ? context.tr('Tất cả', 'All') : lang).toUpperCase()));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              provider.setRepoFilters(language: val == 'All' ? '' : val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Repositories List
              Expanded(
                child: provider.isLoadingRepos
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ShimmerLoader.listSkeleton(count: 4),
                      )
                    : provider.trendingRepos.isEmpty
                        ? Center(
                            child: Text(
                              context.tr('Không có repository trending nào phù hợp.', 'No trending repositories match your filter.'),
                              style: const TextStyle(color: Colors.white60),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: provider.trendingRepos.length,
                            itemBuilder: (context, index) {
                              final repo = provider.trendingRepos[index];
                              return _buildRepoCard(context, repo, provider, index + 1);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepoCard(BuildContext context, GitHubRepo repo, AppProvider provider, int rank) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16.0),
        onTap: () => _showRepoDetailsDialog(context, repo, provider),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank circle badge
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rank <= 3 ? const Color(0xFF06B6D4).withOpacity(0.2) : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: rank <= 3 ? const Color(0xFF06B6D4) : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: rank <= 3 ? const Color(0xFF06B6D4) : Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Repo name and owner
                Expanded(
                  child: Text(
                    repo.repoName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Bookmark star
                if (provider.isLoggedIn)
                  GestureDetector(
                    onTap: () => provider.toggleBookmark(itemType: 'repo', itemId: repo.id),
                    child: Icon(
                      repo.isBookmarked ? Icons.star : Icons.star_border,
                      color: const Color(0xFF06B6D4),
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            if (repo.description != null && repo.description!.isNotEmpty)
              Text(
                repo.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 12),
            // Stats & language row
            Row(
              children: [
                // Language indicator
                if (repo.language != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getLanguageColor(repo.language),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    repo.language!,
                    style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 16),
                ],
                // Star count icon
                const Icon(Icons.star_outline_rounded, size: 14, color: Colors.white54),
                const SizedBox(width: 3),
                Text(
                  _formatCount(repo.starsCount),
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const SizedBox(width: 16),
                // Fork count icon
                const Icon(Icons.call_split, size: 12, color: Colors.white54),
                const SizedBox(width: 3),
                Text(
                  _formatCount(repo.forksCount),
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const Spacer(),
                // Stars today dynamic badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, size: 10, color: Color(0xFF10B981)),
                      const SizedBox(width: 2),
                      Text(
                        '+${repo.starsToday}',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return '$number';
  }

  void _showRepoDetailsDialog(BuildContext context, GitHubRepo repo, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161F30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                repo.repoName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                '${context.tr('Tác giả', 'Author')}: ${repo.owner}',
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const Divider(color: Colors.white12, height: 20),
              Text(
                context.tr('GIỚI THIỆU', 'ABOUT'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF06B6D4)),
              ),
              const SizedBox(height: 6),
              Text(
                repo.description ?? context.tr('Không có mô tả dự án.', 'No project description.'),
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final Uri url = Uri.parse(repo.repoUrl);
                        try {
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${context.tr('Không thể mở liên kết', 'Could not open link')}: ${repo.repoUrl}')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${context.tr('Lỗi', 'Error')}: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(context.tr('MỞ TRÊN GITHUB', 'OPEN ON GITHUB')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
