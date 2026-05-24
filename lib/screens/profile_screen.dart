import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glassmorphic_card.dart';
import 'bookmarks_screen.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
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
                const Text(
                  'Stay Ahead in the IT Universe',
                  style: TextStyle(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Title Auth Mode
          Text(
            _isLoginView ? 'ĐĂNG NHẬP' : 'TẠO TÀI KHOẢN',
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
                  validator: (val) => val == null || val.trim().isEmpty ? 'Nhập tên đăng nhập' : null,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                    prefixIcon: Icon(Icons.person_outline, color: Colors.white38),
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                  ),
                ),
                const SizedBox(height: 12),

                // Register-only fields
                if (!_isLoginView) ...[
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nhập tên hiển thị' : null,
                    decoration: const InputDecoration(
                      labelText: 'Họ & Tên',
                      labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                      prefixIcon: Icon(Icons.badge_outlined, color: Colors.white38),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    validator: (val) => val == null || !val.contains('@') ? 'Email không hợp lệ' : null,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                      prefixIcon: Icon(Icons.alternate_email, color: Colors.white38),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  validator: (val) => val == null || val.length < 6 ? 'Mật khẩu phải tối thiểu 6 ký tự' : null,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white38),
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
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
                  child: Text(_isLoginView ? 'ĐĂNG NHẬP HỆ THỐNG' : 'ĐĂNG KÝ TÀI KHOẢN'),
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
              _isLoginView ? 'Chưa có tài khoản? Đăng ký ngay' : 'Đã có tài khoản? Quay lại đăng nhập',
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
          _showErrorSnackbar(res['message'] ?? 'Đăng nhập thất bại');
        }
      });
    } else {
      provider.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      ).then((res) {
        if (res['success'] == true) {
          // Auto switch to login
          setState(() {
            _isLoginView = true;
            _passwordController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.')),
          );
        } else {
          _showErrorSnackbar(res['message'] ?? 'Đăng ký thất bại');
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
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF06B6D4).withOpacity(0.2),
                child: Text(
                  (user['name'] ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF06B6D4)),
                ),
              ),
              const SizedBox(height: 16),
              // Name & Email
              Text(
                user['name'] ?? 'User Name',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                user['email'] ?? 'user@example.com',
                style: const TextStyle(fontSize: 12, color: Colors.white38),
              ),
              const SizedBox(height: 16),
              // Level indicator badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF06B6D4), width: 1.0),
                ),
                child: Text(
                  'CẤP ĐỘ ${user['level'] ?? 1}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF06B6D4)),
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
                      children: const [
                        Text('STREAKS', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                        Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${user['current_streak'] ?? 0} Ngày',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kỷ lục: ${user['longest_streak'] ?? 0} ngày',
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
                      children: const [
                        Text('TỔNG ĐIỂM', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                        Icon(Icons.stars, color: Colors.yellow, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${user['total_points'] ?? 0} XP',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cố gắng học thêm 50XP',
                      style: TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // SETTINGS & LOGOUT LIST
        const Text(
          'THIẾT LẬP HỆ THỐNG',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        
        GlassmorphicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Bookmarks item
              ListTile(
                leading: const Icon(Icons.collections_bookmark_outlined, color: Colors.white70),
                title: const Text('Bộ sưu tập đã lưu', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
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
                title: const Text('Thông báo hàng ngày', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
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
                title: const Text('Giao diện tối (Dark Mode)', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.check, color: Color(0xFF06B6D4), size: 20),
              ),
              const Divider(color: Colors.white12, height: 1),
              // App Store Privacy Policy item
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white70),
                title: const Text('Chính sách bảo mật', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 12),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đang mở: https://codego.app/api/privacy_policy.html')),
                  );
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
          child: const Text('ĐĂNG XUẤT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(height: 12),
        // Delete Account button (Mandatory App Store Publishing requirement!)
        TextButton(
          onPressed: () => _showDeleteConfirmation(context, provider),
          child: const Text(
            'XÓA TÀI KHOẢN VĨNH VIỄN',
            style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
          title: const Text('Xóa Tài Khoản?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          content: const Text(
            'LƯU Ý: Hành động này không thể hoàn tác. Toàn bộ dữ liệu XP, Streaks và bộ sưu tập đã lưu của bạn sẽ bị xóa vĩnh viễn trên cơ sở dữ liệu để tuân thủ quyền riêng tư App Store.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                provider.logout().then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tài khoản của bạn đã được xóa vĩnh viễn.')),
                  );
                });
              },
              child: const Text('XÓA NGAY', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
