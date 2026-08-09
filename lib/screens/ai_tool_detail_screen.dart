import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ai_tool.dart';
import '../providers/app_provider.dart';
import '../widgets/glassmorphic_card.dart';

class AiToolDetailScreen extends StatelessWidget {
  final AiTool tool;

  const AiToolDetailScreen({super.key, required this.tool});

  void _copyWebsiteUrl(BuildContext context, String? url) {
    if (url == null || url.isEmpty) return;
    Clipboard.setData(ClipboardData(text: url)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF30D158), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('Đã sao chép liên kết của ${tool.name} vào bộ nhớ tạm!', 'Copied website link of ${tool.name} to clipboard!'),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1C1C1E),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          duration: const Duration(seconds: 2),
        ),
      );

    });
  }

  void _launchWebsiteUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('Không thể mở liên kết:', 'Could not open link:')} $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr('Lỗi:', 'Error:')} $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine category colors — Apple Palette
    Color categoryColor = const Color(0xFF0A84FF);
    if (tool.category == 'IDE') {
      categoryColor = const Color(0xFFBF5AF2); // Purple for IDE
    } else if (tool.category == 'Local Runner') {
      categoryColor = const Color(0xFFFF9F0A); // Orange for Local Tool
    } else if (tool.category == 'LLM Model') {
      categoryColor = const Color(0xFF30D158); // Green for Model
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tool.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CARD WITH KEY INFO — Apple style
              GlassmorphicCard(
                borderRadius: 0,
                borderWidth: 0,
                backgroundColor: const Color(0xFF1C1C1E),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge category
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.15),
                              border: Border.all(color: categoryColor.withOpacity(0.4), width: 0.5),
                            ),
                            child: Text(
                              tool.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: categoryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Rating Badge
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${tool.efficiencyScore}/10',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              tool.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (tool.isFreePrioritized) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF30D158).withOpacity(0.15),
                                border: Border.all(color: const Color(0xFF30D158).withOpacity(0.3), width: 0.5),
                              ),
                              child: Text(
                                context.tr('ƯU TIÊN FREE/TRIAL', 'PRIORITIZED FREE/TRIAL'),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF30D158),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tool.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SPECIFICATIONS SECTION — phẳng full-width
              Text(
                context.tr('THÔNG SỐ KỸ THUẬT & CHI PHÍ', 'SPECIFICATIONS & COST'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0A84FF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              GlassmorphicCard(
                borderRadius: 0,
                borderWidth: 0,
                backgroundColor: const Color(0xFF1C1C1E),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSpecRow(
                        Icons.sell_outlined,
                        Colors.amberAccent,
                        context.tr('Hình thức thanh toán', 'Pricing model'),
                        tool.pricingType,
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      _buildSpecRow(
                        Icons.price_change_outlined,
                        Colors.lightGreenAccent,
                        context.tr('Chi tiết chi phí', 'Cost details'),
                        tool.pricingDetail,
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      _buildSpecRow(
                        Icons.speed_outlined,
                        const Color(0xFF0A84FF),
                        context.tr('Tốc độ xử lý', 'Speed rating'),
                        tool.speedRating,
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      _buildSpecRow(
                        Icons.layers_outlined,
                        const Color(0xFFBF5AF2),
                        context.tr('Khung ngữ cảnh (Context)', 'Context Window'),
                        tool.contextWindow,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // EXPERT EVALUATION
              Text(
                context.tr('ĐÁNH GIÁ CHUYÊN SÂU', 'EXPERT EVALUATION'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0A84FF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              GlassmorphicCard(
                borderRadius: 0,
                borderWidth: 0,
                backgroundColor: const Color(0xFF1C1C1E),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    tool.evaluation,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // HOW TO USE GUIDE (MARKDOWN)
              Text(
                context.tr('HƯỚNG DẪN SỬ DỤNG CHI TIẾT', 'DETAILED USAGE GUIDE'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0A84FF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              GlassmorphicCard(
                borderRadius: 0,
                borderWidth: 0,
                backgroundColor: const Color(0xFF1C1C1E),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: tool.howToUse.isEmpty
                      ? Text(
                          context.tr('Đang cập nhật hướng dẫn sử dụng...', 'Usage guide is being updated...'),
                          style: const TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
                        )
                      : MarkdownBody(
                          data: tool.howToUse,
                          shrinkWrap: true,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                            h1: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 2.0,
                            ),
                            h2: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1.8,
                            ),
                            h3: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.6,
                            ),
                            listBullet: const TextStyle(color: Color(0xFF0A84FF), fontSize: 14),
                            code: TextStyle(
                              color: const Color(0xFF0A84FF),
                              backgroundColor: Colors.white.withOpacity(0.06),
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            codeblockPadding: const EdgeInsets.all(12),
                            blockquote: TextStyle(color: Colors.white.withOpacity(0.55), fontStyle: FontStyle.italic),
                            blockquoteDecoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              border: const Border(left: BorderSide(color: Color(0xFF0A84FF), width: 3)),
                            ),
                            blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            a: const TextStyle(
                              color: Color(0xFF0A84FF),
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTapLink: (text, href, title) {
                            _launchWebsiteUrl(context, href);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ACTION BUTTONS (VISIT WEBSITE & COPY LINK)
              if (tool.websiteUrl != null && tool.websiteUrl!.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A84FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _launchWebsiteUrl(context, tool.websiteUrl),
                        icon: const Icon(Icons.language, size: 16),
                        label: Text(
                          context.tr('TRUY CẬP WEBSITE', 'VISIT WEBSITE'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24, width: 0.5),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _copyWebsiteUrl(context, tool.websiteUrl),
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: Text(
                          context.tr('SAO CHÉP LINK', 'COPY LINK'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, Color iconColor, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
