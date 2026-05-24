import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/ai_tool.dart';
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
              const Icon(Icons.check_circle_outline, color: Color(0xFF06B6D4), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã sao chép liên kết của ${tool.name} vào bộ nhớ tạm!',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF161F30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine category colors
    Color categoryColor = const Color(0xFF06B6D4);
    if (tool.category == 'IDE') {
      categoryColor = const Color(0xFF8B5CF6); // Violet for IDE
    } else if (tool.category == 'Local Runner') {
      categoryColor = const Color(0xFFF59E0B); // Amber for Local Tool
    } else if (tool.category == 'LLM Model') {
      categoryColor = const Color(0xFF10B981); // Emerald for Model
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
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
            letterSpacing: 0.8,
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
              // HEADER CARD WITH KEY INFO
              GlassmorphicCard(
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
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: categoryColor.withOpacity(0.4), width: 0.8),
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
                                color: const Color(0xFF10B981).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 0.5),
                              ),
                              child: const Text(
                                'ƯU TIÊN FREE/TRIAL',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF10B981),
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

              // SPECIFICATIONS SECTION
              const Text(
                'THÔNG SỐ KỸ THUẬT & CHI PHÍ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF06B6D4),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSpecRow(
                        Icons.sell_outlined,
                        Colors.amberAccent,
                        'Hình thức thanh toán',
                        tool.pricingType,
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      _buildSpecRow(
                        Icons.price_change_outlined,
                        Colors.lightGreenAccent,
                        'Chi tiết chi phí',
                        tool.pricingDetail,
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      _buildSpecRow(
                        Icons.speed_outlined,
                        const Color(0xFF06B6D4),
                        'Tốc độ xử lý',
                        tool.speedRating,
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      _buildSpecRow(
                        Icons.layers_outlined,
                        const Color(0xFF8B5CF6),
                        'Context Window',
                        tool.contextWindow,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // EXPERT EVALUATION
              const Text(
                'ĐÁNH GIÁ CHUYÊN SÂU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF06B6D4),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              GlassmorphicCard(
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
              const Text(
                'HƯỚNG DẪN SỬ DỤNG CHI TIẾT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF06B6D4),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: tool.howToUse.isEmpty
                      ? const Text(
                          'Đang cập nhật hướng dẫn sử dụng...',
                          style: TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
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
                            listBullet: const TextStyle(color: Color(0xFF06B6D4), fontSize: 14),
                            code: TextStyle(
                              color: const Color(0xFF06B6D4),
                              backgroundColor: Colors.white.withOpacity(0.06),
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            codeblockPadding: const EdgeInsets.all(12),
                            blockquote: TextStyle(color: Colors.white.withOpacity(0.55), fontStyle: FontStyle.italic),
                            blockquoteDecoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              border: const Border(left: BorderSide(color: Color(0xFF06B6D4), width: 3)),
                            ),
                            blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            a: const TextStyle(
                              color: Color(0xFF06B6D4),
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTapLink: (text, href, title) {
                            _copyWebsiteUrl(context, href);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ACTION BUTTON (COPY LINK / WEBSITE)
              if (tool.websiteUrl != null && tool.websiteUrl!.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF161F30),
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _copyWebsiteUrl(context, tool.websiteUrl),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF06B6D4)),
                        const SizedBox(width: 8),
                        Text(
                          'SAO CHÉP LINK TRANG CHỦ ${tool.name.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
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
