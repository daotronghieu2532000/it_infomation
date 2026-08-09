import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_provider.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/shimmer_loader.dart';
import '../models/dev_workflow.dart';
import 'dashboard_screen.dart';
import 'workflow_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            context.tr('BỘ SƯU TẬP', 'BOOKMARKS'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFF0A84FF),
            labelColor: const Color(0xFF0A84FF),
            unselectedLabelColor: Colors.white54,
            dividerColor: Colors.white10,
            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            isScrollable: true,
            tabs: [
              Tab(text: context.tr('TIN TỨC', 'NEWS')),
              Tab(text: context.tr('DỰ ÁN', 'REPOSITORIES')),
              Tab(text: context.tr('PROMPTS', 'PROMPTS')),
              Tab(text: context.tr('QUY TRÌNH', 'WORKFLOWS')),
            ],
          ),
        ),
        body: !provider.isLoggedIn
            ? _buildNotLoggedInPlaceholder(context)
            : TabBarView(
                children: [
                  _buildArticlesTab(context, provider),
                  _buildReposTab(context, provider),
                  _buildPromptsTab(context, provider),
                  _buildWorkflowsTab(context, provider),
                ],
              ),
      ),
    );
  }

  // ============================================
  // TAB COMPONENT BUILDERS
  // ============================================

  Widget _buildNotLoggedInPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.zero,
            border: Border.all(color: Colors.white12, width: 0.5),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 54, color: Color(0xFF0A84FF)),
              const SizedBox(height: 16),
              Text(
                context.tr('Yêu Cầu Đăng Nhập', 'Login Required'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('Vui lòng đăng nhập để lưu trữ các bài viết, prompts, quy trình và theo dõi chuỗi ngày học tập của bạn.', 'Please log in to save articles, prompts, workflows, and track your daily learning streak.'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.white54, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Quay về trang cá nhân
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A84FF),
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
                child: Text(context.tr('ĐĂNG NHẬP NGAY', 'LOG IN NOW')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark_border_rounded, size: 44, color: Colors.white24),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesTab(BuildContext context, AppProvider provider) {
    final list = provider.bookmarkedArticles;
    if (list.isEmpty) {
      return _buildEmptyPlaceholder(context.tr('Chưa lưu trữ bài viết nào.', 'No bookmarked articles yet.'));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: list.length,
      itemBuilder: (context, index) {
        final article = list[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.zero,
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
              );
            },
            child: Row(
              children: [
                if (article.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: article.thumbnailUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerLoader(width: 56, height: 56),
                      errorWidget: (context, url, error) => Container(width: 56, height: 56, color: Colors.black26),
                    ),
                  )
                else
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.article_outlined, color: Colors.white24, size: 24),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.sourceName,
                        style: const TextStyle(fontSize: 10, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_remove_rounded, color: Colors.redAccent, size: 18),
                  onPressed: () => provider.toggleBookmark(itemType: 'article', itemId: article.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReposTab(BuildContext context, AppProvider provider) {
    final list = provider.bookmarkedRepos;
    if (list.isEmpty) {
      return _buildEmptyPlaceholder(context.tr('Chưa lưu trữ repository nào.', 'No bookmarked repositories yet.'));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: list.length,
      itemBuilder: (context, index) {
        final repo = list[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.zero,
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.folder_rounded, color: Color(0xFF007AFF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repo.repoName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '★ ${repo.starsCount} • ${repo.language ?? "All"}',
                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.star_rounded, color: Colors.redAccent, size: 20),
                onPressed: () => provider.toggleBookmark(itemType: 'repo', itemId: repo.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromptsTab(BuildContext context, AppProvider provider) {
    final list = provider.bookmarkedPrompts;
    if (list.isEmpty) {
      return _buildEmptyPlaceholder(context.tr('Chưa lưu trữ prompt nào.', 'No bookmarked prompts yet.'));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: list.length,
      itemBuilder: (context, index) {
        final prompt = list[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.zero,
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFBF5AF2).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.bolt_rounded, color: Color(0xFFBF5AF2), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Model: ${prompt.targetModel}',
                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_remove_rounded, color: Colors.redAccent, size: 18),
                onPressed: () => provider.toggleBookmark(itemType: 'prompt', itemId: prompt.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkflowsTab(BuildContext context, AppProvider provider) {
    final list = provider.bookmarkedWorkflows;
    if (list.isEmpty) {
      return _buildEmptyPlaceholder(context.tr('Chưa lưu trữ quy trình nào.', 'No bookmarked workflows yet.'));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: list.length,
      itemBuilder: (context, index) {
        final workflow = list[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.zero,
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => WorkflowDetailScreen(workflow: workflow)),
              ).then((_) {
                provider.loadWorkflows();
              });
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF30D158).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.settings_suggest_rounded, color: Color(0xFF30D158), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workflow.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${context.tr('Thể loại:', 'Category:')} ${workflow.toolCategory}',
                        style: const TextStyle(fontSize: 10, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_remove_rounded, color: Colors.redAccent, size: 18),
                  onPressed: () => provider.toggleBookmark(itemType: 'workflow', itemId: workflow.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
