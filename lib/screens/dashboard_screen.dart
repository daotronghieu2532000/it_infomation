import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../models/article.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/shimmer_loader.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final categories = ['All', 'AI', 'Mobile', 'Frontend', 'Backend', 'Devops', 'Security'];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadNews(),
          color: const Color(0xFF06B6D4),
          backgroundColor: const Color(0xFF161F30),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Beautiful Tech Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CodeGo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF06B6D4),
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('TIN CÔNG NGHỆ', 'TECH NEWS'),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Actions Row (Sync, Settings & Streak)
                      Row(
                        children: [
                          // Settings Button
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          // Sync/Refresh button
                          provider.isSyncingNews
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06B6D4)),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.sync_rounded, color: Color(0xFF06B6D4), size: 22),
                                  onPressed: () {
                                    provider.triggerSyncNews().then((res) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(res['message'] ?? context.tr('Đồng bộ tin tức hoàn tất!', 'News sync completed!')),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    });
                                  },
                                ),
                          const SizedBox(width: 8),
                          if (provider.isLoggedIn)
                            GestureDetector(
                              onTap: () => DefaultTabController.of(context).animateTo(4), // Go to Profile
                              child: GlassmorphicCard(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                borderRadius: 20,
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${provider.userInfo?['current_streak'] ?? 0} ${context.tr('NGÀY', 'DAYS')}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 1. WEEKLY HIGHLIGHTS CAROUSEL
              if (provider.weeklyHighlights.isNotEmpty && !provider.isLoadingNews)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          context.tr('TIÊU ĐIỂM TUẦN', 'WEEKLY HIGHLIGHTS'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8B5CF6),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          itemCount: provider.weeklyHighlights.length,
                          itemBuilder: (context, index) {
                            final article = provider.weeklyHighlights[index];
                            return _buildWeeklyCard(context, article);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                )
              else if (provider.isLoadingNews)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerLoader(width: 150, height: 16),
                        SizedBox(height: 8),
                        ShimmerLoader(width: double.infinity, height: 190, borderRadius: 16),
                      ],
                    ),
                  ),
                ),

              // 2. HORIZONTAL CATEGORIES FILTER
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = provider.selectedNewsCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FilterChip(
                          label: Text(
                            (cat == 'All' ? context.tr('TẤT CẢ', 'ALL') : cat).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.black : Colors.white70,
                              letterSpacing: 1.0,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => provider.setNewsCategory(cat),
                          selectedColor: const Color(0xFF06B6D4),
                          backgroundColor: const Color(0xFF161F30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF06B6D4) : Colors.white.withOpacity(0.05),
                              width: 0.8,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 3. DAILY TECH FEED
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                sliver: provider.isLoadingNews
                    ? SliverToBoxAdapter(child: ShimmerLoader.listSkeleton())
                    : provider.dailyNews.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                context.tr('Không tìm thấy bài viết nào.', 'No articles found.'),
                                style: const TextStyle(color: Colors.white60),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final article = provider.dailyNews[index];
                                return _buildDailyCard(context, article, provider);
                              },
                              childCount: provider.dailyNews.length,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // WIDGET BUILDERS
  // ============================================

  Widget _buildWeeklyCard(BuildContext context, Article article) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GlassmorphicCard(
        padding: EdgeInsets.zero,
        onTap: () => _openArticleDetail(context, article),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail Image
            if (article.thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: article.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerLoader(width: double.infinity, height: double.infinity),
                errorWidget: (context, url, error) => Container(color: const Color(0xFF161F30)),
              )
            else
              Container(color: const Color(0xFF161F30)),
            // Dark Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      article.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        article.sourceName,
                        style: const TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.remove_red_eye_outlined, size: 10, color: Colors.white60),
                      const SizedBox(width: 2),
                      Text(
                        '${article.viewCount}',
                        style: const TextStyle(fontSize: 10, color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyCard(BuildContext context, Article article, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(12.0),
        onTap: () => _openArticleDetail(context, article),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image Left
            if (article.thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: article.thumbnailUrl!,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ShimmerLoader(width: 90, height: 90),
                  errorWidget: (context, url, error) => Container(width: 90, height: 90, color: const Color(0xFF1E293B)),
                ),
              )
            else
              Container(width: 90, height: 90, decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 14),
            // Info Content Right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF06B6D4),
                        ),
                      ),
                      // Save bookmark icon
                      if (provider.isLoggedIn)
                        GestureDetector(
                          onTap: () => provider.toggleBookmark(itemType: 'article', itemId: article.id),
                          child: Icon(
                            article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: const Color(0xFF06B6D4),
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        article.sourceName,
                        style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.remove_red_eye_outlined, size: 10, color: Colors.white38),
                      const SizedBox(width: 2),
                      Text(
                        '${article.viewCount}',
                        style: const TextStyle(fontSize: 10, color: Colors.white38),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openArticleDetail(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }
}

// ============================================
// ARTICLE DETAIL SCREEN
// ============================================
class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isLiked = widget.article.isLiked;
    final isBookmarked = widget.article.isBookmarked;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19).withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.white),
            onPressed: () {
              Share.share(
                '${context.tr('Đọc bài viết', 'Read article')} "${widget.article.title}" ${context.tr('từ', 'from')} CodeGo TechFlow: ${widget.article.sourceUrl ?? "https://codego.app"}',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            if (widget.article.thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: widget.article.thumbnailUrl!,
                width: double.infinity,
                height: 230,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerLoader(width: double.infinity, height: 230),
                errorWidget: (context, url, error) => Container(height: 230, color: const Color(0xFF1E293B)),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3), width: 0.8),
                    ),
                    child: Text(
                      widget.article.category.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF06B6D4)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    widget.article.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  // Author and source
                  Row(
                    children: [
                      Text(
                        '${context.tr('Nguồn', 'Source')}: ${widget.article.sourceName}',
                        style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.remove_red_eye_outlined, size: 12, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.article.viewCount}',
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  
                  // Summary in bold italics
                  Text(
                    widget.article.summary,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rich Markdown content body
                  MarkdownBody(
                    data: widget.article.content ?? context.tr('Đang tải nội dung bài viết...', 'Loading article content...'),
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                      h1: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.8),
                      h2: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.6),
                      h3: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, height: 1.4),
                      code: const TextStyle(color: Color(0xFF06B6D4), backgroundColor: Color(0xFF1E293B), fontSize: 12, fontFamily: 'monospace'),
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFF161F30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
                      ),
                      blockquote: const TextStyle(color: Colors.white60, fontSize: 13, fontStyle: FontStyle.italic),
                      blockquoteDecoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: Color(0xFF06B6D4), width: 4)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: provider.isLoggedIn
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF161F30),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Like action
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white70,
                    ),
                    onPressed: () {
                      provider.toggleLike(itemType: 'article', itemId: widget.article.id);
                      setState(() {
                        widget.article.isLiked = !isLiked;
                      });
                    },
                  ),
                  // Bookmark action
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? const Color(0xFF06B6D4) : Colors.white70,
                    ),
                    onPressed: () {
                      provider.toggleBookmark(itemType: 'article', itemId: widget.article.id);
                      setState(() {
                        widget.article.isBookmarked = !isBookmarked;
                      });
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
