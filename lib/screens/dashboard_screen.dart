import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../models/article.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/shimmer_loader.dart';
import 'settings_screen.dart';
import '../widgets/daily_quiz_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowDailyQuiz();
    });
  }

  Future<void> _checkAndShowDailyQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShowed = prefs.getInt('last_auto_quiz_timestamp') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Nếu chưa từng hiển thị hoặc đã quá 12 tiếng (12 * 3600 * 1000 ms)
    if (now - lastShowed >= 12 * 3600 * 1000) {
      if (mounted) {
        _showDailyQuizBottomSheet(context);
        await prefs.setInt('last_auto_quiz_timestamp', now);
      }
    }
  }

  void _showDailyQuizBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pull bar
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 8),
                const DailyQuizWidget(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final categories = ['All', 'AI', 'Mobile', 'Frontend', 'Backend', 'Devops', 'Security'];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadNews(),
          color: const Color(0xFF0A84FF),
          backgroundColor: const Color(0xFF1C1C1E),
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
                                color: const Color(0xFF0A84FF),
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('TIN CÔNG NGHỆ', 'TECH NEWS'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
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
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A84FF)),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.sync_rounded, color: Color(0xFF0A84FF), size: 22),
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
                                borderRadius: 0,
                                child: Row(
                                  children: [
                                    Image.asset('assets/bonfire.png', width: 20, height: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${provider.userInfo?['current_streak'] ?? 0} ${context.tr('NGÀY', 'DAYS')}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
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

              // 0. DAILY TECH QUIZ (Đố vui hàng ngày) - hiển thị dưới dạng banner kéo Bottom Sheet
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: InkWell(
                    onTap: () => _showDailyQuizBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBF5AF2).withOpacity(0.08),
                        border: Border.all(color: const Color(0xFFBF5AF2).withOpacity(0.3), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.psychology_outlined, color: Color(0xFFBF5AF2), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('THỬ THÁCH ĐỐ VUI HÀNG NGÀY', 'DAILY QUIZ CHALLENGE'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFBF5AF2),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.tr('Trả lời câu hỏi nhận ngay +20 XP tích lũy!', 'Answer today\'s quiz to get +20 XP!'),
                                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Color(0xFFBF5AF2), size: 12),
                        ],
                      ),
                    ),
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
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFBF5AF2),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 240,
                        child: WeeklyHighlightsSlider(
                          articles: provider.weeklyHighlights,
                          onTap: (article) => _openArticleDetail(context, article),
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
                        ShimmerLoader(width: double.infinity, height: 190, borderRadius: 0),
                      ],
                    ),
                  ),
                ),

              // 2. HORIZONTAL CATEGORIES FILTER
              SliverToBoxAdapter(
                child: Container(
                  height: 42,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white12, width: 0.5),
                      top: BorderSide(color: Colors.white12, width: 0.5),
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = provider.selectedNewsCategory == cat;
                      final isLast = index == categories.length - 1;
                      return Row(
                        children: [
                          InkWell(
                            onTap: () => provider.setNewsCategory(cat),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                (cat == 'All' ? context.tr('TẤT CẢ', 'ALL') : cat).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                                  color: isSelected ? const Color(0xFF0A84FF) : Colors.white60,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          if (!isLast)
                            const Text(
                              '|',
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              // 3. DAILY TECH FEED
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      child: GlassmorphicCard(
        padding: EdgeInsets.zero,
        borderRadius: 0,
        borderWidth: 0,
        onTap: () => _openArticleDetail(context, article),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail Image
            if (article.thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: article.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerLoader(width: double.infinity, height: double.infinity, borderRadius: 0),
                errorWidget: (context, url, error) => Container(color: const Color(0xFF1C1C1E)),
              )
            else
              Container(color: const Color(0xFF1C1C1E)),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFBF5AF2),
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
        onTap: () => _openArticleDetail(context, article),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image Left
            if (article.thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: article.thumbnailUrl!,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerLoader(width: 90, height: 90, borderRadius: 0),
                errorWidget: (context, url, error) => Container(width: 90, height: 90, color: const Color(0xFF1C1C1E)),
              )
            else
              Container(width: 90, height: 90, color: const Color(0xFF1C1C1E)),
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
                          color: Color(0xFF0A84FF),
                        ),
                      ),
                      // Save bookmark icon
                      if (provider.isLoggedIn)
                        GestureDetector(
                          onTap: () => provider.toggleBookmark(itemType: 'article', itemId: article.id),
                          child: Icon(
                            article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: const Color(0xFF0A84FF),
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
  bool _isSummarizing = false;
  String? _aiSummaryResult;

  void _generateAISummary(AppProvider provider) async {
    setState(() {
      _isSummarizing = true;
    });

    final articleText = "${widget.article.title}\n${widget.article.summary}\n${widget.article.content ?? ''}";
    final prompt = provider.isEnglish
        ? "Please summarize the following article in 3 short bullet points in English. Focus on core technology context:\n\n$articleText"
        : "Hãy tóm tắt bài viết sau thành 3 dòng gạch đầu dòng ngắn gọn bằng tiếng Việt. Tập trung vào cốt lõi công nghệ:\n\n$articleText";

    try {
      print("[DEBUG AI SUMMARY] SENDING PROMPT:\n$prompt");
      final res = await provider.getAIExplanation(prompt);
      print("[DEBUG AI SUMMARY] RECEIVED RESPONSE:\n$res");
      if (res['success'] == true) {
        String result = res['result_markdown'] ?? '';
        
        // Phát hiện nếu server trả về kết quả Mockup giải thích code demo do chưa cấu hình API Key
        if (result.contains('Chế độ Demo') || result.contains('Mã nguồn') || result.contains('đoạn code')) {
          print("[DEBUG AI SUMMARY] SERVER IS IN DEMO MODE. FALLING BACK TO CLIENT-SIDE SUMMARIZER.");
          
          final content = widget.article.content ?? widget.article.summary ?? '';
          
          // Nhận diện ngôn ngữ dựa trên các ký tự tiếng Việt đặc trưng
          final hasVietnamese = RegExp(r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]', caseSensitive: false).hasMatch(content);
          
          // Tách các câu bằng dấu chấm, hỏi, cảm
          final sentenceRegex = RegExp(r'(?<=[.!?])\s+');
          final sentences = content.split(sentenceRegex);
          final cleanSentences = <String>[];
          
          for (var s in sentences) {
            final trimmed = s.trim();
            if (trimmed.isEmpty || trimmed.contains('`') || trimmed.contains('#') || trimmed.length < 15) {
              continue;
            }
            cleanSentences.add(trimmed);
          }
          
          final summaryPoints = cleanSentences.take(3).toList();
          
          if (summaryPoints.isEmpty) {
            result = hasVietnamese
                ? "### 🧠 Tóm tắt bài viết (Client Offline)\n\n* Không thể tự động phân tách câu từ bài viết này. Vui lòng liên hệ quản trị viên để cấu hình `GEMINI_API_KEY`."
                : "### 🧠 Article Summary (Client Offline)\n\n* Could not automatically extract key sentences. Please contact admin to configure `GEMINI_API_KEY`.";
          } else {
            if (hasVietnamese) {
              result = "### 🧠 Tóm tắt bài viết (Client Offline)\n\n*Đây là tóm tắt tự động được trích xuất trực tiếp từ bài viết gốc:*\n\n" + 
                  summaryPoints.map((p) => "* $p").join("\n");
            } else {
              result = "### 🧠 Article Summary (Client Offline)\n\n*Here is the automatic summary extracted directly from the original article:*\n\n" + 
                  summaryPoints.map((p) => "* $p").join("\n");
            }
          }
        }
        
        setState(() {
          _aiSummaryResult = result;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Lỗi tóm tắt bài viết')),
        );
      }
    } catch (e) {
      print("[DEBUG AI SUMMARY] EXCEPTION: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối AI: $e')),
      );
    } finally {
      setState(() {
        _isSummarizing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isLiked = widget.article.isLiked;
    final isBookmarked = widget.article.isBookmarked;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
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
                placeholder: (context, url) => const ShimmerLoader(width: double.infinity, height: 230, borderRadius: 0),
                errorWidget: (context, url, error) => Container(height: 230, color: const Color(0xFF1C1C1E)),
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
                      color: const Color(0xFF0A84FF).withOpacity(0.1),
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: const Color(0xFF0A84FF).withOpacity(0.3), width: 0.5),
                    ),
                    child: Text(
                      widget.article.category.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0A84FF)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    widget.article.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
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
                  
                  // AI Summary Integration
                  const SizedBox(height: 12),
                  if (_aiSummaryResult == null && !_isSummarizing)
                    OutlinedButton.icon(
                      onPressed: () => _generateAISummary(provider),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFFBF5AF2)),
                      label: Text(
                        context.tr('TÓM TẮT NHANH BẰNG AI', 'AI QUICK SUMMARY (TL;DR)'),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFBF5AF2), letterSpacing: 0.5),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBF5AF2), width: 0.8),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    )
                  else if (_isSummarizing)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      color: Colors.white.withOpacity(0.02),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFBF5AF2)),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.tr('AI đang đọc và tóm tắt bài viết...', 'AI is analyzing and summarizing...'),
                            style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  else if (_aiSummaryResult != null)
                    GlassmorphicCard(
                      borderRadius: 0,
                      borderWidth: 0.5,
                      backgroundColor: const Color(0xFF1C1C1E),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 13, color: Color(0xFFBF5AF2)),
                              const SizedBox(width: 6),
                              Text(
                                context.tr('TÓM TẮT NHANH BẰNG AI (TL;DR)', 'AI SUMMARY (TL;DR)'),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFBF5AF2), letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          MarkdownBody(
                            data: _aiSummaryResult!,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                              listBullet: const TextStyle(color: Color(0xFFBF5AF2), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
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
                      code: const TextStyle(color: Color(0xFF0A84FF), backgroundColor: Color(0xFF1C1C1E), fontSize: 12, fontFamily: 'monospace'),
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
                      ),
                      blockquote: const TextStyle(color: Colors.white60, fontSize: 13, fontStyle: FontStyle.italic),
                      blockquoteDecoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: Color(0xFF0A84FF), width: 4)),
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
                color: Colors.black,
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
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
                      color: isBookmarked ? const Color(0xFF0A84FF) : Colors.white70,
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

class WeeklyHighlightsSlider extends StatefulWidget {
  final List<Article> articles;
  final Function(Article) onTap;

  const WeeklyHighlightsSlider({
    super.key,
    required this.articles,
    required this.onTap,
  });

  @override
  State<WeeklyHighlightsSlider> createState() => _WeeklyHighlightsSliderState();
}

class _WeeklyHighlightsSliderState extends State<WeeklyHighlightsSlider> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Bắt đầu tại vị trí ở giữa để có thể vuốt lặp cả 2 bên
    _currentPage = widget.articles.isNotEmpty ? widget.articles.length * 100 : 0;
    _pageController = PageController(initialPage: _currentPage);
    
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && widget.articles.isNotEmpty) {
        setState(() {
          _currentPage++;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) return const SizedBox();
    
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (page) {
            _currentPage = page;
            // Khởi động lại timer khi người dùng tự vuốt để tránh bị chuyển trang ngay lập tức
            _startTimer();
          },
          itemBuilder: (context, index) {
            final article = widget.articles[index % widget.articles.length];
            return _buildSlideCard(context, article);
          },
        ),
        // Indicators
        Positioned(
          bottom: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.articles.length, (index) {
              final isSelected = (_currentPage % widget.articles.length) == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isSelected ? 18 : 6,
                height: 3,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFBF5AF2) : Colors.white24,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSlideCard(BuildContext context, Article article) {
    return InkWell(
      onTap: () => widget.onTap(article),
      child: GlassmorphicCard(
        padding: EdgeInsets.zero,
        borderRadius: 0,
        borderWidth: 0,
        backgroundColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            if (article.thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: article.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerLoader(width: double.infinity, height: double.infinity, borderRadius: 0),
                errorWidget: (context, url, error) => Container(color: const Color(0xFF1C1C1E)),
              )
            else
              Container(color: const Color(0xFF1C1C1E)),
            
            // Dark Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: const Color(0xFFBF5AF2),
                    child: Text(
                      article.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        article.sourceName,
                        style: const TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.remove_red_eye_outlined, size: 11, color: Colors.white60),
                      const SizedBox(width: 3),
                      Text(
                        '${article.viewCount}',
                        style: const TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold),
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
}
