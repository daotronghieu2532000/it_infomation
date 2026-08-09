import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mở liên kết chính sách bảo mật
  void _launchPrivacyPolicy(BuildContext context) async {
    final Uri url = Uri.parse('https://codego.io.vn/privacy_policy.html');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!context.mounted) return;
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Không thể mở liên kết.', 'Could not launch URL.'))),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
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
      final launched = await launchUrl(emailUri);
      if (!context.mounted) return;
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Không tìm thấy ứng dụng email tương thích.', 'No email app found.'))),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr('Lỗi:', 'Error:')} $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.tr('CÀI ĐẶT', 'SETTINGS'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LỜI CẢM ƠN (ACKNOWLEDGEMENTS)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                context.tr('LỜI CẢM ƠN & LIÊN HỆ', 'ACKNOWLEDGEMENTS & CONTACT'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white38,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.04), width: 0.5),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D55).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Color(0xFFFF2D55), size: 18),
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
                      fontSize: 12.5,
                      color: Colors.white70,
                      height: 1.45,
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  InkWell(
                    onTap: () => _launchEmail(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF), // iOS Blue
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.mail_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('Gmail hỗ trợ', 'Support Gmail'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'trongh138@gmail.com',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 11),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CHỌN NGÔN NGỮ (LANGUAGE SELECTION)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                context.tr('NGÔN NGỮ', 'LANGUAGE'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white38,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.04), width: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5856D6), // iOS Purple
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.translate_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.tr('Chọn ngôn ngữ', 'Language'),
                        style: const TextStyle(fontSize: 13.5, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  // Apple Sliding Segmented Control
                  CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.dark,
                    ),
                    child: CupertinoSlidingSegmentedControl<bool>(
                      groupValue: provider.isEnglish,
                      backgroundColor: Colors.black26,
                      thumbColor: const Color(0xFF3A3A3C),
                      children: const {
                        false: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            '🇻🇳 VI',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        true: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            '🇬🇧 EN',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      },
                      onValueChanged: (val) {
                        if (val != null) {
                          provider.toggleLanguage(val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // PHÁP LÝ & BẢO MẬT (PRIVACY POLICY)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                context.tr('PHÁP LÝ', 'LEGAL'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white38,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.04), width: 0.5),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF30D158), // iOS Green
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.privacy_tip_rounded, color: Colors.white, size: 16),
                ),
                title: Text(
                  context.tr('Chính sách bảo mật', 'Privacy Policy'),
                  style: const TextStyle(fontSize: 13.5, color: Colors.white, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 11),
                onTap: () => _launchPrivacyPolicy(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
