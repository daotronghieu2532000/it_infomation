import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../widgets/glassmorphic_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Mở liên kết chính sách bảo mật
  void _launchPrivacyPolicy(BuildContext context) async {
    final Uri url = Uri.parse('https://codego.io.vn/privacy_policy.html');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Không thể mở liên kết.', 'Could not launch URL.'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr('Lỗi:', 'Error:')} $e')),
      );
    }
  }

  // Mở mail client gửi tới Gmail liên hệ
  void _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'trongh138@gmail.com',
      queryParameters: {
        'subject': 'CodeGo TechFlow Feedback',
      },
    );
    try {
      if (!await launchUrl(emailUri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Không tìm thấy ứng dụng email tương thích.', 'No email app found.'))),
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
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.tr('CÀI ĐẶT', 'SETTINGS'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LỜI CẢM ƠN (ACKNOWLEDGEMENTS)
            Text(
              context.tr('LỜI CẢM ƠN', 'ACKNOWLEDGEMENTS'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white38,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            GlassmorphicCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Color(0xFF06B6D4), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('Chào bạn,', 'Hello Dear User,'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr(
                      'Chúng tôi xin chân thành cảm ơn bạn đã sử dụng CodeGo TechFlow. Ứng dụng được thiết kế nhằm mục đích hỗ trợ lập trình viên Việt Nam tiếp cận các công nghệ và tin tức mới nhất.',
                      'We sincerely thank you for using CodeGo TechFlow. The application is designed to support developers in accessing the latest technologies and news.',
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CHỌN NGÔN NGỮ (LANGUAGE SELECTION)
            Text(
              context.tr('NGÔN NGỮ', 'LANGUAGE'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white38,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            GlassmorphicCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Tiếng Việt',
                      style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    trailing: !provider.isEnglish
                        ? const Icon(Icons.check_circle, color: Color(0xFF06B6D4), size: 18)
                        : null,
                    onTap: () => provider.toggleLanguage(false),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  ListTile(
                    title: const Text(
                      'English',
                      style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    trailing: provider.isEnglish
                        ? const Icon(Icons.check_circle, color: Color(0xFF06B6D4), size: 18)
                        : null,
                    onTap: () => provider.toggleLanguage(true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // PHÁP LÝ & BẢO MẬT (PRIVACY POLICY)
            Text(
              context.tr('PHÁP LÝ', 'LEGAL'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white38,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            GlassmorphicCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white70, size: 20),
                title: Text(
                  context.tr('Chính sách bảo mật', 'Privacy Policy'),
                  style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 12),
                onTap: () => _launchPrivacyPolicy(context),
              ),
            ),
            const SizedBox(height: 24),

            // LIÊN HỆ & HỖ TRỢ (CONTACT)
            Text(
              context.tr('LIÊN HỆ', 'CONTACT'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white38,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            GlassmorphicCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.mail_outline_rounded, color: Colors.white70, size: 20),
                title: Text(
                  context.tr('Gmail hỗ trợ', 'Support Gmail'),
                  style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'trongh138@gmail.com',
                  style: TextStyle(fontSize: 11, color: Colors.white38),
                ),
                trailing: const Icon(Icons.open_in_new_rounded, color: Color(0xFF06B6D4), size: 16),
                onTap: () => _launchEmail(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
