import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/glassmorphic_card.dart';
import '../providers/app_provider.dart';
import '../models/ai_tool.dart';
import 'ai_tool_detail_screen.dart';

class DevSpaceScreen extends StatefulWidget {
  const DevSpaceScreen({super.key});

  @override
  State<DevSpaceScreen> createState() => _DevSpaceScreenState();
}

class _DevSpaceScreenState extends State<DevSpaceScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F19),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B0F19),
          elevation: 0,
          title: const Text(
            'DEVSPACE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFF06B6D4),
            labelColor: Color(0xFF06B6D4),
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
            tabs: [
              Tab(text: 'CÔNG CỤ AI'),
              Tab(text: 'SỰ KIỆN TECH'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AiToolsTab(),
            TechEventsTab(),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 1. CÔNG CỤ AI TAB (AI TOOLS HUB)
// =========================================================================
class AiToolsTab extends StatefulWidget {
  const AiToolsTab({super.key});

  @override
  State<AiToolsTab> createState() => _AiToolsTabState();
}

class _AiToolsTabState extends State<AiToolsTab> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách công cụ AI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAiTools();
    });
  }

  Future<void> _refreshData() async {
    await context.read<AppProvider>().loadAiTools();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    if (provider.isLoadingAiTools && provider.aiTools.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)));
    }

    if (provider.aiTools.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF06B6D4),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.widgets_outlined, size: 48, color: Colors.white30),
                SizedBox(height: 12),
                Text(
                  'Không thể lấy danh sách công cụ AI.\nVuốt xuống để thử lại.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF06B6D4),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: provider.aiTools.length,
        itemBuilder: (context, index) {
          final tool = provider.aiTools[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AiToolCard(tool: tool),
          );
        },
      ),
    );
  }
}

// Card Widget đại diện cho 1 công cụ AI hiển thị thông tin tóm tắt và dẫn tới trang chi tiết
class AiToolCard extends StatelessWidget {
  final AiTool tool;
  const AiToolCard({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    final t = tool;

    // Định nghĩa màu sắc theo danh mục
    Color categoryColor = const Color(0xFF06B6D4);
    if (t.category == 'IDE') {
      categoryColor = const Color(0xFF8B5CF6); // Tím cho IDE
    } else if (t.category == 'Local Runner') {
      categoryColor = const Color(0xFFF59E0B); // Cam cho Local Tool
    } else if (t.category == 'LLM Model') {
      categoryColor = const Color(0xFF10B981); // Xanh lá cho Mô hình
    }

    return GlassmorphicCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AiToolDetailScreen(tool: t),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng đầu: Badge chuyên mục, Rating, nút sang trang chi tiết
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge category
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: categoryColor.withOpacity(0.4), width: 0.8),
                  ),
                  child: Text(
                    t.category.toUpperCase(),
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: categoryColor),
                  ),
                ),
                // Rating Score & Arrow
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${t.efficiencyScore}/10',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white38,
                      size: 11,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dòng 2: Tên công cụ AI & Tag ưu tiên Free
            Row(
              children: [
                Text(
                  t.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                if (t.isFreePrioritized) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ƯU TIÊN FREE/TRIAL',
                      style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Dòng 3: Mô tả ngắn gọn
            Text(
              t.description,
              style: const TextStyle(fontSize: 11, color: Colors.white60, height: 1.4),
            ),
            const SizedBox(height: 12),

            // Khối Thông số kỹ thuật & Chi phí dạng Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Column(
                children: [
                  // Hàng 1: Chi phí
                  Row(
                    children: [
                      const Icon(Icons.sell_outlined, color: Colors.amberAccent, size: 14),
                      const SizedBox(width: 8),
                      const Text('Chi phí:', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          t.pricingDetail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 10),
                  // Hàng 2: Tốc độ & Ngữ cảnh
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cột 1: Tốc độ
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.speed_outlined, color: Color(0xFF06B6D4), size: 14),
                            const SizedBox(width: 6),
                            const Text('Tốc độ:', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                t.speedRating,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Cột 2: Ngữ cảnh
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.layers_outlined, color: Color(0xFF8B5CF6), size: 14),
                            const SizedBox(width: 6),
                            const Text('Context:', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                t.contextWindow,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
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

// =========================================================================
// 2. TECH EVENTS TAB (CONFERENCES TIMELINE)
// =========================================================================
class TechEventsTab extends StatelessWidget {
  const TechEventsTab({super.key});

  final List<Map<String, String>> _events = const [
    {
      'title': 'Google I/O 2026',
      'date': '12 - 14 Tháng 5, 2026',
      'location': 'Mountain View, California (Hybrid)',
      'desc': 'Hội nghị thường niên lớn nhất của Google dành cho lập trình viên toàn cầu. Trọng tâm giới thiệu các cải tiến mới của hệ sinh thái Android, AI Gemini 2.0, các tính năng Web và các công cụ điện toán đám mây GCP.',
      'tag': 'AI & Android',
    },
    {
      'title': 'Apple WWDC 2026',
      'date': '08 - 12 Tháng 6, 2026',
      'location': 'Apple Park, California (Online)',
      'desc': 'Worldwide Developers Conference giới thiệu các phiên bản hệ điều hành iOS 20, iPadOS 20, macOS 17 và watchOS 13. Cập nhật các bộ SDK mới nhất cho Vision Pro và tối ưu Swift.',
      'tag': 'iOS & macOS',
    },
    {
      'title': 'Microsoft Build 2026',
      'date': '20 - 22 Tháng 5, 2026',
      'location': 'Seattle, Washington',
      'desc': 'Hội nghị lập trình viên chuyên sâu của Microsoft, tập trung mạnh mẽ vào các cải tiến phát triển AI Copilot tích hợp sâu vào Windows 11, các dịch vụ đám mây Azure AI và bộ đôi .NET 10.',
      'tag': 'Azure & .NET',
    },
    {
      'title': 'AWS re:Invent 2026',
      'date': '30 Tháng 11 - 04 Tháng 12, 2026',
      'location': 'Las Vegas, Nevada',
      'desc': 'Diễn đàn điện toán đám mây lớn nhất hành tinh của Amazon Web Services. Nơi công bố hàng loạt dịch vụ cloud, dữ liệu mới và các hạ tầng điện toán phục vụ AI tạo sinh quy mô lớn.',
      'tag': 'Cloud & DevOps',
    },
    {
      'title': 'Vietnam Web Summit 2026',
      'date': '12 Tháng 12, 2026',
      'location': 'TP. Hồ Chí Minh, Việt Nam',
      'desc': 'Đại hội công nghệ Web và Internet lớn nhất tại Việt Nam. Nơi quy tụ hàng nghìn lập trình viên trong nước thảo luận về xu hướng Web3, bảo mật ứng dụng, tối ưu hóa hạ tầng và cơ hội nghề nghiệp.',
      'tag': 'Local Event',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final ev = _events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left timeline indicator
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0B0F19),
                      border: Border.all(color: const Color(0xFF06B6D4), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  if (index < _events.length - 1)
                    Container(
                      width: 2,
                      height: 140,
                      color: Colors.white12,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Right event card content
              Expanded(
                child: GlassmorphicCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06B6D4).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ev['tag']!,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF06B6D4)),
                            ),
                          ),
                          const Icon(Icons.event_note, color: Colors.white30, size: 16),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ev['title']!,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📅 ${ev['date']}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '📍 ${ev['location']}',
                        style: const TextStyle(fontSize: 10, color: Colors.white38),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ev['desc']!,
                        style: const TextStyle(fontSize: 11, color: Colors.white60, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
