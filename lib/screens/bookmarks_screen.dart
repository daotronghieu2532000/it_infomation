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
        backgroundColor: const Color(0xFF0B0F19),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B0F19),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'BỘ SƯU TẬP',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.0),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFF8B5CF6),
            labelColor: const Color(0xFF8B5CF6),
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            isScrollable: true,
            tabs: const [
              Tab(text: 'TIN TỨC'),
              Tab(text: 'REPOSITORIES'),
              Tab(text: 'PROMPTS'),
              Tab(text: 'WORKFLOWS'),
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
        padding: const EdgeInsets.all(24.0),
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 60, color: Color(0xFF8B5CF6)),
              const SizedBox(height: 16),
              const Text(
                'Yêu Cầu Đăng Nhập',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng đăng nhập để lưu trữ các bài viết, prompts, quy trình và theo dõi chuỗi ngày học tập của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  DefaultTabController.of(context).animateTo(2); // Redirect to Profile/Auth Tab
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                child: const Text('ĐĂNG NHẬP NGAY'),
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
          const Icon(Icons.collections_bookmark_outlined, size: 48, color: Colors.white30),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesTab(BuildContext context, AppProvider provider) {
    final list = provider.bookmarkedArticles;
    if (list.isEmpty) {
      return _buildEmptyPlaceholder('Chưa lưu trữ bài viết nào.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final article = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassmorphicCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
              );
            },
            child: Row(
              children: [
                if (article.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: article.thumbnailUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerLoader(width: 60, height: 60),
                      errorWidget: (context, url, error) => Container(width: 60, height: 60, color: const Color(0xFF161F30)),
                    ),
                  )
                else
                  Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(8))),
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
                  icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent, size: 20),
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
      return _buildEmptyPlaceholder('Chưa lưu trữ repository nào.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final repo = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassmorphicCard(
            child: Row(
              children: [
                const Icon(Icons.folder_open_outlined, color: Color(0xFF8B5CF6), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.repoName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '★ ${repo.starsCount} • ${repo.language ?? "All"}',
                        style: const TextStyle(fontSize: 11, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.star_border, color: Colors.redAccent, size: 20),
                  onPressed: () => provider.toggleBookmark(itemType: 'repo', itemId: repo.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromptsTab(BuildContext context, AppProvider provider) {
    final list = provider.bookmarkedPrompts;
    if (list.isEmpty) {
      return _buildEmptyPlaceholder('Chưa lưu trữ prompt nào.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final prompt = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassmorphicCard(
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFF8B5CF6), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prompt.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Model: ${prompt.targetModel}',
                        style: const TextStyle(fontSize: 11, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent, size: 20),
                  onPressed: () => provider.toggleBookmark(itemType: 'prompt', itemId: prompt.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkflowsTab(BuildContext context, AppProvider provider) {
    final list = provider.bookmarkedWorkflows;
    if (list.isEmpty) {
      return _buildEmptyPlaceholder('Chưa lưu trữ quy trình nào.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final workflow = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassmorphicCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => WorkflowDetailScreen(workflow: workflow)),
              ).then((_) {
                provider.loadWorkflows();
              });
            },
            child: Row(
              children: [
                const Icon(Icons.settings_suggest_rounded, color: Color(0xFF8B5CF6), size: 24),
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
                      const SizedBox(height: 2),
                      Text(
                        'Category: ${workflow.toolCategory}',
                        style: const TextStyle(fontSize: 10, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent, size: 20),
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
