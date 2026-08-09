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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadTrendingRepos(),
          color: const Color(0xFF0A84FF),
          backgroundColor: const Color(0xFF1C1C1E),
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
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
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
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A84FF)),
                              )
                            : IconButton(
                                icon: const Icon(Icons.sync_rounded, color: Color(0xFF0A84FF), size: 22),
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

              // Filter Controls (Period & Language) — Apple style flat
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1C1C1E),
                  border: Border(
                    bottom: BorderSide(color: Colors.white12, width: 0.5),
                    top: BorderSide(color: Colors.white12, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    // Period Selector (Daily / Weekly)
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.white12, width: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Colors.white38),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String>(
                                value: provider.selectedRepoPeriod,
                                dropdownColor: const Color(0xFF1C1C1E),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 16),
                                underline: const SizedBox(),
                                isExpanded: true,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                items: [
                                  DropdownMenuItem(value: 'daily', child: Text(context.tr('HÀNG NGÀY', 'DAILY'))),
                                  DropdownMenuItem(value: 'weekly', child: Text(context.tr('HÀNG TUẦN', 'WEEKLY'))),
                                ],
                                onChanged: (val) {
                                  if (val != null) provider.setRepoFilters(period: val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Language Selector
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.code_rounded, size: 14, color: Colors.white38),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String>(
                                value: provider.selectedRepoLanguage.isEmpty ? 'All' : provider.selectedRepoLanguage,
                                dropdownColor: const Color(0xFF1C1C1E),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 16),
                                underline: const SizedBox(),
                                isExpanded: true,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                items: languages.map((lang) {
                                  return DropdownMenuItem(value: lang, child: Text((lang == 'All' ? context.tr('TẤT CẢ NGÔN NGỮ', 'ALL LANGUAGES') : lang).toUpperCase()));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    provider.setRepoFilters(language: val == 'All' ? '' : val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                            padding: EdgeInsets.zero,
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
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      child: GlassmorphicCard(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        borderRadius: 0,
        borderWidth: 0,
        backgroundColor: Colors.transparent,
        onTap: () => _showRepoDetailsDialog(context, repo, provider),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank number badge — phẳng, không bo góc hoặc dùng icon hạng 1, 2, 3
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  child: rank == 1
                      ? Image.asset('assets/award.png', width: 32, height: 32)
                      : rank == 2
                          ? Image.asset('assets/second-rank.png', width: 28, height: 28)
                          : rank == 3
                              ? Image.asset('assets/3rd-place.png', width: 28, height: 28)
                              : Container(
                                  width: 20,
                                  height: 20,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '$rank',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                ),
                const SizedBox(width: 10),
                // Repo name: owner / repoName
                Expanded(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                      children: [
                        TextSpan(
                          text: '${repo.owner} / ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white54,
                          ),
                        ),
                        TextSpan(
                          text: repo.repoName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bookmark star
                if (provider.isLoggedIn)
                  GestureDetector(
                    onTap: () => provider.toggleBookmark(itemType: 'repo', itemId: repo.id),
                    child: Icon(
                      repo.isBookmarked ? Icons.star : Icons.star_border,
                      color: const Color(0xFF0A84FF),
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (repo.description != null && repo.description!.isNotEmpty)
              Text(
                repo.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
              ),
            const SizedBox(height: 12),
            // Stats row
            Row(
              children: [
                if (repo.language != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getLanguageColor(repo.language),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(repo.language!, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                ],
                const Icon(Icons.star_outline_rounded, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(_formatCount(repo.starsCount), style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                const Icon(Icons.call_split_rounded, size: 13, color: Colors.white38),
                const SizedBox(width: 4),
                Text(_formatCount(repo.forksCount), style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w600)),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 12, color: Color(0xFF30D158)),
                    const SizedBox(width: 3),
                    Text(
                      '+${repo.starsToday} ${context.tr('sao', 'stars')}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF30D158)),
                    ),
                  ],
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
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Inter',
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: '${repo.owner} / ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white54,
                        ),
                      ),
                      TextSpan(
                        text: repo.repoName,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Stats row inside modal
                Row(
                  children: [
                    if (repo.language != null) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getLanguageColor(repo.language),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(repo.language!, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                    ],
                    const Icon(Icons.star_outline_rounded, size: 14, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text('${_formatCount(repo.starsCount)} ${context.tr('sao', 'stars')}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    const SizedBox(width: 16),
                    const Icon(Icons.call_split_rounded, size: 13, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text('${_formatCount(repo.forksCount)} forks', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
                const Divider(color: Colors.white12, height: 32),
                Text(
                  context.tr('GIỚI THIỆU DỰ ÁN', 'PROJECT SUMMARY'),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0A84FF), letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  repo.description ?? context.tr('Không có mô tả dự án.', 'No project description.'),
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 28),
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
                        icon: const Icon(Icons.open_in_new_rounded, size: 15),
                        label: Text(
                          context.tr('MỞ TRÊN GITHUB', 'VIEW ON GITHUB'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A84FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
