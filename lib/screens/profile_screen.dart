import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  bool _obscurePassword = true;
  
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

      if (!mounted) return;

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

    showCupertinoDialog(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(
            context.tr('Chỉnh Sửa Hồ Sơ', 'Edit Profile'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoTextFormFieldRow(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    placeholder: context.tr('Họ & Tên', 'Display Name'),
                    placeholderStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                    padding: EdgeInsets.zero,
                    validator: (val) => val == null || val.trim().isEmpty ? context.tr('Nhập tên hiển thị', 'Enter display name') : null,
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextFormFieldRow(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    placeholder: context.tr('Địa chỉ email', 'Email Address'),
                    placeholderStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                    padding: EdgeInsets.zero,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val == null || !val.contains('@') ? context.tr('Email không hợp lệ', 'Invalid email') : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr('Hủy', 'Cancel')),
            ),
            CupertinoDialogAction(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.pop(dialogContext);
                provider.updateProfile(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                ).then((res) {
                  if (context.mounted) {
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
                  }
                });
              },
              child: Text(context.tr('Lưu', 'Save')),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          context.tr('CÁ NHÂN', 'PROFILE'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
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
          padding: provider.isLoggedIn
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
          const SizedBox(height: 30),
          // Logo & Slogan
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12, width: 1),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon/iconnn.png',
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'CodeGo TechFlow',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('Dẫn đầu trong vũ trụ công nghệ', 'Stay Ahead in the IT Universe'),
                  style: const TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // Title Auth Mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              _isLoginView ? context.tr('ĐĂNG NHẬP', 'LOGIN') : context.tr('TẠO TÀI KHOẢN', 'CREATE ACCOUNT'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1.0),
            ),
          ),
          const SizedBox(height: 10),

          // Fields Card — Bo góc tròn kiểu iOS Grouped
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12, width: 0.5),
            ),
            child: Column(
              children: [
                // Username field
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  validator: (val) => val == null || val.trim().isEmpty ? context.tr('Tên đăng nhập không được trống', 'Username is required') : null,
                  decoration: InputDecoration(
                    hintText: context.tr('Tên đăng nhập', 'Username'),
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                    prefixIcon: const Icon(Icons.person_rounded, color: Colors.white38, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                
                // Register-only fields
                if (!_isLoginView) ...[
                  const Divider(color: Colors.white10, height: 0.5, indent: 48),
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    validator: (val) => val == null || val.trim().isEmpty ? context.tr('Họ & Tên không được trống', 'Display name is required') : null,
                    decoration: InputDecoration(
                      hintText: context.tr('Họ & Tên', 'Display Name'),
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                      prefixIcon: const Icon(Icons.badge_rounded, color: Colors.white38, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 0.5, indent: 48),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    validator: (val) => val == null || !val.contains('@') ? context.tr('Email không hợp lệ', 'Invalid email address') : null,
                    decoration: InputDecoration(
                      hintText: context.tr('Địa chỉ email', 'Email Address'),
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                      prefixIcon: const Icon(Icons.alternate_email_rounded, color: Colors.white38, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                ],
                
                const Divider(color: Colors.white10, height: 0.5, indent: 48),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  validator: (val) => val == null || val.length < 6 ? context.tr('Mật khẩu tối thiểu 6 ký tự', 'Password must be at least 6 characters') : null,
                  decoration: InputDecoration(
                    hintText: context.tr('Mật khẩu', 'Password'),
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                    prefixIcon: const Icon(Icons.lock_rounded, color: Colors.white38, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: Colors.white38,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Action Button - bo góc tròn tinh tế kiểu Apple
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: provider.isLoadingAuth
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A84FF)))
                : ElevatedButton(
                    onPressed: () => _handleSubmitAuth(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                    child: Text((_isLoginView ? context.tr('Đăng Nhập', 'Log In') : context.tr('Tạo Tài Khoản', 'Create Account')).toUpperCase()),
                  ),
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
              style: const TextStyle(color: Color(0xFF0A84FF), fontSize: 12, fontWeight: FontWeight.w700),
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
    if (!mounted) return;
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
        // Avatar Header Card — Tràn viền và dính sát đỉnh trang, không bo góc
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.zero,
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
            ),
            image: const DecorationImage(
              image: AssetImage('assets/banner_dark.png'),
              fit: BoxFit.cover,
              opacity: 0.15,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
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
                          backgroundColor: const Color(0xFF0A84FF).withOpacity(0.2),
                          backgroundImage: (user['avatar'] != null && user['avatar'].toString().isNotEmpty)
                              ? NetworkImage(user['avatar'].toString())
                              : null,
                          child: (user['avatar'] == null || user['avatar'].toString().isEmpty)
                              ? Text(
                                  (user['name'] ?? 'U').substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0A84FF)),
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
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A84FF)),
                                ),
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0A84FF),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A84FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF0A84FF).withOpacity(0.3), width: 0.5),
                          ),
                          child: Text(
                            '${context.tr('CẤP ĐỘ', 'LEVEL')} ${user['level'] ?? 1}',
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF0A84FF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
              // Level progress bar (Apple Gamification)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${context.tr('Tiến độ tăng cấp', 'Level Progress')}',
                        style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${(user['total_points'] ?? 0) % 1000}/1000 XP',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0A84FF), fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: ((user['total_points'] ?? 0) % 1000) / 1000.0,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0A84FF)),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // STREAKS & POINTS GRID CARDS — Tràn viền, không bo góc
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5),
              bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Daily Streak card
              Expanded(
                child: Container(
                  color: const Color(0xFF1C1C1E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.tr('CHUỖI NGÀY', 'STREAKS'), style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                          Image.asset('assets/bonfire.png', width: 20, height: 20),
                        ],
                      ),
                      const SizedBox(height: 10),
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
              Container(width: 0.5, height: 80, color: Colors.white12), // Đường phân cách mỏng ở giữa
              // Total points card
              Expanded(
                child: Container(
                  color: const Color(0xFF1C1C1E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      const SizedBox(height: 10),
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
        ),
        const SizedBox(height: 20),

        // SETTINGS & LOGOUT LIST
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            context.tr('THIẾT LẬP HỆ THỐNG', 'SYSTEM SETTINGS'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        
        // Grouped Settings List (iOS 17 Flat design - Tràn viền, không bo góc)
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.zero,
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5),
              bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5),
            ),
          ),
          child: Column(
            children: [
              // Bookmarks item
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF), // Blue
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.collections_bookmark_rounded, color: Colors.white, size: 16),
                ),
                title: Text(context.tr('Bộ sưu tập đã lưu', 'Saved Bookmarks'), style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 11),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const BookmarksScreen()),
                  );
                },
              ),
              const Divider(color: Colors.white10, height: 0.5, indent: 56),
              // Leaderboard item
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9F0A), // Orange
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Image.asset('assets/award.png', width: 16, height: 16),
                ),
                title: Text(context.tr('Bảng xếp hạng TechFlow', 'TechFlow Leaderboard'), style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 11),
                onTap: () => _showLeaderboardBottomSheet(context, provider),
              ),
              const Divider(color: Colors.white10, height: 0.5, indent: 56),
              // Notification item
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF453A), // Red
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 16),
                ),
                title: Text(context.tr('Thông báo hàng ngày', 'Daily Notifications'), style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                trailing: Switch(
                  value: true,
                  activeColor: const Color(0xFF30D158), // Green toggle
                  onChanged: (_) {},
                ),
              ),
              const Divider(color: Colors.white10, height: 0.5, indent: 56),
              // Theme item
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E8E93), // Grey
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.dark_mode_rounded, color: Colors.white, size: 16),
                ),
                title: Text(context.tr('Giao diện tối (Dark Mode)', 'Dark Theme'), style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.check, color: Color(0xFF30D158), size: 18),
              ),
              const Divider(color: Colors.white10, height: 0.5, indent: 56),
              // App Store Privacy Policy item
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF30D158), // Green
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.privacy_tip_rounded, color: Colors.white, size: 16),
                ),
                title: Text(context.tr('Chính sách bảo mật', 'Privacy Policy'), style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 11),
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

        // LOGOUT & DELETE ACCOUNT BUTTONS — Tràn viền, không bo góc
        ElevatedButton(
          onPressed: () => provider.logout(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C1C1E),
            foregroundColor: Colors.white70,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.white10, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(context.tr('ĐĂNG XUẤT', 'LOG OUT'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 12),
        // Delete Account button (Mandatory App Store Publishing requirement!)
        TextButton(
          onPressed: () => _showDeleteConfirmation(context, provider),
          child: Text(
            context.tr('XÓA TÀI KHOẢN VĨNH VIỄN', 'DELETE ACCOUNT PERMANENTLY'),
            style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppProvider provider) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(context.tr('Xóa Tài Khoản?', 'Delete Account?')),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              context.tr(
                'LƯU Ý: Hành động này không thể hoàn tác. Toàn bộ dữ liệu XP, Streaks và bộ sưu tập đã lưu của bạn sẽ bị xóa vĩnh viễn trên cơ sở dữ liệu để tuân thủ quyền riêng tư App Store.',
                'WARNING: This action cannot be undone. All your XP, Streaks, and saved bookmarks will be permanently deleted from the database to comply with App Store privacy guidelines.',
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr('Hủy', 'Cancel')),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                provider.deleteAccount().then((res) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res['message'] ?? context.tr('Tài khoản của bạn đã được xóa vĩnh viễn.', 'Your account has been permanently deleted.')),
                        backgroundColor: res['success'] == true ? Colors.green : Colors.redAccent,
                      ),
                    );
                  }
                });
              },
              child: Text(context.tr('Xóa ngay', 'Delete now')),
            ),
          ],
        );
      },
    );
  }

  void _showLeaderboardBottomSheet(BuildContext context, AppProvider provider) {
    provider.loadLeaderboard();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<AppProvider>(
              builder: (context, prov, child) {
                if (prov.isLoadingLeaderboard) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0A84FF)));
                }

                final list = prov.leaderboard;
                if (list.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(width: 36, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.5))),
                      const SizedBox(height: 40),
                      Center(child: Text(context.tr('Không có dữ liệu', 'No data available'), style: const TextStyle(color: Colors.white38))),
                    ],
                  );
                }

                final top1 = list.isNotEmpty ? list[0] : null;
                final top2 = list.length > 1 ? list[1] : null;
                final top3 = list.length > 2 ? list[2] : null;
                final remainList = list.length > 3 ? list.sublist(3) : [];

                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 36, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.5))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/award.png', width: 22, height: 22),
                        const SizedBox(width: 8),
                        Text(context.tr('BẢNG XẾP HẠNG TECHFLOW', 'TECHFLOW LEADERBOARD'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(context.tr('Top 50 lập trình viên có điểm XP cao nhất', 'Top 50 developers with highest XP'), style: const TextStyle(fontSize: 10, color: Colors.white38)),
                    const Divider(color: Colors.white10, height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (top2 != null) _buildPodiumUser(context, user: top2, rank: 2, avatarRadius: 28, color: const Color(0xFFC0C0C0), badgeIcon: 'assets/second-rank.png'),
                          if (top1 != null) Padding(padding: const EdgeInsets.only(bottom: 12.0), child: _buildPodiumUser(context, user: top1, rank: 1, avatarRadius: 36, color: const Color(0xFFFFD700), badgeIcon: 'assets/award.png')),
                          if (top3 != null) _buildPodiumUser(context, user: top3, rank: 3, avatarRadius: 26, color: const Color(0xFFCD7F32), badgeIcon: 'assets/3rd-place.png'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white10, height: 1),
                    Expanded(
                      child: remainList.isEmpty
                          ? Center(child: Text(context.tr('Tham gia học tập để lọt vào bảng xếp hạng!', 'Learn more to get on the leaderboard!'), style: const TextStyle(color: Colors.white24, fontSize: 11)))
                          : ListView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.zero,
                              itemCount: remainList.length,
                              itemBuilder: (context, index) {
                                final entry = remainList[index];
                                final rank = index + 4;
                                final isCurrentUser = entry['user_id'].toString() == prov.userInfo?['user_id']?.toString();
                                return Container(
                                  color: isCurrentUser ? const Color(0xFF0A84FF).withOpacity(0.08) : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                  child: Row(
                                    children: [
                                      Container(width: 28, alignment: Alignment.centerLeft, child: Text('$rank', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white38))),
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: const Color(0xFF0A84FF).withOpacity(0.12),
                                        backgroundImage: (entry['avatar'] != null && entry['avatar'].toString().isNotEmpty) ? NetworkImage(entry['avatar'].toString()) : null,
                                        child: (entry['avatar'] == null || entry['avatar'].toString().isEmpty) ? Text((entry['name'] ?? 'U').substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A84FF))) : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(entry['name'] ?? 'User', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.w600, color: isCurrentUser ? const Color(0xFF0A84FF) : Colors.white)),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Image.asset('assets/bonfire.png', width: 11, height: 11),
                                                const SizedBox(width: 2),
                                                Text('${entry['current_streak'] ?? 0} ${context.tr('ngày', 'days')}', style: const TextStyle(fontSize: 10, color: Colors.white38)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text('${entry['total_points'] ?? 0} XP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isCurrentUser ? const Color(0xFF0A84FF) : const Color(0xFFFF9F0A))),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // WIDGET HELPER RENDER TỪNG USER PODIUM
  Widget _buildPodiumUser(
    BuildContext context, {
    required dynamic user,
    required int rank,
    required double avatarRadius,
    required Color color,
    required String badgeIcon,
  }) {
    final String displayName = user['name'] ?? 'User';
    final int points = user['total_points'] ?? 0;
    final int streak = user['current_streak'] ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar Stack with Krone / Badge
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: rank == 1 ? 2.5 : 1.5),
                boxShadow: rank == 1
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 14,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: color.withOpacity(0.12),
                backgroundImage: (user['avatar'] != null && user['avatar'].toString().isNotEmpty)
                    ? NetworkImage(user['avatar'].toString())
                    : null,
                child: (user['avatar'] == null || user['avatar'].toString().isEmpty)
                    ? Text(
                        displayName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: avatarRadius * 0.7,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      )
                    : null,
              ),
            ),
            // Badge Cup Icon - Đặt ở đỉnh đầu (Top)
            Positioned(
              top: rank == 1 ? -16 : -12,
              child: Image.asset(
                badgeIcon,
                width: rank == 1 ? 24 : 20,
                height: rank == 1 ? 24 : 20,
                errorBuilder: (context, error, stackTrace) {
                  IconData fallbackIcon = Icons.stars_rounded;
                  if (rank == 1) fallbackIcon = Icons.emoji_events_rounded;
                  return Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 1.0),
                    ),
                    child: Icon(fallbackIcon, size: rank == 1 ? 14 : 10, color: color),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Name
        Container(
          constraints: const BoxConstraints(maxWidth: 85),
          child: Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Points
        Text(
          '$points XP',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        // Streak line
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/bonfire.png', width: 10, height: 10),
            Text(
              ' $streak',
              style: const TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
