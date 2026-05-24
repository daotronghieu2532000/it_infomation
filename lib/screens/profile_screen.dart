import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../widgets/glassmorphic_card.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoginView = true; // Toggle between Login and Register views
  
  // Controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isUploadingAvatar = false;

  void _pickAndUploadAvatar(BuildContext context, AppProvider provider) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      final res = await provider.uploadAvatar(image.path);
      
      setState(() {
        _isUploadingAvatar = false;
      });

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('Tải ảnh đại diện thành công!', 'Avatar uploaded successfully!'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorSnackbar(res['message'] ?? context.tr('Lỗi upload ảnh', 'Upload failed'));
      }
    } catch (e) {
      setState(() {
        _isUploadingAvatar = false;
      });
      _showErrorSnackbar('${context.tr('Lỗi:', 'Error:')} $e');
    }
  }

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    final user = provider.userInfo ?? {};
    final nameController = TextEditingController(text: user['name'] ?? '');
    final emailController = TextEditingController(text: user['email'] ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161F30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            context.tr('Chỉnh Sửa Hồ Sơ', 'Edit Profile'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  validator: (val) => val == null || val.trim().isEmpty ? context.tr('Nhập tên hiển thị', 'Enter display name') : null,
                  decoration: InputDecoration(
                    labelText: context.tr('Họ & Tên', 'Display Name'),
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  validator: (val) => val == null || !val.contains('@') ? context.tr('Email không hợp lệ', 'Invalid email') : null,
                  decoration: InputDecoration(
                    labelText: context.tr('Địa chỉ email', 'Email Address'),
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('HỦY', 'CANCEL'), style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.pop(context);
                provider.updateProfile(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                ).then((res) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        res['success'] == true 
                            ? context.tr('Cập nhật hồ sơ thành công!', 'Profile updated successfully!')
                            : (res['message'] ?? context.tr('Cập nhật hồ sơ thất bại', 'Profile update failed')),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: res['success'] == true ? Colors.green : Colors.redAccent,
                    ),
                  );
                });
              },
              child: Text(context.tr('LƯU', 'SAVE'), style: const TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        title: Text(
          context.tr('CÁ NHÂN', 'PROFILE'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: provider.isLoggedIn 
              ? _buildProfileView(context, provider) 
              : _buildAuthView(context, provider),
        ),
      ),
    );
  }

  // ============================================
  // VIEW 1: AUTHENTICATION (LOGIN & REGISTER)
  // ============================================

  Widget _buildAuthView(BuildContext context, AppProvider provider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // Logo & Slogan
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF06B6D4), width: 1.5),
                  ),
                  child: const Icon(Icons.bolt, size: 40, color: Color(0xFF06B6D4)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CodeGo TechFlow',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('Dẫn đầu trong vũ trụ công nghệ', 'Stay Ahead in the IT Universe'),
                  style: const TextStyle(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Title Auth Mode
          Text(
            _isLoginView ? context.tr('ĐĂNG NHẬP', 'LOGIN') : context.tr('TẠO TÀI KHOẢN', 'CREATE ACCOUNT'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
          ),
          const SizedBox(height: 16),

          // Fields Card
          GlassmorphicCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Username field
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  validator: (val) => val == null || val.trim().isEmpty ? context.tr('Nhập tên đăng nhập', 'Enter username') : null,
                  decoration: InputDecoration(
                    labelText: context.tr('Tên đăng nhập', 'Username'),
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white38),
                    border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                  ),
                ),
                const SizedBox(height: 12),

                // Register-only fields
                if (!_isLoginView) ...[
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    validator: (val) => val == null || val.trim().isEmpty ? context.tr('Nhập tên hiển thị', 'Enter display name') : null,
                    decoration: InputDecoration(
                      labelText: context.tr('Họ & Tên', 'Display Name'),
                      labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      prefixIcon: const Icon(Icons.badge_outlined, color: Colors.white38),
                      border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    validator: (val) => val == null || !val.contains('@') ? context.tr('Email không hợp lệ', 'Invalid email') : null,
                    decoration: InputDecoration(
                      labelText: context.tr('Địa chỉ email', 'Email Address'),
                      labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      prefixIcon: const Icon(Icons.alternate_email, color: Colors.white38),
                      border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  validator: (val) => val == null || val.length < 6 ? context.tr('Mật khẩu phải tối thiểu 6 ký tự', 'Password must be at least 6 characters') : null,
                  decoration: InputDecoration(
                    labelText: context.tr('Mật khẩu', 'Password'),
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38),
                    border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          provider.isLoadingAuth
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
              : ElevatedButton(
                  onPressed: () => _handleSubmitAuth(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  child: Text(_isLoginView ? context.tr('ĐĂNG NHẬP HỆ THỐNG', 'LOG IN') : context.tr('ĐĂNG KÝ TÀI KHOẢN', 'REGISTER')),
                ),
          const SizedBox(height: 16),

          // Toggle Mode Link
          TextButton(
            onPressed: () {
              setState(() {
                _isLoginView = !_isLoginView;
                _formKey.currentState?.reset();
              });
            },
            child: Text(
              _isLoginView ? context.tr('Chưa có tài khoản? Đăng ký ngay', 'No account? Register now') : context.tr('Đã có tài khoản? Quay lại đăng nhập', 'Have account? Back to login'),
              style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmitAuth(AppProvider provider) {
    if (_formKey.currentState?.validate() != true) return;

    if (_isLoginView) {
      provider.login(_usernameController.text.trim(), _passwordController.text).then((res) {
        if (res['success'] != true) {
          _showErrorSnackbar(res['message'] ?? context.tr('Đăng nhập thất bại', 'Login failed'));
        }
      });
    } else {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      provider.register(
        username,
        _emailController.text.trim(),
        password,
        _nameController.text.trim(),
      ).then((res) {
        if (res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr('Đăng ký thành công! Đang tự động đăng nhập...', 'Registration successful! Logging in...'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Auto login
          provider.login(username, password).then((loginRes) {
            if (loginRes['success'] != true) {
              setState(() {
                _isLoginView = true;
                _passwordController.clear();
              });
              _showErrorSnackbar(loginRes['message'] ?? context.tr('Đăng nhập tự động thất bại', 'Automatic login failed'));
            } else {
            }
          });
        } else {
          _showErrorSnackbar(res['message'] ?? context.tr('Đăng ký thất bại', 'Registration failed'));
        }
      });
    }
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // ============================================
  // VIEW 2: LOGGED IN USER PROFILE DETAIL
  // ============================================

  Widget _buildProfileView(BuildContext context, AppProvider provider) {
    final user = provider.userInfo ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        // Avatar Header Card
        GlassmorphicCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Section with Pick Image
              GestureDetector(
                onTap: () => _pickAndUploadAvatar(context, provider),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFF06B6D4).withOpacity(0.2),
                      backgroundImage: (user['avatar'] != null && user['avatar'].toString().isNotEmpty)
                          ? NetworkImage(user['avatar'].toString())
                          : null,
                      child: (user['avatar'] == null || user['avatar'].toString().isEmpty)
                          ? Text(
                              (user['name'] ?? 'U').substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF06B6D4)),
                            )
                          : null,
                    ),
                    if (_isUploadingAvatar)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06B6D4)),
                            ),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF06B6D4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 12, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // User Info details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user['name'] ?? 'User Name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showEditProfileDialog(context, provider),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user['email'] ?? 'user@example.com',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.white38),
                    ),
                    const SizedBox(height: 8),
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.4), width: 0.8),
                      ),
                      child: Text(
                        '${context.tr('CẤP ĐỘ', 'LEVEL')} ${user['level'] ?? 1}',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF06B6D4)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // STREAKS & POINTS GRID CARDS
        Row(
          children: [
            // Daily Streak card
            Expanded(
              child: GlassmorphicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('CHUỖI NGÀY', 'STREAKS'), style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${user['current_streak'] ?? 0} ${context.tr('Ngày', 'Days')}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr('Kỷ lục:', 'Record:')} ${user['longest_streak'] ?? 0} ${context.tr('ngày', 'days')}',
                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Total points card
            Expanded(
              child: GlassmorphicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('TỔNG ĐIỂM', 'TOTAL POINTS'), style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                        const Icon(Icons.stars, color: Colors.yellow, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${user['total_points'] ?? 0} XP',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('Cố gắng học thêm 50XP', 'Try to learn 50XP more'),
                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // SETTINGS & LOGOUT LIST
        Text(
          context.tr('THIẾT LẬP HỆ THỐNG', 'SYSTEM SETTINGS'),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        
        GlassmorphicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Bookmarks item
              ListTile(
                leading: const Icon(Icons.collections_bookmark_outlined, color: Colors.white70),
                title: Text(context.tr('Bộ sưu tập đã lưu', 'Saved Bookmarks'), style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const BookmarksScreen()),
                  );
                },
              ),
              const Divider(color: Colors.white12, height: 1),
              // Notification item
              ListTile(
                leading: const Icon(Icons.notifications_outlined, color: Colors.white70),
                title: Text(context.tr('Thông báo hàng ngày', 'Daily Notifications'), style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                trailing: Switch(
                  value: true,
                  activeColor: const Color(0xFF06B6D4),
                  onChanged: (_) {},
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              // Theme item
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined, color: Colors.white70),
                title: Text(context.tr('Giao diện tối (Dark Mode)', 'Dark Theme'), style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.check, color: Color(0xFF06B6D4), size: 20),
              ),
              const Divider(color: Colors.white12, height: 1),
              // App Store Privacy Policy item
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white70),
                title: Text(context.tr('Chính sách bảo mật', 'Privacy Policy'), style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 12),
                onTap: () async {
                  final Uri url = Uri.parse('https://codego.io.vn/privacy_policy.html');
                  try {
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('Không thể mở liên kết chính sách bảo mật.', 'Could not open privacy policy link.'))),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${context.tr('Lỗi:', 'Error:')} $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // LOGOUT & DELETE ACCOUNT BUTTONS
        ElevatedButton(
          onPressed: () => provider.logout(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF161F30),
            foregroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(context.tr('ĐĂNG XUẤT', 'LOG OUT'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(height: 12),
        // Delete Account button (Mandatory App Store Publishing requirement!)
        TextButton(
          onPressed: () => _showDeleteConfirmation(context, provider),
          child: Text(
            context.tr('XÓA TÀI KHOẢN VĨNH VIỄN', 'DELETE ACCOUNT PERMANENTLY'),
            style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161F30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(context.tr('Xóa Tài Khoản?', 'Delete Account?'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          content: Text(
            context.tr(
              'LƯU Ý: Hành động này không thể hoàn tác. Toàn bộ dữ liệu XP, Streaks và bộ sưu tập đã lưu của bạn sẽ bị xóa vĩnh viễn trên cơ sở dữ liệu để tuân thủ quyền riêng tư App Store.',
              'WARNING: This action cannot be undone. All your XP, Streaks, and saved bookmarks will be permanently deleted from the database to comply with App Store privacy guidelines.',
            ),
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('HỦY', 'CANCEL'), style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                provider.deleteAccount().then((res) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['message'] ?? context.tr('Tài khoản của bạn đã được xóa vĩnh viễn.', 'Your account has been permanently deleted.')),
                      backgroundColor: res['success'] == true ? Colors.green : Colors.redAccent,
                    ),
                  );
                });
              },
              child: Text(context.tr('XÓA NGAY', 'DELETE NOW'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
